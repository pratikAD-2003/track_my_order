import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';
import '../../../service/dialog_service.dart';
import '../../../service/routes_service.dart';

class CustomerLiveTrackingController extends GetxController {
  final OrderService _orderService = OrderService();

  final Rx<OrderModel?> order = Rx<OrderModel?>(null);
  final Rx<LatLng?> riderLocation = Rx<LatLng?>(null);
  final markers = <MarkerId, Marker>{}.obs;
  final polylines = <PolylineId, Polyline>{}.obs;

  GoogleMapController? mapController;
  StreamSubscription<OrderModel?>? _orderSub;
  StreamSubscription<Map<String, double>?>? _partnerLocationSub;
  BitmapDescriptor? _scooterIcon;

  @override
  void onInit() {
    super.onInit();
    _loadScooterIcon();
    final args = Get.arguments;
    if (args is OrderModel) {
      order.value = args;
      _initTracking(args);
    } else if (args is String) {
      _fetchOrderById(args);
    }
  }

  @override
  void onClose() {
    _orderSub?.cancel();
    _partnerLocationSub?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _loadScooterIcon() async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      const double size = 40.0;

      // Outer blue circle background
      final Paint circlePaint = Paint()..color = const Color(0xFF0F62FE);
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, circlePaint);

      // White border ring
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2.5, borderPaint);

      // Draw Scooter / Bike Icon
      final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.directions_bike_rounded.codePoint),
        style: TextStyle(
          fontSize: 24.0,
          fontFamily: Icons.directions_bike_rounded.fontFamily,
          package: Icons.directions_bike_rounded.fontPackage,
          color: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );

      final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List uint8List = byteData.buffer.asUint8List();
        _scooterIcon = BitmapDescriptor.bytes(uint8List);
        if (order.value != null) {
          _updateMapMarkersAndRoute(order.value!);
        }
      }
    } catch (e) {
      debugPrint('[CustomerLiveTrackingController] Error creating scooter marker icon: $e');
    }
  }

  Future<void> _fetchOrderById(String orderId) async {
    final fetched = await _orderService.fetchOrderById(orderId);
    if (fetched != null) {
      order.value = fetched;
      _initTracking(fetched);
    }
  }

  void _initTracking(OrderModel o) {
    // 1. Listen to real-time order status changes
    _orderSub = _orderService.streamOrder(o.id).listen((updated) {
      if (updated != null) {
        order.value = updated;
        _updateMapMarkersAndRoute(updated);

        // Auto-navigate back when order is delivered or cancelled
        if (updated.isDelivered || updated.isCancelled) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (Get.isRegistered<CustomerLiveTrackingController>()) {
              Get.back();
            }
          });
        }
      }
    });

    // 2. Listen to real-time partner live coordinates if assigned
    if (o.partnerId != null && o.partnerId!.isNotEmpty) {
      _startPartnerLocationStream(o.partnerId!);
    }

    _updateMapMarkersAndRoute(o);
  }

  void _startPartnerLocationStream(String partnerId) {
    _partnerLocationSub?.cancel();
    _partnerLocationSub = _orderService.streamPartnerLocation(partnerId).listen((latLngMap) async {
      if (latLngMap != null) {
        final lat = latLngMap['lat'];
        final lng = latLngMap['lng'];
        if (lat != null && lng != null) {
          riderLocation.value = LatLng(lat, lng);
          _updateRiderMarker(LatLng(lat, lng));

          // ── Live ETA calculation & update as rider moves on customer tracking screen ──
          final o = order.value;
          if (o != null && o.isActive) {
            final targetLat = o.isAccepted ? o.pickupLat : o.dropLat;
            final targetLng = o.isAccepted ? o.pickupLng : o.dropLng;
            try {
              final routeInfo = await RoutesService().computeRoute(
                originLat: lat,
                originLng: lng,
                destLat: targetLat,
                destLng: targetLng,
              );
              if (routeInfo.durationMinutes != o.estimatedMinutes) {
                order.value = o.copyWith(estimatedMinutes: routeInfo.durationMinutes);
                await _orderService.updateOrderEstimatedMinutes(
                  orderId: o.id,
                  estimatedMinutes: routeInfo.durationMinutes,
                );
              }
            } catch (_) {}
          }
        }
      }
    });
  }

  Future<void> _updateMapMarkersAndRoute(OrderModel o) async {
    final newMarkers = <MarkerId, Marker>{};

    // Pickup Marker
    newMarkers[const MarkerId('pickup')] = Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(o.pickupLat, o.pickupLng),
      infoWindow: InfoWindow(title: 'Pickup Location', snippet: o.pickupAddress),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    // Drop Marker
    newMarkers[const MarkerId('drop')] = Marker(
      markerId: const MarkerId('drop'),
      position: LatLng(o.dropLat, o.dropLng),
      infoWindow: InfoWindow(title: 'Drop Location', snippet: o.dropAddress),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    // Rider Live Location Marker with custom Scooter Icon
    final currentRiderPos = riderLocation.value;
    if (currentRiderPos != null) {
      newMarkers[const MarkerId('rider')] = Marker(
        markerId: const MarkerId('rider'),
        position: currentRiderPos,
        infoWindow: InfoWindow(
          title: '🛵 Scooter • ${o.partnerName ?? "Delivery Partner"}',
          snippet: o.partnerVehicle ?? 'Motorcycle',
        ),
        icon: _scooterIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }

    markers.assignAll(newMarkers);

    // Compute precise road polyline points via RoutesService
    List<LatLng> polylinePoints = [];
    if (currentRiderPos != null) {
      final targetLat = o.isAccepted ? o.pickupLat : o.dropLat;
      final targetLng = o.isAccepted ? o.pickupLng : o.dropLng;
      try {
        final routeInfo = await RoutesService().computeRoute(
          originLat: currentRiderPos.latitude,
          originLng: currentRiderPos.longitude,
          destLat: targetLat,
          destLng: targetLng,
        );
        polylinePoints = routeInfo.polylinePoints;
      } catch (_) {}
    }

    if (polylinePoints.isEmpty) {
      polylinePoints = [
        LatLng(o.pickupLat, o.pickupLng),
        ?currentRiderPos,
        LatLng(o.dropLat, o.dropLng),
      ];
    }

    final polylineId = const PolylineId('route');
    polylines[polylineId] = Polyline(
      polylineId: polylineId,
      points: polylinePoints,
      color: const Color(0xFF0F62FE),
      width: 6,
    );
  }

  void _updateRiderMarker(LatLng pos) {
    final o = order.value;
    if (o == null) return;
    _updateMapMarkersAndRoute(o);

    // Smoothly animate camera to rider's new live position
    mapController?.animateCamera(
      CameraUpdate.newLatLng(pos),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final o = order.value;
    if (o != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              o.pickupLat < o.dropLat ? o.pickupLat : o.dropLat,
              o.pickupLng < o.dropLng ? o.pickupLng : o.dropLng,
            ),
            northeast: LatLng(
              o.pickupLat > o.dropLat ? o.pickupLat : o.dropLat,
              o.pickupLng > o.dropLng ? o.pickupLng : o.dropLng,
            ),
          ),
          90.0,
        ),
      );
    }
  }

  void callPartner() {
    final phone = order.value?.partnerPhone;
    if (phone != null && phone.isNotEmpty) {
      DialogService.showToast(message: 'Calling ${order.value?.partnerName ?? "Rider"} at $phone');
    } else {
      DialogService.showToast(message: 'Partner phone number not available.', isWarning: true);
    }
  }

  void messagePartner() {
    final phone = order.value?.partnerPhone;
    if (phone != null && phone.isNotEmpty) {
      DialogService.showToast(message: 'SMS to ${order.value?.partnerName ?? "Rider"} at $phone');
    } else {
      DialogService.showToast(message: 'Partner phone number not available.', isWarning: true);
    }
  }
}
