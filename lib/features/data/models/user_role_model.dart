import 'package:campus_care/features/domain/entities/user_role_entity.dart';

class UserRoleModel {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;

  UserRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  // Convert from Firestore document
  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }

  // Convert to domain entity
  UserRoleEntity toEntity() {
    return UserRoleEntity(
      id: id,
      name: name,
      description: description,
      permissions: permissions,
    );
  }

  // Convert from domain entity
  factory UserRoleModel.fromEntity(UserRoleEntity entity) {
    return UserRoleModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      permissions: entity.permissions,
    );
  }
}
