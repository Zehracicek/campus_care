import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String requestId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, requestId, userId, text, createdAt];
}
