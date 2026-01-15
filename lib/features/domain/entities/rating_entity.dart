import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String requestId;
  final String userId;
  final int rating; // 1-5 yıldız
  final String? comment; // Opsiyonel yorum
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    requestId,
    userId,
    rating,
    comment,
    createdAt,
  ];
}
