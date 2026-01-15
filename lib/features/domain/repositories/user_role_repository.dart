import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/user_role_entity.dart';

abstract class UserRoleRepository {
  /// Get all user roles
  Future<Result<List<UserRoleEntity>>> getAllRoles();

  /// Get a role by ID
  Future<Result<UserRoleEntity>> getRoleById(String id);

  /// Create a new role
  Future<Result<UserRoleEntity>> createRole(UserRoleEntity role);

  /// Update a role
  Future<Result<UserRoleEntity>> updateRole(UserRoleEntity role);

  /// Delete a role
  Future<Result<void>> deleteRole(String id);
}
