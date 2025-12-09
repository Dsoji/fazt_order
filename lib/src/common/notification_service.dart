import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.d('📱 Background message received: ${message.notification?.title}');
  logger.d('📱 Message data: ${message.data}');

  // Show notification using AwesomeNotifications
  if (message.notification != null) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'high_importance_channel',
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}

class NotificationService {
  static final _logger = Logger();

  static Future<void> initializeFCM() async {
    // Step 1: Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      'resource://drawable/notify_icon',
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelGroupKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription: 'Used for important alerts',
          defaultColor: AppColors.brand400,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: false,
          criticalAlerts: true,
        ),
      ],
      debug: true,
    );

    // Step 2: Request Firebase Notification Permission
    final permission = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.d('Notification permission: ${permission.authorizationStatus}');

    // Step 2.5: Set iOS foreground presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Step 3: Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Step 4: Save FCM Token
    String? newToken = await FirebaseMessaging.instance.getToken();
    if (newToken != null) {
      var box = Hive.box('data');
      String? savedToken = box.get('fcm_token');
      _logger.d("Current saved token: $savedToken, New token: $newToken");
      if (savedToken != newToken) {
        await box.put('fcm_token', newToken);
        _logger.d("✅ FCM Token saved: $newToken");
      } else {
        _logger.d("✅ FCM Token already saved (same value)");
      }
    } else {
      _logger.w("⚠️ FCM Token is null!");
    }

    // Step 5: Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _logger.d('🔄 FCM Token refreshed: $newToken');
      var box = Hive.box('data');
      box.put('fcm_token', newToken);
    });

    // Step 6: Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d("📥 Foreground FCM message: ${message.notification?.title}");
      _logger.d("📥 Message data: ${message.data}");

      // Show local notification when app is in foreground
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      }
    });

    // Step 7: Handle notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logger.i("🔔 Notification clicked from background: ${message.data}");
      // Handle navigation here if needed
    });

    // Step 8: Handle notification when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _logger.i("🔔 App opened from terminated state: ${message.data}");
        // Handle navigation here if needed
      }
    });
  }

  static void showLocalNotification({
    required String? title,
    required String? body,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'high_importance_channel',
        title: title ?? 'New Notification',
        body: body ?? '',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
