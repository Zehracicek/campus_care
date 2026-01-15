import 'package:equatable/equatable.dart';

enum PhotoType { before, during, after, other }

class PhotoEntity extends Equatable {
  final String id;
  final String url;
  final String requestId;
  final String uploadedBy;
  final PhotoType type;
  final DateTime uploadedAt;

  const PhotoEntity({
    required this.id,
    required this.url,
    required this.requestId,
    required this.uploadedBy,
    required this.type,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, url, requestId, uploadedBy, type, uploadedAt];
}
