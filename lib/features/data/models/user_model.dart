import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final String? roleId;
  final String? departmentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    this.roleId,
    this.departmentId,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      roleId: json['roleId'] as String?,
      departmentId: json['departmentId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'roleId': roleId,
      'departmentId': departmentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: name,
      photoUrl: photoUrl,
      phone: phone,
      roleId: roleId,
      departmentId: departmentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.displayName ?? '',
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      roleId: entity.roleId,
      departmentId: entity.departmentId,
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt,
    );
  }
}
