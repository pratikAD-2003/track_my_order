import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../route/app_routes.dart';
import '../../../utils/my_theme.dart';
import 'role_controller.dart';

class RoleScreen extends GetView<RoleController> {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        title: const Text('Select Your Role (Temporary)'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to Track My Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please select how you want to use the app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: MyTheme.textSecondary,
              ),
            ),
            SizedBox(height: 40.h),
            _buildRoleCard(
              title: 'Customer',
              subtitle: 'Send packages, create orders, and track live deliveries',
              icon: Icons.person_rounded,
              onTap: () => Get.offAllNamed(AppRoutes.customerHome),
            ),
            SizedBox(height: 16.h),
            _buildRoleCard(
              title: 'Delivery Partner',
              subtitle: 'Accept deliveries, navigate routes, and confirm OTP',
              icon: Icons.delivery_dining_rounded,
              onTap: () => Get.offAllNamed(AppRoutes.partnerHome),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: MyTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: MyTheme.secondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 32.sp, color: MyTheme.primary),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: MyTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: MyTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: MyTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
