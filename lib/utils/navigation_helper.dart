import 'package:get/get.dart';

class NavigationHelper {
  static Future<dynamic>? navigateTo(String route, {dynamic args}) =>
      Get.toNamed(route, arguments: args);

  static Future<dynamic>? navigateAndReplace(String route) =>
      Get.offNamed(route);

  static Future<dynamic>? navigateAndClear(String route) =>
      Get.offAllNamed(route);

  static void backToPrevious() => Get.back();
}
