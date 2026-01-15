import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/demirbas_model.dart';
import 'package:campus_care/features/domain/entities/fixture_entity.dart';
import 'package:campus_care/features/domain/repositories/demirbas_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'demirbaslar';

  FixtureRepositoryImpl(this._firestore);

  @override
  Future<Result<List<FixtureEntity>>> getAllDemirbas() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final items = snapshot.docs
          .map((doc) => FixtureModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Success(items);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> createDemirbas(FixtureEntity entity) async {
    try {
      final model = FixtureModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        quantity: entity.quantity,
        createdAt: entity.createdAt,
        createdById: entity.createdById,
      );

      await _firestore.collection(_collection).add(model.toJson());
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteDemirbas(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
