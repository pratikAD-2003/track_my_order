import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'select_location_controller.dart';

class SelectLocationScreen extends StatefulWidget {
  final String? initialPickupAddress;
  final String? initialDropAddress;
  final bool focusDrop;

  const SelectLocationScreen({
    super.key,
    this.initialPickupAddress,
    this.initialDropAddress,
    this.focusDrop = false,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  static const Color primaryBlue = Color(0xFF0F62FE);
  static const Color pickupGreen = Color(0xFF10B981);
  static const Color dropRed = Color(0xFFEF4444);
  static const Color uberDark = Color(0xFF0F172A);

  late final SelectLocationController controller;

  @override
  void initState() {
    super.initState();
    Get.delete<SelectLocationController>(force: true);
    controller = Get.put(SelectLocationController());
    controller.initFromParams(
      initialPickup: widget.initialPickupAddress,
      initialDrop: widget.initialDropAddress,
      focusDrop: widget.focusDrop,
    );
  }

  @override
  void dispose() {
    Get.delete<SelectLocationController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: uberDark, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Pickup & Drop',
          style: TextStyle(
            color: uberDark,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 1. Uber-style Dual Location Input Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Left Route Timeline Indicators
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: const BoxDecoration(
                        color: pickupGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 36.h,
                      color: const Color(0xFF94A3B8),
                    ),
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: dropRed,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 12.w),

                // Middle TextFields
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pickup Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.pickupTextController,
                              focusNode: controller.pickupFocusNode,
                              onChanged: controller.onSearchChanged,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: uberDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Pickup location',
                                hintStyle: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                              ),
                            ),
                          ),
                          Obx(() {
                            final hasPickup = controller.pickupLocation.value != null || controller.pickupTextController.text.isNotEmpty;
                            if (hasPickup) {
                              return GestureDetector(
                                onTap: controller.clearPickup,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4.w),
                                  child: Icon(Icons.cancel_rounded,
                                      size: 18.sp, color: const Color(0xFF94A3B8)),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),

                      Divider(height: 14.h, thickness: 1, color: const Color(0xFFE2E8F0)),

                      // Drop Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.dropTextController,
                              focusNode: controller.dropFocusNode,
                              onChanged: controller.onSearchChanged,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: uberDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Where to? (Drop location)',
                                hintStyle: TextStyle(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                              ),
                            ),
                          ),
                          Obx(() {
                            final hasDrop = controller.dropLocation.value != null || controller.dropTextController.text.isNotEmpty;
                            if (hasDrop) {
                              return GestureDetector(
                                onTap: controller.clearDrop,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4.w),
                                  child: Icon(Icons.cancel_rounded,
                                      size: 18.sp, color: const Color(0xFF94A3B8)),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Right Swap Button
                GestureDetector(
                  onTap: controller.swapLocations,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 20.sp,
                      color: uberDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Action Shortcuts: "Set on Map" & "Use Current Location"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                // Set on Map Button (Uber Style)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      final isPickup = controller.isPickupFocused.value;
                      controller.openMapPicker(isPickup: isPickup);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 18.sp, color: uberDark),
                          SizedBox(width: 6.w),
                          Text(
                            'Set on map',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: uberDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Current Location Button
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: controller.useCurrentLocation,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            if (controller.isFetchingGps.value) {
                              return SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            return Icon(Icons.my_location_rounded, size: 18.sp, color: primaryBlue);
                          }),
                          SizedBox(width: 6.w),
                          Text(
                            'Current location',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),
          Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9)),

          // 3. Search Predictions List or Recent Suggestions
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Searching places...',
                        style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                );
              }

              final results = controller.predictions;
              if (results.isEmpty) {
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  children: [
                    // Quick Map Picker Row
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.pin_drop_rounded, size: 20.sp, color: uberDark),
                      ),
                      title: Text(
                        'Choose on Map',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: uberDark),
                      ),
                      subtitle: Text(
                        'Pinpoint exact location on interactive map',
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 22.sp),
                      onTap: () => controller.openMapPicker(isPickup: controller.isPickupFocused.value),
                    ),
                    Divider(height: 16.h, color: const Color(0xFFF1F5F9)),

                    // Current Location Row
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.navigation_rounded, size: 20.sp, color: primaryBlue),
                      ),
                      title: Text(
                        'Use Current GPS Location',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: uberDark),
                      ),
                      subtitle: Text(
                        'Fast location detection via GPS sensor',
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 22.sp),
                      onTap: controller.useCurrentLocation,
                    ),
                  ],
                );
              }

              return ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFFF1F5F9),
                  indent: 52.w,
                ),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on_outlined, size: 20.sp, color: const Color(0xFF475569)),
                    ),
                    title: Text(
                      item.mainText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: uberDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.secondaryText.isNotEmpty ? item.secondaryText : item.fullText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => controller.selectPrediction(item),
                  );
                },
              );
            }),
          ),

          // 4. Sticky Bottom Action Bar (Shows when ready to confirm)
          Obx(() {
            final hasPickup = controller.pickupLocation.value != null;
            final hasDrop = controller.dropLocation.value != null;

            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: (hasPickup && hasDrop) ? controller.confirmLocations : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: uberDark,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      (hasPickup && hasDrop)
                          ? 'Confirm Locations'
                          : (!hasPickup ? 'Select Pickup Location' : 'Select Drop Location'),
                      style: TextStyle(
                        color: (hasPickup && hasDrop) ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
