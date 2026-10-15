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
                          'Completed & active jobs history',
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
                              'All Jobs',
                              isSelected: current == 'All Jobs',
                              onTap: () => controller.setFilter('All Jobs'),
                            ),
                            _buildFilterChip(
                              'Active (${controller.activeCount})',
                              isSelected: current == 'Active',
                              onTap: () => controller.setFilter('Active'),
                            ),
                            _buildFilterChip(
                              'Completed (${controller.completedCount})',
                              isSelected: current == 'Completed',
                              onTap: () => controller.setFilter('Completed'),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 14.h),

                    // List of Partner Deliveries
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final jobs = controller.filteredJobs;
                        if (jobs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delivery_dining_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                                SizedBox(height: 10.h),
                                Text(
                                  'No deliveries found',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Deliveries matching this filter will show here.',
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            Color statusBg;
                            Color statusColor;
                            if (job.isDelivered) {
                              statusBg = const Color(0xFFDCFCE7);
                              statusColor = const Color(0xFF15803D);
                            } else if (job.isPending) {
                              statusBg = const Color(0xFFFEF3C7);
                              statusColor = const Color(0xFFD97706);
                            } else if (job.isAccepted) {
                              statusBg = const Color(0xFFE0EDFF);
                              statusColor = const Color(0xFF0F62FE);
                            } else {
                              statusBg = const Color(0xFFFFEDD5);
                              statusColor = const Color(0xFFC2410C);
                            }

                            return _buildPartnerDeliveryCard(
                              orderId: job.orderNumber,
                              category: job.itemDescription,
                              date: '${job.createdAt.day}/${job.createdAt.month}/${job.createdAt.year} at ${job.createdAt.hour.toString().padLeft(2, '0')}:${job.createdAt.minute.toString().padLeft(2, '0')}',
                              statusText: job.statusDisplay,
                              statusBg: statusBg,
                              statusColor: statusColor,
                              pickup: job.pickupAddress,
                              drop: job.dropAddress,
                              distanceTime: job.isDelivered
                                  ? '2.1 km • Delivered'
                                  : '2.1 km • ETA ${job.estimatedMinutes} min',
                              onTap: () => OrderBottomSheets.showRiderViewOrderDetails(job),
                            );
                          },
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
    const primaryGreen = Color(0xFF006837);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildPartnerDeliveryCard({
    required String orderId,
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
