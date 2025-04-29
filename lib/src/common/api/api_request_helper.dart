import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fazt_order/src/common/api/api.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../toast/toast.dart';
import '../utils/utils.dart';

final apiRequestHelperProvider = Provider<ApiRequestHelper>((ref) {
  final apiClient = ref.read(dioApiClientProvider);
  return ApiRequestHelper(apiClient: apiClient);
});

class ApiRequestHelper {
  final IApiClient apiClient;

  ApiRequestHelper({required this.apiClient});

  Future<ResultValue<T>> handleApiRequest<T>(
    Future<Response<dynamic>> Function() request, {
    bool showSuccessToast = false,
    bool showErrorToast = false,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await request();
      return _handleResponse(response, parser, showSuccessToast);
    } on DioException catch (e, s) {
      return _handleDioError<T>(e, s, showErrorToast);
    } catch (e, s) {
      return _handleGeneralException<T>(e.toString(), s, showErrorToast);
    }
  }

  ResultValue<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic data) parser,
    bool showSuccessToast,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = BaseModel.fromMap(response.data);
      if (showSuccessToast) {
        ToastService().showToast(
          NotificationType.success,
          message: data.message ?? '',
        );
      }
      return ResultValue.success(
          parser(data.data ?? data.predictions ?? data.result));
    } else {
      return _handleErrorResponse<T>(response);
    }
  }

  ResultValue<T> _handleErrorResponse<T>(Response<dynamic> response) {
    final error = jsonDecode(response.toString());
    ErrorService.handleErrors(error);
    return ResultValue.error(
      FailureHandler(
        message: error['message'] ?? 'Unknown error',
        stackTrace: StackTrace.current,
      ),
    );
  }

  ResultValue<T> _handleDioError<T>(
    DioException e,
    StackTrace s,
    bool showErrorToast,
  ) {
    if (e.error is SocketException) {
      return ResultValue.error(
        FailureHandler(
          message:
              "Oops! Something went wrong. The server took too long to respond. Please try refreshing the page or come back later.",
          stackTrace: s,
          exception: e,
          code: e.response?.statusCode,
        ),
      );
    }

    return ResultValue.error(
      FailureHandler(
        message: e.response?.statusMessage ?? 'Something went wrong',
        stackTrace: s,
        code: e.response?.statusCode,
        exception: e,
      ),
    );
  }

  ResultValue<T> _handleGeneralException<T>(
    dynamic e,
    StackTrace s,
    bool showErrorToast,
  ) {
    final errorMessage = e is String ? e : 'An unexpected error occurred';
    if (showErrorToast) {
      ErrorService.handleErrors(errorMessage);
    }
    return ResultValue.error(
      FailureHandler(
        message: errorMessage,
        stackTrace: s,
        exception: e,
      ),
    );
  }
}

class ResultValue<T> {
  final T? value;
  final FailureHandler? error;

  ResultValue.success(this.value) : error = null;
  ResultValue.error(this.error) : value = null;

  bool get isSuccess => value != null;
  bool get isError => error != null;
}
