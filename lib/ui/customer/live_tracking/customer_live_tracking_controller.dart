import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../firebase/order_service.dart';
import '../../../models/order_model.dart';

class CustomerLiveTrackingController extends GetxController {
  final OrderService _orderService = OrderService();

  final Rx<OrderModel?> order = Rx<OrderModel?>(null);
  final Rx<LatLng?> riderLocation = Rx<LatLng?>(null);
  final markers = <MarkerId, Marker>{}.obs;
  final polylines = <PolylineId, Polyline>{}.obs;

  GoogleMapController? mapController;
  StreamSubscription<OrderModel?>? _orderSub;
  StreamSubscription<Map<String, double>?>? _partnerLocationSub;

  @override
  void onInit() {
    super.onInit();
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
    _partnerLocationSub = _orderService.streamPartnerLocation(partnerId).listen((latLngMap) {
      if (latLngMap != null) {
        final lat = latLngMap['lat'];
        final lng = latLngMap['lng'];
        if (lat != null && lng != null) {
          riderLocation.value = LatLng(lat, lng);
          _updateRiderMarker(LatLng(lat, lng));
        }
      }
    });
  }

  void _updateMapMarkersAndRoute(OrderModel o) {
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

    // Rider Live Location Marker
    final currentRiderPos = riderLocation.value;
    if (currentRiderPos != null) {
      newMarkers[const MarkerId('rider')] = Marker(
        markerId: const MarkerId('rider'),
        position: currentRiderPos,
        infoWindow: InfoWindow(
          title: o.partnerName ?? 'Delivery Partner',
          snippet: o.partnerVehicle ?? 'Motorcycle',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }

    markers.assignAll(newMarkers);

    // Polyline route: Pickup -> Rider (if available) -> Drop
    final polylinePoints = <LatLng>[
      LatLng(o.pickupLat, o.pickupLng),
    ];
    if (currentRiderPos != null) {
      polylinePoints.add(currentRiderPos);
    }
    polylinePoints.add(LatLng(o.dropLat, o.dropLng));

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
      Get.snackbar(
        'Call Partner',
        'Calling ${order.value?.partnerName ?? "Rider"} at $phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Contact', 'Partner phone number not available.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void messagePartner() {
    final phone = order.value?.partnerPhone;
    if (phone != null && phone.isNotEmpty) {
      Get.snackbar(
        'Message Partner',
        'SMS to ${order.value?.partnerName ?? "Rider"} at $phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F62FE),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar('Contact', 'Partner phone number not available.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
