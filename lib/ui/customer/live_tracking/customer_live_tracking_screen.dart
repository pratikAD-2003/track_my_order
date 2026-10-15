import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'customer_live_tracking_controller.dart';

class CustomerLiveTrackingScreen extends GetView<CustomerLiveTrackingController> {
  const CustomerLiveTrackingScreen({super.key});

  static const Color primaryBlue = Color(0xFF0F62FE);
  static const Color pickupGreen = Color(0xFF10B981);
  static const Color dropRed = Color(0xFFEF4444);
  static const Color uberDark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map View
          Obx(() {
            final o = controller.order.value;
            if (o == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(o.pickupLat, o.pickupLng),
                zoom: 14.5,
              ),
              onMapCreated: controller.onMapCreated,
              markers: Set<Marker>.of(controller.markers.values),
              polylines: Set<Polyline>.of(controller.polylines.values),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            );
          }),

          // 2. Top App Bar with Status Pill
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
                      child: Icon(Icons.arrow_back_rounded, size: 20.sp, color: uberDark),
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
                      child: Obx(() {
                        final o = controller.order.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10.r,
                                  height: 10.r,
                                  decoration: const BoxDecoration(
                                    color: pickupGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  o?.orderNumber ?? 'Live Tracking',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: uberDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                o?.statusDisplay ?? 'Active',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Tracking Card (Uber / Swiggy style)
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
              child: Obx(() {
                final o = controller.order.value;
                if (o == null) return const SizedBox.shrink();

                return Column(
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

                    // ETA Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '~${o.estimatedMinutes} mins',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: uberDark,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.vpn_key_rounded, size: 16.sp, color: const Color(0xFFB45309)),
                              SizedBox(width: 6.w),
                              Text(
                                'OTP: ${o.otp}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),
                    Divider(height: 1, color: const Color(0xFFF1F5F9)),
                    SizedBox(height: 14.h),

                    // Partner / Rider Info Row
                    if (o.partnerName != null && o.partnerName!.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delivery_dining_rounded, color: primaryBlue, size: 24.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.partnerName!,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: uberDark,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  o.partnerVehicle ?? 'Delivery Partner • Motorcycle',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Call Button
                          GestureDetector(
                            onTap: controller.callPartner,
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: const BoxDecoration(
                                color: pickupGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.call_rounded, color: Colors.white, size: 20.sp),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Message Button
                          GestureDetector(
                            onTap: controller.messagePartner,
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.message_rounded, color: Colors.white, size: 20.sp),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 22.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Searching for a nearby delivery partner...',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Route Summary
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(width: 8.r, height: 8.r, decoration: const BoxDecoration(color: pickupGreen, shape: BoxShape.circle)),
                              SizedBox(width: 10.w),
                              Expanded(child: Text(o.pickupAddress, style: TextStyle(fontSize: 12.sp, color: uberDark, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(width: 2.w, height: 16.h, color: const Color(0xFF94A3B8)),
                            ),
                          ),
                          Row(
                            children: [
                              Container(width: 8.r, height: 8.r, decoration: BoxDecoration(color: dropRed, borderRadius: BorderRadius.circular(2.r))),
                              SizedBox(width: 10.w),
                              Expanded(child: Text(o.dropAddress, style: TextStyle(fontSize: 12.sp, color: uberDark, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
