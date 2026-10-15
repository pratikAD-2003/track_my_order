import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../route/app_routes.dart';
import '../../../service/dialog_service.dart';
import '../../../service/shared_pref_service.dart';
import '../../../service/notification_service.dart';
import '../../../service/routes_service.dart';

class PartnerHomeController extends GetxController {
  final _authService = AuthService();
  final _orderService = OrderService();

  // ── Reactive user state ───────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final isLoading = false.obs;

  // ── Partner online status ─────────────────────────────────────────────────
  final isOnline = true.obs;

  // ── Reactive order state ──────────────────────────────────────────────────
  final Rx<OrderModel?> activeOrder = Rx<OrderModel?>(null);
  final RxList<OrderModel> availableOrders = <OrderModel>[].obs;
  final RxList<OrderModel> recentDeliveries = <OrderModel>[].obs;
  final isProcessingAction = false.obs;

  StreamSubscription<OrderModel?>? _activeOrderSub;
  StreamSubscription<List<OrderModel>>? _availableOrdersSub;
  StreamSubscription<List<OrderModel>>? _recentDeliveriesSub;
  StreamSubscription<Position>? _positionStreamSub;
  Timer? _gpsTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfileAndOrders();
  }

  @override
  void onClose() {
    _activeOrderSub?.cancel();
    _availableOrdersSub?.cancel();
    _recentDeliveriesSub?.cancel();
    _positionStreamSub?.cancel();
    _gpsTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadUserProfileAndOrders() async {
    isLoading.value = true;
    try {
      final uid = _authService.currentUid;
      if (uid != null) {
        final user = await _authService.fetchUserProfile(uid);
        currentUser.value = user;
        _startListeningOrders(uid);
      } else {
        final savedUid = SharedPrefService.getUid() ?? '';
        currentUser.value = UserModel(
          uid: savedUid,
          name: SharedPrefService.getUserName(),
          phone: SharedPrefService.getUserPhone(),
          email: SharedPrefService.getUserEmail(),
          role: 'partner',
          createdAt: DateTime.now(),
          isActive: true,
        );
        if (savedUid.isNotEmpty) {
          _startListeningOrders(savedUid);
        }
      }
    } catch (e) {
      currentUser.value = UserModel(
        uid: SharedPrefService.getUid() ?? '',
        name: SharedPrefService.getUserName(),
        phone: SharedPrefService.getUserPhone(),
        email: SharedPrefService.getUserEmail(),
        role: 'partner',
        createdAt: DateTime.now(),
        isActive: true,
      );
      final savedUid = SharedPrefService.getUid() ?? '';
      if (savedUid.isNotEmpty) {
        _startListeningOrders(savedUid);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _startListeningOrders(String partnerUid) {
    _activeOrderSub?.cancel();
    _availableOrdersSub?.cancel();
    _recentDeliveriesSub?.cancel();

    // 1. Partner's active assigned order
    _activeOrderSub = _orderService.streamPartnerActiveOrder(partnerUid).listen(
      (order) {
        activeOrder.value = order;
      },
      onError: (err) {
        debugPrint('[PartnerHomeController] Error streaming partner active order: $err');
      },
    );

    // 2. Available pool of pending orders
    _availableOrdersSub = _orderService.streamAvailableOrders().listen(
      (orders) {
        availableOrders.assignAll(orders);
      },
      onError: (err) {
        debugPrint('[PartnerHomeController] Error streaming available orders: $err');
      },
    );

    // 3. Partner's past and completed deliveries
    _recentDeliveriesSub = _orderService.streamPartnerOrders(partnerUid).listen(
      (orders) {
        recentDeliveries.assignAll(orders);
      },
      onError: (err) {
        debugPrint('[PartnerHomeController] Error streaming partner deliveries: $err');
      },
    );

    // 4. Start active live GPS location broadcasting for the rider
    _startGpsReporting(partnerUid);
  }

  void _startGpsReporting(String partnerUid) {
    _gpsTimer?.cancel();
    _positionStreamSub?.cancel();

    // 1. Periodic timer every 4 seconds
    _gpsTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _reportCurrentPosition(partnerUid);
    });

    // 2. Geolocator background position stream with Android Foreground Service notification config
    try {
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          forceLocationManager: true,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Delivery Active 🛵',
            notificationText: 'Live location sharing is running in the background',
            notificationIcon: AndroidResource(name: 'ic_launcher'),
            enableWakeLock: true,
          ),
        ),
      ).listen(
        (pos) async {
          if (isOnline.value || activeOrder.value != null) {
            await _orderService.updatePartnerLocation(
              partnerId: partnerUid,
              lat: pos.latitude,
              lng: pos.longitude,
            );
          }
        },
        onError: (e) {
          debugPrint('[PartnerHomeController] Position stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('[PartnerHomeController] Error starting position stream: $e');
    }
  }

  Future<void> _reportCurrentPosition(String partnerUid) async {
    if (isOnline.value || activeOrder.value != null) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return;

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return;
        }

        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        await _orderService.updatePartnerLocation(
          partnerId: partnerUid,
          lat: pos.latitude,
          lng: pos.longitude,
        );

        // ── Live ETA calculation & update based on rider current position ──
        final currentActiveOrder = activeOrder.value;
        if (currentActiveOrder != null && currentActiveOrder.isActive) {
          final targetLat = currentActiveOrder.isAccepted
              ? currentActiveOrder.pickupLat
              : currentActiveOrder.dropLat;
          final targetLng = currentActiveOrder.isAccepted
              ? currentActiveOrder.pickupLng
              : currentActiveOrder.dropLng;

          final routeInfo = await RoutesService().computeRoute(
            originLat: pos.latitude,
            originLng: pos.longitude,
            destLat: targetLat,
            destLng: targetLng,
          );

          if (routeInfo.durationMinutes != currentActiveOrder.estimatedMinutes) {
            await _orderService.updateOrderEstimatedMinutes(
              orderId: currentActiveOrder.id,
              estimatedMinutes: routeInfo.durationMinutes,
            );
            activeOrder.value = currentActiveOrder.copyWith(
              estimatedMinutes: routeInfo.durationMinutes,
            );
          }
        }
      } catch (e) {
        debugPrint('[PartnerHomeController] GPS reporting / ETA update error: $e');
      }
    }
  }

  /// Forces immediate reload of all orders
  Future<void> refreshOrders() async {
    await _orderService.refreshAllOrders();
  }

  // ── Convenience getters ───────────────────────────────────────────────────
  String get userName =>
      currentUser.value?.name ?? SharedPrefService.getUserName();
  String get userEmail =>
      currentUser.value?.email ?? SharedPrefService.getUserEmail();
  String get userPhone =>
      currentUser.value?.phone ?? SharedPrefService.getUserPhone();
  String get firstNameGreeting {
    final name = userName;
    return name.isNotEmpty ? name.split(' ').first : 'Partner';
  }

  int get totalDeliveriesCount =>
      recentDeliveries.where((o) => o.isDelivered).length;
  int get availableOrdersCount => availableOrders.length;

  void toggleOnlineStatus() async {
    if (!isOnline.value) {
      // Check location permission before turning online
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        DialogService.showToast(message: 'Please enable GPS location to go online.', isWarning: true);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        DialogService.showToast(message: 'Location permission is mandatory for delivery partners.', isWarning: true);
        return;
      }
    }

    isOnline.value = !isOnline.value;
    DialogService.showToast(
      message: isOnline.value ? 'You are Online & ready for orders' : 'You are Offline',
    );
  }

  // ── Partner Actions ───────────────────────────────────────────────────────

  /// Accept an available delivery job
  Future<void> acceptOrder(OrderModel order) async {
    if (!isOnline.value) {
      DialogService.showToast(message: 'Please toggle Online first to accept orders.', isWarning: true);
      return;
    }

    // ── CRITICAL: Verify location permissions & GPS are enabled before accepting ──
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        DialogService.showToast(message: 'Please enable GPS location services to accept deliveries.', isWarning: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        DialogService.showToast(message: 'Location permission is mandatory for delivery partners.', isWarning: true);
        return;
      }
    } catch (e) {
      debugPrint('[PartnerHomeController] Location check error: $e');
    }

    if (activeOrder.value != null) {
      DialogService.showToast(message: 'Please complete your current active order before accepting another.', isWarning: true);
      return;
    }

    String uid = currentUser.value?.uid.isNotEmpty == true
        ? currentUser.value!.uid
        : (_authService.currentUid ?? SharedPrefService.getUid() ?? '');
    if (uid.isEmpty) {
      uid = 'partner_${DateTime.now().millisecondsSinceEpoch}';
      await SharedPrefService.setUid(uid);
      await SharedPrefService.setUserRole('partner');
      await SharedPrefService.setUserName('Delivery Partner');
    }
    final name = currentUser.value?.name.isNotEmpty == true
        ? currentUser.value!.name
        : (SharedPrefService.getUserName().isNotEmpty ? SharedPrefService.getUserName() : 'Delivery Partner');
    final phone = currentUser.value?.phone.isNotEmpty == true
        ? currentUser.value!.phone
        : (SharedPrefService.getUserPhone().isNotEmpty ? SharedPrefService.getUserPhone() : '+91 98765 43210');

    final partner = UserModel(
      uid: uid,
      name: name,
      phone: phone,
      email: currentUser.value?.email ?? SharedPrefService.getUserEmail(),
      role: 'partner',
      createdAt: DateTime.now(),
      isActive: true,
    );

    // Optimistic local state update
    final updated = order.copyWith(
      partnerId: partner.uid,
      partnerName: partner.name,
      partnerPhone: partner.phone,
      partnerVehicle: 'Motorcycle',
      status: 'accepted',
      updatedAt: DateTime.now(),
    );
    activeOrder.value = updated;
    availableOrders.removeWhere((o) => o.id == order.id);

    isProcessingAction.value = true;
    try {
      await _orderService.acceptOrder(orderId: order.id, partner: partner);
      DialogService.showToast(message: 'Order Accepted! 🚀 Head to pickup location.');
    } catch (e) {
      DialogService.showToast(message: 'Could not accept order: $e', isWarning: true);
    } finally {
      isProcessingAction.value = false;
    }
  }

  /// Mark order as Picked Up
  Future<void> markPickedUp(String orderId) async {
    if (activeOrder.value != null && activeOrder.value!.id == orderId) {
      activeOrder.value = activeOrder.value!.copyWith(status: 'picked_up', updatedAt: DateTime.now());
    }

    isProcessingAction.value = true;
    try {
      await _orderService.updateOrderStatus(orderId: orderId, newStatus: 'picked_up');
      DialogService.showToast(message: 'Order Picked Up! 📦');
    } catch (e) {
      DialogService.showToast(message: 'Failed to update: $e', isWarning: true);
    } finally {
      isProcessingAction.value = false;
    }
  }

  /// Mark order as In Transit / Out for delivery
  Future<void> startTransit(String orderId) async {
    if (activeOrder.value != null && activeOrder.value!.id == orderId) {
      activeOrder.value = activeOrder.value!.copyWith(status: 'in_transit', updatedAt: DateTime.now());
    }

    isProcessingAction.value = true;
    try {
      await _orderService.updateOrderStatus(orderId: orderId, newStatus: 'in_transit');
      DialogService.showToast(message: 'In Transit! 🛵 Ask customer for delivery OTP.');
    } catch (e) {
      DialogService.showToast(message: 'Failed to update: $e', isWarning: true);
    } finally {
      isProcessingAction.value = false;
    }
  }

  /// Complete Delivery with Customer's OTP
  Future<bool> completeDelivery({
    required String orderId,
    required String enteredOtp,
  }) async {
    isProcessingAction.value = true;
    try {
      await _orderService.verifyOtpAndDeliver(orderId: orderId, enteredOtp: enteredOtp);

      if (activeOrder.value != null && activeOrder.value!.id == orderId) {
        final finished = activeOrder.value!.copyWith(status: 'delivered', updatedAt: DateTime.now());
        recentDeliveries.insert(0, finished);
        activeOrder.value = null;
      }

      DialogService.showToast(message: 'Delivered Successfully! 🎉 OTP verified.');
      return true;
    } catch (e) {
      DialogService.showToast(message: e.toString().replaceAll('Exception: ', ''), isWarning: true);
      return false;
    } finally {
      isProcessingAction.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final oldUid = currentUser.value?.uid.isNotEmpty == true
          ? currentUser.value!.uid
          : (SharedPrefService.getUid() ?? '');
      if (oldUid.isNotEmpty) {
        await NotificationService().clearSessionOnLogout(oldUid);
      }
      await _activeOrderSub?.cancel();
      await _availableOrdersSub?.cancel();
      await _recentDeliveriesSub?.cancel();
      _gpsTimer?.cancel();
      isOnline.value = false;
      await _authService.logout();
      await SharedPrefService.clearUserSession();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      DialogService.showToast(message: 'Could not log out. Please try again.', isWarning: true);
    }
  }

  void confirmLogout() {
    DialogService.showConfirmationDialog(
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isWarning: true,
      onConfirm: logout,
    );
  }
}
