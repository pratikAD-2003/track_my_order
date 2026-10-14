import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../route/app_routes.dart';
import '../../../utils/order_bottom_sheets.dart';
import 'customer_home_controller.dart';

class CustomerHomeScreen extends GetView<CustomerHomeController> {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0F62FE);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: User Profile & Notification
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, size: 28.sp, color: primaryBlue),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Customer',
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
                                value: '12',
                                icon: Icons.assignment_outlined,
                                iconBg: const Color(0xFFE0EDFF),
                                iconColor: primaryBlue,
                                cardBg: const Color(0xFFEEF5FF),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Active Riders',
                                value: '3',
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
                              onTap: () => Get.toNamed(AppRoutes.customerMyOrders),
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(Icons.chevron_right_rounded, size: 18.sp, color: primaryBlue),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Recent Order Items List
                        _buildOrderItem(
                          icon: Icons.restaurant_rounded,
                          orderId: '#ORD5678',
                          category: 'Food Delivery',
                          time: 'Today, 10:24 AM',
                          statusText: 'Delivered',
                          statusBg: const Color(0xFFDCFCE7),
                          statusColor: const Color(0xFF15803D),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD5677',
                          category: 'Documents',
                          time: 'Today, 09:15 AM',
                          statusText: 'Out for Delivery',
                          statusBg: const Color(0xFFE0F2FE),
                          statusColor: const Color(0xFF0369A1),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD5676',
                          category: 'Grocery',
                          time: 'Yesterday, 06:32 PM',
                          statusText: 'Picked Up',
                          statusBg: const Color(0xFFFFEDD5),
                          statusColor: const Color(0xFFC2410C),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD5675',
                          category: 'Electronics',
                          time: 'Yesterday, 04:18 PM',
                          statusText: 'Pending',
                          statusBg: const Color(0xFFF1F5F9),
                          statusColor: const Color(0xFF475569),
                        ),
                        _buildOrderItem(
                          icon: Icons.inventory_2_outlined,
                          orderId: '#ORD5674',
                          category: 'Pharmacy',
                          time: 'Yesterday, 11:03 AM',
                          statusText: 'Delivered',
                          statusBg: const Color(0xFFDCFCE7),
                          statusColor: const Color(0xFF15803D),
                        ),
                      ],
                    ),

                    // Floating Action Button (+) Opens Create Order Sheet directly
                    Positioned(
                      right: 16.w,
                      bottom: 24.h,
                      child: FloatingActionButton(
                        onPressed: () => OrderBottomSheets.showCreateOrderForm(context),
                        backgroundColor: primaryBlue,
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
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
                  color: const Color(0xFF881337),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'In Transit',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0284C7),
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
                  color: const Color(0xFFE0EDFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.inventory_2_outlined, color: const Color(0xFF0F62FE), size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#ORD1234',
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
                        'ETA 12 min',
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
                        '2.8 km',
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
                  Text('10:15 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
              Column(
                children: [
                  Text('Rider', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F62FE))),
                  Text('On the way', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Destination', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  Text('10:32 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Rider Details Sub-card
          InkWell(
            onTap: () => OrderBottomSheets.showCustomerViewOrderDetails(),
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
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: Icon(Icons.person_rounded, size: 22.sp, color: const Color(0xFF0F62FE)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rohit Kumar',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Rider • MH12 AB 4567',
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
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.phone_rounded, color: const Color(0xFF0284C7), size: 16.sp),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: const Color(0xFF0284C7), size: 16.sp),
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
