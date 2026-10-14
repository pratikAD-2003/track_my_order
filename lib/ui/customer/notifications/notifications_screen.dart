import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _primary = Color(0xFF0F62FE);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _NotifHeader(controller: controller),

          // ── List ────────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final list = controller.notifications as List;
              if (list.isEmpty) {
                return _EmptyState();
              }

              return RefreshIndicator(
                color: _primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  controller.onInit();
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index] as Map<String, dynamic>;
                    return _NotifCard(
                      item: item,
                      onDismiss: () => controller.deleteNotification(index),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _NotifHeader extends StatelessWidget {
  final NotificationsController controller;
  const _NotifHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F62FE), Color(0xFF0043CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 20.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20.sp),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Obx(() => Text(
                          '${controller.notifications.length} total',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        )),
                  ],
                ),
              ),
              Obx(() {
                if ((controller.notifications as List).isEmpty) {
                  return const SizedBox.shrink();
                }
                return TextButton.icon(
                  onPressed: () => _showClearDialog(controller),
                  icon: Icon(Icons.delete_sweep_rounded,
                      color: Colors.white.withValues(alpha: 0.9), size: 18.sp),
                  label: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(NotificationsController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Clear All Notifications?'),
        content: const Text('This will remove all notification history permanently.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.back();
              controller.clearAll();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDismiss;

  const _NotifCard({required this.item, required this.onDismiss});

  Color get _accentColor {
    final val = item['colorHex'];
    if (val is num) return Color(val.toInt());
    return const Color(0xFF0F62FE);
  }

  IconData get _icon {
    final status = item['status']?.toString() ?? '';
    switch (status) {
      case 'accepted':
        return Icons.delivery_dining_rounded;
      case 'picked_up':
        return Icons.inventory_2_rounded;
      case 'in_transit':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatTime(dynamic ts) {
    if (ts is! num) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title']?.toString() ?? 'Order Update';
    final body = item['body']?.toString() ?? '';
    final time = _formatTime(item['timestamp']);
    final isUnread = item['read'] == false;

    return Dismissible(
      key: Key(item['id']?.toString() ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isUnread
              ? Border.all(color: _accentColor.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_icon, color: _accentColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: _accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 11.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 4.w),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        if (item['orderNumber'] != null) ...[
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '#${item['orderNumber']}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: _accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 56.sp,
              color: const Color(0xFF93C5FD),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'You will receive live alerts here when your order status changes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
