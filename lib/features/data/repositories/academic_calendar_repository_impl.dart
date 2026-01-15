import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/academic_calendar_model.dart';
import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';
import 'package:campus_care/features/domain/repositories/academic_calendar_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicCalendarRepositoryImpl implements AcademicCalendarRepository {
  final FirebaseFirestore _firestore;

  AcademicCalendarRepositoryImpl(this._firestore);

  static const String _collection = 'academic_calendars';

  @override
  Future<Result<List<AcademicCalendarEntity>>> getAllAcademicCalendars() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('startDate', descending: false)
          .get();

      final calendars = snapshot.docs
          .map(
            (doc) =>
                AcademicCalendarModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();

      return Success(calendars);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<Result<List<AcademicCalendarEntity>>> streamAcademicCalendars() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('startDate', descending: false)
          .snapshots()
          .map((snapshot) {
            final calendars = snapshot.docs
                .map(
                  (doc) => AcademicCalendarModel.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }),
                )
                .toList();
            return Success(calendars);
          });
    } catch (e) {
      return Stream.value(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> createAcademicCalendar(
    AcademicCalendarEntity entity,
  ) async {
    try {
      final model = AcademicCalendarModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        startDate: entity.startDate,
        endDate: entity.endDate,
        type: entity.type,
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
  Future<Result<void>> updateAcademicCalendar(
    AcademicCalendarEntity entity,
  ) async {
    try {
      final model = AcademicCalendarModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        startDate: entity.startDate,
        endDate: entity.endDate,
        type: entity.type,
        createdAt: entity.createdAt,
        createdById: entity.createdById,
      );

      await _firestore
          .collection(_collection)
          .doc(entity.id)
          .update(model.toJson());
      return Success(null); 
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAcademicCalendar(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
