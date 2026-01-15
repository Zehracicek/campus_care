import 'package:campus_care/features/domain/entities/photo_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String url;
  final String requestId;
  final String uploadedBy;
  final PhotoType type;
  final DateTime uploadedAt;

  PhotoModel({
    required this.id,
    required this.url,
    required this.requestId,
    required this.uploadedBy,
    required this.type,
    required this.uploadedAt,
  });

  // Convert from Firestore document
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      url: json['url'] as String,
      requestId: json['requestId'] as String,
      uploadedBy: json['uploadedBy'] as String,
      type: PhotoType.values.firstWhere(
        (e) => e.toString() == 'PhotoType.${json['type']}',
      ),
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'requestId': requestId,
      'uploadedBy': uploadedBy,
      'type': type.name,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  // Convert to domain entity
  PhotoEntity toEntity() {
    return PhotoEntity(
      id: id,
      url: url,
      requestId: requestId,
      uploadedBy: uploadedBy,
      type: type,
      uploadedAt: uploadedAt,
    );
  }

  // Convert from domain entity
  factory PhotoModel.fromEntity(PhotoEntity entity) {
    return PhotoModel(
      id: entity.id,
      url: entity.url,
      requestId: entity.requestId,
      uploadedBy: entity.uploadedBy,
      type: entity.type,
      uploadedAt: entity.uploadedAt,
    );
  }
}
