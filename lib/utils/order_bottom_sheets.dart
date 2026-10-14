import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../ui/customer/home/customer_home_controller.dart';
import 'map_widget.dart';

class OrderBottomSheets {
  // Primary brand colors
  static const primaryBlue = Color(0xFF0F62FE);
  static const primaryGreen = Color(0xFF006837);

  // ---------------------------------------------------------------------------
  // 1. Customer – Create Order Flow (Step 1, Step 2 Pickup, Step 3 Drop)
  // ---------------------------------------------------------------------------

  /// Step 1: Create Order Form Bottom Sheet
  static void showCreateOrderForm(
    BuildContext context, {
    Future<bool> Function({
      required String name,
      required String pickup,
      required String drop,
    })? onCreateOrder,
  }) {
    final nameController = TextEditingController(text: 'Food Delivery');
    final pickupController =
        TextEditingController(text: '12, MG Road, Near City Mall, Bhopal');
    final dropController =
        TextEditingController(text: '21, New Market Rd, Bhopal');
    final isSubmitting = false.obs;

    final categories = ['Food Delivery', 'Documents', 'Grocery', 'Pharmacy'];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title & Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Order',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded,
                        size: 22.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                'Enter order details to create a new delivery',
                style: TextStyle(
                    fontSize: 12.5.sp, color: const Color(0xFF64748B)),
              ),

              SizedBox(height: 14.h),

              // Category Preset Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ActionChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        backgroundColor: const Color(0xFFEEF5FF),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r)),
                        onPressed: () {
                          nameController.text = cat;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 12.h),

              // Order Name *
              RichText(
                text: TextSpan(
                  text: 'Order Name / Item ',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: const Color(0xFF64748B), size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Food Delivery, Urgent Docs',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Pickup Location *
              RichText(
                text: TextSpan(
                  text: 'Pickup Location ',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: const Color(0xFF10B981), size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: pickupController,
                        decoration: const InputDecoration(
                          hintText: 'Enter pickup address',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.map_outlined,
                          color: primaryBlue, size: 20.sp),
                      tooltip: 'Pick on map',
                      onPressed: () {
                        Get.back();
                        showPickupMapSelection(context);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Drop Location *
              RichText(
                text: TextSpan(
                  text: 'Drop Location ',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: const Color(0xFFEF4444), size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: dropController,
                        decoration: const InputDecoration(
                          hintText: 'Enter drop destination',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.map_outlined,
                          color: primaryBlue, size: 20.sp),
                      tooltip: 'Pick on map',
                      onPressed: () {
                        Get.back();
                        showDropMapSelection(context);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              // Place Delivery Order Button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: isSubmitting.value
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final pickup = pickupController.text.trim();
                            final drop = dropController.text.trim();

                            if (name.isEmpty ||
                                pickup.isEmpty ||
                                drop.isEmpty) {
                              Get.snackbar(
                                  'Missing Details', 'Please fill in all fields.');
                              return;
                            }

                            isSubmitting.value = true;
                            bool success = false;
                            if (onCreateOrder != null) {
                              success = await onCreateOrder(
                                  name: name, pickup: pickup, drop: drop);
                            } else {
                              try {
                                final controller =
                                    Get.find<CustomerHomeController>();
                                success = await controller.createOrder(
                                  itemDescription: name,
                                  pickupAddress: pickup,
                                  dropAddress: drop,
                                );
                              } catch (_) {
                                success = false;
                              }
                            }
                            isSubmitting.value = false;

                            if (success) {
                              Get.back();
                            }
                          },
                    child: isSubmitting.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Place Delivery Order',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Step 2: Select Pickup Location Map + Bottom Sheet
  static void showPickupMapSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Stack(
            children: [
              InteractiveMapWidget(
                title: 'Select Pickup Location',
                searchHint: 'Search for pickup location',
                pickupLabel: 'Pickup Location\nTap to set',
              ),
              // Overlay Bottom Sheet for Selected Location
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 22.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selected Location', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                                SizedBox(height: 2.h),
                                Text(
                                  '12, MG Road, Near City Mall, Bhopal',
                                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Change', style: TextStyle(color: primaryBlue, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showDropMapSelection(context);
                          },
                          child: Text('Confirm Pickup', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
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
    );
  }

  /// Step 3: Select Drop Location Map + Bottom Sheet
  static void showDropMapSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Stack(
            children: [
              InteractiveMapWidget(
                title: 'Select Drop Location',
                searchHint: 'Search for drop location',
                showRoute: true,
                showDropPin: true,
                pickupLabel: 'Pickup Location',
                dropLabel: 'Drop Location\nTap to set',
              ),
              // Overlay Bottom Sheet for Drop Location
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 22.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selected Location', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                                SizedBox(height: 2.h),
                                Text(
                                  '21, New Market Rd, Bhopal',
                                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Change', style: TextStyle(color: primaryBlue, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showCustomerViewOrderDetails();
                          },
                          child: Text('Create Order', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
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
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Order Details Bottom Sheet (Customer View, Rider View, & With Map View)
  // ---------------------------------------------------------------------------

  /// Customer View Order Details Bottom Sheet
  static void showCustomerViewOrderDetails([OrderModel? order]) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded,
                        size: 22.sp, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    'Order Details',
                    style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A)),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.more_vert_rounded,
                        color: const Color(0xFF64748B), size: 22.sp),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Status Badge & ETA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: order?.isDelivered == true
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      order != null ? order.statusDisplay : 'On the way',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: order?.isDelivered == true
                            ? const Color(0xFF15803D)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14.sp, color: primaryBlue),
                          SizedBox(width: 4.w),
                          Text(
                            order != null
                                ? 'ETA ${order.estimatedMinutes} min'
                                : 'ETA 12 min',
                            style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue),
                          ),
                        ],
                      ),
                      Text('2.8 km',
                          style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              Text(
                order?.orderNumber ?? '#ORD5678',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A)),
              ),
              Text(
                order != null
                    ? '${order.itemDescription} • Placed on ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}'
                    : 'Placed on 12 Apr, 10:24 AM',
                style: TextStyle(
                    fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              ),

              SizedBox(height: 14.h),

              // Customer Delivery OTP Card
              if (order != null && !order.isDelivered)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.key_rounded,
                            color: primaryBlue, size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Confirmation OTP',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF1E40AF),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Share with rider upon arrival',
                              style: TextStyle(
                                  fontSize: 10.5.sp,
                                  color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          order.otp,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Pickup & Drop Box
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: const Color(0xFF10B981), size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Location',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A))),
                              Text(
                                  order?.pickupAddress ??
                                      '12, MG Road, Near City Mall, Bhopal',
                                  style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 8.w, top: 4.h, bottom: 4.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            width: 1.5,
                            height: 16.h,
                            color: const Color(0xFFCBD5E1)),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: const Color(0xFFEF4444), size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Drop Location',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A))),
                              Text(
                                  order?.dropAddress ??
                                      '21, New Market Rd, Bhopal',
                                  style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Rider Details
              if (order?.partnerName != null && order!.partnerName!.isNotEmpty)
                _buildPersonDetailRow(
                  roleLabel: 'Rider Details',
                  name: order.partnerName!,
                  phone: order.partnerPhone?.isNotEmpty == true
                      ? order.partnerPhone!
                      : '+91 87654 32109',
                  avatarBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF15803D),
                )
              else
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.two_wheeler_rounded,
                            color: const Color(0xFFD97706), size: 20.sp),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Looking for nearby rider...',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A))),
                            Text('A delivery partner will accept soon',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 20.h),

              // Close / Done Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text('Close',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Rider View Order Details Bottom Sheet
  static void showRiderViewOrderDetails([OrderModel? order]) {
    Color statusBg = const Color(0xFFDCFCE7);
    Color statusColor = const Color(0xFF15803D);
    if (order != null) {
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
        statusBg = const Color(0xFFFFEDD5);
        statusColor = const Color(0xFFC2410C);
      }
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, size: 22.sp, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    'Order Details',
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  Icon(Icons.more_vert_rounded, color: const Color(0xFF64748B), size: 22.sp),
                ],
              ),

              SizedBox(height: 12.h),

              // Status Badge & ETA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      order?.statusDisplay ?? 'Picked Up',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 14.sp, color: primaryBlue),
                          SizedBox(width: 4.w),
                          Text(
                            order != null
                                ? (order.isDelivered ? 'Delivered' : 'ETA ${order.estimatedMinutes} min')
                                : 'ETA 8 min',
                            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: primaryBlue),
                          ),
                        ],
                      ),
                      Text('2.1 km', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              Text(order?.orderNumber ?? '#ORD8765', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Text(
                order != null
                    ? '${order.itemDescription} • Placed at ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}'
                    : 'Placed on 12 Apr, 09:15 AM',
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              ),

              SizedBox(height: 16.h),

              // Pickup & Drop Box
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Location', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text(order?.pickupAddress ?? '12, MG Road, Near City Mall, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.w, top: 4.h, bottom: 4.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(width: 1.5, height: 16.h, color: const Color(0xFFCBD5E1)),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Drop Location', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text(order?.dropAddress ?? '21, New Market Rd, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Order Items Section
              Text('Order Items', style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: const Color(0xFF64748B), size: 22.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order?.itemDescription ?? 'Package Details', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text('Standard parcel handling', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Close / Back button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text('Close', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Order Details With Map Preview View
  static void showOrderDetailsWithMap() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Order ID & Badge & Close
              Row(
                children: [
                  Text('#ORD8765', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12.r)),
                    child: Text('Picked Up', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close_rounded, size: 20.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Embedded Map View Box
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  height: 160.h,
                  width: double.infinity,
                  child: InteractiveMapWidget(
                    showRoute: true,
                    showDropPin: true,
                    pickupLabel: 'Pickup',
                    dropLabel: 'Drop',
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Pickup & Drop horizontal timeline
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: const Color(0xFF10B981), size: 18.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text('12, MG Road\n10:25 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_right_alt_rounded, color: const Color(0xFF94A3B8), size: 22.sp),
                  Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 18.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Drop', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text('21, New Market Rd\n10:48 AM', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              const Divider(color: Color(0xFFF1F5F9)),

              // Rider Row
              Row(
                children: [
                  CircleAvatar(radius: 16.r, backgroundColor: const Color(0xFFDCFCE7), child: Icon(Icons.person_rounded, size: 18.sp, color: const Color(0xFF15803D))),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rider', style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF64748B))),
                        Text('Amit Kumar', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text('+91 87654 32109', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                    child: Icon(Icons.phone_rounded, color: const Color(0xFF15803D), size: 16.sp),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // Order Items Row
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 20.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Items', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                          Text('Food Items (3) • Burger, Cold Coffee...', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // View Route on Map Button
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0EDFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    Get.back();
                    showCustomerViewOrderDetails();
                  },
                  icon: Icon(Icons.map_rounded, color: primaryBlue, size: 18.sp),
                  label: Text('View Route on Map', style: TextStyle(color: primaryBlue, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Helper Person Detail Row with Call & Chat buttons
  static Widget _buildPersonDetailRow({
    required String roleLabel,
    required String name,
    required String phone,
    required Color avatarBg,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: avatarBg,
            child: Icon(Icons.person_rounded, size: 22.sp, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roleLabel, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                Text(name, style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Text(phone, style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Icon(Icons.phone_rounded, color: iconColor, size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded, color: iconColor, size: 16.sp),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Incoming Order Request Bottom Sheet (Partner / Rider)
  // ---------------------------------------------------------------------------

  static void showPartnerOrderDetails({
    OrderModel? order,
    required VoidCallback onAccepted,
  }) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 18.h),
            Container(
              width: 54.w,
              height: 54.h,
              decoration: const BoxDecoration(
                  color: primaryGreen, shape: BoxShape.circle),
              child: Center(
                child: Icon(Icons.delivery_dining_rounded,
                    color: Colors.white, size: 28.sp),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              order?.itemDescription ?? 'Delivery Order',
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2024)),
            ),
            Text(
              order?.orderNumber ?? '#ORD8765',
              style: TextStyle(fontSize: 13.sp, color: primaryGreen, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.storefront_outlined,
                    size: 20.sp, color: const Color(0xFF4B5563)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup Address',
                          style: TextStyle(
                              fontSize: 13.5.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text(
                          order?.pickupAddress ??
                              '23 Acme Rd, Ogba, Ikeja 100001, Lagos, Nigeria',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 20.sp, color: const Color(0xFF4B5563)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Drop off • ${order?.customerName ?? 'Customer'} (${order?.customerPhone ?? ''})',
                          style: TextStyle(
                              fontSize: 13.5.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text(
                          order?.dropAddress ??
                              '31 Ishola Bello St, Ojodu, Ikeja 101233, Lagos, Nigeria',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r)),
                ),
                onPressed: () {
                  Get.back();
                  onAccepted();
                },
                child: Text('Accept Order',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// OTP Verification Bottom Sheet
  static void showOtpVerification({
    OrderModel? order,
    required Future<bool> Function(String otp) onVerify,
  }) {
    final List<TextEditingController> controllers =
        List.generate(4, (_) => TextEditingController());
    final isVerifying = false.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Confirm Delivery (OTP)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text(
                'Enter the 4-digit OTP provided by ${order?.customerName ?? 'the customer'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp, color: const Color(0xFF6B7280))),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 54.w,
                  height: 54.h,
                  child: TextField(
                    controller: controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 3) {
                        FocusManager.instance.primaryFocus?.nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() {
              return SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r)),
                  ),
                  onPressed: isVerifying.value
                      ? null
                      : () async {
                          final enteredOtp =
                              controllers.map((c) => c.text).join();
                          if (enteredOtp.length < 4) {
                            Get.snackbar('Incomplete OTP',
                                'Please enter all 4 digits of the OTP.',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          isVerifying.value = true;
                          final success = await onVerify(enteredOtp);
                          isVerifying.value = false;
                          if (success) {
                            Get.back();
                          }
                        },
                  child: isVerifying.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Verify & Finish Delivery',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold)),
                ),
              );
            }),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void showCustomerOrderDetails([OrderModel? order]) {
    showCustomerViewOrderDetails(order);
  }
}
