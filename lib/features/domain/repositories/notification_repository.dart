import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Get notifications by user
  Future<Result<List<NotificationEntity>>> getNotificationsByUser(
    String userId,
  );

  /// Get unread notifications
  Future<Result<List<NotificationEntity>>> getUnreadNotifications(
    String userId,
  );

  /// Get a notification by ID
  Future<Result<NotificationEntity>> getNotificationById(String id);

  /// Create a new notification
  Future<Result<NotificationEntity>> createNotification(
    NotificationEntity notification,
  );

  /// Mark notification as read
  Future<Result<NotificationEntity>> markAsRead(String id);

  /// Delete a notification
  Future<Result<void>> deleteNotification(String id);

  /// Delete all user notifications
  Future<Result<void>> deleteAllUserNotifications(String userId);

  /// Stream notifications for real-time updates
  Stream<Result<List<NotificationEntity>>> streamNotificationsByUser(
    String userId,
  );
}
