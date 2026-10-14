import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../route/app_routes.dart';
import '../../../utils/order_bottom_sheets.dart';
import 'partner_home_controller.dart';

class PartnerHomeScreen extends GetView<PartnerHomeController> {
  const PartnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006837);

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: Rider Profile & Notification
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, size: 28.sp, color: primaryGreen),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rider Alex',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Rider',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Switch Role button for convenience
                  IconButton(
                    icon: Icon(Icons.switch_account_rounded, color: Colors.white.withValues(alpha: 0.85), size: 22.sp),
                    onPressed: () => Get.offAllNamed(AppRoutes.roleScreen),
                    tooltip: 'Switch Role',
                  ),
                  SizedBox(width: 4.w),
                  // Notification Bell with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22.sp),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Main White Rounded Body Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                child: Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 90.h),
                      children: [
                        // Stat Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Orders',
                                value: '28',
                                icon: Icons.assignment_outlined,
                                iconBg: const Color(0xFFE0EDFF),
                                iconColor: const Color(0xFF0F62FE),
                                cardBg: const Color(0xFFEEF5FF),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Available Orders',
                                value: '5',
                                icon: Icons.group_outlined,
                                iconBg: const Color(0xFFDCFCE7),
                                iconColor: const Color(0xFF10B981),
                                cardBg: const Color(0xFFF0FDF4),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Active Order Card
                        _buildActiveOrderCard(context),

                        SizedBox(height: 24.h),

                        // Recent Orders Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Orders',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.partnerMyOrders),
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F62FE),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFF0F62FE)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Recent Order Items List
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD8764',
                          category: 'Food Delivery',
                          time: 'Today, 09:05 AM',
                          statusText: 'Out for Delivery',
                          statusBg: const Color(0xFFE0F2FE),
                          statusColor: const Color(0xFF0369A1),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD8763',
                          category: 'Grocery',
                          time: 'Yesterday, 07:12 PM',
                          statusText: 'Picked Up',
                          statusBg: const Color(0xFFFFEDD5),
                          statusColor: const Color(0xFFC2410C),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD8762',
                          category: 'Documents',
                          time: 'Yesterday, 05:36 PM',
                          statusText: 'Pending',
                          statusBg: const Color(0xFFF1F5F9),
                          statusColor: const Color(0xFF475569),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD8761',
                          category: 'Electronics',
                          time: 'Yesterday, 02:14 PM',
                          statusText: 'Delivered',
                          statusBg: const Color(0xFFDCFCE7),
                          statusColor: const Color(0xFF15803D),
                        ),
                      ],
                    ),

                    // Bottom "((o)) Go Online" Button
                    Positioned(
                      left: 16.w,
                      right: 16.w,
                      bottom: 18.h,
                      child: SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          onPressed: () {
                            OrderBottomSheets.showPartnerOrderDetails(
                              onAccepted: () => OrderBottomSheets.showRiderViewOrderDetails(),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sensors_rounded, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Go Online',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardBg,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF64748B), size: 20.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Active Order & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Order',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006837),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Picked Up',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Order details
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.inventory_2_outlined, color: const Color(0xFFC2410C), size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#ORD8765',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Food Delivery',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 14.sp, color: const Color(0xFF475569)),
                      SizedBox(width: 4.w),
                      Text(
                        'ETA 18 min',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.near_me_outlined, size: 13.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 2.w),
                      Text(
                        '5.2 km',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Stepper Timeline
          Stack(
            alignment: Alignment.center,
            children: [
              // Line
              Row(
                children: [
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Container(
                      height: 3.h,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3.h,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
              // Points
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 24.sp),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F62FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.directions_bike_rounded, color: Colors.white, size: 16.sp),
                  ),
                  Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 24.sp),
                ],
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pickup', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text('10:25 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
              Column(
                children: [
                  Text('On the way', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F62FE))),
                  Text('Rider', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Destination', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text('10:43 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Customer Details Sub-card
          InkWell(
            onTap: () => OrderBottomSheets.showOtpVerification(
              onVerified: () => Get.offAllNamed(AppRoutes.partnerHome),
            ),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Icon(Icons.person_rounded, size: 22.sp, color: const Color(0xFF15803D)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Name',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '+91 98765 43210',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone_rounded, color: const Color(0xFF15803D), size: 16.sp),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: const Color(0xFF15803D), size: 16.sp),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required IconData icon,
    required String orderId,
    required String category,
    required String time,
    required String statusText,
    required Color statusBg,
    required Color statusColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$category • $time',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 18.sp),
        ],
      ),
    );
  }
}
