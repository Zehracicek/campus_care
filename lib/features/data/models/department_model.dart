import 'package:campus_care/features/domain/entities/department_entity.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String? managerId;
  final String campusId;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    this.managerId,
    required this.campusId,
  });

  // Convert from Firestore document
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      managerId: json['managerId'] as String?,
      campusId: json['campusId'] as String,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'managerId': managerId,
      'campusId': campusId,
    };
  }

  // Convert to domain entity
  DepartmentEntity toEntity() {
    return DepartmentEntity(
      id: id,
      name: name,
      description: description,
      managerId: managerId,
      campusId: campusId,
    );
  }

  // Convert from domain entity
  factory DepartmentModel.fromEntity(DepartmentEntity entity) {
    return DepartmentModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      managerId: entity.managerId,
      campusId: entity.campusId ?? '',
    );
  }
}
