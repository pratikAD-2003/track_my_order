import 'package:get/get.dart';
import '../../../firebase/auth_service.dart';
import '../../../route/app_routes.dart';
import '../../../service/shared_pref_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 2), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    final firebaseUser = AuthService().currentUser;
    final isLoggedIn = SharedPrefService.getIsLogin();
    final role = SharedPrefService.getUserRole();

    if (firebaseUser != null && isLoggedIn && role != null) {
      // User is logged in — route to correct home
      if (role == 'customer') {
        Get.offAllNamed(AppRoutes.customerHome);
      } else {
        Get.offAllNamed(AppRoutes.partnerHome);
      }
    } else {
      // Not logged in — move directly to login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void onTapSplash() {
    _checkAuthState();
  }
}
