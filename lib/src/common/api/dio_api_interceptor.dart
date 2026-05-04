import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../router/app_router.dart';
import '../res/base.dart';

final logger = Logger();

final dioApiInterceptorProvider = Provider<DioApiInterceptor>((ref) {
  return DioApiInterceptor(ref: ref);
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

  // Static variables to track refresh token requests
  static Future<Response?>? _refreshTokenFuture;
  static DateTime? _lastRefreshTime;
  static const Duration _refreshCooldown = Duration(seconds: 30);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final token = await authLocalService.getToken();
    var box = Hive.box('data');
    final token = box.get('accessToken');
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

    if (statusCode == 401) {
      var box = Hive.box('data');
      String? refreshToken = box.get('refreshToken');
      logger.d(refreshToken);

      // Check if we should wait for an ongoing refresh or skip if too soon
      if (_refreshTokenFuture != null) {
        log('Refresh token request already in progress, waiting...');
        try {
          final refreshResponse = await _refreshTokenFuture;
          if (refreshResponse != null) {
            // Use the token from the ongoing refresh
            final token = box.get('accessToken');
            return _retryOriginalRequest(err, handler, token);
          }
        } catch (e) {
          log('Error waiting for refresh token: $e');
        }
      }

      // Check if last refresh was less than 30 seconds ago
      if (_lastRefreshTime != null) {
        final timeSinceLastRefresh =
            DateTime.now().difference(_lastRefreshTime!);
        if (timeSinceLastRefresh < _refreshCooldown) {
          log('Last refresh was ${timeSinceLastRefresh.inSeconds}s ago, using existing token');
          final token = box.get('accessToken');
          return _retryOriginalRequest(err, handler, token);
        }
      }

      // Create a new refresh token request
      _refreshTokenFuture = _performTokenRefresh(refreshToken, box);

      try {
        final refreshResponse = await _refreshTokenFuture;
        if (refreshResponse != null) {
          final token = box.get('accessToken');
          return _retryOriginalRequest(err, handler, token);
        }
      } catch (e) {
        log('Error during token refresh: $e');
      } finally {
        // Clear the future after completion
        _refreshTokenFuture = null;
      }

      return handler.next(err);
    }

    return handler.next(err);
  }

  Future<Response?> _performTokenRefresh(String? refreshToken, Box box) async {
    final dio = Dio()
      ..interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

    try {
      log('Over here we are trying to refresh the token');
      final response = await dio.post(
        '${BasePaths.baseProdUrl}auth/refresh-token',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Over here refreshing the token was successful');
        final data = response.data;
        final token = data['data']['accessToken'];
        final newrefreshToken = data['data']['refreshToken'];

        box.put('accessToken', token);
        box.put('refreshToken', newrefreshToken);

        // Update the last refresh time
        _lastRefreshTime = DateTime.now();

        return response;
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        Fluttertoast.showToast(
          msg:
              "Oops! There was a problem. A quick log in should get things back on track.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        final box = Hive.box('data');
        await box.clear();
        ref.read(routerProvider).go('/onboarding');
      }
      rethrow;
    } catch (e) {
      log('Unexpected error during token refresh: $e');
      rethrow;
    }

    return null;
  }

  Future<void> _retryOriginalRequest(
    DioException err,
    ErrorInterceptorHandler handler,
    String? token,
  ) async {
    final dio = Dio()
      ..interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));

    final origin = err.requestOptions;
    log('Over here we try the request again');

    // Create a new request with all original details
    final retryOptions = Options(
      method: origin.method,
      headers: {
        ...origin.headers,
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      contentType: origin.contentType,
      responseType: origin.responseType,
      followRedirects: origin.followRedirects,
      validateStatus: origin.validateStatus,
    );

    final previousReqResponse = await dio.request(
      origin.uri.toString(),
      data: origin.data,
      queryParameters: origin.queryParameters,
      options: retryOptions,
    );

    return handler.resolve(previousReqResponse);
  }
}
