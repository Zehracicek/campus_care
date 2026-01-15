import 'package:campus_care/features/domain/entities/fixture_entity.dart';

class FixtureModel extends FixtureEntity {
  const FixtureModel({
    required super.id,
    required super.name,
    required super.description,
    required super.quantity,
    required super.createdAt,
    required super.createdById,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      createdById: json['createdById'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
    };
  }
}
