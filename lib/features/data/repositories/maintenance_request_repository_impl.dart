import 'dart:math';

import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/maintenance_request_model.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MaintenanceRequestRepositoryImpl implements MaintenanceRequestRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MaintenanceRequestRepositoryImpl(this._firestore);

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getAllRequests() async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByUser(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByStatus(
    MaintenanceStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByPriority(
    MaintenancePriority priority,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .where('priority', isEqualTo: priority.name)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsByCategory(
    String categoryId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();
      final requests = snapshot.docs
          .map((doc) => MaintenanceRequestModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceRequestEntity>> getRequestById(String id) async {
    try {
      final doc = await _firestore
          .collection('maintenanceRequests')
          .doc(id)
          .get();
      if (!doc.exists) {
        return Failure(message: 'Request not found');
      }
      final request = MaintenanceRequestModel.fromJson(doc.data()!).toEntity();
      return Success(request);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceRequestEntity>> createRequest(
    MaintenanceRequestEntity request,
  ) async {
    try {
      final id = request.id.isEmpty ? _uuid.v4() : request.id;
      final requestWithId = MaintenanceRequestEntity(
        id: id,
        title: request.title,
        description: request.description,
        userId: request.userId,
        categoryId: request.categoryId,
        locationId: request.locationId,
        roomId: request.roomId,
        priority: request.priority,
        status: request.status,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
        completedAt: request.completedAt,
        photoUrls: request.photoUrls,
        adminNote: request.adminNote,
      );
      final model = MaintenanceRequestModel.fromEntity(requestWithId);
      await _firestore
          .collection('maintenanceRequests')
          .doc(id)
          .set(model.toJson());
      return Success(requestWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceRequestEntity>> updateRequest(
    MaintenanceRequestEntity request,
  ) async {
    try {
      final model = MaintenanceRequestModel.fromEntity(request);
      await _firestore
          .collection('maintenanceRequests')
          .doc(request.id)
          .update(model.toJson());
      return Success(request);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceRequestEntity>> updateRequestStatus(
    String id,
    MaintenanceStatus status,
  ) async {
    try {
      await _firestore.collection('maintenanceRequests').doc(id).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
        if (status == MaintenanceStatus.completed)
          'completedAt': Timestamp.now(),
      });
      final result = await getRequestById(id);
      return result;
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteRequest(String id) async {
    try {
      await _firestore.collection('maintenanceRequests').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceRequestEntity>>> getRequestsNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      // Get all requests with locationId
      final snapshot = await _firestore
          .collection('maintenanceRequests')
          .where('locationId', isNotEqualTo: null)
          .get();

      final requests = <MaintenanceRequestEntity>[];
      for (final doc in snapshot.docs) {
        final request = MaintenanceRequestModel.fromJson(doc.data()).toEntity();
        // Fetch location and check distance
        final locationDoc = await _firestore
            .collection('locations')
            .doc(request.locationId)
            .get();
        if (locationDoc.exists) {
          final locationData = locationDoc.data()!;
          final locLat = (locationData['latitude'] as num).toDouble();
          final locLon = (locationData['longitude'] as num).toDouble();
          if (_calculateDistance(latitude, longitude, locLat, locLon) <=
              radiusInKm) {
            requests.add(request);
          }
        }
      }
      return Success(requests);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<Result<List<MaintenanceRequestEntity>>> streamRequests() {
    try {
      return _firestore
          .collection('maintenanceRequests')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final requests = snapshot.docs
                .map(
                  (doc) =>
                      MaintenanceRequestModel.fromJson(doc.data()).toEntity(),
                )
                .toList();
            return Success(requests);
          });
    } catch (e) {
      return Stream.value(Failure(message: e.toString()));
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;
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
