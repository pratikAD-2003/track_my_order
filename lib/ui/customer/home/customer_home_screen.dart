import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/order_model.dart';
import '../../../route/app_routes.dart';
import '../../../utils/order_bottom_sheets.dart';
import 'customer_home_controller.dart';

class CustomerHomeScreen extends GetView<CustomerHomeController> {
  const CustomerHomeScreen({super.key});

  static const primaryBlue = Color(0xFF0F62FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: Real User Profile & Logout
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
                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
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

                    SizedBox(width: 2.w),
                    // Notification Bell with Live Unread Badge
                    GestureDetector(
                      onTap: controller.showNotificationSheet,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                          Obx(() {
                            final count = controller
                                .notificationService
                                .unreadCount
                                .value;
                            if (count <= 0) return const SizedBox.shrink();
                            return Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: EdgeInsets.all(3.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.w,
                                  minHeight: 16.h,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Logout button
                    IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 22.sp,
                      ),
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
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28.r),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildShimmerLoading();
                    }
                    return Stack(
                    children: [
                      RefreshIndicator(
                        color: primaryBlue,
                        backgroundColor: Colors.white,
                        onRefresh: controller.refreshOrders,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 90.h),
                          children: [
                            // Stat Cards Row
                            Obx(() {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Total Orders',
                                      value: '${controller.totalOrdersCount}',
                                      icon: Icons.assignment_outlined,
                                      iconBg: const Color(0xFFE0EDFF),
                                      iconColor: primaryBlue,
                                      cardBg: const Color(0xFFEEF5FF),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Active Orders',
                                      value: '${controller.activeOrdersCount}',
                                      icon: Icons.local_shipping_outlined,
                                      iconBg: const Color(0xFFDCFCE7),
                                      iconColor: const Color(0xFF10B981),
                                      cardBg: const Color(0xFFF0FDF4),
                                    ),
                                  ),
                                ],
                              );
                            }),

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
                                  onTap: () =>
                                      Get.toNamed(AppRoutes.customerMyOrders),
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
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18.sp,
                                        color: primaryBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Reactive Recent Orders List
                            Obx(() {
                              final orders = controller.recentOrders;
                              if (orders.isEmpty) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 24.h,
                                    horizontal: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 36.sp,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'No orders yet',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Place your first delivery by tapping the (+) button below.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: orders.take(5).map((order) {
                                  Color statusBg;
                                  Color statusColor;
                                  if (order.isCancelled) {
                                    statusBg = const Color(0xFFFEE2E2);
                                    statusColor = const Color(0xFFDC2626);
                                  } else if (order.isDelivered) {
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
                                    statusColor = const Color(0xFF0369A1);
                                  }

                                  return InkWell(
                                    onTap: () =>
                                        OrderBottomSheets.showCustomerViewOrderDetails(
                                          order,
                                        ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: _buildOrderItem(
                                      icon: Icons.inventory_2_outlined,
                                      orderId: order.orderNumber,
                                      category: order.itemDescription,
                                      time:
                                          '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                                      statusText: order.statusDisplay,
                                      statusBg: statusBg,
                                      statusColor: statusColor,
                                    ),
                                  );
                                }).toList(),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Floating Action Button (+) Opens Create Order Sheet directly
                      Positioned(
                        right: 16.w,
                        bottom: 24.h,
                        child: FloatingActionButton(
                          onPressed: () =>
                              OrderBottomSheets.showCreateOrderForm(
                                context,
                                onCreateOrder:
                                    ({
                                      required name,
                                      required pickup,
                                      required drop,
                                    }) => controller.createOrder(
                                      itemDescription: name,
                                      pickupAddress: pickup,
                                      dropAddress: drop,
                                    ),
                              ),
                          backgroundColor: primaryBlue,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 90.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: 130.w,
            height: 16.h,
            margin: EdgeInsets.only(right: 180.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                height: 76.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
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
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
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
    return Obx(() {
      final order = controller.activeOrder.value;

      if (order == null) {
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
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: primaryBlue,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'No Active Delivery',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Ready to send a package? Create a new delivery order to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 40.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => OrderBottomSheets.showCreateOrderForm(
                    context,
                    onCreateOrder:
                        ({required name, required pickup, required drop}) =>
                            controller.createOrder(
                              itemDescription: name,
                              pickupAddress: pickup,
                              dropAddress: drop,
                            ),
                  ),
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  label: Text(
                    'Create Delivery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      Color badgeBg;
      Color badgeColor;
      if (order.isPending) {
        badgeBg = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFD97706);
      } else if (order.isAccepted) {
        badgeBg = const Color(0xFFE0EDFF);
        badgeColor = primaryBlue;
      } else if (order.isPickedUp) {
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Active Order, LIVE badge, and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Active Order',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Track Rider Button (shown only when rider is assigned)
            if (order.partnerId != null &&
                order.partnerId!.isNotEmpty &&
                !order.isPending) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.toNamed(
                    AppRoutes.customerLiveTracking,
                    arguments: order,
                  ),
                  icon: Icon(
                    Icons.directions_bike_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  label: Text(
                    'Track Rider',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
            ],

            // Order Description and ETA Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EDFF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: primaryBlue,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order.itemDescription,
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
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: primaryBlue,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          order.estimatedMinutes <= 0 ? 'ETA Arriving' : 'ETA ${order.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // 4-Step Interactive Stepper Pipeline
            _buildDeliveryStepper(order),

            SizedBox(height: 16.h),

            // Pickup & Drop Addresses Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2.h),
                        width: 10.w,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Location',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              order.pickupAddress,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        SizedBox(width: 4.w),
                        Container(
                          width: 2.w,
                          height: 14.h,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.sp,
                        color: const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Destination',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              order.dropAddress,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Customer OTP Banner Card
            Container(
              margin: EdgeInsets.only(top: 14.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      color: primaryBlue,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Confirmation OTP',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF1E40AF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Give this code to rider upon arrival',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      order.otp,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // Rider Details Sub-card
            InkWell(
              onTap: () =>
                  OrderBottomSheets.showCustomerViewOrderDetails(order),
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: order.partnerName != null
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFEFF6FF),
                      child: Icon(
                        order.partnerName != null
                            ? Icons.directions_bike_rounded
                            : Icons.search_rounded,
                        size: 22.sp,
                        color: order.partnerName != null
                            ? const Color(0xFF15803D)
                            : primaryBlue,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.partnerName != null
                                ? order.partnerName!
                                : 'Searching for nearby rider...',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            order.partnerName != null
                                ? '${order.partnerVehicle ?? "Motorcycle"} • ${order.partnerPhone ?? ""}'
                                : 'A partner will accept your request soon',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.partnerName != null &&
                        (order.partnerPhone?.isNotEmpty == true))
                      IconButton(
                        icon: Icon(
                          Icons.phone_in_talk_rounded,
                          color: primaryBlue,
                          size: 22.sp,
                        ),
                        onPressed: () {
                          Get.snackbar(
                            'Rider Contact',
                            '${order.partnerName}: ${order.partnerPhone}',
                            backgroundColor: primaryBlue,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        tooltip: 'Call Rider',
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                  ],
                ),
              ),
            ),

            // Cancel button: only allowed when order is pending
            if (order.isPending) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                    ),
                    onPressed: () => controller.cancelOrder(order.id),
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 16.sp,
                      color: const Color(0xFFDC2626),
                    ),
                    label: Text(
                      'Cancel Request',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  /// 4-Step Interactive Stepper Pipeline
  Widget _buildDeliveryStepper(OrderModel order) {
    int currentStep = 0;
    if (order.isAccepted) currentStep = 1;
    if (order.isPickedUp) currentStep = 2;
    if (order.isInTransit) currentStep = 3;
    if (order.isDelivered) currentStep = 4;

    final steps = [
      {'title': 'Placed', 'icon': Icons.receipt_long_rounded},
      {'title': 'Assigned', 'icon': Icons.person_pin_circle_rounded},
      {'title': 'Picked Up', 'icon': Icons.inventory_2_rounded},
      {'title': 'In Transit', 'icon': Icons.directions_bike_rounded},
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Connecting line
              final stepBefore = index ~/ 2;
              final isLineActive = currentStep > stepBefore;
              return Expanded(
                child: Container(
                  height: 3.h,
                  color: isLineActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE2E8F0),
                ),
              );
            }

            final stepIndex = index ~/ 2;
            final isCompleted = currentStep > stepIndex;
            final isCurrent = currentStep == stepIndex;

            Color circleBg;
            Color iconColor;
            IconData iconData = steps[stepIndex]['icon'] as IconData;

            if (isCompleted) {
              circleBg = const Color(0xFF10B981);
              iconColor = Colors.white;
              iconData = Icons.check_rounded;
            } else if (isCurrent) {
              circleBg = primaryBlue;
              iconColor = Colors.white;
            } else {
              circleBg = const Color(0xFFF1F5F9);
              iconColor = const Color(0xFF94A3B8);
            }

            return Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: const Color(0xFF93C5FD), width: 3.w)
                    : null,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(iconData, color: iconColor, size: 16.sp),
            );
          }),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = currentStep > index;
            final isCurrent = currentStep == index;
            return SizedBox(
              width: 60.w,
              child: Text(
                steps[index]['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isCurrent || isCompleted
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isCurrent
                      ? primaryBlue
                      : (isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8)),
                ),
              ),
            );
          }),
        ),
      ],
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
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFFCBD5E1),
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}
