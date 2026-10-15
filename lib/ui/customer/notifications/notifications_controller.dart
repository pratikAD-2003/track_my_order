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
    final uid = SharedPrefService.getUid() ?? '';
    _markAllRead(uid);

    if (uid.isNotEmpty) {
      notificationService.refreshNotificationHistory(uid);
    }
  }

  void _markAllRead(String uid) {
    notificationService.markAllRead(uid);
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
