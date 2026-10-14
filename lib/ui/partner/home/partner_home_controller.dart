import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';
import '../../../route/app_routes.dart';
import '../../../service/shared_pref_service.dart';

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

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    Get.snackbar(
      isOnline.value ? 'You are Online' : 'You are Offline',
      isOnline.value
          ? 'You can now receive new delivery orders.'
          : 'You will not receive any new delivery orders.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isOnline.value ? const Color(0xFF006837) : Colors.grey.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ── Partner Actions ───────────────────────────────────────────────────────

  /// Accept an available delivery job
  Future<void> acceptOrder(OrderModel order) async {
    if (!isOnline.value) {
      Get.snackbar(
        'Offline',
        'Please toggle Online first to accept orders.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (activeOrder.value != null) {
      Get.snackbar(
        'Active Order In Progress',
        'Please complete your current active order before accepting another.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Order Accepted! 🚀',
        'You have accepted ${order.orderNumber}. Head to the pickup location.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF006837),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not accept order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        'Order Picked Up! 📦',
        'Package picked up from merchant/customer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC2410C),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e', snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar(
        'In Transit! 🛵',
        'On the way to destination. Ask the customer for the delivery OTP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0284C7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e', snackPosition: SnackPosition.BOTTOM);
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

      Get.snackbar(
        'Delivered Successfully! 🎉',
        'OTP verified and delivery completed! Great job.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF006837),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'OTP Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessingAction.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _activeOrderSub?.cancel();
      await _availableOrdersSub?.cancel();
      await _recentDeliveriesSub?.cancel();
      isOnline.value = false;
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
