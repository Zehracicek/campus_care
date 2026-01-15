import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/maintenance_history_entity.dart';

abstract class MaintenanceHistoryRepository {
  /// Get history by request ID
  Future<Result<List<MaintenanceHistoryEntity>>> getHistoryByRequest(
    String requestId,
  );

  /// Create a history entry
  Future<Result<MaintenanceHistoryEntity>> createHistory(
    MaintenanceHistoryEntity history,
  );

  /// Get history by user
  Future<Result<List<MaintenanceHistoryEntity>>> getHistoryByUser(
    String userId,
  );
}
