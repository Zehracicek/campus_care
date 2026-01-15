import 'package:campus_care/features/data/models/personel_model.dart';
import 'package:campus_care/features/domain/entities/personel_entity.dart';
import 'package:campus_care/features/domain/repositories/personel_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PersonelRepositoryImpl implements PersonelRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  PersonelRepositoryImpl(this._firestore);

  @override
  Future<List<PersonelEntity>> getPersonel() async {
    try {
      final snapshot = await _firestore
          .collection('personel')
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => PersonelModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PersonelEntity> createPersonel(PersonelEntity personel) async {
    try {
      final id = personel.id.isEmpty ? _uuid.v4() : personel.id;
      final withId = personel.copyWith(id: id);
      final model = PersonelModel.fromEntity(withId);
      await _firestore.collection('personel').doc(id).set(model.toJson());
      return withId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PersonelEntity> updatePersonel(PersonelEntity personel) async {
    try {
      final model = PersonelModel.fromEntity(personel);
      await _firestore
          .collection('personel')
          .doc(personel.id)
          .update(model.toJson());
      return personel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePersonel(String id) async {
    try {
      await _firestore.collection('personel').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<PersonelEntity>> streamPersonel() {
    return _firestore
        .collection('personel')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PersonelModel.fromJson(doc.data()).toEntity())
              .toList(),
        );
  }
}
