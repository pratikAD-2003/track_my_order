import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/maps_config.dart';
import '../../models/place_location.dart';
import '../../service/places_service.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final String title;
  final bool isPickup;
  final LatLng? initialPosition;

  const MapLocationPickerScreen({
    super.key,
    this.title = 'Select Location on Map',
    this.isPickup = true,
    this.initialPosition,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final PlacesService _placesService = PlacesService();
  GoogleMapController? _mapController;

  late LatLng _currentCenter;
  PlaceLocation? _selectedLocation;
  bool _isLoadingAddress = false;
  bool _isMapMoving = false;
  Timer? _debounceTimer;

  static const Color primaryBlue = Color(0xFF0F62FE);
  static const Color pickupGreen = Color(0xFF10B981);
  static const Color dropRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition ??
        const LatLng(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    _reverseGeocodeCenter(_currentCenter);

    if (widget.initialPosition == null) {
      _fetchCurrentGpsAndAnimate();
    }
  }

  Future<void> _fetchCurrentGpsAndAnimate() async {
    final cur = await _placesService.getCurrentLocation();
    if (cur != null && mounted) {
      final target = LatLng(cur.latitude, cur.longitude);
      _currentCenter = target;
      _reverseGeocodeCenter(target);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16.5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
    if (!_isMapMoving) {
      setState(() {
        _isMapMoving = true;
      });
    }
  }

  void _onCameraIdle() {
    setState(() {
      _isMapMoving = false;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _reverseGeocodeCenter(_currentCenter);
    });
  }

  Future<void> _reverseGeocodeCenter(LatLng latLng) async {
    setState(() {
      _isLoadingAddress = true;
    });

    final loc = await _placesService.reverseGeocode(latLng.latitude, latLng.longitude);

    if (mounted) {
      setState(() {
        _selectedLocation = loc;
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    final cur = await _placesService.getCurrentLocation();
    if (cur != null && _mapController != null) {
      final target = LatLng(cur.latitude, cur.longitude);
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isPickup ? pickupGreen : dropRed;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 15.5,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.initialPosition == null) {
                _fetchCurrentGpsAndAnimate();
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 2. Fixed Center Floating Pin (Uber-style)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 38.h),
              child: AnimatedScale(
                scale: _isMapMoving ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.isPickup ? 'PICKUP HERE' : 'DELIVER HERE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.location_on_rounded,
                      size: 44.sp,
                      color: themeColor,
                    ),
                    Container(
                      width: 8.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Top Floating App Bar
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
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
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10.r,
                            height: 10.r,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: widget.isPickup ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius: widget.isPickup ? null : BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating GPS Target Button
          Positioned(
            right: 16.w,
            bottom: 220.h,
            child: GestureDetector(
              onTap: _goToCurrentLocation,
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: primaryBlue,
                  size: 24.sp,
                ),
              ),
            ),
          ),

          // 5. Bottom Location Confirmation Card (Uber-style)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isPickup ? Icons.trip_origin_rounded : Icons.location_on_rounded,
                          color: themeColor,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isLoadingAddress)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Locating address...',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              Text(
                                _selectedLocation?.title ?? 'Selected Location',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                _selectedLocation?.address ?? 'Move map to select',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF64748B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _selectedLocation == null || _isLoadingAddress
                          ? null
                          : () => Get.back(result: _selectedLocation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A), // Uber-style sleek black
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.isPickup ? 'Confirm Pickup Location' : 'Confirm Drop Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
