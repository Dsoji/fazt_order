import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'provider.dart';
import 'styles.dart';
import 'toast_widget.dart';
import 'type.dart';

class ToastWrapper extends StatefulWidget {
  final Widget child;
  final ToastStyle style;

  const ToastWrapper({
    super.key,
    required this.child,
    this.style = ToastStyle.style1,
  });

  @override
  ToastWrapperState createState() => ToastWrapperState();
}

class ToastWrapperState extends State<ToastWrapper> {
  bool isExpended = false;
  final List<NotificationType> _toasts = [];
  final List<String> _messages = [];
  final List<GlobalKey<ToastWidgetState>> _toastKeys = [];
  final List<Timer> _toastTimers = [];
  late ToastStyle _style;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _style = widget.style;
    super.initState();
  }

  @override
  void dispose() {
    _removeOverlay();
    // Cancel all timers to prevent memory leaks.
    for (final timer in _toastTimers) {
      timer.cancel();
    }
    _toastTimers.clear();
    super.dispose();
  }

  ToastStyle _getStyleForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ToastStyle.style1;
      case NotificationType.error:
        return ToastStyle.style3;
      case NotificationType.warning:
        return ToastStyle.style3;
      case NotificationType.info:
        return ToastStyle.style2;

      default:
        return ToastStyle.style1;
    }
  }

  // Remove the overlay entry if it exists.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Update or create the overlay entry.
  void _updateOverlay() {
    if (_toasts.isEmpty) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return _buildOverlayContent();
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Overlay.of(context).insert(_overlayEntry!);
      });
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  Widget _buildOverlayContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    int total = _toasts.length;
    // Build widgets in reverse order so that the last element in the list appears on top.
    List<Widget> children = List.generate(total, (visualIndex) {
      int actualIndex = total - 1 - visualIndex;
      final type = _toasts[actualIndex];
      final message = _messages[actualIndex];
      final key = _toastKeys[actualIndex];
      return AnimatedPositioned(
        key: key,
        curve: isExpended ? Curves.easeOutBack : Curves.easeOut,
        top: isExpended
            ? 60 + visualIndex * 65 // Expanded: space out toasts from the top.
            : getGap(visualIndex), // Collapsed: use a smaller gap.
        left: 20,
        right: 20,
        duration: isExpended
            ? const Duration(milliseconds: 400)
            : const Duration(milliseconds: 200),
        child: Transform.scale(
          scaleX: isExpended ? 1 : getScale(visualIndex),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpended = !isExpended;
              });
              _updateOverlay();
            },
            onDoubleTap: () {
              int topIndex = 0; // We now consider index 0 as the "top"

              // If the tapped toast is not already at the top...
              if (actualIndex != topIndex) {
                // Remove the tapped toast from its current position.
                final tappedType = _toasts.removeAt(actualIndex);
                final tappedKey = _toastKeys.removeAt(actualIndex);
                final tappedTimer = _toastTimers.removeAt(actualIndex);

                // Insert the tapped toast at the top.
                setState(() {
                  _toasts.insert(0, tappedType);
                  _messages.insert(0, message);
                  _toastKeys.insert(0, tappedKey);
                  _toastTimers.insert(0, tappedTimer);
                });

                // Reset its timer.
                tappedTimer.cancel();
                final newTimer = Timer(const Duration(seconds: 5), () {
                  if (!mounted) return;
                  final newIdx = _toastKeys.indexOf(tappedKey);
                  if (newIdx != -1) {
                    _deleteToast(newIdx);
                  }
                });

                _toastTimers[0] = newTimer;
                _updateOverlay();
              } else {
                // If already at the top, reset its timer.
                _toastTimers[0].cancel();
                _toastTimers[0] = Timer(const Duration(seconds: 5), () {
                  if (!mounted) return;
                  _deleteToast(0);
                });
              }
            },
            child: ToastWidget(
              style: _getStyleForType(type),
              type: type,
              message: message, // Pass the message here
              onCloce: () => _deleteToast(actualIndex),
            ),
          ),
        ),
      );
    });
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: IgnorePointer(
          ignoring: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: children,
          ),
        ),
      ),
    );
  }

  // Public method to show a toast.
  void showToast(NotificationType type, {String? message}) {
    final key = GlobalKey<ToastWidgetState>();
    setState(() {
      _toasts.insert(0, type);
      _messages.insert(0, message ?? _getDefaultMessage(type));
      _toastKeys.insert(0, key);
    });
    _updateOverlay();

    final timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      final index = _toastKeys.indexOf(key);
      if (index != -1) {
        _deleteToast(index);
      }
    });
    _toastTimers.insert(0, timer);
  }

  String _getDefaultMessage(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return "Success";
      case NotificationType.error:
        return "Error occurred";
      case NotificationType.warning:
        return "Warning";
      case NotificationType.info:
        return "Information";
    }
  }

  // Delete a toast at a given actual index.
  void _deleteToast(int index) {
    if (index < _toastTimers.length) {
      _toastTimers[index].cancel();
      _toastTimers.removeAt(index);
    }
    setState(() {
      _toasts.removeAt(index);
      _messages.removeAt(index); // Remove the message as well
      _toastKeys.removeAt(index);
      if (_toastKeys.isEmpty) {
        isExpended = false;
      }
    });
    _updateOverlay();
  }

  // Helper to compute the vertical gap (for collapsed state) based on visual order.
  double getGap(int visualIndex) {
    return 60 + visualIndex * 6;
  }

  // Helper to compute a scale factor based on visual order.
  double getScale(int visualIndex) {
    int total = _toastKeys.length;
    if (total <= 3) {
      if (visualIndex == 0) {
        if (total == 1) return 1;
        if (total == 2) return 0.92;
        return 0.84;
      }
      if (visualIndex == 1) {
        if (total <= 2) return 1;
        return 0.92;
      }
    }
    if (visualIndex == 0) return 0.84;
    if (visualIndex == 1) return 0.92;
    return 1;
  }

  void setStyle(ToastStyle style) {
    setState(() {
      _style = widget.style;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToastProvider(
      showToast: showToast,
      deleteToast: _deleteToast,
      setStyle: setStyle,
      child: widget.child,
    );
  }
}
