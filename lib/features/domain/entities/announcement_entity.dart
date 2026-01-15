import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String> photoUrls;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.photoUrls = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorId,
    authorName,
    createdAt,
    updatedAt,
    isActive,
    photoUrls,
  ];
}
