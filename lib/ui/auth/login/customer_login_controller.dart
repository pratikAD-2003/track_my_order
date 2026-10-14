import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../route/app_routes.dart';

class CustomerLoginController extends GetxController {
  final isCustomer = true.obs;
  final isLoginTab = true.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleTab(bool login) {
    isLoginTab.value = login;
  }

  void toggleRole() {
    isCustomer.value = !isCustomer.value;
  }

  void submit() {
    final roleName = isCustomer.value ? 'Customer' : 'Partner';
    final actionName = isLoginTab.value ? 'Login' : 'Signup';

    Get.snackbar(
      'Success',
      '$actionName successful as $roleName!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isCustomer.value ? const Color(0xFF0F62FE) : const Color(0xFF006837),
      colorText: Colors.white,
    );

    if (isCustomer.value) {
      Get.offAllNamed(AppRoutes.customerHome);
    } else {
      Get.offAllNamed(AppRoutes.partnerHome);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
