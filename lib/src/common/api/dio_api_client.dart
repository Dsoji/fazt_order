import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utils/utils.dart';
import 'api_client.dart';

/// dio api client provider
final dioApiClientProvider = Provider<IApiClient>((ref) {
  return DioApiClient(ref);
});

final dioApiClientProviderNoAuth = Provider<DioApiClient>((ref) {
  return DioApiClient(ref);
});

class DioApiClient implements IApiClient {
  DioApiClient(this.ref) : _dio = Dio() {
    final baseOptions = BaseOptions(
      connectTimeout: 1.minutes,
      receiveTimeout: 1.minutes,
      contentType: 'application/json',
      validateStatus: _validateStatus,
      baseUrl: 'https://fazt.onrender.com/v1/',
    );

    // set the options
    _dio.options = baseOptions;

    final presetHeaders = <String, String>{
      Headers.acceptHeader: '*/*',
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    _dio.options.headers = presetHeaders;

    // final dioApiInterceptor = ref.read(dioApiInterceptorProvider);

    // _dio.interceptors.addAll(
    //   [
    //     // if (kDebugMode)
    //     //   LogInterceptor(
    //     //     requestHeader: false,
    //     //     requestBody: true,
    //     //     responseBody: true,
    //     //   ),
    //     dioApiInterceptor,
    //   ],
    // );
  }
  final Ref ref;

  final Dio _dio;

  @override
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  @override
  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      //log reuqrest url and body
      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  @override
  Future<Response> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  }) async {
    try {
      final response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  @override
  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  @override
  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  @override
  Future<Response> uploadFiles(
    String uri,
    String? action, {
    required File file,
    // required List<File> files,
  }) async {
    try {
      final formData = FormData.fromMap(
        {
          'file': await MultipartFile.fromFile(
            file.path,
          ),
          if (action != '') 'action': action,
          // 'files': [
          //   for (final file in files)
          //     await MultipartFile.fromFile(
          //       file.path,
          //     ),
          // ],
        },
      );

      final response = await _dio.post(
        uri,
        data: formData,
      );

      return response;
    } catch (e) {
      throw ApiException.getException(e);
    }
  }

  /// validate the status of a request
  bool _validateStatus(int? status) {
    return status! == 200 || status == 201;
  }
}

extension ResponseExtension on Response {
  bool get isSuccess {
    final is200 = statusCode == HttpStatus.ok;
    final is201 = statusCode == HttpStatus.created;
    return is200 || is201;
  }
}
