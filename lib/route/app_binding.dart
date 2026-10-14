import 'package:get/get.dart';
import '../binding.dart';
import '../ui/auth/splash/splash_screen.dart';
import '../ui/auth/onboarding/onboarding_screen.dart';
import '../ui/auth/role/role_screen.dart';
import '../ui/auth/login/customer_login_screen.dart';
import '../ui/customer/home/customer_home_screen.dart';
import '../ui/customer/my_orders/customer_my_orders_screen.dart';
import '../ui/partner/home/partner_home_screen.dart';
import '../ui/partner/my_orders/partner_my_orders_screen.dart';
import 'app_routes.dart';

class AppBinding {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingScreen,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.roleScreen,
      page: () => const RoleScreen(),
      binding: RoleBinding(),
    ),
    // Customer Screens
    GetPage(
      name: AppRoutes.customerLogin,
      page: () => const CustomerLoginScreen(),
      binding: CustomerLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeScreen(),
      binding: CustomerHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.customerMyOrders,
      page: () => const CustomerMyOrdersScreen(),
      binding: CustomerMyOrdersBinding(),
    ),
    // Partner Screens
    GetPage(
      name: AppRoutes.partnerHome,
      page: () => const PartnerHomeScreen(),
      binding: PartnerHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.partnerMyOrders,
      page: () => const PartnerMyOrdersScreen(),
      binding: PartnerMyOrdersBinding(),
    ),
  ];
}
