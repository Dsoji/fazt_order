import 'dart:io';

import 'package:dio/dio.dart';

abstract class IApiClient {
  /// get
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  /// post
  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  });

  /// put
  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  });

  /// patch
  Future<Response> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  });

  /// delete
  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
  });

  /// upload files
  Future<Response> uploadFiles(
    String uri,
    String? action, {
    required File file,
    // required List<File> files,
  });
}
