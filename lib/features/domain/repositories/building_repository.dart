import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/building_entity.dart';

abstract class BuildingRepository {
  /// Get all buildings
  Future<Result<List<BuildingEntity>>> getAllBuildings();

  /// Get buildings by campus
  Future<Result<List<BuildingEntity>>> getBuildingsByCampus(String campusId);

  /// Get a building by ID
  Future<Result<BuildingEntity>> getBuildingById(String id);

  /// Create a new building
  Future<Result<BuildingEntity>> createBuilding(BuildingEntity building);

  /// Update a building
  Future<Result<BuildingEntity>> updateBuilding(BuildingEntity building);

  /// Delete a building
  Future<Result<void>> deleteBuilding(String id);
}
