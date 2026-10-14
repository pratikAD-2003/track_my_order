import 'dart:math' as math;
import 'package:flutter/material.dart';

enum MapStyleMode { lagosPartner, newYorkCustomer }

class RealisticMapView extends StatefulWidget {
  final MapStyleMode mode;
  final bool showPolyline;
  final bool animateVehicle;

  const RealisticMapView({
    super.key,
    this.mode = MapStyleMode.lagosPartner,
    this.showPolyline = true,
    this.animateVehicle = true,
  });

  @override
  State<RealisticMapView> createState() => _RealisticMapViewState();
}

class _RealisticMapViewState extends State<RealisticMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _MapPainter(
            mode: widget.mode,
            showPolyline: widget.showPolyline,
            vehicleProgress: widget.animateVehicle ? _animController.value : 0.65,
          ),
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  final MapStyleMode mode;
  final bool showPolyline;
  final double vehicleProgress;

  _MapPainter({
    required this.mode,
    required this.showPolyline,
    required this.vehicleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background base terrain
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE8F1E9),
    );

    // Green park zones
    final greenPaint = Paint()
      ..color = const Color(0xFFD8EAD9)
      ..style = PaintingStyle.fill;

    final parkPath1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.45, 0)
      ..quadraticBezierTo(w * 0.35, h * 0.18, 0, h * 0.22)
      ..close();
    canvas.drawPath(parkPath1, greenPaint);

    final parkPath2 = Path()
      ..moveTo(w * 0.6, h * 0.45)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, h * 0.7)
      ..quadraticBezierTo(w * 0.75, h * 0.65, w * 0.6, h * 0.45)
      ..close();
    canvas.drawPath(parkPath2, greenPaint);

    // Water / River
    final waterPaint = Paint()
      ..color = const Color(0xFFBCE0FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.25, h * 0.62, w * 0.45, h * 0.48, w * 0.7, h * 0.58)
      ..cubicTo(w * 0.85, h * 0.64, w * 0.95, h * 0.72, w, h * 0.8);
    canvas.drawPath(riverPath, waterPaint);

    final minorRiverPaint = Paint()
      ..color = const Color(0xFFCEE8FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.45, h * 0.48)
        ..quadraticBezierTo(w * 0.55, h * 0.3, w * 0.8, h * 0.2),
      minorRiverPaint,
    );

    // Secondary Roads
    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final roadPaths = [
      Path()
        ..moveTo(0, h * 0.12)
        ..lineTo(w, h * 0.18),
      Path()
        ..moveTo(0, h * 0.32)
        ..lineTo(w, h * 0.28),
      Path()
        ..moveTo(0, h * 0.45)
        ..lineTo(w, h * 0.42),
      Path()
        ..moveTo(0, h * 0.75)
        ..lineTo(w, h * 0.68),
      Path()
        ..moveTo(w * 0.15, 0)
        ..lineTo(w * 0.22, h),
      Path()
        ..moveTo(w * 0.42, 0)
        ..lineTo(w * 0.38, h),
      Path()
        ..moveTo(w * 0.68, 0)
        ..lineTo(w * 0.75, h),
      Path()
        ..moveTo(w * 0.88, 0)
        ..lineTo(w * 0.82, h),
    ];

    for (final path in roadPaths) {
      canvas.drawPath(path, secondaryRoadPaint);
    }

    // Main Avenues / Highways
    final mainRoadBg = Paint()
      ..color = const Color(0xFFD1D8DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11;
    final mainRoadFg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final avenue1 = Path()
      ..moveTo(0, h * 0.25)
      ..cubicTo(w * 0.35, h * 0.28, w * 0.65, h * 0.15, w, h * 0.22);

    final avenue2 = Path()
      ..moveTo(w * 0.28, 0)
      ..cubicTo(w * 0.32, h * 0.35, w * 0.58, h * 0.6, w * 0.52, h);

    canvas.drawPath(avenue1, mainRoadBg);
    canvas.drawPath(avenue1, mainRoadFg);
    canvas.drawPath(avenue2, mainRoadBg);
    canvas.drawPath(avenue2, mainRoadFg);

    // Labels
    _drawLabels(canvas, size);

    // Route + animated vehicle
    if (showPolyline) {
      _drawRoute(canvas, size);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (mode == MapStyleMode.lagosPartner) {
      _drawText(canvas, 'Ojodu', Offset(w * 0.65, h * 0.15), isBold: true, fontSize: 14);
      _drawText(canvas, 'AGUDA', Offset(w * 0.3, h * 0.23), isSubtle: true, fontSize: 10);
      _drawText(canvas, 'ISHERI', Offset(w * 0.8, h * 0.21), isSubtle: true, fontSize: 10);
      _drawText(canvas, 'Hotel Ogba', Offset(w * 0.12, h * 0.18), isSubtle: true, fontSize: 9, hasIcon: true);
      _drawText(canvas, 'Berger Bus-Sta.', Offset(w * 0.78, h * 0.1), isSubtle: true, fontSize: 8);
      _drawText(canvas, 'Asfelicity\nLimited', Offset(w * 0.08, h * 0.09), isSubtle: true, fontSize: 8);
    } else {
      _drawText(canvas, 'Manhattan', Offset(w * 0.2, h * 0.28), isBold: true, fontSize: 14);
      _drawText(canvas, 'East River', Offset(w * 0.46, h * 0.38), isSubtle: true, fontSize: 10);
      _drawText(canvas, 'Brooklyn', Offset(w * 0.64, h * 0.14), isBold: true, fontSize: 14);
      _drawText(canvas, 'Queens', Offset(w * 0.8, h * 0.27), isSubtle: true, fontSize: 11);
      _drawText(canvas, 'Williamsburg', Offset(w * 0.56, h * 0.24), isSubtle: true, fontSize: 9);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    bool isBold = false,
    bool isSubtle = false,
    double fontSize = 12,
    bool hasIcon = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isSubtle ? const Color(0xFF88959F) : const Color(0xFF2B3A42),
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          fontSize: fontSize,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (hasIcon) {
      canvas.drawCircle(
        Offset(offset.dx - 8, offset.dy + 6),
        3.5,
        Paint()..color = const Color(0xFFE91E63),
      );
    }

    textPainter.paint(canvas, offset);
  }

  void _drawRoute(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final List<Offset> points;
    final Color polyColor;

    if (mode == MapStyleMode.lagosPartner) {
      polyColor = const Color(0xFF65298C);
      points = [
        Offset(w * 0.72, h * 0.12),
        Offset(w * 0.72, h * 0.18),
        Offset(w * 0.66, h * 0.21),
        Offset(w * 0.65, h * 0.32),
        Offset(w * 0.55, h * 0.36),
        Offset(w * 0.52, h * 0.44),
      ];
    } else {
      polyColor = const Color(0xFF2F80ED);
      points = [
        Offset(w * 0.52, h * 0.48),
        Offset(w * 0.48, h * 0.42),
        Offset(w * 0.52, h * 0.35),
        Offset(w * 0.58, h * 0.28),
        Offset(w * 0.55, h * 0.22),
        Offset(w * 0.52, h * 0.16),
      ];
    }

    final routePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      routePath.lineTo(points[i].dx, points[i].dy);
    }

    // Glow
    canvas.drawPath(
      routePath,
      Paint()
        ..color = polyColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Solid polyline
    canvas.drawPath(
      routePath,
      Paint()
        ..color = polyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Destination pin
    _drawMarker(canvas, points.last, pinColor: const Color(0xFFEB5757), isDestination: true);

    // Origin pin
    _drawMarker(
      canvas,
      points.first,
      pinColor: mode == MapStyleMode.lagosPartner ? const Color(0xFF2F80ED) : const Color(0xFF27AE60),
      isDestination: false,
    );

    // Animated vehicle
    _drawMovingVehicle(canvas, points, polyColor);
  }

  void _drawMarker(Canvas canvas, Offset position, {required Color pinColor, required bool isDestination}) {
    if (isDestination) {
      canvas.drawCircle(Offset(position.dx, position.dy + 2), 12, Paint()..color = Colors.black12);
      canvas.drawCircle(position, 12, Paint()..color = pinColor);
      canvas.drawCircle(position, 5, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(position, 8, Paint()..color = pinColor);
      canvas.drawCircle(position, 4, Paint()..color = Colors.white);
    }
  }

  void _drawMovingVehicle(Canvas canvas, List<Offset> points, Color color) {
    if (points.length < 2) return;

    double totalLength = 0;
    final List<double> segmentLengths = [];
    for (int i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      segmentLengths.add(len);
      totalLength += len;
    }

    final targetDist = vehicleProgress * totalLength;
    double currentDist = 0;
    Offset vehiclePos = points.first;
    double angle = 0;

    for (int i = 0; i < segmentLengths.length; i++) {
      final segLen = segmentLengths[i];
      if (currentDist + segLen >= targetDist || i == segmentLengths.length - 1) {
        final ratio = segLen == 0 ? 0.0 : (targetDist - currentDist) / segLen;
        vehiclePos = Offset.lerp(points[i], points[i + 1], ratio.clamp(0.0, 1.0))!;
        final diff = points[i + 1] - points[i];
        angle = math.atan2(diff.dy, diff.dx);
        break;
      }
      currentDist += segLen;
    }

    // Pulse
    canvas.drawCircle(vehiclePos, 18, Paint()..color = color.withValues(alpha: 0.2));

    // White outer ring
    canvas.drawCircle(vehiclePos, 13, Paint()..color = Colors.white);

    // Colored inner
    canvas.drawCircle(vehiclePos, 10, Paint()..color = color);

    // Arrow direction
    canvas.save();
    canvas.translate(vehiclePos.dx, vehiclePos.dy);
    canvas.rotate(angle);

    final arrowPath = Path()
      ..moveTo(5, 0)
      ..lineTo(-3, -3.5)
      ..lineTo(-1.5, 0)
      ..lineTo(-3, 3.5)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.vehicleProgress != vehicleProgress ||
        oldDelegate.mode != mode ||
        oldDelegate.showPolyline != showPolyline;
  }
}
