import 'package:equatable/equatable.dart';

class DepartmentEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? managerId;
  final String? campusId;

  const DepartmentEntity({
    required this.id,
    required this.name,
    required this.description,
    this.managerId,
    this.campusId,
  });

  @override
  List<Object?> get props => [id, name, description, managerId, campusId];
}
