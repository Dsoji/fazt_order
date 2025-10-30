import 'dart:io';

import 'package:fazt_order/redirect_screen.dart';
import 'package:fazt_order/src/common/api/dio_api_interceptor.dart';
import 'package:firebase_core/firebase_core.dart';
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

  final navigatorKey = GlobalKey<NavigatorState>();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ProviderScope(
        overrides: [
          navigatorKeyProvider.overrideWithValue(navigatorKey),
        ],
        child: MyApp(navigatorKey: navigatorKey),
      ),
    );
  });
}

class MyApp extends HookConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final scale =
        mediaQuery.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2);
    Animate.restartOnHotReload = true;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Fazt Vendor',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.neutral950),
        scaffoldBackgroundColor: AppColors.neutral950,
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
      home: const RedirectScreen(),
    );
  }
}
