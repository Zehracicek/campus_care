import 'package:campus_care/features/domain/entities/maintenance_assignment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceAssignmentModel {
  final String id;
  final String requestId;
  final String assignedToId;
  final String assignedById;
  final DateTime assignedAt;
  final String? notes;

  MaintenanceAssignmentModel({
    required this.id,
    required this.requestId,
    required this.assignedToId,
    required this.assignedById,
    required this.assignedAt,
    this.notes,
  });

  // Convert from Firestore document
  factory MaintenanceAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceAssignmentModel(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      assignedToId: json['assignedToId'] as String,
      assignedById: json['assignedById'] as String,
      assignedAt: (json['assignedAt'] as Timestamp).toDate(),
      notes: json['notes'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'assignedToId': assignedToId,
      'assignedById': assignedById,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'notes': notes,
    };
  }

  // Convert to domain entity
  MaintenanceAssignmentEntity toEntity() {
    return MaintenanceAssignmentEntity(
      id: id,
      requestId: requestId,
      assignedToId: assignedToId,
      assignedById: assignedById,
      assignedAt: assignedAt,
      notes: notes,
    );
  }

  // Convert from domain entity
  factory MaintenanceAssignmentModel.fromEntity(
    MaintenanceAssignmentEntity entity,
  ) {
    return MaintenanceAssignmentModel(
      id: entity.id,
      requestId: entity.requestId,
      assignedToId: entity.assignedToId,
      assignedById: entity.assignedById,
      assignedAt: entity.assignedAt,
      notes: entity.notes,
    );
  }
}
