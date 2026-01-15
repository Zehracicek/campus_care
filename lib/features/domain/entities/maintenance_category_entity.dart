import 'package:equatable/equatable.dart';

class MaintenanceCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String departmentId;
  final int estimatedHours;

  const MaintenanceCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.departmentId,
    required this.estimatedHours,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    icon,
    departmentId,
    estimatedHours,
  ];
}
