import 'package:campus_care/features/domain/entities/maintenance_history_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceHistoryModel {
  final String id;
  final String requestId;
  final String userId;
  final String action;
  final String? oldStatus;
  final String? newStatus;
  final String? notes;
  final DateTime timestamp;

  MaintenanceHistoryModel({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.action,
    this.oldStatus,
    this.newStatus,
    this.notes,
    required this.timestamp,
  });

  // Convert from Firestore document
  factory MaintenanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistoryModel(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String?,
      notes: json['notes'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'userId': userId,
      'action': action,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Convert to domain entity
  MaintenanceHistoryEntity toEntity() {
    return MaintenanceHistoryEntity(
      id: id,
      requestId: requestId,
      userId: userId,
      action: action,
      oldStatus: oldStatus,
      newStatus: newStatus,
      notes: notes,
      timestamp: timestamp,
    );
  }

  // Convert from domain entity
  factory MaintenanceHistoryModel.fromEntity(MaintenanceHistoryEntity entity) {
    return MaintenanceHistoryModel(
      id: entity.id,
      requestId: entity.requestId,
      userId: entity.userId,
      action: entity.action,
      oldStatus: entity.oldStatus,
      newStatus: entity.newStatus,
      notes: entity.notes,
      timestamp: entity.timestamp,
    );
  }
}
