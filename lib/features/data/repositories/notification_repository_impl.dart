import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/notification_model.dart';
import 'package:campus_care/features/domain/entities/notification_entity.dart';
import 'package:campus_care/features/domain/repositories/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  NotificationRepositoryImpl(this._firestore);

  @override
  Future<Result<List<NotificationEntity>>> getNotificationsByUser(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(notifications);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<NotificationEntity>>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(notifications);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<NotificationEntity>> getNotificationById(String id) async {
    try {
      final doc = await _firestore.collection('notifications').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Notification not found');
      }
      final notification = NotificationModel.fromJson(doc.data()!).toEntity();
      return Success(notification);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<NotificationEntity>> createNotification(
    NotificationEntity notification,
  ) async {
    try {
      final id = notification.id.isEmpty ? _uuid.v4() : notification.id;
      final notificationWithId = NotificationEntity(
        id: id,
        userId: notification.userId,
        requestId: notification.requestId,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        isRead: notification.isRead,
        createdAt: notification.createdAt,
      );
      final model = NotificationModel.fromEntity(notificationWithId);
      await _firestore.collection('notifications').doc(id).set(model.toJson());
      return Success(notificationWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<NotificationEntity>> markAsRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
      });
      final result = await getNotificationById(id);
      return result;
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAllUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<Result<List<NotificationEntity>>> streamNotificationsByUser(
    String userId,
  ) {
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final notifications = snapshot.docs
                .map((doc) => NotificationModel.fromJson(doc.data()).toEntity())
                .toList();
            return Success(notifications);
          });
    } catch (e) {
      return Stream.value(Failure(message: e.toString()));
    }
  }
}
