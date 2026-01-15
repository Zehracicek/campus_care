import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';

abstract class UserRepository {
  /// Get user by ID
  Future<Result<UserEntity>> getUserById(String id);

  /// Get users by role
  Future<Result<List<UserEntity>>> getUsersByRole(String roleId);

  /// Get users by department
  Future<Result<List<UserEntity>>> getUsersByDepartment(String departmentId);

  /// Create or update user profile
  Future<Result<UserEntity>> updateUserProfile(UserEntity user);

  /// Delete user
  Future<Result<void>> deleteUser(String id);

  /// Search users by name or email
  Future<Result<List<UserEntity>>> searchUsers(String query);
}
