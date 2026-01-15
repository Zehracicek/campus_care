import 'package:equatable/equatable.dart';

class FixtureEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final DateTime createdAt;
  final String createdById;

  const FixtureEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.createdAt,
    required this.createdById,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    quantity,
    createdAt,
    createdById,
  ];
}
