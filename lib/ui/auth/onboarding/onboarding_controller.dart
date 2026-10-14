import 'package:get/get.dart';
import '../../../route/app_routes.dart';

class OnboardingController extends GetxController {
  void onGetStarted() {
    Get.offAllNamed(AppRoutes.roleScreen);
  }
}
