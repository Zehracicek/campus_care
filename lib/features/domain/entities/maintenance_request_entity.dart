import 'package:equatable/equatable.dart';

enum MaintenanceStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled,
  rejected,
}

enum MaintenancePriority { low, medium, high, urgent }

class MaintenanceRequestEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String categoryId;
  final String locationId;
  final String? roomId;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<String> photoUrls;
  final String? adminNote;

  const MaintenanceRequestEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.categoryId,
    required this.locationId,
    this.roomId,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.photoUrls = const [],
    this.adminNote,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    userId,
    categoryId,
    locationId,
    roomId,
    priority,
    status,
    createdAt,
    updatedAt,
    completedAt,
    photoUrls,
    adminNote,
  ];
}
