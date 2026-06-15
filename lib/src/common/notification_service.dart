import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important alerts',
  importance: Importance.max,
  playSound: true,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.d('📱 Background message received: ${message.notification?.title}');
  logger.d('📱 Message data: ${message.data}');

  if (message.notification != null) {
    await NotificationService.showLocalNotification(
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }
}

class NotificationService {
  static final _logger = Logger();

  static Future<void> initializeFCM() async {
    const androidInit = AndroidInitializationSettings('notify_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    final permission = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    _logger.d('Notification permission: ${permission.authorizationStatus}');

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // iOS: Firebase can't mint an FCM token until it has received an APNS token from
    // Apple. Under Flutter 3.35+'s UIScene lifecycle the APNS token can take longer
    // than a single 5s wait to arrive on a cold start, so retry before giving up.
    if (Platform.isIOS) {
      const maxAttempts = 6;
      String? apnsToken;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          apnsToken = await FirebaseMessaging.instance
              .getAPNSToken()
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          _logger.w("⚠️ APNS token attempt $attempt/$maxAttempts failed: $e");
        }
        if (apnsToken != null) {
          _logger.d("✅ APNS token received on attempt $attempt: $apnsToken");
          break;
        }
        if (attempt < maxAttempts) {
          _logger.d(
              "… APNS token not ready (attempt $attempt/$maxAttempts), retrying in 2s");
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      if (apnsToken == null) {
        _logger.w(
            "⚠️ APNS token unavailable after $maxAttempts attempts (likely simulator) — FCM token may be null.");
      }
    }

    try {
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
    } catch (e) {
      _logger.w("⚠️ Could not get FCM token (expected on simulator): $e");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _logger.d('🔄 FCM Token refreshed: $newToken');
      var box = Hive.box('data');
      box.put('fcm_token', newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d("📥 Foreground FCM message: ${message.notification?.title}");
      _logger.d("📥 Message data: ${message.data}");

      if (message.notification != null) {
        showLocalNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _logger.i("🔔 Notification clicked from background: ${message.data}");
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _logger.i("🔔 App opened from terminated state: ${message.data}");
      }
    });
  }

  static Future<void> showLocalNotification({
    required String? title,
    required String? body,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        highImportanceChannel.id,
        highImportanceChannel.name,
        channelDescription: highImportanceChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'notify_icon',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title ?? 'New Notification',
      body ?? '',
      details,
    );
  }
}
