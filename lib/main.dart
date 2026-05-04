import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fazt_order/src/common/notification_service.dart';
import 'package:fazt_order/src/features/profile/data/service/permission_service.dart';
import 'package:fazt_order/src/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import 'firebase_options.dart';
import 'src/common/res/app_colors.dart';
import 'src/common/utils/dimesnsion.dart';

final logger = Logger();

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final envPath = '${Directory.current.path}/.env';
  // logger.d('Looking for .env at: $envPath');

  try {
    await dotenv.load(fileName: '.env');
    logger.d('Environment variables loaded successfully');
  } catch (e) {
    logger.d('Error loading .env: $e');
    logger.d('Current directory: ${Directory.current.path}');
    logger.d('Files in current directory: ${Directory.current.listSync()}');
    logger.d('Please create a .env file with MAP_KEY=your_google_maps_api_key');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('data');

  await NotificationService.initializeFCM();
  await PermissionService().requestAllPermissions();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final scale =
        mediaQuery.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2);
    Animate.restartOnHotReload = true;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      title: 'Fazt Vendor',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.neutral990),
        scaffoldBackgroundColor: AppColors.neutral990,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) => MediaQuery(
        data: mediaQuery.copyWith(textScaler: scale),
        child: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            Dims.setSize(media);
            return child!;
          },
        ),
      ),
    );
  }
}
