import 'package:equatable/equatable.dart';

class UserRoleEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;

  const UserRoleEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, description, permissions];
}
