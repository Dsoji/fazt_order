import 'package:flutter/material.dart';

import 'styles.dart';
import 'toast_warpper.dart';
import 'type.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  GlobalKey<ToastWrapperState>? _wrapperKey;
  bool _initialized = false;

  void initialize(GlobalKey<ToastWrapperState> key) {
    _wrapperKey = key;
    _initialized = true;
    debugPrint('[ToastService] ✅ Initialized with wrapper key: $_wrapperKey');
  }

  void showToast(NotificationType type, {String? message}) {
    if (!_initialized) {
      debugPrint('[ToastService] ❌ Not initialized');
      return;
    }

    debugPrint('[ToastService] 🔔 Show toast $type: $message');
    _wrapperKey?.currentState?.showToast(type, message: message);
  }

  void setStyle(ToastStyle style) {
    if (!_initialized) {
      debugPrint('ToastService not initialized');
      return;
    }
    _wrapperKey?.currentState?.setStyle(style);
  }
}
