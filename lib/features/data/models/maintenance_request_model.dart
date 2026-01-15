import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRequestModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final MaintenanceStatus status;
  final MaintenancePriority priority;
  final String userId;
  final String? locationId;
  final String? roomId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final List<String> photoUrls;
  final String? adminNote;

  MaintenanceRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.status,
    required this.priority,
    required this.userId,
    this.locationId,
    this.roomId,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.photoUrls = const [],
    this.adminNote,
  });

  // Convert from Firestore document
  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.toString() == 'MaintenanceStatus.${json['status']}',
      ),
      priority: MaintenancePriority.values.firstWhere(
        (e) => e.toString() == 'MaintenancePriority.${json['priority']}',
      ),
      userId: json['userId'] as String,
      locationId: json['locationId'] as String?,
      roomId: json['roomId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      photoUrls:
          (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      adminNote: json['adminNote'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'status': status.name,
      'priority': priority.name,
      'userId': userId,
      'locationId': locationId,
      'roomId': roomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'photoUrls': photoUrls,
      'adminNote': adminNote,
    };
  }

  // Convert to domain entity
  MaintenanceRequestEntity toEntity() {
    return MaintenanceRequestEntity(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      status: status,
      priority: priority,
      userId: userId,
      locationId: locationId ?? '',
      roomId: roomId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt,
      photoUrls: photoUrls,
      adminNote: adminNote,
    );
  }

  // Convert from domain entity
  factory MaintenanceRequestModel.fromEntity(MaintenanceRequestEntity entity) {
    return MaintenanceRequestModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      status: entity.status,
      priority: entity.priority,
      userId: entity.userId,
      locationId: entity.locationId,
      roomId: entity.roomId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
      photoUrls: entity.photoUrls,
      adminNote: entity.adminNote,
    );
  }
}
