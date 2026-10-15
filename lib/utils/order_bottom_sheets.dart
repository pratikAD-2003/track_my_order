import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../models/place_location.dart';
import '../service/dialog_service.dart';
import '../service/places_service.dart';
import '../ui/customer/home/customer_home_controller.dart';
import '../ui/location/select_location_screen.dart';

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
    String? initialPickup,
    String? initialDrop,
    Future<bool> Function({
      required String name,
      required String pickup,
      required String drop,
    })? onCreateOrder,
  }) {
    final nameController = TextEditingController(text: 'Food Delivery');
    final pickupController = TextEditingController(
      text: initialPickup ?? 'Fetching current location...',
    );
    final dropController = TextEditingController(
      text: initialDrop ?? '',
    );
    final isSubmitting = false.obs;

    PlaceLocation? selectedPickupLoc;
    PlaceLocation? selectedDropLoc;

    // Initially always auto-fetch device current location for pickup if not provided
    if (initialPickup == null || initialPickup.isEmpty) {
      PlacesService().getCurrentLocation().then((loc) {
        if (loc != null) {
          selectedPickupLoc = loc;
          pickupController.text = loc.address;
        } else if (pickupController.text == 'Fetching current location...') {
          pickupController.text = 'Current Location';
        }
      });
    }

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

              // Helper callback to open SelectLocationScreen
              Builder(
                builder: (ctx) {
                  Future<void> openSelectLocationScreen({bool focusDrop = false}) async {
                    final result = await Navigator.push<dynamic>(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => SelectLocationScreen(
                          initialPickupAddress: pickupController.text,
                          initialDropAddress: dropController.text,
                          focusDrop: focusDrop,
                        ),
                      ),
                    );

                    if (result is Map) {
                      final p = result['pickup'] as PlaceLocation?;
                      final d = result['drop'] as PlaceLocation?;
                      if (p != null) {
                        selectedPickupLoc = p;
                        pickupController.text = p.address;
                      }
                      if (d != null) {
                        selectedDropLoc = d;
                        dropController.text = d.address;
                      }
                    }
                  }

                  return AnimatedBuilder(
                    animation: Listenable.merge([pickupController, dropController]),
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup Location *
                          RichText(
                            text: TextSpan(
                              text: 'Pickup Location ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              children: const [
                                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => openSelectLocationScreen(focusDrop: false),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.trip_origin_rounded, color: const Color(0xFF10B981), size: 18.sp),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      pickupController.text.isNotEmpty
                                          ? pickupController.text
                                          : 'Select pickup location',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: pickupController.text.isNotEmpty
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.my_location_rounded, color: const Color(0xFF10B981), size: 20.sp),
                                ],
                              ),
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
                                color: const Color(0xFF0F172A),
                              ),
                              children: const [
                                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () => openSelectLocationScreen(focusDrop: true),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: 18.sp),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      dropController.text.isNotEmpty
                                          ? dropController.text
                                          : 'Select drop destination',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: dropController.text.isNotEmpty
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.location_on_outlined, color: const Color(0xFFEF4444), size: 20.sp),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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
                              DialogService.showToast(message: 'Please fill in all fields.', isWarning: true);
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
                                  pickupLocation: selectedPickupLoc,
                                  dropLocation: selectedDropLoc,
                                  pickupAddress: pickup,
                                  dropAddress: drop,
                                );
                              } catch (_) {
                                success = false;
                              }
                            }
                            isSubmitting.value = false;

                            if (success) {
                              if (Get.isBottomSheetOpen == true) {
                                Get.back(closeOverlays: true);
                              } else {
                                Get.back();
                              }
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
                              color: Colors.white,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Customer – View Order Details Bottom Sheet
  // ---------------------------------------------------------------------------
  static void showCustomerViewOrderDetails(OrderModel order) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details (${order.orderNumber})',
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
              Divider(height: 20.h, color: const Color(0xFFE2E8F0)),

              // Item Description
              Text(
                'Item / Package',
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3.h),
              Text(
                order.itemDescription,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 14.h),

              // Route Details
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 10.r, height: 10.r, decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
                        SizedBox(width: 10.w),
                        Expanded(child: Text(order.pickupAddress, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500))),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(width: 2.w, height: 24.h, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 10.r, height: 10.r, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2.r))),
                        SizedBox(width: 10.w),
                        Expanded(child: Text(order.dropAddress, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // OTP & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery OTP', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      Text(order.otp, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 2)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Status', style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      Text(order.statusDisplay, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: primaryGreen)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Partner / Rider – View Order Details Bottom Sheet
  // ---------------------------------------------------------------------------
  static void showRiderViewOrderDetails(OrderModel order) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Job (${order.orderNumber})',
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
              Divider(height: 20.h, color: const Color(0xFFE2E8F0)),

              Text(
                'Customer & Item',
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                '${order.customerName} (${order.customerPhone})',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 2.h),
              Text(
                order.itemDescription,
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF475569)),
              ),
              SizedBox(height: 14.h),

              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 10.r, height: 10.r, decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
                        SizedBox(width: 10.w),
                        Expanded(child: Text(order.pickupAddress, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500))),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(width: 2.w, height: 24.h, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 10.r, height: 10.r, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2.r))),
                        SizedBox(width: 10.w),
                        Expanded(child: Text(order.dropAddress, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Partner / Rider – OTP Verification Bottom Sheet (4 Fields)
  // ---------------------------------------------------------------------------
  static void showOtpVerification({
    required OrderModel order,
    required Future<bool> Function(String otp) onVerify,
  }) {
    final List<TextEditingController> controllers =
        List.generate(4, (_) => TextEditingController());
    final List<FocusNode> focusNodes =
        List.generate(4, (_) => FocusNode());
    final isVerifying = false.obs;

    void clearAllBoxes() {
      for (final c in controllers) {
        c.clear();
      }
      focusNodes[0].requestFocus();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verify Delivery OTP',
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
              'Ask customer for the 4-digit delivery OTP for order ${order.orderNumber}',
              style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 20.h),

            // 4 Separate OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 58.w,
                  height: 64.h,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: primaryGreen, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (index < 3) {
                          focusNodes[index + 1].requestFocus();
                        } else {
                          focusNodes[index].unfocus();
                        }
                      } else {
                        if (index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                onPressed: isVerifying.value
                    ? null
                    : () async {
                        final code = controllers.map((c) => c.text.trim()).join();
                        if (code.length != 4) {
                          DialogService.showToast(message: 'Please enter all 4 digits of the OTP.', isWarning: true);
                          return;
                        }
                        isVerifying.value = true;
                        final success = await onVerify(code);
                        isVerifying.value = false;
                        if (success) {
                          if (Get.isBottomSheetOpen == true) {
                            Get.back(closeOverlays: true);
                          } else {
                            Get.back();
                          }
                        }
                      },
                child: isVerifying.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Verify & Finish Delivery',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
              ),
            )),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
