import 'package:equatable/equatable.dart';

class MaintenanceAssignmentEntity extends Equatable {
  final String id;
  final String requestId;
  final String assignedToId;
  final String assignedById;
  final DateTime assignedAt;
  final String? notes;

  const MaintenanceAssignmentEntity({
    required this.id,
    required this.requestId,
    required this.assignedToId,
    required this.assignedById,
    required this.assignedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    requestId,
    assignedToId,
    assignedById,
    assignedAt,
    notes,
  ];
}
