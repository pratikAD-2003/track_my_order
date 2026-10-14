import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/my_theme.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Shows a bottom sheet with Camera and Gallery options, and returns the selected image path.
  static Future<String?> pickImage() async {
    final context = Get.context;
    if (context == null) return null;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E2843),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: MyTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt_rounded, color: MyTheme.primary, size: 20.sp),
              ),
              title: Text(
                'Camera',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E2843)),
              ),
              subtitle: Text(
                'Take a photo using camera',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A94A6)),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            Divider(color: const Color(0xFFF2F4F3), height: 16.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library_rounded, color: const Color(0xFF1565C0), size: 20.sp),
              ),
              title: Text(
                'Gallery',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E2843)),
              ),
              subtitle: Text(
                'Choose an image from gallery',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A94A6)),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );

    if (source == null) return null;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      return image?.path;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return null;
    }
  }
}
