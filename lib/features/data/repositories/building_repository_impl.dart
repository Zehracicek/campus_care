import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/building_model.dart';
import 'package:campus_care/features/domain/entities/building_entity.dart';
import 'package:campus_care/features/domain/repositories/building_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  BuildingRepositoryImpl(this._firestore);

  @override
  Future<Result<List<BuildingEntity>>> getAllBuildings() async {
    try {
      final snapshot = await _firestore.collection('buildings').get();
      final buildings = snapshot.docs
          .map((doc) => BuildingModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(buildings);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<BuildingEntity>>> getBuildingsByCampus(
    String campusId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('buildings')
          .where('campusId', isEqualTo: campusId)
          .get();
      final buildings = snapshot.docs
          .map((doc) => BuildingModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(buildings);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<BuildingEntity>> getBuildingById(String id) async {
    try {
      final doc = await _firestore.collection('buildings').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Building not found');
      }
      final building = BuildingModel.fromJson(doc.data()!).toEntity();
      return Success(building);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<BuildingEntity>> createBuilding(BuildingEntity building) async {
    try {
      final id = building.id.isEmpty ? _uuid.v4() : building.id;
      final buildingWithId = BuildingEntity(
        id: id,
        name: building.name,
        code: building.code,
        campusId: building.campusId,
        floorCount: building.floorCount,
        locationId: building.locationId,
      );
      final model = BuildingModel.fromEntity(buildingWithId);
      await _firestore.collection('buildings').doc(id).set(model.toJson());
      return Success(buildingWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<BuildingEntity>> updateBuilding(BuildingEntity building) async {
    try {
      final model = BuildingModel.fromEntity(building);
      await _firestore
          .collection('buildings')
          .doc(building.id)
          .update(model.toJson());
      return Success(building);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteBuilding(String id) async {
    try {
      await _firestore.collection('buildings').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
