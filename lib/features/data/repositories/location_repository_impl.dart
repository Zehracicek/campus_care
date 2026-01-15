import 'dart:math';

import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/location_model.dart';
import 'package:campus_care/features/domain/entities/location_entity.dart';
import 'package:campus_care/features/domain/repositories/location_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LocationRepositoryImpl implements LocationRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  LocationRepositoryImpl(this._firestore);

  @override
  Future<Result<LocationEntity?>> getLocationByBuilding(
    String buildingId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .where('buildingId', isEqualTo: buildingId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return Success(null);
      }
      final location = LocationModel.fromJson(
        snapshot.docs.first.data(),
      ).toEntity();
      return Success(location);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<LocationEntity>> getLocationById(String id) async {
    try {
      final doc = await _firestore.collection('locations').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Location not found');
      }
      final location = LocationModel.fromJson(doc.data()!).toEntity();
      return Success(location);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<LocationEntity>> createLocation(LocationEntity location) async {
    try {
      final id = location.id.isEmpty ? _uuid.v4() : location.id;
      final locationWithId = LocationEntity(
        id: id,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        buildingId: location.buildingId,
        metadata: location.metadata,
      );
      final model = LocationModel.fromEntity(locationWithId);
      await _firestore.collection('locations').doc(id).set(model.toJson());
      return Success(locationWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<LocationEntity>> updateLocation(LocationEntity location) async {
    try {
      final model = LocationModel.fromEntity(location);
      await _firestore
          .collection('locations')
          .doc(location.id)
          .update(model.toJson());
      return Success(location);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteLocation(String id) async {
    try {
      await _firestore.collection('locations').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<LocationEntity>>> getLocationsNear(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      // Note: Firestore doesn't support geospatial queries natively
      // This is a simplified implementation. For production, consider using GeoFlutterFire
      final snapshot = await _firestore.collection('locations').get();
      final locations = snapshot.docs
          .map((doc) => LocationModel.fromJson(doc.data()).toEntity())
          .where((location) {
            final distance = _calculateDistance(
              latitude,
              longitude,
              location.latitude,
              location.longitude,
            );
            return distance <= radiusInKm;
          })
          .toList();
      return Success(locations);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  // Haversine formula for distance calculation
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
