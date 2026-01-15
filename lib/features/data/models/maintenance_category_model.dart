import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';

class MaintenanceCategoryModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String departmentId;
  final int estimatedHours;

  MaintenanceCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.departmentId,
    required this.estimatedHours,
  });

  // Convert from Firestore document
  factory MaintenanceCategoryModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '',
      departmentId: json['departmentId'] as String? ?? '',
      estimatedHours: json['estimatedHours'] as int? ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'departmentId': departmentId,
      'estimatedHours': estimatedHours,
    };
  }

  // Convert to domain entity
  MaintenanceCategoryEntity toEntity() {
    return MaintenanceCategoryEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      departmentId: departmentId,
      estimatedHours: estimatedHours,
    );
  }

  // Convert from domain entity
  factory MaintenanceCategoryModel.fromEntity(
    MaintenanceCategoryEntity entity,
  ) {
    return MaintenanceCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      departmentId: entity.departmentId,
      estimatedHours: entity.estimatedHours,
    );
  }
}
