import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../toast/toast.dart';

class ErrorService {
  static void handleErrors(e) {
    log('The error: $e');
    // ignore: unused_local_variable
    String message = '';
    if (e is String) {
      // Handle string error messages
      message = e;
    } else if (e is Map) {
      if ((e['message'] ?? []).isNotEmpty || e['message'] != null) {
        if (e['message'] is List) {
          message = e['message'][0] ?? '';
        } else {
          message = e['message'] ?? '';
        }
      } else {
        message = 'An error occured, please try again.';
      }
    } else if (e is TimeoutException) {
      // Handle timeout errors
      message = 'The request timed out. Please try again.';
    } else if (e is Error) {
      // Handle general errors
      message = 'An error occured, please try again.';
    } else if (e is Exception) {
      // Handle general exceptions
      message = 'An error occured, please try again.';
    } else if (e is FormatException) {
      // Handle formatting errors
      message = 'There is something wrong with the format.';
    } else if (e is JsonUnsupportedObjectError) {
      // Handle JSON parsing errors
      message = 'There is something wrong with the JSON format.';
    } else {
      // Handle other types of errors
      message = 'AN error occured, please try again.';
    }

    // Show error message using a toast widget
    ToastService().showToast(
      NotificationType.error,
      message: message,
    );
  }
}
