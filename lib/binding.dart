import 'package:get/get.dart';
import 'firebase/auth_service.dart';
import 'ui/auth/splash/splash_controller.dart';
import 'ui/auth/login/login_controller.dart';
import 'ui/customer/home/customer_home_controller.dart';
import 'ui/customer/my_orders/customer_my_orders_controller.dart';
import 'ui/customer/notifications/notifications_controller.dart';
import 'ui/partner/home/partner_home_controller.dart';
import 'ui/partner/my_orders/partner_my_orders_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService as a permanent singleton for the whole app
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

// Customer Bindings
class CustomerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
  }
}

class CustomerMyOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerMyOrdersController>(() => CustomerMyOrdersController());
  }
}

class CustomerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}

// Partner Bindings
class PartnerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerHomeController>(() => PartnerHomeController());
  }
}

class PartnerMyOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerMyOrdersController>(() => PartnerMyOrdersController());
  }
}
