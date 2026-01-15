import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';

abstract class MaintenanceRequestRepository {
  /// Get all maintenance requests
  Future<Result<List<MaintenanceRequestEntity>>> getAllRequests();

  /// Get requests by user
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByUser(
    String userId,
  );

  /// Get requests by status
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByStatus(
    MaintenanceStatus status,
  );

  /// Get requests by priority
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByPriority(
    MaintenancePriority priority,
  );

  /// Get requests by category
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByCategory(
    String categoryId,
  );

  /// Get a request by ID
  Future<Result<MaintenanceRequestEntity>> getRequestById(String id);

  /// Create a new request
  Future<Result<MaintenanceRequestEntity>> createRequest(
    MaintenanceRequestEntity request,
  );

  /// Update a request
  Future<Result<MaintenanceRequestEntity>> updateRequest(
    MaintenanceRequestEntity request,
  );

  /// Update request status
  Future<Result<MaintenanceRequestEntity>> updateRequestStatus(
    String id,
    MaintenanceStatus status,
  );

  /// Delete a request
  Future<Result<void>> deleteRequest(String id);

  /// Get requests near location (for map)
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  );

  /// Stream requests for real-time updates
  Stream<Result<List<MaintenanceRequestEntity>>> streamRequests();
}
