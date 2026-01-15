import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/campus_model.dart';
import 'package:campus_care/features/domain/entities/campus_entity.dart';
import 'package:campus_care/features/domain/repositories/campus_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CampusRepositoryImpl implements CampusRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CampusRepositoryImpl(this._firestore);

  @override
  Future<Result<List<CampusEntity>>> getAllCampuses() async {
    try {
      final snapshot = await _firestore.collection('campuses').get();
      final campuses = snapshot.docs
          .map((doc) => CampusModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(campuses);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CampusEntity>> getCampusById(String id) async {
    try {
      final doc = await _firestore.collection('campuses').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Campus not found');
      }
      final campus = CampusModel.fromJson(doc.data()!).toEntity();
      return Success(campus);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CampusEntity>> createCampus(CampusEntity campus) async {
    try {
      final id = campus.id.isEmpty ? _uuid.v4() : campus.id;
      final campusWithId = CampusEntity(
        id: id,
        name: campus.name,
        address: campus.address,
        latitude: campus.latitude,
        longitude: campus.longitude,
        description: campus.description,
      );
      final model = CampusModel.fromEntity(campusWithId);
      await _firestore.collection('campuses').doc(id).set(model.toJson());
      return Success(campusWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CampusEntity>> updateCampus(CampusEntity campus) async {
    try {
      final model = CampusModel.fromEntity(campus);
      await _firestore
          .collection('campuses')
          .doc(campus.id)
          .update(model.toJson());
      return Success(campus);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteCampus(String id) async {
    try {
      await _firestore.collection('campuses').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
