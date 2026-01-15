import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/notification_entity.dart';
import 'package:campus_care/features/domain/usecases/notification_usecases.dart';
import 'package:flutter/material.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationController extends ChangeNotifier {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadNotificationsUseCase _getUnreadNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationState _state = NotificationState();
  NotificationState get state => _state;

  NotificationController({
    required GetNotificationsUseCase getNotificationsUseCase,
    required GetUnreadNotificationsUseCase getUnreadNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _getUnreadNotificationsUseCase = getUnreadNotificationsUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase;

  void _updateState(NotificationState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadNotifications(String userId) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await _getNotificationsUseCase(
      params: GetNotificationsParams(userId),
    );

    if (result is Success<List<NotificationEntity>>) {
      _updateState(
        _state.copyWith(notifications: result.data, isLoading: false),
      );
      await _updateUnreadCount(userId);
    } else if (result is Failure<List<NotificationEntity>>) {
      _updateState(_state.copyWith(isLoading: false, error: result.message));
    }
  }

  Future<void> _updateUnreadCount(String userId) async {
    final result = await _getUnreadNotificationsUseCase(
      params: GetNotificationsParams(userId),
    );

    if (result is Success<List<NotificationEntity>>) {
      _updateState(_state.copyWith(unreadCount: result.data.length));
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final result = await _markNotificationAsReadUseCase(
      params: MarkNotificationAsReadParams(notificationId),
    );

    if (result is Success) {
      // Reload notifications after marking as read
      await loadNotifications(userId);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final unreadNotifications = _state.notifications
        .where((notification) => !notification.isRead)
        .toList();

    for (final notification in unreadNotifications) {
      await _markNotificationAsReadUseCase(
        params: MarkNotificationAsReadParams(notification.id),
      );
    }

    // Reload notifications after marking all as read
    await loadNotifications(userId);
  }
}
