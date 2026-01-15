import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/notification_entity.dart';
import 'package:campus_care/features/domain/repositories/notification_repository.dart';

class GetNotificationsParams {
  final String userId;

  GetNotificationsParams(this.userId);
}

class GetNotificationsUseCase
    implements
        FutureUseCase<
          Result<List<NotificationEntity>>,
          GetNotificationsParams
        > {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<Result<List<NotificationEntity>>> call({
    GetNotificationsParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'GetNotificationsParams is required'),
      );
    }
    return _repository.getNotificationsByUser(params.userId);
  }
}

class GetUnreadNotificationsUseCase
    implements
        FutureUseCase<
          Result<List<NotificationEntity>>,
          GetNotificationsParams
        > {
  final NotificationRepository _repository;

  GetUnreadNotificationsUseCase(this._repository);

  @override
  Future<Result<List<NotificationEntity>>> call({
    GetNotificationsParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'GetNotificationsParams is required'),
      );
    }
    return _repository.getUnreadNotifications(params.userId);
  }
}

class MarkNotificationAsReadParams {
  final String notificationId;

  MarkNotificationAsReadParams(this.notificationId);
}

class MarkNotificationAsReadUseCase
    implements
        FutureUseCase<
          Result<NotificationEntity>,
          MarkNotificationAsReadParams
        > {
  final NotificationRepository _repository;

  MarkNotificationAsReadUseCase(this._repository);

  @override
  Future<Result<NotificationEntity>> call({
    MarkNotificationAsReadParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'MarkNotificationAsReadParams is required'),
      );
    }
    return _repository.markAsRead(params.notificationId);
  }
}
