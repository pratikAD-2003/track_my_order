import 'dart:async';
import 'package:get/get.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../service/shared_pref_service.dart';

class CustomerMyOrdersController extends GetxController {
  final _authService = AuthService();
  final _orderService = OrderService();

  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxString selectedFilter = 'All Orders'.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<OrderModel>>? _ordersSub;

  @override
  void onInit() {
    super.onInit();
    _startListeningOrders();
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    super.onClose();
  }

  void _startListeningOrders() {
    final uid = _authService.currentUid ?? SharedPrefService.getUid() ?? '';
    if (uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _orderService.fetchAllOrders().then((all) {
      final mine = all.where((o) => o.customerId == uid).toList();
      if (mine.isNotEmpty) {
        allOrders.assignAll(mine);
        isLoading.value = false;
      }
    });

    _ordersSub = _orderService.streamCustomerOrders(uid).listen(
      (orders) {
        allOrders.assignAll(orders);
        isLoading.value = false;
      },
      onError: (err) {
        isLoading.value = false;
      },
    );
  }

  Future<void> refreshOrders() async {
    await _orderService.refreshAllOrders();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<OrderModel> get filteredOrders {
    switch (selectedFilter.value) {
      case 'Active':
        return allOrders.where((o) => o.isActive).toList();
      case 'Delivered':
        return allOrders.where((o) => o.isDelivered).toList();
      case 'Cancelled':
        return allOrders.where((o) => o.isCancelled).toList();
      default:
        return allOrders;
    }
  }

  int get activeCount => allOrders.where((o) => o.isActive).length;
  int get deliveredCount => allOrders.where((o) => o.isDelivered).length;
  int get cancelledCount => allOrders.where((o) => o.isCancelled).length;
}
