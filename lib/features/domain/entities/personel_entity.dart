import 'package:equatable/equatable.dart';

class PersonelEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String position;
  final DateTime createdAt;
  final bool isActive;

  const PersonelEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.createdAt,
    this.isActive = true,
  });

  PersonelEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? position,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return PersonelEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    department,
    position,
    createdAt,
    isActive,
  ];
}
