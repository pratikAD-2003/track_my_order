import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTheme {
  static const Color background = Color(0xFFF3F4F3);
  static const Color primary = Color(0xFF1F7A5A);
  static const Color secondary = Color(0xFFE9EEEB);

  static const Color textPrimary = Color(0xFF171C19);
  static const Color textSecondary = Color(0xFF68736D);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(
      color: const Color(0xFFDDE4DF),
      width: 0.8,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.035),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
