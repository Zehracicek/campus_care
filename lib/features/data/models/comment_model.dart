import 'package:campus_care/features/domain/entities/comment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String requestId;
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  // Convert from Firestore document
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Convert to domain entity
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      requestId: requestId,
      userId: userId,
      text: text,
      createdAt: createdAt,
    );
  }

  // Convert from domain entity
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      requestId: entity.requestId,
      userId: entity.userId,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }
}
