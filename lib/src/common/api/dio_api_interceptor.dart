import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../toast/toast.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final dioApiInterceptorProvider = Provider<DioApiInterceptor>((ref) {
  // final authLocalService = ref.read(authenticationLocalServiceProvider);
  // final appRouter = ref.read(appRouteProvider);

  return DioApiInterceptor(
    // authLocalService: authLocalService,
    // appRouter: appRouter,
    ref: ref,
  );
});

class DioApiInterceptor extends Interceptor {
  DioApiInterceptor({
    // required this.authLocalService,
    // required this.appRouter,
    required this.ref,
  });

  // final AuthenticationLocalService authLocalService;
  // final AppRouter appRouter;
  final Ref ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final token = await authLocalService.getToken();
    var box = Hive.box('data');
    final token = box.get('accessToken');
    final nav = ref.read(navigatorKeyProvider).currentState;
    log('navigator is null: ${nav == null}');
    if (kDebugMode) {
      log('Url🔗: ${options.uri}');

      if (options.data != null && options.data is! FormData) {
        Map<String, dynamic> payload = jsonDecode(jsonEncode(options.data));

        String formattedPayload = '{\n';
        payload.forEach((key, value) {
          formattedPayload += '"$key": "${value.toString()}",\n';
        });
        formattedPayload += '}';

        log('Payload🛫🛬: $formattedPayload');
      }
    }

    options.headers.addAll(
      {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // final refreshToken = await authLocalService.geRefreshToken();

    if (statusCode == 401) {
      /// get the previous user from the local storage
      // UserModel previousUser = await authLocalService.getUser();
      ref.read(navigatorKeyProvider).currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );

      final dio = Dio()
        ..interceptors.add(LogInterceptor(
          request: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          // logPrint: (obj) =>
          //     log(obj.toString()), // Customize print function if needed
        ));

      /// make a request to the refresh token endpoint
      try {
        // final response = await dio.post(
        //   EnvironmentConfig.instance.baseUrl + ApiEndpoints.refreshToken,
        //   data: {
        //     'refreshToken': refreshToken,
        //   },
        // );

        // if (response.statusCode == 200 || response.statusCode == 201) {
        //   final data = response.data;

        //   /// update the user by copying the new tokens to the previous user model

        //   //! UserModel updatedUser = previousUser.copyWith(
        //   //   accessToken: data['data']['access_token'] ?? '',
        //   //   refreshToken: data['data']['refresh_token'] ?? '',
        //   // );

        //   /// save the updated user object to the local storage
        //   // await authLocalService.setUser(updatedUser);

        //   /// hit the previous request with the new token retrieved
        //   final origin = err.response?.requestOptions;

        //   final previousReqResponse = await dio.request(
        //     EnvironmentConfig.instance.baseUrl + origin!.path,
        //     data: origin.data,
        //     options: Options(
        //       headers: {
        //         HttpHeaders.authorizationHeader:
        //             'Bearer ${data['data']['access_token']}',
        //       },
        //     ),
        //   );

        //   return handler.resolve(previousReqResponse);
        // }
      } on DioException catch (dioError) {
        if (dioError.response != null) {
          ToastService().showToast(
            NotificationType.error,
            message:
                'Oops! There was a problem. A quick log in should get things back on track.',
          );
          Navigator.of(ref.read(navigatorKeyProvider).currentContext!)
              .pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
          // appRouter.replaceAll([
          //   const AuthRoute(children: [SignInRoute()]),
          // ]);
        }
      } catch (e) {
        // Handle any other errors
        log('Unexpected error: $e');
      }

      return handler.next(err);
    }

    return handler.next(err);
  }
}
