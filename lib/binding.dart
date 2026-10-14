import 'package:get/get.dart';
import 'ui/auth/splash/splash_controller.dart';
import 'ui/auth/onboarding/onboarding_controller.dart';
import 'ui/auth/role/role_controller.dart';
import 'ui/auth/login/customer_login_controller.dart';
import 'ui/customer/home/customer_home_controller.dart';
import 'ui/customer/my_orders/customer_my_orders_controller.dart';
import 'ui/partner/home/partner_home_controller.dart';
import 'ui/partner/my_orders/partner_my_orders_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}

class RoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleController>(() => RoleController());
  }
}

// Customer Bindings
class CustomerLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerLoginController>(() => CustomerLoginController());
  }
}

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
