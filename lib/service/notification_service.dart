import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'shared_pref_service.dart';

/// Top-level background message handler for FCM
/// Called when app is in background/terminated and an FCM message arrives.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  // Show a local heads-up notification in the OS tray
  try {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: initSettings);

    const androidDetails = AndroidNotificationDetails(
      'delivery_updates_channel',
      'Order & Delivery Updates',
      channelDescription: 'Real-time notifications for order status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final title = message.notification?.title ?? message.data['title'] ?? 'Order Update';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data['orderId'],
    );
  } catch (e) {
    debugPrint('[BGHandler] Local notification error: $e');
  }
  debugPrint('[BGHandler] Background FCM: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _rtdbBaseUrl = 'https://firestoreapp-a55a3-default-rtdb.firebaseio.com';

  /// FCM Legacy HTTP API — used by the rider device to push directly to customer
  static const String _fcmServerKey =
      'AAAAURHUYkk:APA91bFpz-6aEbL1zQs4NbChbe_EOwmgOsp1czASTS3Hcf0ZIa9QAHpt9uhr3JA86YOucotSImDtgx47awxfrzuWvNAtmL2BFelZmmvEyVj2al3DfAHozwFYVIs_CQgEAlUm4FeDwmyW';
  static const String _fcmApiUrl = 'https://fcm.googleapis.com/fcm/send';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxInt unreadCount = 0.obs;
  final RxList<Map<String, dynamic>> notificationHistory = <Map<String, dynamic>>[].obs;

  bool _isInitialized = false;
  StreamSubscription? _rtdbNotifSub;
  HttpClient? _notifSseClient;
  String? _listeningCustomerId;
  final Set<String> _processedNotifIds = <String>{};

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Request OS notification permissions
      await _requestPermissions();

      // 2. Initialize Local Notifications Plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // 3. Create high-importance Android channel for heads-up alerts
      const androidChannel = AndroidNotificationChannel(
        'delivery_updates_channel',
        'Order & Delivery Updates',
        description: 'Real-time notifications for order status, rider updates, and OTPs',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      // 4. Configure FCM Foreground Handler
      // (Background handler is registered in main.dart before runApp)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NotificationService] Foreground FCM received: ${message.notification?.title}');
        final title = message.notification?.title ?? message.data['title'] ?? 'Order Update';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        showNotification(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
        );
      });

      // 5. Retrieve and save FCM Token
      await saveDeviceToken();

      _fcm.onTokenRefresh.listen((newToken) {
        _syncTokenToBackends(newToken);
      });
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('[NotificationService] Permission request warning: $e');
    }
  }

  /// Retrieves and stores the device FCM token in Firestore and RTDB
  Future<String?> saveDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await _syncTokenToBackends(token);
        return token;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error getting FCM token: $e');
    }
    return null;
  }

  Future<void> _syncTokenToBackends(String token) async {
    final uid = SharedPrefService.getUid();
    if (uid == null || uid.isEmpty) return;

    try {
      // 1. Sync to Firestore user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Sync to RTDB for instant access by delivery partner
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$uid.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 4));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'token': token,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();

      debugPrint('[NotificationService] FCM token synced for user: $uid');
    } catch (e) {
      debugPrint('[NotificationService] Token sync warning: $e');
    }
  }

  // ── App Foreground Detection ────────────────────────────────────────────────

  /// Returns true if the app is currently visible on screen (resumed).
  bool get _isAppInForeground {
    try {
      return SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed;
    } catch (_) {
      return false;
    }
  }

  // ── Show Notification (Smart: foreground = in-app, background = system) ──────

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Color bannerColor = const Color(0xFF0F62FE),
  }) async {
    final id = Random().nextInt(100000);
    final inForeground = _isAppInForeground;

    if (inForeground) {
      // ── Foreground: show in-app snackbar only ──────────────────────────────
      try {
        if (Get.context != null) {
          Get.snackbar(
            title,
            body,
            snackPosition: SnackPosition.TOP,
            backgroundColor: bannerColor,
            colorText: Colors.white,
            icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 14,
            duration: const Duration(seconds: 4),
            boxShadows: [
              BoxShadow(
                color: bannerColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          );
        }
      } catch (_) {}
    } else {
      // ── Background / Terminated: fire OS system notification ──────────────
      try {
        final androidDetails = AndroidNotificationDetails(
          'delivery_updates_channel',
          'Order & Delivery Updates',
          channelDescription:
              'Real-time notifications for order status, rider updates, and OTPs',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF0F62FE),
          playSound: true,
          enableVibration: true,
        );
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
        final details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );
        await _localNotifications.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: details,
          payload: payload,
        );
      } catch (e) {
        debugPrint('[NotificationService] Local notification warning: $e');
      }
    }
  }

  // ── Dispatch Notification From Rider to Customer ──────────────────────────

  /// Dispatches an order status change notification from the rider directly to the customer.
  /// Writes to RTDB notification queue and pushes to FCM device token.
  Future<void> sendOrderStatusNotification({
    required String customerId,
    required String orderId,
    required String orderNumber,
    required String newStatus,
    String? partnerName,
    String? otp,
  }) async {
    String title;
    String body;
    Color color;

    switch (newStatus) {
      case 'accepted':
        title = '🛵 Delivery Partner Assigned!';
        body = '${partnerName ?? "A partner"} has accepted order $orderNumber and is heading to the pickup point.';
        color = const Color(0xFF0F62FE);
        break;
      case 'picked_up':
        title = '📦 Package Picked Up!';
        body = 'Your order $orderNumber has been picked up from merchant and will be on its way shortly.';
        color = const Color(0xFFC2410C);
        break;
      case 'in_transit':
        title = '🚀 Out for Delivery!';
        body = 'Rider is on the way with order $orderNumber! Please have your OTP ${otp != null ? "($otp)" : ""} ready.';
        color = const Color(0xFF0284C7);
        break;
      case 'delivered':
        title = '🎉 Order Delivered!';
        body = 'Order $orderNumber was successfully delivered. Thank you for using Track My Order!';
        color = const Color(0xFF10B981);
        break;
      case 'cancelled':
        title = '❌ Order Cancelled';
        body = 'Your delivery order $orderNumber has been cancelled.';
        color = const Color(0xFFDC2626);
        break;
      default:
        title = 'Order Status Update';
        body = 'Order $orderNumber status changed to $newStatus.';
        color = const Color(0xFF0F62FE);
    }

    final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final notifData = {
      'id': notifId,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'status': newStatus,
      'title': title,
      'body': body,
      'colorHex': color.toARGB32(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'read': false,
    };

    // 1. Write to RTDB customer notification channel
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId/$notifId.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 4));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(notifData));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
      debugPrint('[NotificationService] Notification $notifId queued in RTDB for customer $customerId');
    } catch (e) {
      debugPrint('[NotificationService] Error queuing notification: $e');
    }

    // 2. Fire real FCM push to customer device (works even when app is background/terminated)
    try {
      final customerToken = await _fetchCustomerFcmToken(customerId);
      if (customerToken != null && customerToken.isNotEmpty) {
        await _sendFcmPush(
          deviceToken: customerToken,
          title: title,
          body: body,
          data: {
            'orderId': orderId,
            'orderNumber': orderNumber,
            'status': newStatus,
            'notifId': notifId,
            'colorHex': color.toARGB32().toString(),
          },
        );
      } else {
        debugPrint('[NotificationService] No FCM token found for customer $customerId — skipping FCM push');
      }
    } catch (e) {
      debugPrint('[NotificationService] FCM push error: $e');
    }

    // 3. Write to Firestore for persistent history
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .collection('notifications')
          .doc(notifId)
          .set(notifData);
    } catch (_) {}
  }

  // ── FCM REST API Helpers ──────────────────────────────────────────────────

  /// Fetches the stored FCM device token for a customer from RTDB.
  Future<String?> _fetchCustomerFcmToken(String customerId) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$customerId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final bodyStr = await resp.transform(utf8.decoder).join();
      client.close();
      if (bodyStr.isEmpty || bodyStr == 'null') return null;
      final parsed = jsonDecode(bodyStr);
      if (parsed is Map) return parsed['token']?.toString();
    } catch (e) {
      debugPrint('[NotificationService] Error fetching FCM token: $e');
    }
    return null;
  }

  /// Sends a real FCM push notification via the Legacy HTTP API.
  /// Delivers to the device even when the app is background or terminated.
  Future<void> _sendFcmPush({
    required String deviceToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final client = HttpClient();
    try {
      final url = Uri.parse(_fcmApiUrl);
      final req = await client.postUrl(url).timeout(const Duration(seconds: 8));
      req.headers.contentType = ContentType.json;
      req.headers.set('Authorization', 'key=$_fcmServerKey');
      req.write(jsonEncode({
        'to': deviceToken,
        'priority': 'high',
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'android_channel_id': 'delivery_updates_channel',
        },
        'data': data.map((k, v) => MapEntry(k, v.toString())),
        'android': {
          'priority': 'HIGH',
          'ttl': '60s',
          'notification': {
            'channel_id': 'delivery_updates_channel',
            'notification_priority': 'PRIORITY_MAX',
            'sound': 'default',
            'default_vibrate_timings': true,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        'apns': {
          'headers': {'apns-priority': '10'},
          'payload': {
            'aps': {
              'alert': {'title': title, 'body': body},
              'sound': 'default',
              'badge': 1,
            }
          },
        },
      }));
      final resp = await req.close().timeout(const Duration(seconds: 8));
      final respBody = await resp.transform(utf8.decoder).join();
      debugPrint('[NotificationService] FCM push sent → status=${resp.statusCode} body=$respBody');
    } catch (e) {
      debugPrint('[NotificationService] FCM push HTTP error: $e');
    } finally {
      client.close();
    }
  }

  // ── Customer Notification Listener (Real-Time Influx) ─────────────────────

  /// Subscribes to real-time notification events for the customer
  void startListeningCustomerNotifications(String customerId) {
    if (_listeningCustomerId == customerId && _notifSseClient != null) return;
    _listeningCustomerId = customerId;
    _notifSseClient?.close(force: true);

    // Initial fetch of unread count & history
    _fetchCustomerNotificationHistory(customerId);

    // Listen continuously via SSE on notifications/$customerId.json
    _startCustomerNotificationSse(customerId);
  }

  Future<void> _fetchCustomerNotificationHistory(String customerId) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final body = await resp.transform(utf8.decoder).join();
      client.close();

      if (body.isEmpty || body == 'null') return;
      final parsed = jsonDecode(body);
      if (parsed is Map) {
        final list = <Map<String, dynamic>>[];
        int unread = 0;
        parsed.forEach((k, v) {
          if (v is Map) {
            final map = Map<String, dynamic>.from(v);
            list.add(map);
            if (map['read'] == false) unread++;
            _processedNotifIds.add(k.toString());
          }
        });
        list.sort((a, b) => (b['timestamp'] as num? ?? 0).compareTo(a['timestamp'] as num? ?? 0));
        notificationHistory.assignAll(list);
        unreadCount.value = unread;
      }
    } catch (_) {}
  }

  Future<void> _startCustomerNotificationSse(String customerId) async {
    while (_listeningCustomerId == customerId) {
      try {
        _notifSseClient?.close(force: true);
        _notifSseClient = HttpClient();
        final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
        final request = await _notifSseClient!.getUrl(url).timeout(const Duration(seconds: 10));
        request.headers.set('Accept', 'text/event-stream');
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
                _handleIncomingNotificationEvent(currentEvent, path, data);
              }
            } catch (e) {
              debugPrint('[NotificationService] SSE notif parse error: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('[NotificationService] Notification SSE error ($e), reconnecting in 2s...');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _handleIncomingNotificationEvent(String event, String path, dynamic data) {
    if (data is! Map) return;

    if (path == '/' || path.isEmpty) {
      // Full dump
      data.forEach((k, v) {
        if (v is Map) {
          _processedNotifIds.add(k.toString());
        }
      });
      return;
    }

    final clean = path.startsWith('/') ? path.substring(1) : path;
    final parts = clean.split('/');
    final notifId = parts[0];

    // Check if this is a newly arrived notification that we haven't shown yet
    if (!_processedNotifIds.contains(notifId)) {
      _processedNotifIds.add(notifId);

      final title = data['title']?.toString() ?? 'Order Update';
      final body = data['body']?.toString() ?? '';
      final colorVal = data['colorHex'] is num ? (data['colorHex'] as num).toInt() : 0xFF0F62FE;

      // Increment badge and show heads-up notification!
      unreadCount.value++;
      notificationHistory.insert(0, Map<String, dynamic>.from(data));

      showNotification(
        title: title,
        body: body,
        bannerColor: Color(colorVal),
      );
    }
  }

  void clearListening() {
    _listeningCustomerId = null;
    _notifSseClient?.close(force: true);
    _rtdbNotifSub?.cancel();
  }

  // ── Notification Management Helpers ──────────────────────────────────────

  /// Marks all notifications in history as read and resets badge counter.
  void markAllRead() {
    unreadCount.value = 0;
    final updated = notificationHistory.map((n) {
      return {...n, 'read': true};
    }).toList();
    notificationHistory.assignAll(updated);
  }

  /// Re-fetches notification history from RTDB for the given customer.
  Future<void> refreshNotificationHistory(String customerId) async {
    await _fetchCustomerNotificationHistory(customerId);
  }

  /// Deletes all notifications from RTDB for the given customer.
  Future<void> clearAllNotifications(String customerId) async {
    notificationHistory.clear();
    unreadCount.value = 0;
    _processedNotifIds.clear();
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
      final req = await client.deleteUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
    } catch (e) {
      debugPrint('[NotificationService] Clear notifications warning: $e');
    }
  }
}
