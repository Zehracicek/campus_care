import 'package:flutter/material.dart';

import 'app_notification_type.dart';

/// Defines a modular, extensible interface for showing notifications.
abstract class NotificationService {
  void show(
    BuildContext context, {
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  });

  void success(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: AppNotificationType.success,
      duration: duration,
      alignment: alignment,
    );
  }

  void error(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: AppNotificationType.error,
      duration: duration,
      alignment: alignment,
    );
  }

  void warning(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: AppNotificationType.warning,
      duration: duration,
      alignment: alignment,
    );
  }

  void info(
    BuildContext context, {
    required String title,
    required String message,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    show(
      context,
      title: title,
      message: message,
      type: AppNotificationType.info,
      duration: duration,
      alignment: alignment,
    );
  }
}
