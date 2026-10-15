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
/// Called by Android/iOS when app is background or terminated.
/// NOTE: Do NOT show a local notification here — Android automatically shows
/// FCM messages that contain a 'notification' payload in the system tray.
/// Showing one manually here causes DOUBLE notifications.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('[BGHandler] FCM received in background: ${message.notification?.title}');
  // Android OS displays the notification automatically from the FCM 'notification' payload.
  // No manual local notification needed.
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _rtdbBaseUrl = 'https://firestoreapp-a55a3-default-rtdb.firebaseio.com';
  static const String _fcmV1Url =
      'https://fcm.googleapis.com/v1/projects/firestoreapp-a55a3/messages:send';

  /// Service account for FCM v1 API OAuth2 authentication.
  /// FCM Legacy API was shut down by Google — v1 is mandatory.
  static const _serviceAccount = {
    'type': 'service_account',
    'project_id': 'firestoreapp-a55a3',
    'private_key_id': '0bfc43272f15b2c585fce2cceb2772ce97e13a15',
    'private_key':
        '-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQDHy86esE6Yr7DK\nrEc+ha6k1CZ+r24MGC4GIKJX7CFDJupY6bn83wlU/6l/6Ab/u2Mf+1aF9ANyBT5m\n2u+j1Ijb257jfr1LH57oih5nYWINzM3rInYYDrrflEjrSsxW14YVMK/twLD9jrBk\nNfO9hN95+CCjDXSkzy0XWSmEZ8CJF5mojN81o5d4gSNJjD417jsY47RWf/oBjEcs\n/1WdVQUYdGHT9AVHaOblraU6094t/9mLbSsjED0fSsRYElxGsAgHjpg9O1KR4+XL\nJ4LD0kBuAMwctFc1MChfw+QFRoUieYNKT3/iT8gCictavANk+CDtDVl9zKq8s0ys\nwo090PyfAgMBAAECgf9rs3GuGVxE8nBa0IOXMHj0YWhe4jJwUph8tRrOSnujt1ac\nl2Gq7pAZQbgdOvaK5HiKxPHfQ6qXzDvXNi34Ipmj6r+74pYn6OPAdrPtBpHU3pIi\nLnF6hnY2D7k/HRMJvSSKR7SOdVDzXfe4DV1WzEmrdhYhzx8RuJyV+Xpn5YXkX98J\nEuSas9r05HVbc0MSBPtH4MoYeKtnN8fEGvNaIHFqmSXLggOVhhmS5/fnoxewpId1\nKNYdUmreDJF5fT1DFbySSZB1auiEOUWvdTh3XYDxFqw2t46i0qV0zT/5h6kPXfuj\nwvnDyoSxwvl1MPCuSsp77PgV1Yq4zwLqN8odKcECgYEA/YpVRbZ7PiNGUJL4ShfU\nn4T8CliIYbhKLcw7llSavuf+PKbXYy2RiTDaYz9/Wq1oHp2Q/AP/+QgTL/eTK/xA\n0uS6SxJpNW9QQTSINpakHpb0LDmyV4Qi49ha6phpws+rOfm3I0B88WuEb25bnzzC\nDYTHC7tQSZVM7Zr7nBoXP28CgYEAybwAFIdUBKHBeTTkbZYoWhfgHQ4t0+GVPKd4\nNwPyTnUFy2dCFszJHJj86yTfpiRUioLX7a93KcS6e0ohHFisbWz83HqfWJ6fKlJ8\nOcQ1m7SPMeBuBJoWBPBRZ0oGP1+9gs82wa896D11RxxNGjEOPn00xHbK+/LOwAvJ\nWGhzfdECgYEAv1z+uYxe/upu8vfK8VmFQRWFimWCIoePbXu96dxXpAnESZD/9rp5\nI1w9KTXO8Oj7MkhpGt4GALeIi+bILSXK46KBvZHa2Nr4bw6wVMtkejYje5HcutNf\n5irxjCmXgdNugGarRK8y3qDxJ43bF5grOzrhZUhu8+r9UkVs7UiADX8CgYAOiP8w\ne3ewRb9c7lSvGKyboTDCpyziIVTRY/ejbyNcR849E5mNbv/mkZdXkfaTT/bPbBIG\nzCe32Lbe/z5XfoQd9kZZ1HP6vKMXN44/00VRjLbsjxEeP8PqYy5aVNkSY+GRtUBq\nwCejvhnfH8jmZDZ0hizxIuYJNTt0VuUQ+6WmoQKBgHHs3lyDCJXo6kTL8nIJWrdk\ntdBDWpvoYivOkUJ3DnhwMQJ2dLAmRs4yKuZ1gPPCNpDBrCDSw0I6oBjRxLN0KT8w\nW88ubjHMjDZytNqJzV7xbwul3gWN6wbKeA9rn3fsXqb0zY0bADRWaC2EczC/0Yzg\nsGI0c27I3N3slTtn5fxg\n-----END PRIVATE KEY-----\n',
    'client_email': 'firebase-adminsdk-q9e2j@firestoreapp-a55a3.iam.gserviceaccount.com',
    'client_id': '117119256117807819518',
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
  };

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final RxInt unreadCount = 0.obs;
  final RxList<Map<String, dynamic>> notificationHistory = <Map<String, dynamic>>[].obs;

  bool _isInitialized = false;
  HttpClient? _notifSseClient;
  String? _listeningCustomerId;
  final Set<String> _processedNotifIds = <String>{};


  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Request OS notification permissions
      await _requestPermissions();

      // 2. Configure Foreground Notification Presentation
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Initialize Local Notifications Plugin
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

      // 4. Create high-importance Android channel for heads-up alerts
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

      // 5. Configure FCM Foreground Listener
      // In foreground, Android does not display system tray notifications automatically.
      // Display the single heads-up notification via local notifications.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NS] Foreground FCM push received: ${message.notification?.title}');
        final notif = message.notification;
        if (notif != null) {
          showNotification(
            title: notif.title ?? 'Order Update',
            body: notif.body ?? '',
            payload: message.data['orderId'],
          );
        }
      });

      // 6. Retrieve and save device FCM token
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

  /// Retrieves and stores the device FCM token in Firestore and RTDB.
  /// Called at app start — may fail if user not logged in yet (UID unknown).
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

  /// Call this AFTER login/signup when the UID is known.
  /// Guarantees the FCM token is registered so push notifications reach this device.
  Future<void> syncTokenForUid(String uid) async {
    if (uid.isEmpty) return;
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;
      debugPrint('[NS] syncTokenForUid: saving FCM token for $uid');

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to RTDB
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$uid.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 5));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'token': token, 'updatedAt': DateTime.now().millisecondsSinceEpoch}));
      final resp = await req.close().timeout(const Duration(seconds: 5));
      await resp.drain();
      client.close();

      debugPrint('[NS] ✅ FCM token synced for uid=$uid token=${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('[NS] syncTokenForUid error: $e');
    }
  }

  Future<void> _syncTokenToBackends(String token) async {
    final uid = SharedPrefService.getUid();
    if (uid == null || uid.isEmpty) return;

    try {
      // 1. Sync to Firestore user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Sync to RTDB for instant access by delivery partner
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$uid.json');
      final req = await client.putUrl(url).timeout(const Duration(seconds: 4));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'token': token,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      await resp.drain();
      client.close();

      debugPrint('[NotificationService] FCM token synced for user: $uid');
    } catch (e) {
      debugPrint('[NotificationService] Token sync warning: $e');
    }
  }

  // ── Show Notification ──────────────────────────────────────────────────────
  // Always fires a system OS heads-up notification regardless of app state.
  // If app is in foreground, flutter_local_notifications shows it as a heads-up banner.

  final Map<String, DateTime> _recentShownNotifications = {};

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Color bannerColor = const Color(0xFF0F62FE),
  }) async {
    // 1. Deduplication guard: ignore exact duplicate notifications within 5 seconds
    final now = DateTime.now();
    final dedupeKey = '$title::$body';
    if (_recentShownNotifications.containsKey(dedupeKey)) {
      final prevTime = _recentShownNotifications[dedupeKey]!;
      if (now.difference(prevTime).inSeconds < 5) {
        debugPrint('[NS] ⚡ Suppressed duplicate notification within 5s: $title');
        return;
      }
    }
    _recentShownNotifications[dedupeKey] = now;
    _recentShownNotifications.removeWhere((_, time) => now.difference(time).inSeconds > 15);

    // Deterministic ID so even if identical messages arrive, they overwrite rather than duplicate
    final id = (title.hashCode ^ body.hashCode).abs() % 100000;

    // Always show OS system notification (heads-up in foreground, tray in background)
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
        fullScreenIntent: false,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
      debugPrint('[NS] Local system notification shown: $title');
    } catch (e) {
      debugPrint('[NS] Local notification error: $e');
    }
  }

  // ── Dispatch Notification From Rider to Customer ──────────────────────────

  /// Dispatches an order status change notification from the rider directly to the customer.
  /// Writes to RTDB notification queue and triggers high-priority FCM push.
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

    // 1. Write to RTDB customer notification channel (Triggers real-time SSE listener in customer app)
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

  // ── FCM Token Fetch ──────────────────────────────────────────────────

  /// Fetches FCM token for a customer: tries Firestore first (authenticated),
  /// then falls back to RTDB.
  Future<String?> _fetchCustomerFcmToken(String customerId) async {
    // 1. Firestore (most reliable — authenticated SDK)
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId)
          .get()
          .timeout(const Duration(seconds: 5));
      final token = doc.data()?['fcmToken']?.toString();
      if (token != null && token.isNotEmpty) {
        debugPrint('[NS] FCM token fetched from Firestore ✓ (${token.substring(0, 20)}...)');
        return token;
      }
      debugPrint('[NS] FCM token not found in Firestore for $customerId');
    } catch (e) {
      debugPrint('[NS] Firestore token fetch failed: $e');
    }

    // 2. RTDB fallback
    try {
      final client = HttpClient();
      final url = Uri.parse('$_rtdbBaseUrl/user_fcm_tokens/$customerId.json');
      final req = await client.getUrl(url).timeout(const Duration(seconds: 4));
      final resp = await req.close().timeout(const Duration(seconds: 4));
      final bodyStr = await resp.transform(utf8.decoder).join();
      client.close();
      debugPrint('[NS] RTDB token response for $customerId: $bodyStr');
      if (bodyStr.isEmpty || bodyStr == 'null') return null;
      final parsed = jsonDecode(bodyStr);
      if (parsed is Map) {
        final token = parsed['token']?.toString();
        if (token != null && token.isNotEmpty) {
          debugPrint('[NS] FCM token fetched from RTDB ✓');
          return token;
        }
      }
    } catch (e) {
      debugPrint('[NS] RTDB token fetch failed: $e');
    }

    debugPrint('[NS] ❌ No FCM token found for customer $customerId in Firestore or RTDB');
    return null;
  }

  // ── FCM v1 Push ────────────────────────────────────────────────────

  /// Gets an OAuth2 access token from the service account for FCM v1 API.
  Future<String?> _getFcmAccessToken() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(_serviceAccount);
      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await clientViaServiceAccount(credentials, scopes)
          .timeout(const Duration(seconds: 15));
      final token = authClient.credentials.accessToken.data;
      authClient.close();
      debugPrint('[NS] OAuth2 access token obtained (${token.substring(0, 20)}...)');
      return token;
    } catch (e) {
      debugPrint('[NS] ❌ OAuth2 token error: $e');
      return null;
    }
  }

  /// Sends a real FCM push via the FCM v1 REST API.
  /// Delivers to device OS even when app is background or terminated.
  Future<void> _sendFcmPush({
    required String deviceToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // 1. Get OAuth2 bearer token
    final accessToken = await _getFcmAccessToken();
    if (accessToken == null) {
      debugPrint('[NS] ❌ Cannot send FCM push: failed to get OAuth2 token');
      return;
    }

    // 2. POST to FCM v1
    final client = HttpClient();
    try {
      final req = await client
          .postUrl(Uri.parse(_fcmV1Url))
          .timeout(const Duration(seconds: 10));
      req.headers.contentType = ContentType.json;
      req.headers.set('Authorization', 'Bearer $accessToken');

      req.write(jsonEncode({
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
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'tag': 'order_${data['orderId'] ?? 'status'}',
            },
          },
        },
      }));

      final resp = await req.close().timeout(const Duration(seconds: 10));
      final respBody = await resp.transform(utf8.decoder).join();

      if (resp.statusCode == 200) {
        debugPrint('[NS] ✅ FCM v1 push delivered! token=${deviceToken.substring(0, 15)}...');
      } else {
        debugPrint('[NS] ❌ FCM v1 error ${resp.statusCode}: $respBody');
      }
    } catch (e) {
      debugPrint('[NS] FCM v1 push exception: $e');
    } finally {
      client.close();
    }
  }

  // ── Customer Notification Listener (Real-Time Influx) ─────────────────────

  /// Subscribes to real-time notification events for the customer
  void startListeningCustomerNotifications(String customerId) {
    if (_listeningCustomerId == customerId && _notifSseClient != null) return;
    _listeningCustomerId = customerId;
    _notifSseClient?.close(force: true);

    // Initial fetch of unread count & history
    _fetchCustomerNotificationHistory(customerId);

    // Listen continuously via SSE on notifications/$customerId.json
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
      // Full dump
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

    // Check if this is a newly arrived notification that we haven't shown yet
    if (!_processedNotifIds.contains(notifId)) {
      _processedNotifIds.add(notifId);

      // Increment badge and store in history for in-app notification center
      unreadCount.value++;
      notificationHistory.insert(0, Map<String, dynamic>.from(data));
      // NOTE: Do NOT call showNotification() here.
      // FCM push is the single source of truth for heads-up / system tray notifications.
    }
  }

  void clearListening() {
    _listeningCustomerId = null;
    _notifSseClient?.close(force: true);
  }

  // ── Notification Management Helpers ──────────────────────────────────────

  /// Marks all notifications in history as read and resets badge counter.
  void markAllRead() {
    unreadCount.value = 0;
    final updated = notificationHistory.map((n) {
      return {...n, 'read': true};
    }).toList();
    notificationHistory.assignAll(updated);
  }

  /// Re-fetches notification history from RTDB for the given customer.
  Future<void> refreshNotificationHistory(String customerId) async {
    await _fetchCustomerNotificationHistory(customerId);
  }

  /// Deletes all notifications from RTDB for the given customer.
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
