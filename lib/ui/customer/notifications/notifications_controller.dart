import 'package:get/get.dart';
import '../../../service/notification_service.dart';
import '../../../service/shared_pref_service.dart';

class NotificationsController extends GetxController {
  final notificationService = NotificationService();

  // Expose reactive list & unread count from shared singleton
  RxList<Map<String, dynamic>> get notifications => notificationService.notificationHistory;
  RxInt get unreadCount => notificationService.unreadCount;

  @override
  void onInit() {
    super.onInit();
    // Mark all as read when screen opens
    _markAllRead();

    // Refresh history from RTDB
    final uid = SharedPrefService.getUid() ?? '';
    if (uid.isNotEmpty) {
      notificationService.refreshNotificationHistory(uid);
    }
  }

  void _markAllRead() {
    notificationService.markAllRead();
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
    }
  }

  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    final uid = SharedPrefService.getUid() ?? '';
    if (uid.isNotEmpty) {
      notificationService.clearAllNotifications(uid);
    }
  }
}
