import 'package:flutter/material.dart';

import '../res/app_colors.dart';
import 'toast.dart';

const Color infoPrimary = Color(0xff4B85F5);
const Color black = Color(0xff28292A);

const Color infoSecondary = Color(0xffEDF2FD);
const Color errorSecondary = Color(0xffFDECEC);
const Color warningSecondary = Color(0xffFFFAE8);
const Color successSecondary = Color(0xffE5FCF1);
const Color blackSecondary = Color(0xff28292A);

class ToastColors {
  final Color primary;
  final Color secondary;

  ToastColors({required this.primary, required this.secondary});
}

extension NotificationTypeColor on NotificationType {
  ToastColors get color {
    switch (this) {
      case NotificationType.info:
        return ToastColors(primary: Colors.black, secondary: Colors.black);
      case NotificationType.error:
        return ToastColors(
          primary: Colors.white,
          secondary: AppColors.red500,
        );
      case NotificationType.warning:
        return ToastColors(primary: Colors.white, secondary: Colors.white);
      case NotificationType.success:
        return ToastColors(
          primary: Colors.white,
          secondary: AppColors.red500,
        );
    }
  }
}

extension NotificationTypeMessage on NotificationType {
  String get message {
    switch (this) {
      case NotificationType.info:
        return "This is an informational message.";
      case NotificationType.error:
        return "An error has occurred.";
      case NotificationType.warning:
        return "This is warning message.";
      case NotificationType.success:
        return "This success message.";
    }
  }
}

enum ToastStyle {
  style1,
  style2,
  style3,
}

extension ToastStyleExtention on ToastStyle {
  BoxDecoration decoration(ToastColors toastColors) {
    switch (this) {
      case ToastStyle.style1:
        return BoxDecoration(
          color: const Color(0xFF34C759),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: -4,
              blurRadius: 16,
              offset: const Offset(12, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          //border: Border.all()
        );
      case ToastStyle.style2:
        return BoxDecoration(
          color: const Color(0xfffffcc00),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: -8,
              blurRadius: 20,
              offset: const Offset(0, 16),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          //border: Border.all()
        );
      case ToastStyle.style3:
        return BoxDecoration(
          color: const Color(0xFFFF3B30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: -8,
              blurRadius: 20,
              offset: const Offset(0, 16),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        );
    }
  }
}
