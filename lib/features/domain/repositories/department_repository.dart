import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';

abstract class DepartmentRepository {
  /// Get all departments
  Future<Result<List<DepartmentEntity>>> getAllDepartments();

  /// Get departments by campus
  Future<Result<List<DepartmentEntity>>> getDepartmentsByCampus(
    String campusId,
  );

  /// Get a department by ID
  Future<Result<DepartmentEntity>> getDepartmentById(String id);

  /// Create a new department
  Future<Result<DepartmentEntity>> createDepartment(
    DepartmentEntity department,
  );

  /// Update a department
  Future<Result<DepartmentEntity>> updateDepartment(
    DepartmentEntity department,
  );

  /// Delete a department
  Future<Result<void>> deleteDepartment(String id);
}
