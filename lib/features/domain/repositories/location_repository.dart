import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/location_entity.dart';

abstract class LocationRepository {
  /// Get location by building
  Future<Result<LocationEntity?>> getLocationByBuilding(String buildingId);

  /// Get a location by ID
  Future<Result<LocationEntity>> getLocationById(String id);

  /// Create a new location
  Future<Result<LocationEntity>> createLocation(LocationEntity location);

  /// Update a location
  Future<Result<LocationEntity>> updateLocation(LocationEntity location);

  /// Delete a location
  Future<Result<void>> deleteLocation(String id);

  /// Get locations near coordinates
  Future<Result<List<LocationEntity>>> getLocationsNear(
    double latitude,
    double longitude,
    double radiusInKm,
  );
}
