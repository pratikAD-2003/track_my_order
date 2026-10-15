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
                    Obx(() {
                      final current = controller.selectedFilter.value;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'All Orders',
                              isSelected: current == 'All Orders',
                              onTap: () => controller.setFilter('All Orders'),
                            ),
                            _buildFilterChip(
                              'Active (${controller.activeCount})',
                              isSelected: current == 'Active',
                              onTap: () => controller.setFilter('Active'),
                            ),
                            _buildFilterChip(
                              'Delivered (${controller.deliveredCount})',
                              isSelected: current == 'Delivered',
                              onTap: () => controller.setFilter('Delivered'),
                            ),
                            _buildFilterChip(
                              'Cancelled',
                              isSelected: current == 'Cancelled',
                              onTap: () => controller.setFilter('Cancelled'),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 16.h),

                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator(color: primaryBlue));
                        }

                        final orders = controller.filteredOrders;
                        return RefreshIndicator(
                          color: primaryBlue,
                          backgroundColor: Colors.white,
                          onRefresh: controller.refreshOrders,
                          child: orders.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(height: 100.h),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                                          SizedBox(height: 10.h),
                                          Text(
                                            'No orders found',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF475569),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Orders in this category will appear here.\nPull down to refresh.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    Color statusBg;
                                    Color statusColor;
                            if (order.isDelivered) {
                              statusBg = const Color(0xFFDCFCE7);
                              statusColor = const Color(0xFF15803D);
                            } else if (order.isPending) {
                              statusBg = const Color(0xFFFEF3C7);
                              statusColor = const Color(0xFFD97706);
                            } else if (order.isAccepted) {
                              statusBg = const Color(0xFFE0EDFF);
                              statusColor = primaryBlue;
                            } else {
                              statusBg = const Color(0xFFE0F2FE);
                              statusColor = const Color(0xFF0284C7);
                            }

                            return _buildCustomerOrderCard(
                              orderId: order.orderNumber,
                              category: order.itemDescription,
                              date: '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} at ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                              statusText: order.statusDisplay,
                              statusBg: statusBg,
                              statusColor: statusColor,
                              pickup: order.pickupAddress,
                              drop: order.dropAddress,
                              riderName: order.partnerName != null
                                  ? '${order.partnerName} (Rider)'
                                  : 'Looking for rider...',
                              eta: order.isDelivered
                                  ? 'Delivered'
                                  : 'ETA ${order.estimatedMinutes} min',
                              onTap: () => OrderBottomSheets.showCustomerViewOrderDetails(order),
                            );
                          },
                        ),
                      );
                    }),
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

  Widget _buildFilterChip(String label, {bool isSelected = false, VoidCallback? onTap}) {
    const primaryBlue = Color(0xFF0F62FE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
