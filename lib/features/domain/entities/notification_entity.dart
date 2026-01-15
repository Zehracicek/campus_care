import 'package:equatable/equatable.dart';

enum NotificationType {
  requestCreated,
  requestAssigned,
  requestStatusChanged,
  requestCompleted,
  commentAdded,
  other,
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String? requestId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.requestId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    requestId,
    title,
    body,
    type,
    isRead,
    createdAt,
  ];
}
