import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Mock Map Canvas with Streets, Route Path, Pins, and Floating Controls
class InteractiveMapWidget extends StatelessWidget {
  final String title;
  final String searchHint;
  final bool showRoute;
  final bool showDropPin;
  final String pickupLabel;
  final String dropLabel;
  final VoidCallback? onBack;

  const InteractiveMapWidget({
    super.key,
    this.title = 'Select Pickup Location',
    this.searchHint = 'Search for pickup location',
    this.showRoute = false,
    this.showDropPin = false,
    this.pickupLabel = 'Pickup Location\nTap to set',
    this.dropLabel = 'Drop Location\nTap to set',
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Canvas Background (Custom Painted Map with Streets & Route)
          CustomPaint(
            size: Size.infinite,
            painter: MapCanvasPainter(
              showRoute: showRoute,
              showDropPin: showDropPin,
            ),
          ),

          // Top Header & Search Bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onBack ?? () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back_rounded, size: 20.sp, color: const Color(0xFF0F172A)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  searchHint,
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: 13.5.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map Pin Callouts
          // Pickup Pin Callout
          Positioned(
            left: 110.w,
            top: 240.h,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    pickupLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 36.sp),
              ],
            ),
          ),

          // Drop Pin Callout (if enabled)
          if (showDropPin)
            Positioned(
              right: 80.w,
              top: 170.h,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      dropLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 36.sp),
                ],
              ),
            ),

          // Right Floating Map Action Buttons (Locate Me & Target)
          Positioned(
            right: 16.w,
            bottom: 220.h,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.center_focus_strong_rounded, color: const Color(0xFF0F172A), size: 20.sp),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.navigation_rounded, color: const Color(0xFF0F62FE), size: 20.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter for Realistic Map Background with Streets, Blocks, and Route Line
class MapCanvasPainter extends CustomPainter {
  final bool showRoute;
  final bool showDropPin;

  MapCanvasPainter({this.showRoute = false, this.showDropPin = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Map background color (light pastel grey/blue grid)
    final bgPaint = Paint()..color = const Color(0xFFEBF1F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Green land/park areas
    final parkPaint = Paint()..color = const Color(0xFFD4EAD9);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 100, 120, 180), const Radius.circular(16)), parkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 140, 260, 120, 160), const Radius.circular(16)), parkPaint);

    // Water body
    final waterPaint = Paint()..color = const Color(0xFFC7E2FE);
    final waterPath = Path()
      ..moveTo(size.width - 100, 0)
      ..quadraticBezierTo(size.width - 60, size.height * 0.3, size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Streets / Roads (White and Yellow lines)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mainRoadPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), mainRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), roadPaint);

    // Vertical roads
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), mainRoadPaint);

    // Diagonal connecting roads
    canvas.drawLine(Offset(0, size.height * 0.1), Offset(size.width * 0.6, size.height * 0.5), roadPaint);

    // Route line (if active)
    if (showRoute) {
      final routePath = Path()
        ..moveTo(128, size.height * 0.38)
        ..lineTo(size.width * 0.35, size.height * 0.45)
        ..lineTo(size.width * 0.55, size.height * 0.45)
        ..lineTo(size.width * 0.7, size.height * 0.3)
        ..lineTo(size.width - 98, 205);

      // Route Outer Glow/Shadow
      final routeGlowPaint = Paint()
        ..color = const Color(0xFF0F62FE).withValues(alpha: 0.3)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, routeGlowPaint);

      // Route Main Blue Line
      final routePaint = Paint()
        ..color = const Color(0xFF0F62FE)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, routePaint);

      // Waypoint dots along the route
      final dotPaint = Paint()..color = Colors.white;
      final blueDotPaint = Paint()..color = const Color(0xFF0F62FE);

      final waypoints = [
        Offset(size.width * 0.35, size.height * 0.45),
        Offset(size.width * 0.55, size.height * 0.45),
        Offset(size.width * 0.7, size.height * 0.3),
      ];

      for (var pt in waypoints) {
        canvas.drawCircle(pt, 6, blueDotPaint);
        canvas.drawCircle(pt, 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
