import 'package:equatable/equatable.dart';

class MaintenanceHistoryEntity extends Equatable {
  final String id;
  final String requestId;
  final String userId;
  final String action;
  final String? oldStatus;
  final String? newStatus;
  final String? notes;
  final DateTime timestamp;

  const MaintenanceHistoryEntity({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.action,
    this.oldStatus,
    this.newStatus,
    this.notes,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    requestId,
    userId,
    action,
    oldStatus,
    newStatus,
    notes,
    timestamp,
  ];
}
