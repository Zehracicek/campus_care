import 'package:campus_care/features/domain/entities/personel_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonelModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String position;
  final DateTime createdAt;
  final bool isActive;

  PersonelModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.createdAt,
    required this.isActive,
  });

  factory PersonelModel.fromJson(Map<String, dynamic> json) {
    return PersonelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  PersonelEntity toEntity() {
    return PersonelEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      department: department,
      position: position,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  factory PersonelModel.fromEntity(PersonelEntity entity) {
    return PersonelModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      department: entity.department,
      position: entity.position,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
    );
  }
}
