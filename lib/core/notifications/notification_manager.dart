import 'package:flutter/material.dart';

import 'app_notification_type.dart';
import 'notification_service.dart';
import 'toast_notification_service.dart';

/// Facade to access the current `NotificationService`.
class NotificationManager {
  NotificationManager._internal();

  static final NotificationManager _instance = NotificationManager._internal();
  static NotificationManager get instance => _instance;

  NotificationService _service = const ToastNotificationService();

  static void useService(NotificationService service) {
    _instance._service = service;
  }

  NotificationService get service => _service;

  void show(
    BuildContext context, {
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    _service.show(
      context,
      title: title,
      message: message,
      type: type,
      duration: duration,
      alignment: alignment,
    );
  }
}
