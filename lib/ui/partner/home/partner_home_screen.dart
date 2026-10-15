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
            // Top Header: Real Partner Profile & Logout
            Obx(() {
              final name = controller.firstNameGreeting;
              final email = controller.userEmail;
              final phone = controller.userPhone;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Avatar with first-letter initial
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            phone.isNotEmpty ? phone : email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Logout button
                    IconButton(
                      icon: Icon(Icons.logout_rounded,
                          color: Colors.white.withValues(alpha: 0.85), size: 22.sp),
                      onPressed: controller.confirmLogout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
              );
            }),

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
                        Obx(() {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Completed',
                                  value: '${controller.totalDeliveriesCount}',
                                  icon: Icons.check_circle_outline_rounded,
                                  iconBg: const Color(0xFFDCFCE7),
                                  iconColor: const Color(0xFF10B981),
                                  cardBg: const Color(0xFFF0FDF4),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Available Jobs',
                                  value: '${controller.availableOrdersCount}',
                                  icon: Icons.two_wheeler_outlined,
                                  iconBg: const Color(0xFFE0EDFF),
                                  iconColor: const Color(0xFF0F62FE),
                                  cardBg: const Color(0xFFEEF5FF),
                                ),
                              ),
                            ],
                          );
                        }),

                        SizedBox(height: 20.h),

                        // Active Order Card
                        _buildActiveOrderCard(context),

                        SizedBox(height: 24.h),

                        // Available / Recent Orders Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Deliveries',
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

                        // Reactive Deliveries List
                        Obx(() {
                          final jobs = controller.recentDeliveries;
                          if (jobs.isEmpty) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment_outlined, size: 36.sp, color: const Color(0xFF94A3B8)),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'No completed jobs yet',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Accept an available delivery above to start earning.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: jobs.take(5).map((job) {
                              Color statusBg;
                              Color statusColor;
                              if (job.isDelivered) {
                                statusBg = const Color(0xFFDCFCE7);
                                statusColor = const Color(0xFF15803D);
                              } else {
                                statusBg = const Color(0xFFE0F2FE);
                                statusColor = const Color(0xFF0284C7);
                              }

                              return InkWell(
                                onTap: () => OrderBottomSheets.showRiderViewOrderDetails(job),
                                borderRadius: BorderRadius.circular(16.r),
                                child: _buildOrderItem(
                                  icon: Icons.inventory_2_outlined,
                                  orderId: job.orderNumber,
                                  category: job.itemDescription,
                                  time: '${job.createdAt.hour.toString().padLeft(2, '0')}:${job.createdAt.minute.toString().padLeft(2, '0')}',
                                  statusText: job.statusDisplay,
                                  statusBg: statusBg,
                                  statusColor: statusColor,
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),

                    // Bottom "Go Online / Go Offline" Toggle Button
                    Positioned(
                      left: 16.w,
                      right: 16.w,
                      bottom: 18.h,
                      child: Obx(() {
                        final online = controller.isOnline.value;
                        return SizedBox(
                          height: 52.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  online ? const Color(0xFFDC2626) : primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            onPressed: () {
                              controller.toggleOnlineStatus();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  online
                                      ? Icons.sensors_off_rounded
                                      : Icons.sensors_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  online ? 'Go Offline' : 'Go Online',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
    const primaryGreen = Color(0xFF006837);

    return Obx(() {
      final active = controller.activeOrder.value;

      if (active == null) {
        if (!controller.isOnline.value) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFFEE2E2)),
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
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sensors_off_rounded,
                      color: const Color(0xFFDC2626), size: 30.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  'You are Offline',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tap "Go Online" below to start receiving real-time delivery orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        // If partner has no active job and is online:
        final available = controller.availableOrders;
        if (available.isNotEmpty) {
          return Column(
            children: available.map((order) {
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'New Delivery Request',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.delivery_dining_rounded,
                              color: primaryGreen, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderNumber,
                                style: TextStyle(
                                    fontSize: 15.sp, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${order.itemDescription} • from ${order.customerName}',
                                style: TextStyle(
                                    fontSize: 12.sp, color: const Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Pickup: ${order.pickupAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF334155)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Drop: ${order.dropAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => controller.acceptOrder(order),
                        child: Text(
                          'Accept Delivery Job',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
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
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.two_wheeler_rounded,
                    color: primaryGreen, size: 30.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                'Waiting for Orders',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'You are online. When a customer places a delivery nearby, it will appear here instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      }

      Color badgeBg;
      Color badgeColor;
      if (active.isAccepted) {
        badgeBg = const Color(0xFFE0EDFF);
        badgeColor = const Color(0xFF0F62FE);
      } else if (active.isPickedUp) {
        badgeBg = const Color(0xFFFFEDD5);
        badgeColor = const Color(0xFFC2410C);
      } else {
        badgeBg = const Color(0xFFE0F2FE);
        badgeColor = const Color(0xFF0284C7);
      }

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
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Active Delivery',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006837),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    active.statusDisplay,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
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
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.inventory_2_outlined,
                      color: primaryGreen, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active.orderNumber,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        active.itemDescription,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        Icon(Icons.access_time_rounded,
                            size: 14.sp, color: const Color(0xFF475569)),
                        SizedBox(width: 4.w),
                        Text(
                          'ETA ${active.estimatedMinutes} min',
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
                        Icon(Icons.near_me_outlined,
                            size: 13.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 2.w),
                        Text(
                          '3.4 km',
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
                Row(
                  children: [
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Container(
                        height: 3.5.h,
                        color: active.isPickedUp || active.isInTransit
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 3.5.h,
                        color: active.isInTransit
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    SizedBox(width: 24.w),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981), width: 2),
                      ),
                      child: Icon(Icons.trip_origin_rounded,
                          color: const Color(0xFF10B981), size: 18.sp),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: active.isPickedUp || active.isInTransit
                            ? primaryGreen
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.directions_bike_rounded,
                          color: Colors.white, size: 16.sp),
                    ),
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEF4444), width: 2),
                      ),
                      child: Icon(Icons.location_on_rounded,
                          color: const Color(0xFFEF4444), size: 18.sp),
                    ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A))),
                      Text(active.pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  children: [
                    Text(active.statusDisplay,
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen)),
                    Text('In Progress',
                        style: TextStyle(
                            fontSize: 10.sp, color: const Color(0xFF64748B))),
                  ],
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Destination',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A))),
                      Text(active.dropAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Customer Details Sub-card
            Container(
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
                    child: Icon(Icons.person_rounded,
                        size: 22.sp, color: const Color(0xFF15803D)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          active.customerName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          active.customerPhone.isNotEmpty
                              ? active.customerPhone
                              : '+91 98765 43210',
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
                    child: Icon(Icons.phone_rounded,
                        color: const Color(0xFF15803D), size: 16.sp),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF15803D), size: 16.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Action Progression Swipe Button for Partner
            if (active.isAccepted)
              _SwipeToActionButton(
                key: const ValueKey('accepted_swipe'),
                text: 'Slide to Mark Picked Up ➔',
                backgroundColor: const Color(0xFFC2410C),
                onSwipeComplete: () => controller.markPickedUp(active.id),
              )
            else if (active.isPickedUp)
              _SwipeToActionButton(
                key: const ValueKey('picked_up_swipe'),
                text: 'Slide to Start Delivery ➔',
                backgroundColor: const Color(0xFF0284C7),
                onSwipeComplete: () => controller.startTransit(active.id),
              )
            else if (active.isInTransit)
              _SwipeToActionButton(
                key: const ValueKey('in_transit_swipe'),
                text: 'Slide to Complete (Enter OTP) ➔',
                backgroundColor: primaryGreen,
                onSwipeComplete: () => OrderBottomSheets.showOtpVerification(
                  order: active,
                  onVerify: (otp) => controller.completeDelivery(
                      orderId: active.id, enteredOtp: otp),
                ),
              ),
          ],
        ),
      );
    });
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

/// Standalone Swipe-to-Act / Slide to Confirm Button Widget
class _SwipeToActionButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onSwipeComplete;

  const _SwipeToActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onSwipeComplete,
  });

  @override
  State<_SwipeToActionButton> createState() => _SwipeToActionButtonState();
}

class _SwipeToActionButtonState extends State<_SwipeToActionButton> {
  double _dragValue = 0.0;
  bool _isCompleted = false;

  @override
  void didUpdateWidget(covariant _SwipeToActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _dragValue = 0.0;
        _isCompleted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final thumbWidth = 46.w;
        final maxTravel = totalWidth - thumbWidth;

        return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: widget.backgroundColor, width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: thumbWidth + (_dragValue * maxTravel),
                height: 50.h,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _dragValue > 0.4 ? Colors.white : widget.backgroundColor,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                left: _dragValue * maxTravel,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragValue += details.delta.dx / maxTravel;
                      if (_dragValue < 0.0) _dragValue = 0.0;
                      if (_dragValue > 1.0) _dragValue = 1.0;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isCompleted) return;
                    if (_dragValue >= 0.75) {
                      setState(() {
                        _dragValue = 1.0;
                        _isCompleted = true;
                      });
                      widget.onSwipeComplete();
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbWidth,
                    height: 44.h,
                    margin: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.backgroundColor,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
