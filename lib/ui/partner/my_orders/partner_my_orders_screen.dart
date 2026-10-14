import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/order_bottom_sheets.dart';
import 'partner_my_orders_controller.dart';

class PartnerMyOrdersScreen extends GetView<PartnerMyOrdersController> {
  const PartnerMyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF006837);

    return Scaffold(
      backgroundColor: primaryGreen,
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
                          'My Deliveries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Completed payouts & active jobs',
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
                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20.sp),
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
                          _buildFilterChip('All Jobs', isSelected: true),
                          _buildFilterChip('Active (1)'),
                          _buildFilterChip('Completed (27)'),
                          _buildFilterChip('Declined'),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Earnings Summary Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.payments_rounded, color: primaryGreen, size: 22.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Earned: \$148.50',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '28 Deliveries Completed • 4.9 ⭐ Rating',
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // List of Partner Deliveries
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          _buildPartnerDeliveryCard(
                            orderId: '#ORD8765',
                            payout: '\$18.50',
                            category: 'Food Delivery',
                            date: 'Today, 09:15 AM',
                            statusText: 'Picked Up',
                            statusBg: const Color(0xFFFFEDD5),
                            statusColor: const Color(0xFFC2410C),
                            pickup: '12, MG Road, Bhopal',
                            drop: '21, New Market Rd, Bhopal',
                            distanceTime: '2.1 km • 8 min ETA',
                            onTap: () => OrderBottomSheets.showRiderViewOrderDetails(),
                          ),
                          _buildPartnerDeliveryCard(
                            orderId: '#ORD8764',
                            payout: '\$14.00',
                            category: 'Food Delivery',
                            date: 'Today, 08:30 AM',
                            statusText: 'Delivered',
                            statusBg: const Color(0xFFDCFCE7),
                            statusColor: const Color(0xFF15803D),
                            pickup: '23 Acme Rd, Ogba',
                            drop: '31 Ishola Bello St, Ojodu',
                            distanceTime: '5.1 km • Completed',
                            onTap: () => OrderBottomSheets.showOrderDetailsWithMap(),
                          ),
                          _buildPartnerDeliveryCard(
                            orderId: '#ORD8763',
                            payout: '\$22.00',
                            category: 'Grocery',
                            date: 'Yesterday, 07:12 PM',
                            statusText: 'Delivered',
                            statusBg: const Color(0xFFDCFCE7),
                            statusColor: const Color(0xFF15803D),
                            pickup: 'Supermarket Central Plaza',
                            drop: 'Block C, Green Park Housing',
                            distanceTime: '6.4 km • Completed',
                            onTap: () => OrderBottomSheets.showOrderDetailsWithMap(),
                          ),
                          _buildPartnerDeliveryCard(
                            orderId: '#ORD8762',
                            payout: '\$12.50',
                            category: 'Documents',
                            date: 'Yesterday, 05:36 PM',
                            statusText: 'Delivered',
                            statusBg: const Color(0xFFDCFCE7),
                            statusColor: const Color(0xFF15803D),
                            pickup: 'City Express Postal Office',
                            drop: '14 Commerce Tower',
                            distanceTime: '3.0 km • Completed',
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
    const primaryGreen = Color(0xFF006837);

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? primaryGreen : const Color(0xFFE2E8F0),
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

  Widget _buildPartnerDeliveryCard({
    required String orderId,
    required String payout,
    required String category,
    required String date,
    required String statusText,
    required Color statusBg,
    required Color statusColor,
    required String pickup,
    required String drop,
    required String distanceTime,
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
              Row(
                children: [
                  Text(
                    payout,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006837),
                    ),
                  ),
                  SizedBox(width: 8.w),
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
                    Icon(Icons.storefront_outlined, color: const Color(0xFF10B981), size: 16.sp),
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
              Text(
                distanceTime,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
              ),
              InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      'View Order',
                      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF006837)),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFF006837)),
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
