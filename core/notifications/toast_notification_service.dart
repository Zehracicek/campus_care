import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'app_notification_type.dart';
import 'notification_service.dart';

/// Notification service implementation using `toastification` package.
class ToastNotificationService implements NotificationService {
  const ToastNotificationService();

  @override
  void show(
    BuildContext context, {
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
    Duration? duration,
    Alignment alignment = Alignment.topRight,
  }) {
    final colors = _colorsFor(type);

    toastification.show(
      context: context,
      style: ToastificationStyle.flat,
      type: _mapType(type),
      autoCloseDuration: duration ?? const Duration(seconds: 4),
      title: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      description: RichText(
        text: TextSpan(
          text: message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.text.withValues(alpha: 0.8),
          ),
        ),
      ),
      alignment: alignment,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 400),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      showIcon: true,
      backgroundColor: colors.background,
      foregroundColor: colors.text,
      borderSide: BorderSide(
        color: colors.text.withValues(alpha: 0.2),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colors.text.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
    );
  }

  @override
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

  @override
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

  @override
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

  @override
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

  _NotificationColors _colorsFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return const _NotificationColors(
          background: Color(0xFFE8F5E8),
          text: Color(0xFF2E7D32),
        );
      case AppNotificationType.error:
        return const _NotificationColors(
          background: Color(0xFFFFEBEE),
          text: Color(0xFFC62828),
        );
      case AppNotificationType.warning:
        return const _NotificationColors(
          background: Color(0xFFFFF8E1),
          text: Color(0xFFF57C00),
        );
      case AppNotificationType.info:
        return const _NotificationColors(
          background: Color(0xFFE3F2FD),
          text: Color(0xFF1565C0),
        );
    }
  }

  ToastificationType _mapType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return ToastificationType.success;
      case AppNotificationType.error:
        return ToastificationType.error;
      case AppNotificationType.warning:
        return ToastificationType.warning;
      case AppNotificationType.info:
        return ToastificationType.info;
    }
  }
}

class _NotificationColors {
  final Color background;
  final Color text;
  const _NotificationColors({required this.background, required this.text});
}
