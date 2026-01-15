import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/maintenance_assignment_entity.dart';

abstract class MaintenanceAssignmentRepository {
  /// Get assignment by request ID
  Future<Result<MaintenanceAssignmentEntity?>> getAssignmentByRequest(
    String requestId,
  );

  /// Get assignments by assigned user
  Future<Result<List<MaintenanceAssignmentEntity>>> getAssignmentsByUser(
    String userId,
  );

  /// Create a new assignment
  Future<Result<MaintenanceAssignmentEntity>> createAssignment(
    MaintenanceAssignmentEntity assignment,
  );

  /// Update an assignment
  Future<Result<MaintenanceAssignmentEntity>> updateAssignment(
    MaintenanceAssignmentEntity assignment,
  );

  /// Delete an assignment
  Future<Result<void>> deleteAssignment(String id);
}
