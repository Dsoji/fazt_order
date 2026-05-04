import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/auth/login/presentation/login_screen.dart';
import '../features/auth/map/map_location_screen.dart';
import '../features/auth/register/presentation/account_verification.dart';
import '../features/auth/register/presentation/registration_screen.dart';
import '../features/dashboard_view.dart';
import '../features/home/presentation/home_preview.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

const _publicPrefixes = <String>[
  '/onboarding',
  '/login',
  '/register',
  '/verify-otp',
  '/set-location',
  '/guest',
];

bool _isPublic(String location) =>
    _publicPrefixes.any((p) => location == p || location.startsWith('$p/'));

bool _hasToken() {
  final token = Hive.box('data').get('accessToken') as String?;
  return token != null && token.isNotEmpty;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final authed = _hasToken();

      if (loc == '/') return authed ? '/dashboard' : '/onboarding';
      if (!authed && !_isPublic(loc)) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => null),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final extra = (state.extra as Map<String, dynamic>?) ?? const {};
          return AccountVerificationScreen(
            email: extra['email'] as String,
            firstName: extra['firstName'] as String?,
            lastName: extra['lastName'] as String?,
            phone: extra['phone'] as String?,
            referralCode: extra['referralCode'] as String?,
            purpose: (extra['purpose'] as String?) ?? 'signup',
          );
        },
      ),
      GoRoute(
        path: '/set-location',
        builder: (_, __) => const MapLocationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardView(),
      ),
      GoRoute(
        path: '/guest',
        builder: (_, __) => const HomePreview(),
      ),
    ],
  );
});
