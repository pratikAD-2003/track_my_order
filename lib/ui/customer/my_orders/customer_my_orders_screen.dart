import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/order_bottom_sheets.dart';
import 'customer_my_orders_controller.dart';

class CustomerMyOrdersScreen extends GetView<CustomerMyOrdersController> {
  const CustomerMyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0F62FE);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: Back button & Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20.sp),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Orders',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Track active and past deliveries',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.tune_rounded, color: Colors.white, size: 20.sp),
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
                child: Column(
                  children: [
                    SizedBox(height: 16.h),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          _buildFilterChip('All Orders', isSelected: true),
                          _buildFilterChip('Active (2)'),
                          _buildFilterChip('Delivered (10)'),
                          _buildFilterChip('Cancelled'),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // List of Customer Orders
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          _buildCustomerOrderCard(
                            orderId: '#ORD5678',
                            category: 'Food Delivery',
                            date: 'Today, 10:24 AM',
                            statusText: 'In Transit',
                            statusBg: const Color(0xFFE0F2FE),
                            statusColor: const Color(0xFF0284C7),
                            pickup: '12, MG Road, Bhopal',
                            drop: '21, New Market Rd, Bhopal',
                            riderName: 'Rohit Kumar (Rider)',
                            eta: 'ETA 12 min • 2.8 km',
                            onTap: () => OrderBottomSheets.showCustomerViewOrderDetails(),
                          ),
                          _buildCustomerOrderCard(
                            orderId: '#ORD5677',
                            category: 'Documents',
                            date: 'Today, 09:15 AM',
                            statusText: 'Out for Delivery',
                            statusBg: const Color(0xFFE0F2FE),
                            statusColor: const Color(0xFF0369A1),
                            pickup: 'Acme Rd, Ikeja',
                            drop: 'Ishola Bello St, Ojodu',
                            riderName: 'Amit Kumar (Rider)',
                            eta: 'ETA 25 min • 4.1 km',
                            onTap: () => OrderBottomSheets.showCustomerViewOrderDetails(),
                          ),
                          _buildCustomerOrderCard(
                            orderId: '#ORD5676',
                            category: 'Grocery',
                            date: 'Yesterday, 06:32 PM',
                            statusText: 'Delivered',
                            statusBg: const Color(0xFFDCFCE7),
                            statusColor: const Color(0xFF15803D),
                            pickup: 'Supermarket Plaza',
                            drop: 'Green Valley Apartments',
                            riderName: 'Brooklyn Simmons',
                            eta: 'Delivered at 7:10 PM',
                            onTap: () => OrderBottomSheets.showOrderDetailsWithMap(),
                          ),
                          _buildCustomerOrderCard(
                            orderId: '#ORD5675',
                            category: 'Electronics',
                            date: 'Yesterday, 04:18 PM',
                            statusText: 'Delivered',
                            statusBg: const Color(0xFFDCFCE7),
                            statusColor: const Color(0xFF15803D),
                            pickup: 'Tech Zone Store',
                            drop: 'Sunset Boulevard',
                            riderName: 'Adams Taylor',
                            eta: 'Delivered at 5:02 PM',
                            onTap: () => OrderBottomSheets.showOrderDetailsWithMap(),
                          ),
                        ],
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

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    const primaryBlue = Color(0xFF0F62FE);

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? primaryBlue : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCustomerOrderCard({
    required String orderId,
    required String category,
    required String date,
    required String statusText,
    required Color statusBg,
    required Color statusColor,
    required String pickup,
    required String drop,
    required String riderName,
    required String eta,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    orderId,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '• $category',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
            ],
          ),

          SizedBox(height: 4.h),

          Text(
            date,
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
          ),

          SizedBox(height: 12.h),

          // Route Timeline Container
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        pickup,
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF334155)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 7.w, top: 2.h, bottom: 2.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(width: 1.5, height: 10.h, color: const Color(0xFFCBD5E1)),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        drop,
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF334155)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_bike_rounded, size: 16.sp, color: const Color(0xFF0F62FE)),
                  SizedBox(width: 6.w),
                  Text(
                    riderName,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                  ),
                ],
              ),
              InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F62FE)),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFF0F62FE)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
