import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'map_widget.dart';

class OrderBottomSheets {
  // Primary brand colors
  static const primaryBlue = Color(0xFF0F62FE);
  static const primaryGreen = Color(0xFF006837);

  // ---------------------------------------------------------------------------
  // 1. Customer – Create Order Flow (Step 1, Step 2 Pickup, Step 3 Drop)
  // ---------------------------------------------------------------------------

  /// Step 1: Create Order Form Bottom Sheet
  static void showCreateOrderForm(BuildContext context) {
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
                    icon: Icon(Icons.close_rounded, size: 22.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              Text(
                'Enter order details to create a new delivery',
                style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
              ),

              SizedBox(height: 18.h),

              // Order Name *
              RichText(
                text: TextSpan(
                  text: 'Order Name ',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: const Color(0xFF64748B), size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Food Delivery',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
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
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () {
                  Get.back();
                  showPickupMapSelection(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: const Color(0xFF64748B), size: 20.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Select pickup location',
                          style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF94A3B8)),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Use Current Location
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    showPickupMapSelection(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded, color: primaryBlue, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Use Current Location',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Drop Location *
              RichText(
                text: TextSpan(
                  text: 'Drop Location ',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  children: const [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () {
                  Get.back();
                  showDropMapSelection(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: const Color(0xFF64748B), size: 20.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Select drop location',
                          style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF94A3B8)),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Get.back();
                    showPickupMapSelection(context);
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
  static void showCustomerViewOrderDetails() {
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
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'On the way',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7)),
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
                          Text('ETA 12 min', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ],
                      ),
                      Text('2.8 km', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              Text('#ORD5678', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Text('Placed on 12 Apr, 10:24 AM', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),

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
                              Text('12, MG Road, Near City Mall, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
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
                              Text('21, New Market Rd, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
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
              _buildPersonDetailRow(
                roleLabel: 'Rider Details',
                name: 'Amit Kumar',
                phone: '+91 87654 32109',
                avatarBg: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF15803D),
              ),

              SizedBox(height: 20.h),

              // Track Live Outlined Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Get.back();
                    showOrderDetailsWithMap();
                  },
                  icon: Icon(Icons.location_searching_rounded, color: primaryBlue, size: 18.sp),
                  label: Text('Track Live', style: TextStyle(color: primaryBlue, fontSize: 14.5.sp, fontWeight: FontWeight.bold)),
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
  static void showRiderViewOrderDetails() {
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
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Picked Up',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
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
                          Text('ETA 8 min', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ],
                      ),
                      Text('2.1 km', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              Text('#ORD8765', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Text('Placed on 12 Apr, 09:15 AM', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),

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
                              Text('12, MG Road, Near City Mall, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
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
                              Text('21, New Market Rd, Bhopal', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
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
                          Text('Food Items (3)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text('Burger, Cold Coffee, French Fries', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Start Navigation Green Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Get.back();
                    showOrderDetailsWithMap();
                  },
                  icon: Icon(Icons.navigation_rounded, color: Colors.white, size: 18.sp),
                  label: Text('Start Navigation', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
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

  static void showPartnerOrderDetails({required VoidCallback onAccepted}) {
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
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)),
            ),
            SizedBox(height: 18.h),
            Container(
              width: 54.w,
              height: 54.h,
              decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  'go',
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text('Gofresh Delivery Services', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2024))),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.storefront_outlined, size: 20.sp, color: const Color(0xFF4B5563)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup Address (3.6 km - 9 mins)', style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text('23 Acme Rd, Ogba, Ikeja 100001, Lagos, Nigeria', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline_rounded, size: 20.sp, color: const Color(0xFF4B5563)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Drop off (5.1 km - 12 mins)', style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text('31 Ishola Bello St, Ojodu, Ikeja 101233, Lagos, Nigeria', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                ),
                onPressed: () {
                  Get.back();
                  onAccepted();
                },
                child: Text('Accept Order', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
  static void showOtpVerification({required VoidCallback onVerified}) {
    final List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
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
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Confirm Delivery (OTP)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Enter the 4-digit OTP provided by the customer', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 52.w,
                  height: 52.h,
                  child: TextField(
                    controller: controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
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
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                ),
                onPressed: () {
                  Get.back();
                  Get.snackbar('Order Completed', 'OTP Verified! Delivery marked as complete.', snackPosition: SnackPosition.BOTTOM, backgroundColor: primaryGreen, colorText: Colors.white);
                  onVerified();
                },
                child: Text('Confirm & Finish', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static void showCustomerOrderDetails() {
    showCustomerViewOrderDetails();
  }
}
