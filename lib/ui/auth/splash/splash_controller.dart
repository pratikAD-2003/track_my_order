import 'package:get/get.dart';
import '../../../route/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.currentRoute == AppRoutes.splashScreen) {
        Get.offAllNamed(AppRoutes.onboardingScreen);
      }
    });
  }

  void onTapSplash() {
    Get.offAllNamed(AppRoutes.onboardingScreen);
  }
}
