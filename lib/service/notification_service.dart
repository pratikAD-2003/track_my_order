import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'shared_pref_service.dart';

/// Top-level background message handler for FCM.
/// Invoked by Android OS / iOS when app is in background or terminated and an FCM message arrives.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  try {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: initSettings);

    const androidDetails = AndroidNotificationDetails(
      'delivery_updates_channel',
      'Order & Delivery Updates',
      channelDescription: 'Real-time notifications for order status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final title = message.notification?.title ?? message.data['title'] ?? 'Order Update';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    await plugin.show(
      id: (title.hashCode ^ body.hashCode).abs() % 100000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data['orderId'],
    );
  } catch (e) {
    debugPrint('[BGHandler] Local notification error: $e');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _rtdbBaseUrl = 'https://firestoreapp-a55a3-default-rtdb.firebaseio.com';
  static const String _projectId = 'firestoreapp-a55a3';

  /// Firebase Service Account credentials configuration for FCM HTTP v1 API.
  static final Map<String, String> _serviceAccountMap = {
    "type": "service_account",
    "project_id": "firestoreapp-a55a3",
    "private_key_id": "0bfc43272f15b2c585fce2cceb2772ce97e13a15",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQDHy86esE6Yr7DK\nrEc+ha6k1CZ+r24MGC4GIKJX7CFDJupY6bn83wlU/6l/6Ab/u2Mf+1aF9ANyBT5m\n2u+j1Ijb257jfr1LH57oih5nYWINzM3rInYYDrrflEjrSsxW14YVMK/twLD9jrBk\nNfO9hN95+CCjDXSkzy0XWSmEZ8CJF5mojN81o5d4gSNJjD417jsY47RWf/oBjEcs\n/1WdVQUYdGHT9AVHaOblraU6094t/9mLbSsjED0fSsRYElxGsAgHjpg9O1KR4+XL\nJ4LD0kBuAMwctFc1MChfw+QFRoUieYNKT3/iT8gCictavANk+CDtDVl9zKq8s0ys\nwo090PyfAgMBAAECgf9rs3GuGVxE8nBa0IOXMHj0YWhe4jJwUph8tRrOSnujt1ac\nl2Gq7pAZQbgdOvaK5HiKxPHfQ6qXzDvXNi34Ipmj6r+74pYn6OPAdrPtBpHU3pIi\nLnF6hnY2D7k/HRMJvSSKR7SOdVDzXfe4DV1WzEmrdhYhzx8RuJyV+Xpn5YXkX98J\nEuSas9r05HVbc0MSBPtH4MoYeKtnN8fEGvNaIHFqmSXLggOVhhmS5/fnoxewpId1\nKNYdUmreDJF5fT1DFbySSZB1auiEOUWvdTh3XYDxFqw2t46i0qV0zT/5h6kPXfuj\nwvnDyoSxwvl1MPCuSsp77PgV1Yq4zwLqN8odKcECgYEA/YpVRbZ7PiNGUJL4ShfU\nn4T8CliIYbhKLcw7llSavuf+PKbXYy2RiTDaYz9/Wq1oHp2Q/AP/+QgTL/eTK/xA\n0uS6SxJpNW9QQTSINpakHpb0LDmyV4Qi49ha6phpws+rOfm3I0B88WuEb25bnzzC\nDYTHC7tQSZVM7Zr7nBoXP28CgYEAybwAFIdUBKHBeTTkbZYoWhfgHQ4t0+GVPKd4\nNwPyTnUFy2dCFszJHJj86yTfpiRUioLX7a93KcS6e0ohHFisbWz83HqfWJ6fKlJ8\nOcQ1m7SPMeBuBJoWBPBRZ0oGP1+9gs82wa896D11RxxNGjEOPn00xHbK+/LOwAvJ\nWGhzfdECgYEAv1z+uYxe/upu8vfK8VmFQRWFimWCIoePbXu96dxXpAnESZD/9rp5\nI1w9KTXO8Oj7MkhpGt4GALeIi+bILSXK46KBvZHa2Nr4bw6wVMtkejYje5HcutNf\n5irxjCmXgdNugGarRK8y3qDxJ43bF5grOzrhZUhu8+r9UkVs7UiADX8CgYAOiP8w\ne3ewRb9c7lSvGKyboTDCpyziIVTRY/ejbyNcR849E5mNbv/mkZdXkfaTT/bPbBIG\nzCe32Lbe/z5XfoQd9kZZ1HP6vKMXN44/00VRjLbsjxEeP8PqYy5aVNkSY+GRtUBq\nwCejvhnfH8jmZDZ0hizxIuYJNTt0VuUQ+6WmoQKBgHHs3lyDCJXo6kTL8nIJWrdk\ntdBDWpvoYivOkUJ3DnhwMQJ2dLAmRs4yKuZ1gPPCNpDBrCDSw0I6oBjRxLN0KT8w\nW88ubjHMjDZytNqJzV7xbwul3gWN6wbKeA9rn3fsXqb0zY0bADRWaC2EczC/0Yzg\nsGI0c27I3N3slTtn5fxg\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-q9e2j@firestoreapp-a55a3.iam.gserviceaccount.com",
    "client_id": "117119256117807819518",
  };

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxInt unreadCount = 0.obs;
  final RxList<Map<String, dynamic>> notificationHistory = <Map<String, dynamic>>[].obs;

  bool _isInitialized = false;
  HttpClient? _notifSseClient;
  String? _listeningCustomerId;
  final Set<String> _processedNotifIds = <String>{};

  // ── OAuth2 Token Generation for FCM v1 ────────────────────────────────────

  static Future<String?> _getFcmAccessToken() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(_serviceAccountMap);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(credentials, scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      debugPrint('[NotificationService] FCM v1 OAuth2 Token generation error: $e');
      return null;
    }
  }

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      await _requestPermissions();

      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      const androidChannel = AndroidNotificationChannel(
        'delivery_updates_channel',
        'Order & Delivery Updates',
        description: 'Real-time notifications for order status, rider updates, and OTPs',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title'] ?? 'Order Update';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        showNotification(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
        );
      });

      await saveDeviceToken();

      _fcm.onTokenRefresh.listen((newToken) {
        _syncTokenToBackends(newToken);
      });
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('[NotificationService] Permission request warning: $e');
    }
  }

  Future<String?> saveDeviceToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await _syncTokenToBackends(token);
        return token;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error getting FCM token: $e');
    }
    return null;
  }

  /// Syncs FCM token for a given user ID and role.
  /// Stops old listeners and clears in-memory notification state.
  Future<void> syncTokenForUid(String uid, {String? role}) async {
    if (uid.isEmpty) return;
    try {
      // 1. Stop any old listener from previous user session
      clearListening();

      // 2. Clear previous user's notification history in memory
      notificationHistory.clear();
      unreadCount.value = 0;
      _processedNotifIds.clear();

      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;

      // 3. Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Save to RTDB
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$uid.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 5));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'token': token, 'updatedAt': DateTime.now().millisecondsSinceEpoch}));
      final resp = await req.close().timeout(const Duration(seconds: 5));
      await resp.drain();
      client.close();

      debugPrint('[NS] ✅ FCM token synced for $role (uid=$uid)');
    } catch (e) {
      debugPrint('[NS] syncTokenForUid error: $e');
    }

    // 5. Only start SSE customer notification listener if role is 'customer'
    final userRole = role ?? SharedPrefService.getUserRole();
    if (userRole == 'customer') {
      startListeningCustomerNotifications(uid);
    }
  }

  /// Clears notification listeners, in-memory state, and FCM token records on user logout
  Future<void> clearSessionOnLogout(String oldUid) async {
    // 1. Stop active real-time SSE listener
    clearListening();

    // 2. Reset in-memory badge and notification list
    unreadCount.value = 0;
    notificationHistory.clear();
    _processedNotifIds.clear();

    // 3. Delete FCM token from RTDB mapping for old UID
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$oldUid.json');
      final req = await client.deleteUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
      debugPrint('[NS] 🗑️ Cleared RTDB FCM token for logged-out user: $oldUid');
    } catch (e) {
      debugPrint('[NS] Warning clearing RTDB token on logout: $e');
    }

    // 4. Remove FCM token field from Firestore user document
    try {
      await FirebaseFirestore.instance.collection('users').doc(oldUid).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (_) {}
  }

  Future<void> _syncTokenToBackends(String token) async {
    final uid = SharedPrefService.getUid();
    final role = SharedPrefService.getUserRole();
    if (uid == null || uid.isEmpty) return;

    try {
      await syncTokenForUid(uid, role: role);
    } catch (e) {
      debugPrint('[NotificationService] Token sync warning: $e');
    }
  }

  // ── Show Notification ──────────────────────────────────────────────────────

  final Map<String, DateTime> _recentShownNotifications = {};

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Color bannerColor = const Color(0xFF0F62FE),
  }) async {
    final now = DateTime.now();
    final dedupeKey = '$title::$body';
    if (_recentShownNotifications.containsKey(dedupeKey)) {
      final prevTime = _recentShownNotifications[dedupeKey]!;
      if (now.difference(prevTime).inSeconds < 5) {
        return;
      }
    }
    _recentShownNotifications[dedupeKey] = now;
    _recentShownNotifications.removeWhere((_, time) => now.difference(time).inSeconds > 15);

    final id = (title.hashCode ^ body.hashCode).abs() % 100000;

    try {
      final androidDetails = AndroidNotificationDetails(
        'delivery_updates_channel',
        'Order & Delivery Updates',
        channelDescription: 'Real-time notifications for order status, rider updates, and OTPs',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF0F62FE),
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[NotificationService] Local notification warning: $e');
    }
  }

  // ── Dispatch Notification From Rider to Customer ──────────────────────────

  Future<void> sendOrderStatusNotification({
    required String customerId,
    required String orderId,
    required String orderNumber,
    required String newStatus,
    String? partnerName,
    String? otp,
  }) async {
    String title;
    String body;
    Color color;

    switch (newStatus) {
      case 'accepted':
        title = '🛵 Delivery Partner Assigned!';
        body = '${partnerName ?? "A partner"} has accepted order $orderNumber and is heading to the pickup point.';
        color = const Color(0xFF0F62FE);
        break;
      case 'picked_up':
        title = '📦 Package Picked Up!';
        body = 'Your order $orderNumber has been picked up from merchant and will be on its way shortly.';
        color = const Color(0xFFC2410C);
        break;
      case 'in_transit':
        title = '🚀 Out for Delivery!';
        body = 'Rider is on the way with order $orderNumber! Please have your OTP ${otp != null ? "($otp)" : ""} ready.';
        color = const Color(0xFF0284C7);
        break;
      case 'delivered':
        title = '🎉 Order Delivered!';
        body = 'Order $orderNumber was successfully delivered. Thank you for using Track My Order!';
        color = const Color(0xFF10B981);
        break;
      case 'cancelled':
        title = '❌ Order Cancelled';
        body = 'Your delivery order $orderNumber has been cancelled.';
        color = const Color(0xFFDC2626);
        break;
      default:
        title = 'Order Status Update';
        body = 'Order $orderNumber status changed to $newStatus.';
        color = const Color(0xFF0F62FE);
    }

    final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final notifData = {
      'id': notifId,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'status': newStatus,
      'title': title,
      'body': body,
      'colorHex': color.toARGB32(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'read': false,
    };

    // 1. Write to RTDB customer notification channel
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId/$notifId.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 4));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(notifData));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
      debugPrint('[NotificationService] Notification $notifId queued in RTDB for customer $customerId');
    } catch (e) {
      debugPrint('[NotificationService] Error queuing notification in RTDB: $e');
    }

    // 2. Fire high-priority FCM v1 push to customer device token
    try {
      final customerToken = await _fetchCustomerFcmToken(customerId);
      if (customerToken != null && customerToken.isNotEmpty) {
        await _sendFcmPush(
          deviceToken: customerToken,
          title: title,
          body: body,
          data: {
            'orderId': orderId,
            'orderNumber': orderNumber,
            'status': newStatus,
            'notifId': notifId,
            'colorHex': color.toARGB32().toString(),
            'title': title,
            'body': body,
          },
        );
      } else {
        debugPrint('[NotificationService] No FCM token found for customer $customerId');
      }
    } catch (e) {
      debugPrint('[NotificationService] FCM push attempt error: $e');
    }

    // 3. Write to Firestore for persistent history
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .collection('notifications')
          .doc(notifId)
          .set(notifData);
    } catch (_) {}
  }

  // ── FCM REST API Helpers ──────────────────────────────────────────────────

  Future<String?> _fetchCustomerFcmToken(String customerId) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$customerId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final bodyStr = await resp.transform(utf8.decoder).join();
      client.close();
      if (bodyStr.isEmpty || bodyStr == 'null') return null;
      final parsed = jsonDecode(bodyStr);
      if (parsed is Map) return parsed['token']?.toString();
    } catch (e) {
      debugPrint('[NotificationService] Error fetching FCM token: $e');
    }
    return null;
  }

  Future<void> _sendFcmPush({
    required String deviceToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final client = HttpClient();
    try {
      final accessToken = await _getFcmAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        final url = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
        final req = await client.postUrl(Uri.parse(url)).timeout(const Duration(seconds: 8));
        req.headers.contentType = ContentType.json;
        req.headers.set('Authorization', 'Bearer $accessToken');

        final payload = {
          'message': {
            'token': deviceToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data.map((k, v) => MapEntry(k, v.toString())),
            'android': {
              'priority': 'HIGH',
              'notification': {
                'channel_id': 'delivery_updates_channel',
                'notification_priority': 'PRIORITY_MAX',
                'sound': 'default',
                'default_vibrate_timings': true,
                'default_sound': true,
                'visibility': 'PUBLIC',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
            'apns': {
              'headers': {'apns-priority': '10'},
              'payload': {
                'aps': {
                  'alert': {'title': title, 'body': body},
                  'sound': 'default',
                  'badge': 1,
                  'content-available': 1,
                },
              },
            },
          },
        };

        req.write(jsonEncode(payload));
        final resp = await req.close().timeout(const Duration(seconds: 8));
        final respBody = await resp.transform(utf8.decoder).join();

        if (resp.statusCode == 200) {
          debugPrint('[NotificationService] FCM v1 push delivered successfully to $deviceToken');
        } else {
          debugPrint('[NotificationService] FCM v1 Push status ${resp.statusCode}: $respBody');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] FCM v1 push request error: $e');
    } finally {
      client.close();
    }
  }

  // ── Customer Notification Listener ───────────────────────────────────────

  void startListeningCustomerNotifications(String customerId) {
    if (_listeningCustomerId == customerId && _notifSseClient != null) return;
    _listeningCustomerId = customerId;
    _notifSseClient?.close(force: true);

    _fetchCustomerNotificationHistory(customerId);
    _startCustomerNotificationSse(customerId);
  }

  Future<void> _fetchCustomerNotificationHistory(String customerId) async {
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final body = await resp.transform(utf8.decoder).join();
      client.close();

      if (body.isEmpty || body == 'null') return;
      final parsed = jsonDecode(body);
      if (parsed is Map) {
        final list = <Map<String, dynamic>>[];
        int unread = 0;
        parsed.forEach((k, v) {
          if (v is Map) {
            final map = Map<String, dynamic>.from(v);
            list.add(map);
            if (map['read'] == false) unread++;
            _processedNotifIds.add(k.toString());
          }
        });
        list.sort((a, b) => (b['timestamp'] as num? ?? 0).compareTo(a['timestamp'] as num? ?? 0));
        notificationHistory.assignAll(list);
        unreadCount.value = unread;
      }
    } catch (_) {}
  }

  Future<void> _startCustomerNotificationSse(String customerId) async {
    while (_listeningCustomerId == customerId) {
      try {
        _notifSseClient?.close(force: true);
        _notifSseClient = HttpClient();
        final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
        final request = await _notifSseClient!.getUrl(url).timeout(const Duration(seconds: 10));
        request.headers.set('Accept', 'text/event-stream');
        final response = await request.close().timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        String currentEvent = '';
        await for (final line in response.transform(utf8.decoder).transform(const LineSplitter())) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          if (trimmed.startsWith('event:')) {
            currentEvent = trimmed.substring(6).trim();
            continue;
          }

          if (trimmed.startsWith('data:')) {
            final jsonStr = trimmed.substring(5).trim();
            if (jsonStr == 'null' || jsonStr.isEmpty) continue;

            try {
              final parsed = jsonDecode(jsonStr);
              if (parsed is Map) {
                final path = parsed['path']?.toString() ?? '';
                final data = parsed['data'];
                _handleIncomingNotificationEvent(currentEvent, path, data);
              }
            } catch (e) {
              debugPrint('[NotificationService] SSE notif parse error: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('[NotificationService] Notification SSE error ($e), reconnecting in 2s...');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _handleIncomingNotificationEvent(String event, String path, dynamic data) {
    if (data is! Map) return;

    if (path == '/' || path.isEmpty) {
      data.forEach((k, v) {
        if (v is Map) {
          _processedNotifIds.add(k.toString());
        }
      });
      return;
    }

    final clean = path.startsWith('/') ? path.substring(1) : path;
    final parts = clean.split('/');
    final notifId = parts[0];

    if (!_processedNotifIds.contains(notifId)) {
      _processedNotifIds.add(notifId);

      final title = data['title']?.toString() ?? 'Order Update';
      final body = data['body']?.toString() ?? '';
      final colorVal = data['colorHex'] is num ? (data['colorHex'] as num).toInt() : 0xFF0F62FE;

      unreadCount.value++;
      notificationHistory.insert(0, Map<String, dynamic>.from(data));

      showNotification(
        title: title,
        body: body,
        bannerColor: Color(colorVal),
      );
    }
  }

  void clearListening() {
    _listeningCustomerId = null;
    _notifSseClient?.close(force: true);
  }

  void markAllRead([String? customerId]) {
    unreadCount.value = 0;
    final updated = notificationHistory.map((n) {
      return {...n, 'read': true};
    }).toList();
    notificationHistory.assignAll(updated);

    final uid = customerId ?? _listeningCustomerId ?? SharedPrefService.getUid() ?? '';
    if (uid.isEmpty) return;

    // Persist read status in RTDB
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$uid.json');
      client.getUrl(url).then((req) => req.close()).then((resp) => resp.transform(utf8.decoder).join()).then((bodyStr) {
        if (bodyStr.isNotEmpty && bodyStr != 'null') {
          final parsed = jsonDecode(bodyStr);
          if (parsed is Map) {
            final patchClient = HttpClient();
            final patchUrl = Uri.parse('$_rtdbBaseUrl/notifications/$uid.json');
            final patchMap = <String, dynamic>{};
            parsed.forEach((k, v) {
              if (v is Map) {
                patchMap['$k/read'] = true;
              }
            });
            patchClient.patchUrl(patchUrl).then((req) {
              req.headers.contentType = ContentType.json;
              req.write(jsonEncode(patchMap));
              return req.close();
            }).then((resp) => resp.drain()).catchError((_) {});
          }
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  Future<void> refreshNotificationHistory(String customerId) async {
    await _fetchCustomerNotificationHistory(customerId);
  }

  Future<void> clearAllNotifications(String customerId) async {
    notificationHistory.clear();
    unreadCount.value = 0;
    _processedNotifIds.clear();
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/notifications/$customerId.json');
      final req = await client.deleteUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();
    } catch (e) {
      debugPrint('[NotificationService] Clear notifications warning: $e');
    }
  }
}
