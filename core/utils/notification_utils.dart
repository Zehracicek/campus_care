import 'package:campus_care/core/notifications/app_notification_type.dart';
import 'package:campus_care/core/notifications/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NotificationUtils {
  /// Backward-compatible wrapper delegating to modular `NotificationService`.
  static void showNotification(
    BuildContext context,
    String title,
    String body, {
    ToastificationType type = ToastificationType.info,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    NotificationManager.instance.show(
      context,
      title: title,
      message: body,
      type: _mapType(type),
      duration: duration,
      alignment: alignment,
    );
  }

  static AppNotificationType _mapType(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return AppNotificationType.success;
      case ToastificationType.error:
        return AppNotificationType.error;
      case ToastificationType.warning:
        return AppNotificationType.warning;
      case ToastificationType.info:
      default:
        return AppNotificationType.info;
    }
  }
}
