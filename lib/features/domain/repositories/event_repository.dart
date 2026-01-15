import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';

abstract class EventRepository {
  Future<Result<List<EventEntity>>> getEvents({bool activeOnly = true});
  Future<Result<EventEntity>> createEvent(EventEntity event);
  Future<Result<EventEntity>> updateEvent(EventEntity event);
  Future<Result<void>> deleteEvent(String id);
  Stream<List<EventEntity>> streamEvents({bool activeOnly = true});
}
