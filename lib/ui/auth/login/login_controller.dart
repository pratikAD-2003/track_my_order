import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../firebase/auth_service.dart';
import '../../../route/app_routes.dart';
import '../../../service/shared_pref_service.dart';

class LoginController extends GetxController {
  // ── Observables ───────────────────────────────────────────────────────────
  final isCustomer = true.obs;
  final isLoginTab = true.obs;
  final isLoading = false.obs;
  final showPassword = false.obs;

  // ── Text Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ── Auth Service ──────────────────────────────────────────────────────────
  final _authService = AuthService();

  // ── Tab / Role Toggles ────────────────────────────────────────────────────
  void toggleTab(bool login) {
    isLoginTab.value = login;
    _clearFields();
  }

  void toggleRole() {
    isCustomer.value = !isCustomer.value;
    _clearFields();
  }

  void togglePassword() => showPassword.value = !showPassword.value;

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    if (!GetUtils.isEmail(email)) return 'Please enter a valid email address.';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? _validateSignupFields() {
    if (nameController.text.trim().isEmpty) return 'Full name is required.';
    if (nameController.text.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    if (phoneController.text.trim().isEmpty) return 'Phone number is required.';
    if (phoneController.text.trim().length < 10) {
      return 'Enter a valid phone number.';
    }
    final emailError = _validateEmail(emailController.text.trim());
    if (emailError != null) return emailError;
    final passwordError = _validatePassword(passwordController.text);
    if (passwordError != null) return passwordError;
    return null;
  }

  String? _validateLoginFields() {
    final emailError = _validateEmail(emailController.text.trim());
    if (emailError != null) return emailError;
    final passwordError = _validatePassword(passwordController.text);
    if (passwordError != null) return passwordError;
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoginTab.value ? _login() : _signUp();
  }

  Future<void> _login() async {
    final error = _validateLoginFields();
    if (error != null) {
      _showError(error);
      return;
    }

    isLoading.value = true;
    try {
      final userModel = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userModel == null) {
        _showError('Login failed. Please try again.');
        return;
      }

      // Persist session
      await SharedPrefService.setIsLogin(true);
      await SharedPrefService.setUid(userModel.uid);
      await SharedPrefService.setUserRole(userModel.role);
      await SharedPrefService.setUserName(userModel.name);
      await SharedPrefService.setUserEmail(userModel.email);
      await SharedPrefService.setUserPhone(userModel.phone);

      _showSuccess('Welcome back, ${userModel.name.split(' ').first}!');

      // Navigate based on role
      if (userModel.isCustomer) {
        Get.offAllNamed(AppRoutes.customerHome);
      } else {
        Get.offAllNamed(AppRoutes.partnerHome);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _signUp() async {
    final error = _validateSignupFields();
    if (error != null) {
      _showError(error);
      return;
    }

    isLoading.value = true;
    try {
      final role = isCustomer.value ? 'customer' : 'partner';

      final userModel = await _authService.signUp(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: role,
      );

      if (userModel == null) {
        _showError('Sign up failed. Please try again.');
        return;
      }

      // Persist session
      await SharedPrefService.setIsLogin(true);
      await SharedPrefService.setUid(userModel.uid);
      await SharedPrefService.setUserRole(userModel.role);
      await SharedPrefService.setUserName(userModel.name);
      await SharedPrefService.setUserEmail(userModel.email);
      await SharedPrefService.setUserPhone(userModel.phone);

      _showSuccess('Account created! Welcome, ${userModel.name.split(' ').first}!');

      // Navigate based on role
      if (userModel.isCustomer) {
        Get.offAllNamed(AppRoutes.customerHome);
      } else {
        Get.offAllNamed(AppRoutes.partnerHome);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _clearFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC2626),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF16A34A),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
    );
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
