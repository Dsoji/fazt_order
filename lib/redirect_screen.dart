import 'package:fazt_order/src/features/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import 'src/common/res/app_colors.dart';
import 'src/features/onboarding/presentation/onboarding_screen.dart';

final logger = Logger();

class RedirectScreen extends HookConsumerWidget {
  const RedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.delayed(Duration.zero, () async {
        var box = Hive.box('data');
        final token = box.get('accessToken');
        String? refreshToken = box.get('refreshToken');
        logger.d('refreshToken: $refreshToken');
        logger.d(token);
        final targetScreen =
            token != null ? const DashboardView() : const OnboardingScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      });

      return null;
    }, []);

    return const Scaffold(
      backgroundColor: AppColors.brand600,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
