import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../route/app_routes.dart';
import '../../../service/shared_pref_service.dart';
import '../../../service/notification_service.dart';

class CustomerHomeController extends GetxController {
  final _authService = AuthService();
  final _orderService = OrderService();

  // ── Reactive user state ───────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final isLoading = false.obs;

  // ── Reactive order state ──────────────────────────────────────────────────
  final Rx<OrderModel?> activeOrder = Rx<OrderModel?>(null);
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  final isCreatingOrder = false.obs;

  StreamSubscription<OrderModel?>? _activeOrderSub;
  StreamSubscription<List<OrderModel>>? _recentOrdersSub;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfileAndOrders();
  }

  @override
  void onClose() {
    _activeOrderSub?.cancel();
    _recentOrdersSub?.cancel();
    super.onClose();
  }

  Future<void> _loadUserProfileAndOrders() async {
    isLoading.value = true;
    try {
      final uid = _authService.currentUid;
      if (uid != null) {
        final user = await _authService.fetchUserProfile(uid);
        currentUser.value = user;
        // Re-sync FCM token every time home loads (covers already-logged-in users)
        notificationService.syncTokenForUid(uid);
        _startListeningOrders(uid);
      } else {
        final savedUid = SharedPrefService.getUid() ?? '';
        currentUser.value = UserModel(
          uid: savedUid,
          name: SharedPrefService.getUserName(),
          phone: SharedPrefService.getUserPhone(),
          email: SharedPrefService.getUserEmail(),
          role: 'customer',
          createdAt: DateTime.now(),
          isActive: true,
        );
        if (savedUid.isNotEmpty) {
          notificationService.syncTokenForUid(savedUid);
          _startListeningOrders(savedUid);
        }
      }
    } catch (e) {
      currentUser.value = UserModel(
        uid: SharedPrefService.getUid() ?? '',
        name: SharedPrefService.getUserName(),
        phone: SharedPrefService.getUserPhone(),
        email: SharedPrefService.getUserEmail(),
        role: 'customer',
        createdAt: DateTime.now(),
        isActive: true,
      );
      final savedUid = SharedPrefService.getUid() ?? '';
      if (savedUid.isNotEmpty) {
        notificationService.syncTokenForUid(savedUid);
        _startListeningOrders(savedUid);
      }
    } finally {
      isLoading.value = false;
    }
  }


  final notificationService = NotificationService();

  void _startListeningOrders(String uid) {
    _activeOrderSub?.cancel();
    _recentOrdersSub?.cancel();

    // Listen to real-time order updates
    _activeOrderSub = _orderService.streamCustomerActiveOrder(uid).listen(
      (order) {
        activeOrder.value = order;
      },
      onError: (err) {
        debugPrint('[CustomerHomeController] Error streaming active order: $err');
      },
    );

    _recentOrdersSub = _orderService.streamCustomerOrders(uid).listen(
      (orders) {
        recentOrders.assignAll(orders);
      },
      onError: (err) {
        debugPrint('[CustomerHomeController] Error streaming orders: $err');
      },
    );

    // Listen to real-time incoming push notifications from delivery partner
    notificationService.startListeningCustomerNotifications(uid);
  }

  /// Forces an instant refresh of all orders and user profile from database
  Future<void> refreshOrders() async {
    final uid = currentUser.value?.uid.isNotEmpty == true
        ? currentUser.value!.uid
        : (_authService.currentUid ?? SharedPrefService.getUid() ?? '');
    await Future.wait([
      _orderService.refreshAllOrders(),
      if (uid.isNotEmpty) _loadUserProfileAndOrders(),
    ]);
  }

  /// Opens the full-page Notifications screen
  void showNotificationSheet() {
    notificationService.markAllRead();
    Get.toNamed(AppRoutes.customerNotifications);
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
    return name.isNotEmpty ? name.split(' ').first : 'Customer';
  }

  int get totalOrdersCount => recentOrders.length;
  int get activeOrdersCount => recentOrders.where((o) => o.isActive).length;

  // ── Create Order ──────────────────────────────────────────────────────────
  Future<bool> createOrder({
    required String itemDescription,
    required String pickupAddress,
    required String dropAddress,
  }) async {
    String uid = currentUser.value?.uid.isNotEmpty == true
        ? currentUser.value!.uid
        : (_authService.currentUid ?? SharedPrefService.getUid() ?? '');
    if (uid.isEmpty) {
      uid = 'cust_${DateTime.now().millisecondsSinceEpoch}';
      await SharedPrefService.setUid(uid);
      await SharedPrefService.setUserName('Customer');
      currentUser.value = UserModel(
        uid: uid,
        name: 'Customer',
        phone: '+91 98765 43210',
        email: 'customer@trackmyorder.com',
        role: 'customer',
        createdAt: DateTime.now(),
        isActive: true,
      );
    }

    if (itemDescription.trim().isEmpty) {
      Get.snackbar('Missing Field', 'Please enter order description / name.');
      return false;
    }
    if (pickupAddress.trim().isEmpty) {
      Get.snackbar('Missing Field', 'Please provide a pickup address.');
      return false;
    }
    if (dropAddress.trim().isEmpty) {
      Get.snackbar('Missing Field', 'Please provide a drop address.');
      return false;
    }

    isCreatingOrder.value = true;
    try {
      // Ensure listener is active for this uid
      _startListeningOrders(uid);

      final order = await _orderService.createOrder(
        customerId: uid,
        customerName: userName,
        customerPhone: userPhone.isNotEmpty ? userPhone : '+91 98765 43210',
        itemDescription: itemDescription.trim(),
        pickupAddress: pickupAddress.trim(),
        dropAddress: dropAddress.trim(),
      );

      // Instant optimistic update so customer sees the card right away
      activeOrder.value = order;
      recentOrders.removeWhere((o) => o.id == order.id);
      recentOrders.insert(0, order);

      Get.snackbar(
        'Order Placed! 🎉',
        'Order ${order.orderNumber} placed. Delivery OTP is ${order.otp}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Failed to Place Order',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreatingOrder.value = false;
    }
  }

  // ── Cancel Order ──────────────────────────────────────────────────────────
  Future<void> cancelOrder(String orderId) async {
    try {
      await _orderService.cancelOrder(orderId);
      Get.snackbar(
        'Order Cancelled',
        'Your delivery order has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final oldUid = currentUser.value?.uid.isNotEmpty == true
          ? currentUser.value!.uid
          : (SharedPrefService.getUid() ?? '');
      if (oldUid.isNotEmpty) {
        await notificationService.clearSessionOnLogout(oldUid);
      }
      await _activeOrderSub?.cancel();
      await _recentOrdersSub?.cancel();
      await _authService.logout();
      await SharedPrefService.clearUserSession();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not log out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void confirmLogout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () {
        Get.back();
        logout();
      },
    );
  }
}
