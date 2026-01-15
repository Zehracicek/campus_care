import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/event_model.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:campus_care/features/domain/repositories/event_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  EventRepositoryImpl(this._firestore);

  @override
  Future<Result<List<EventEntity>>> getEvents({bool activeOnly = true}) async {
    try {
      Query query = _firestore.collection('events');
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      final snapshot = await query.orderBy('eventDate').get();
      final events = snapshot.docs
          .map(
            (doc) => EventModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      return Success(events);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<EventEntity>> createEvent(EventEntity event) async {
    try {
      final id = event.id.isEmpty ? _uuid.v4() : event.id;
      final withId = event.copyWith(id: id);
      final model = EventModel.fromEntity(withId);
      await _firestore.collection('events').doc(id).set(model.toJson());
      return Success(withId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<EventEntity>> updateEvent(EventEntity event) async {
    try {
      final model = EventModel.fromEntity(event);
      await _firestore
          .collection('events')
          .doc(event.id)
          .update(model.toJson());
      return Success(event);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<List<EventEntity>> streamEvents({bool activeOnly = true}) {
    Query query = _firestore.collection('events');
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    return query
        .orderBy('eventDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EventModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ).toEntity(),
              )
              .toList(),
        );
  }
}
