import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'my_theme.dart';

class Components {
  /// Reusable Input Field Widget
  static Widget customTextField({
    required TextEditingController controller,
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: MyTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: MyTheme.textSecondary.withValues(alpha: 0.6),
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: MyTheme.textSecondary,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 10.h,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFDDE4DF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFDDE4DF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: MyTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Reusable Button Widget
  static Widget customButton({
    required String text,
    required VoidCallback onPressed,
    bool isSecondary = false,
    Widget? icon,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final effectiveBgColor = backgroundColor ??
        (isSecondary ? MyTheme.secondary : MyTheme.primary);
    final effectiveTextColor = textColor ??
        (isSecondary ? MyTheme.textPrimary : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 46.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          elevation: isSecondary ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: isSecondary
                ? const BorderSide(color: Color(0xFFDDE4DF))
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              SizedBox(width: 6.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom App Bar Widget using header_bkg.png background
  static Widget customAppBar({
    bool showBackButton = true,
    VoidCallback? onBackTap,
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    Widget? child,
    EdgeInsetsGeometry? padding,
    double? bottomRadius,
    double? tailHeight,
    bool isTailStyle = true,
  }) {
    return CustomAppBar(
      showBackButton: showBackButton,
      onBackTap: onBackTap,
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      padding: padding,
      bottomRadius: bottomRadius,
      tailHeight: tailHeight,
      isTailStyle: isTailStyle,
      child: child,
    );
  }
}

/// Standalone Custom AppBar Widget with header_bkg.png background
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? bottomRadius;
  final double? tailHeight;
  final bool isTailStyle;

  const CustomAppBar({
    super.key,
    this.showBackButton = true,
    this.onBackTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.child,
    this.padding,
    this.bottomRadius,
    this.tailHeight,
    this.isTailStyle = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(child != null ? 120.h : 60.h);

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = bottomRadius ?? 32.r;
    final effectiveTailHeight = tailHeight ?? 16.h;

    final CustomClipper<Path> clipper = isTailStyle
        ? TailCornerClipper(
            radius: effectiveRadius,
            tailHeight: effectiveTailHeight,
          )
        : ConcaveCornerClipper(
            radius: effectiveRadius,
          );

    return CustomPaint(
      painter: AppBarShadowPainter(clipper: clipper),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/header_bkg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showBackButton) ...[
                        GestureDetector(
                          onTap: onBackTap ?? () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Get.back();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (titleWidget != null)
                        Expanded(child: titleWidget!)
                      else if (title != null && title!.isNotEmpty)
                        Expanded(
                          child: Text(
                            title!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      if (actions != null && actions!.isNotEmpty) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      ],
                    ],
                  ),
                  if (child != null) ...[
                    SizedBox(height: 12.h),
                    child!,
                  ],
                  if (isTailStyle) SizedBox(height: effectiveTailHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Clipper for bottom-left & bottom-right inner radius tail shape
class TailCornerClipper extends CustomClipper<Path> {
  final double radius;
  final double tailHeight;

  TailCornerClipper({
    required this.radius,
    required this.tailHeight,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = radius.clamp(0.0, size.width / 3);
    final th = tailHeight.clamp(0.0, size.height / 2);

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);

    // Inner radius curve from bottom-right tail to raised center
    path.cubicTo(
      size.width - (r * 0.4), size.height,
      size.width - (r * 0.6), size.height - th,
      size.width - r, size.height - th,
    );

    // Center bottom edge
    path.lineTo(r, size.height - th);

    // Inner radius curve from raised center to bottom-left tail
    path.cubicTo(
      r * 0.6, size.height - th,
      r * 0.4, size.height,
      0, size.height,
    );

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TailCornerClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.tailHeight != tailHeight;
  }
}

/// Clipper for concave (inward) bottom-left & bottom-right corners
class ConcaveCornerClipper extends CustomClipper<Path> {
  final double radius;

  ConcaveCornerClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = radius.clamp(0.0, size.height / 2);

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - r);

    // Bottom-right inner concave curve
    path.cubicTo(
      size.width - (r * 0.5), size.height - r,
      size.width - r, size.height - (r * 0.5),
      size.width - r, size.height,
    );

    // Bottom edge
    path.lineTo(r, size.height);

    // Bottom-left inner concave curve
    path.cubicTo(
      r, size.height - (r * 0.5),
      r * 0.5, size.height - r,
      0, size.height - r,
    );

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ConcaveCornerClipper oldClipper) => oldClipper.radius != radius;
}

/// Paints a drop shadow matching the app bar's custom clipper path
class AppBarShadowPainter extends CustomPainter {
  final CustomClipper<Path> clipper;
  final Color shadowColor;
  final double elevation;

  AppBarShadowPainter({
    required this.clipper,
    this.shadowColor = const Color(0x2B000000),
    this.elevation = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    canvas.drawShadow(path, shadowColor, elevation, false);
  }

  @override
  bool shouldRepaint(covariant AppBarShadowPainter oldDelegate) => true;
}
