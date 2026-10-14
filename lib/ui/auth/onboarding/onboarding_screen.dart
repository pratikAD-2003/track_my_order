import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/my_theme.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.map_rounded,
              size: 100.sp,
              color: MyTheme.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              'Track Every Delivery Live',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Monitor shipments, connect with delivery partners, and ensure secure drop-offs with OTP verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: MyTheme.textSecondary,
              ),
            ),
            SizedBox(height: 48.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: controller.onGetStarted,
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
