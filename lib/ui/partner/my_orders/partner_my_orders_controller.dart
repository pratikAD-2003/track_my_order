import 'dart:async';
import 'package:get/get.dart';
import '../../../firebase/auth_service.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../service/shared_pref_service.dart';

class PartnerMyOrdersController extends GetxController {
  final _authService = AuthService();
  final _orderService = OrderService();

  final RxList<OrderModel> allJobs = <OrderModel>[].obs;
  final RxString selectedFilter = 'All Jobs'.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<OrderModel>>? _jobsSub;

  @override
  void onInit() {
    super.onInit();
    _startListeningJobs();
  }

  @override
  void onClose() {
    _jobsSub?.cancel();
    super.onClose();
  }

  void _startListeningJobs() {
    final uid = _authService.currentUid ?? SharedPrefService.getUid() ?? '';
    if (uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _orderService.fetchAllOrders().then((all) {
      final mine = all.where((o) => o.partnerId == uid).toList();
      if (mine.isNotEmpty) {
        allJobs.assignAll(mine);
        isLoading.value = false;
      }
    });

    _jobsSub = _orderService.streamPartnerOrders(uid).listen(
      (jobs) {
        allJobs.assignAll(jobs);
        isLoading.value = false;
      },
      onError: (err) {
        isLoading.value = false;
      },
    );
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  List<OrderModel> get filteredJobs {
    switch (selectedFilter.value) {
      case 'Active':
        return allJobs.where((o) => o.isActive).toList();
      case 'Completed':
        return allJobs.where((o) => o.isDelivered).toList();
      default:
        return allJobs;
    }
  }

  int get activeCount => allJobs.where((o) => o.isActive).length;
  int get completedCount => allJobs.where((o) => o.isDelivered).length;
}
