import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../service/notification_service.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal() {
    _initRealtimeEngine();
  }

  static const String _rtdbBaseUrl = 'https://firestoreapp-a55a3-default-rtdb.firebaseio.com';

  // In-memory unified cache of orders
  final Map<String, OrderModel> _ordersCache = <String, OrderModel>{};
  final StreamController<Map<String, OrderModel>> _ordersStreamController =
      StreamController<Map<String, OrderModel>>.broadcast();

  Timer? _pollingTimer;
  HttpClient? _sseClient;
  bool _isEngineStarted = false;

  static DatabaseReference? _cachedOrdersRef;
  static DatabaseReference get _ordersRef {
    if (_cachedOrdersRef != null) return _cachedOrdersRef!;
    try {
      final db = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _rtdbBaseUrl,
      );
      _cachedOrdersRef = db.ref('orders');
    } catch (e) {
      debugPrint('[OrderService] Warning creating RTDB instanceFor: $e');
      _cachedOrdersRef = FirebaseDatabase.instance.ref('orders');
    }
    return _cachedOrdersRef!;
  }

  // ── Realtime Synchronization Engine ────────────────────────────────────────

  void _initRealtimeEngine() {
    if (_isEngineStarted) return;
    _isEngineStarted = true;

    // 1. Initial fast REST fetch
    refreshAllOrders();

    // 2. Start persistent Server-Sent Events (SSE) stream
    _startSseStream();

    // 3. Fallback periodic sync timer (runs every 2 seconds for guaranteed freshness)
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _pollRtdbUpdates();
    });

    // 4. Native Firebase RTDB SDK listener
    _listenNativeRtdb();
  }

  void _notifyListeners() {
    _ordersStreamController.add(Map.unmodifiable(_ordersCache));
  }

  /// Starts continuous Server-Sent Events (SSE) streaming from Firebase RTDB.
  /// Delivers sub-100ms real-time event pushes across devices without native SDK socket issues.
  Future<void> _startSseStream() async {
    while (_isEngineStarted) {
      try {
        _sseClient?.close(force: true);
        _sseClient = HttpClient();
        final url = Uri.parse('$_rtdbBaseUrl/orders.json');
        final request = await _sseClient!.getUrl(url).timeout(const Duration(seconds: 10));
        request.headers.set('Accept', 'text/event-stream');
        request.headers.set('Cache-Control', 'no-cache');
        final response = await request.close().timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        String currentEvent = '';
        await for (final line in response.transform(utf8.decoder).transform(const LineSplitter())) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          if (trimmed.startsWith('event:')) {
            currentEvent = trimmed.substring(6).trim();
            continue;
          }

          if (trimmed.startsWith('data:')) {
            final jsonStr = trimmed.substring(5).trim();
            if (jsonStr == 'null' || jsonStr.isEmpty) continue;

            try {
              final parsed = jsonDecode(jsonStr);
              if (parsed is Map) {
                final path = parsed['path']?.toString() ?? '';
                final data = parsed['data'];
                _applySseUpdate(currentEvent, path, data);
              }
            } catch (e) {
              debugPrint('[OrderService] SSE parse error: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('[OrderService] SSE reconnecting in 2s ($e)');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _applySseUpdate(String event, String path, dynamic data) {
    bool hasChanges = false;

    if (path == '/' || path.isEmpty) {
      if (data is Map) {
        data.forEach((key, val) {
          if (val is Map) {
            try {
              final order = OrderModel.fromMap(val, key.toString());
              _ordersCache[key.toString()] = order;
              hasChanges = true;
            } catch (_) {}
          }
        });
      }
    } else {
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final parts = cleanPath.split('/');
      final orderId = parts[0];

      if (parts.length == 1) {
        // e.g. path is "/ord_123"
        if (data == null) {
          if (_ordersCache.containsKey(orderId)) {
            _ordersCache.remove(orderId);
            hasChanges = true;
          }
        } else if (data is Map) {
          if (event == 'patch' && _ordersCache.containsKey(orderId)) {
            final existingMap = _ordersCache[orderId]!.toMap();
            data.forEach((k, v) => existingMap[k.toString()] = v);
            _ordersCache[orderId] = OrderModel.fromMap(existingMap, orderId);
          } else {
            _ordersCache[orderId] = OrderModel.fromMap(data, orderId);
          }
          hasChanges = true;
        }
      } else if (parts.length >= 2) {
        // e.g. path is "/ord_123/status"
        final field = parts[1];
        if (_ordersCache.containsKey(orderId)) {
          final existingMap = _ordersCache[orderId]!.toMap();
          existingMap[field] = data;
          _ordersCache[orderId] = OrderModel.fromMap(existingMap, orderId);
          hasChanges = true;
        } else {
          // New order update arrived piece-meal, trigger full fetch
          unawaited(refreshAllOrders());
        }
      }
    }

    if (hasChanges) {
      _notifyListeners();
    }
  }

  /// Lightweight background polling check every 2s
  Future<void> _pollRtdbUpdates() async {
    try {
      final data = await _fetchRtdbRest('orders');
      if (data is! Map) return;

      bool hasChanges = false;
      final fetchedKeys = <String>{};

      data.forEach((key, val) {
        if (val is Map) {
          final orderId = key.toString();
          fetchedKeys.add(orderId);
          try {
            final newOrder = OrderModel.fromMap(val, orderId);
            final existing = _ordersCache[orderId];
            if (existing == null ||
                existing.status != newOrder.status ||
                existing.partnerId != newOrder.partnerId ||
                existing.partnerName != newOrder.partnerName ||
                existing.updatedAt.millisecondsSinceEpoch != newOrder.updatedAt.millisecondsSinceEpoch) {
              _ordersCache[orderId] = newOrder;
              hasChanges = true;
            }
          } catch (_) {}
        }
      });

      // Prune deleted orders
      final currentKeys = _ordersCache.keys.toList();
      for (final k in currentKeys) {
        if (!fetchedKeys.contains(k)) {
          _ordersCache.remove(k);
          hasChanges = true;
        }
      }

      if (hasChanges) {
        _notifyListeners();
      }
    } catch (_) {}
  }

  void _listenNativeRtdb() {
    try {
      _ordersRef.onValue.listen(
        (event) {
          final snapshot = event.snapshot;
          if (!snapshot.exists || snapshot.children.isEmpty) return;

          bool hasChanges = false;
          for (final child in snapshot.children) {
            final val = child.value;
            if (val is Map) {
              try {
                final order = OrderModel.fromMap(val, child.key ?? '');
                final existing = _ordersCache[order.id];
                if (existing == null ||
                    existing.status != order.status ||
                    existing.partnerId != order.partnerId ||
                    existing.updatedAt.millisecondsSinceEpoch != order.updatedAt.millisecondsSinceEpoch) {
                  _ordersCache[order.id] = order;
                  hasChanges = true;
                }
              } catch (_) {}
            }
          }
          if (hasChanges) {
            _notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('[OrderService] Native RTDB listener warning: $e');
        },
      );
    } catch (e) {
      debugPrint('[OrderService] Native RTDB listener setup warning: $e');
    }
  }

  // ── REST HTTP Helpers ──────────────────────────────────────────────────────

  Future<void> _writeToRtdbRest(String path, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/$path.json');
      final request = await client.putUrl(url).timeout(const Duration(seconds: 4));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close().timeout(const Duration(seconds: 4));
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('[OrderService] REST write warning: $e');
    }
  }

  Future<void> _patchToRtdbRest(String path, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/$path.json');
      final request = await client.patchUrl(url).timeout(const Duration(seconds: 4));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close().timeout(const Duration(seconds: 4));
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('[OrderService] REST patch warning: $e');
    }
  }

  Future<dynamic> _fetchRtdbRest(String path) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/$path.json');
      final request = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(const Duration(seconds: 4));
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (body.isEmpty || body == 'null') return null;
      return jsonDecode(body);
    } catch (e) {
      return null;
    }
  }

  // ── Public Stream Subscriptions ───────────────────────────────────────────

  /// Streams the customer's current active order in real time.
  /// Immediately yields cached active order, and broadcasts every status transition live.
  Stream<OrderModel?> streamCustomerActiveOrder(String customerId) {
    OrderModel? getActive() {
      final mine = _ordersCache.values.where((o) => o.customerId == customerId && o.isActive).toList();
      if (mine.isEmpty) return null;
      mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mine.first;
    }

    late StreamController<OrderModel?> controller;
    StreamSubscription? sub;

    controller = StreamController<OrderModel?>(
      onListen: () {
        controller.add(getActive());
        sub = _ordersStreamController.stream.listen((_) {
          controller.add(getActive());
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Streams all orders placed by the customer, sorted by createdAt descending.
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    List<OrderModel> getList() {
      final mine = _ordersCache.values.where((o) => o.customerId == customerId).toList();
      mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mine;
    }

    late StreamController<List<OrderModel>> controller;
    StreamSubscription? sub;

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        controller.add(getList());
        sub = _ordersStreamController.stream.listen((_) {
          controller.add(getList());
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Streams all pending orders available for delivery partners.
  Stream<List<OrderModel>> streamAvailableOrders() {
    List<OrderModel> getAvail() {
      final avail = _ordersCache.values
          .where((o) => o.isPending && (o.partnerId == null || o.partnerId!.isEmpty))
          .toList();
      avail.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return avail;
    }

    late StreamController<List<OrderModel>> controller;
    StreamSubscription? sub;

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        controller.add(getAvail());
        sub = _ordersStreamController.stream.listen((_) {
          controller.add(getAvail());
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Streams the delivery partner's current active delivery job.
  Stream<OrderModel?> streamPartnerActiveOrder(String partnerId) {
    OrderModel? getActive() {
      final mine = _ordersCache.values.where((o) => o.partnerId == partnerId && o.isActive).toList();
      if (mine.isEmpty) return null;
      mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mine.first;
    }

    late StreamController<OrderModel?> controller;
    StreamSubscription? sub;

    controller = StreamController<OrderModel?>(
      onListen: () {
        controller.add(getActive());
        sub = _ordersStreamController.stream.listen((_) {
          controller.add(getActive());
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Streams all deliveries handled by this partner.
  Stream<List<OrderModel>> streamPartnerOrders(String partnerId) {
    List<OrderModel> getList() {
      final mine = _ordersCache.values.where((o) => o.partnerId == partnerId).toList();
      mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return mine;
    }

    late StreamController<List<OrderModel>> controller;
    StreamSubscription? sub;

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        controller.add(getList());
        sub = _ordersStreamController.stream.listen((_) {
          controller.add(getList());
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Refreshes all orders immediately from database and emits to all listeners.
  Future<List<OrderModel>> refreshAllOrders() async {
    try {
      final data = await _fetchRtdbRest('orders');
      if (data == null || data is! Map) return _ordersCache.values.toList();

      data.forEach((key, val) {
        if (val is Map) {
          try {
            _ordersCache[key.toString()] = OrderModel.fromMap(val, key.toString());
          } catch (_) {}
        }
      });
      _notifyListeners();
      return _ordersCache.values.toList();
    } catch (e) {
      debugPrint('[OrderService] Error refreshing all orders: $e');
      return _ordersCache.values.toList();
    }
  }

  /// Legacy helper for one-time fetch
  Future<List<OrderModel>> fetchAllOrders() => refreshAllOrders();

  // ── Core Mutations ────────────────────────────────────────────────────────

  /// Creates a new delivery order.
  Future<OrderModel> createOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String itemDescription,
    required String pickupAddress,
    double pickupLat = 23.2599,
    double pickupLng = 77.4126,
    required String dropAddress,
    double dropLat = 23.2899,
    double dropLng = 77.4426,
  }) async {
    try {
      final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      final otp = (1000 + Random().nextInt(9000)).toString();
      final orderNumber = '#ORD${1000 + Random().nextInt(9000)}';
      final now = DateTime.now();

      final order = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        itemDescription: itemDescription,
        pickupAddress: pickupAddress,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropAddress: dropAddress,
        dropLat: dropLat,
        dropLng: dropLng,
        status: 'pending',
        otp: otp,
        estimatedMinutes: 15 + Random().nextInt(10),
        createdAt: now,
        updatedAt: now,
      );

      final orderMap = order.toMap();

      // Optimistic local update: instant UI update with zero delay
      _ordersCache[orderId] = order;
      _notifyListeners();

      // Dual-channel write: REST write (fastest) + native SDK write
      await _writeToRtdbRest('orders/$orderId', orderMap);

      unawaited(
        _ordersRef.child(orderId).set(orderMap).timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        ),
      );

      debugPrint('[OrderService] Order $orderId created with OTP $otp');
      return order;
    } catch (e) {
      debugPrint('[OrderService] Error creating order: $e');
      rethrow;
    }
  }

  /// Delivery partner accepts a pending job.
  Future<void> acceptOrder({
    required String orderId,
    required UserModel partner,
  }) async {
    final now = DateTime.now();
    final updateData = <String, dynamic>{
      'partnerId': partner.uid,
      'partnerName': partner.name,
      'partnerPhone': partner.phone,
      'partnerVehicle': 'Motorcycle',
      'status': 'accepted',
      'updatedAt': now.millisecondsSinceEpoch,
    };

    // Optimistic local update
    if (_ordersCache.containsKey(orderId)) {
      _ordersCache[orderId] = _ordersCache[orderId]!.copyWith(
        partnerId: partner.uid,
        partnerName: partner.name,
        partnerPhone: partner.phone,
        partnerVehicle: 'Motorcycle',
        status: 'accepted',
        updatedAt: now,
      );
      _notifyListeners();
    }

    try {
      await _patchToRtdbRest('orders/$orderId', updateData);
      unawaited(
        _ordersRef.child(orderId).update(updateData).timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        ),
      );
      debugPrint('[OrderService] Order $orderId accepted by partner ${partner.name}');

      // Dispatch push notification to customer
      final targetOrder = _ordersCache[orderId];
      if (targetOrder != null && targetOrder.customerId.isNotEmpty) {
        unawaited(NotificationService().sendOrderStatusNotification(
          customerId: targetOrder.customerId,
          orderId: orderId,
          orderNumber: targetOrder.orderNumber,
          newStatus: 'accepted',
          partnerName: partner.name,
        ));
      }
    } catch (e) {
      debugPrint('[OrderService] Error accepting order: $e');
      rethrow;
    }
  }

  /// Partner updates the order status ('picked_up', 'in_transit').
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final now = DateTime.now();
    final updateData = <String, dynamic>{
      'status': newStatus,
      'updatedAt': now.millisecondsSinceEpoch,
    };

    // Optimistic local update
    if (_ordersCache.containsKey(orderId)) {
      _ordersCache[orderId] = _ordersCache[orderId]!.copyWith(
        status: newStatus,
        updatedAt: now,
      );
      _notifyListeners();
    }

    try {
      await _patchToRtdbRest('orders/$orderId', updateData);
      unawaited(
        _ordersRef.child(orderId).update(updateData).timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        ),
      );
      debugPrint('[OrderService] Order $orderId status updated to $newStatus');

      // Dispatch push notification to customer
      final targetOrder = _ordersCache[orderId];
      if (targetOrder != null && targetOrder.customerId.isNotEmpty) {
        unawaited(NotificationService().sendOrderStatusNotification(
          customerId: targetOrder.customerId,
          orderId: orderId,
          orderNumber: targetOrder.orderNumber,
          newStatus: newStatus,
          partnerName: targetOrder.partnerName,
          otp: targetOrder.otp,
        ));
      }
    } catch (e) {
      debugPrint('[OrderService] Error updating status: $e');
      rethrow;
    }
  }

  /// Verifies customer's 4-digit OTP and completes the delivery.
  Future<bool> verifyOtpAndDeliver({
    required String orderId,
    required String enteredOtp,
  }) async {
    try {
      String? correctOtp;
      if (_ordersCache.containsKey(orderId)) {
        correctOtp = _ordersCache[orderId]!.otp.trim();
      }

      if (correctOtp == null) {
        final data = await _fetchRtdbRest('orders/$orderId');
        if (data is Map) {
          correctOtp = data['otp']?.toString().trim();
        }
      }

      if (correctOtp == null) {
        throw Exception('Order not found.');
      }

      if (correctOtp != enteredOtp.trim()) {
        throw Exception('Invalid OTP ($enteredOtp). Correct OTP is required to deliver.');
      }

      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'status': 'delivered',
        'updatedAt': now.millisecondsSinceEpoch,
      };

      // Optimistic local update
      if (_ordersCache.containsKey(orderId)) {
        _ordersCache[orderId] = _ordersCache[orderId]!.copyWith(
          status: 'delivered',
          updatedAt: now,
        );
        _notifyListeners();
      }

      await _patchToRtdbRest('orders/$orderId', updateData);
      unawaited(
        _ordersRef.child(orderId).update(updateData).timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        ),
      );

      debugPrint('[OrderService] Order $orderId delivered successfully');

      // Dispatch push notification to customer
      final targetOrder = _ordersCache[orderId];
      if (targetOrder != null && targetOrder.customerId.isNotEmpty) {
        unawaited(NotificationService().sendOrderStatusNotification(
          customerId: targetOrder.customerId,
          orderId: orderId,
          orderNumber: targetOrder.orderNumber,
          newStatus: 'delivered',
          partnerName: targetOrder.partnerName,
        ));
      }

      return true;
    } catch (e) {
      debugPrint('[OrderService] Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Cancels an order.
  Future<void> cancelOrder(String orderId) async {
    final now = DateTime.now();
    final updateData = <String, dynamic>{
      'status': 'cancelled',
      'updatedAt': now.millisecondsSinceEpoch,
    };

    // Optimistic local update
    if (_ordersCache.containsKey(orderId)) {
      _ordersCache[orderId] = _ordersCache[orderId]!.copyWith(
        status: 'cancelled',
        updatedAt: now,
      );
      _notifyListeners();
    }

    try {
      await _patchToRtdbRest('orders/$orderId', updateData);
      unawaited(
        _ordersRef.child(orderId).update(updateData).timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        ),
      );
      debugPrint('[OrderService] Order $orderId cancelled');

      // Dispatch push notification to customer
      final targetOrder = _ordersCache[orderId];
      if (targetOrder != null && targetOrder.customerId.isNotEmpty) {
        unawaited(NotificationService().sendOrderStatusNotification(
          customerId: targetOrder.customerId,
          orderId: orderId,
          orderNumber: targetOrder.orderNumber,
          newStatus: 'cancelled',
        ));
      }
    } catch (e) {
      debugPrint('[OrderService] Error cancelling order: $e');
      rethrow;
    }
  }

  /// Updates the delivery partner's live GPS coordinates in RTDB
  Future<void> updatePartnerLocation({
    required String partnerId,
    required double lat,
    required double lng,
  }) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/partner_locations/$partnerId.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 4));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'lat': lat,
        'lng': lng,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
    } catch (e) {
      debugPrint('[OrderService] Error updating partner location: $e');
    }
  }

  /// Streams delivery partner's live GPS coordinates in real-time
  Stream<Map<String, double>?> streamPartnerLocation(String partnerId) {
    final controller = StreamController<Map<String, double>?>.broadcast();
    Timer? timer;
    HttpClient? client;

    void fetch() async {
      try {
        client = HttpClient();
        final url = Uri.parse('$_rtdbBaseUrl/partner_locations/$partnerId.json');
        final req = await client!.getUrl(url).timeout(const Duration(seconds: 3));
        final resp = await req.close().timeout(const Duration(seconds: 3));
        final body = await resp.transform(utf8.decoder).join();
        client?.close();

        if (body.isNotEmpty && body != 'null') {
          final parsed = jsonDecode(body);
          if (parsed is Map) {
            final lat = double.tryParse(parsed['lat']?.toString() ?? '');
            final lng = double.tryParse(parsed['lng']?.toString() ?? '');
            if (lat != null && lng != null) {
              controller.add({'lat': lat, 'lng': lng});
            }
          }
        }
      } catch (_) {}
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
      client?.close(force: true);
      controller.close();
    };

    return controller.stream;
  }

  /// Streams a single order by ID in real-time
  Stream<OrderModel?> streamOrder(String orderId) {
    final controller = StreamController<OrderModel?>.broadcast();
    fetchOrderById(orderId).then((o) => controller.add(o));

    final sub = _ordersStreamController.stream.listen((cache) {
      if (cache.containsKey(orderId)) {
        controller.add(cache[orderId]);
      }
    });

    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Fetches a single order by ID from cache or RTDB
  Future<OrderModel?> fetchOrderById(String orderId) async {
    if (_ordersCache.containsKey(orderId)) return _ordersCache[orderId];
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/orders/$orderId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final body = await resp.transform(utf8.decoder).join();
      client.close();

      if (body.isNotEmpty && body != 'null') {
        final parsed = jsonDecode(body);
        if (parsed is Map) {
          final order = OrderModel.fromMap(parsed, orderId);
          _ordersCache[orderId] = order;
          return order;
        }
      }
    } catch (e) {
      debugPrint('[OrderService] fetchOrderById error: $e');
    }
    return null;
  }

  void dispose() {
    _pollingTimer?.cancel();
    _sseClient?.close(force: true);
    _ordersStreamController.close();
  }
}
