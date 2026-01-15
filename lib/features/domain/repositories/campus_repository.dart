import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/campus_entity.dart';

abstract class CampusRepository {
  /// Get all campuses
  Future<Result<List<CampusEntity>>> getAllCampuses();

  /// Get a campus by ID
  Future<Result<CampusEntity>> getCampusById(String id);

  /// Create a new campus
  Future<Result<CampusEntity>> createCampus(CampusEntity campus);

  /// Update a campus
  Future<Result<CampusEntity>> updateCampus(CampusEntity campus);

  /// Delete a campus
  Future<Result<void>> deleteCampus(String id);
}
