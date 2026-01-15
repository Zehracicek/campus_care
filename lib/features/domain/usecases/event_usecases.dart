import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:campus_care/features/domain/repositories/event_repository.dart';

class GetEventsUseCase {
  final EventRepository repository;
  GetEventsUseCase(this.repository);

  Future<Result<List<EventEntity>>> call({bool activeOnly = true}) {
    return repository.getEvents(activeOnly: activeOnly);
  }
}

class CreateEventUseCase {
  final EventRepository repository;
  CreateEventUseCase(this.repository);

  Future<Result<EventEntity>> call({required CreateEventParams params}) {
    return repository.createEvent(params.event);
  }
}

class UpdateEventUseCase {
  final EventRepository repository;
  UpdateEventUseCase(this.repository);

  Future<Result<EventEntity>> call({required UpdateEventParams params}) {
    return repository.updateEvent(params.event);
  }
}

class DeleteEventUseCase {
  final EventRepository repository;
  DeleteEventUseCase(this.repository);

  Future<Result<void>> call({required DeleteEventParams params}) {
    return repository.deleteEvent(params.id);
  }
}

class StreamEventsUseCase {
  final EventRepository repository;
  StreamEventsUseCase(this.repository);

  Stream<List<EventEntity>> call({bool activeOnly = true}) {
    return repository.streamEvents(activeOnly: activeOnly);
  }
}

class CreateEventParams {
  final EventEntity event;
  CreateEventParams(this.event);
}

class UpdateEventParams {
  final EventEntity event;
  UpdateEventParams(this.event);
}

class DeleteEventParams {
  final String id;
  DeleteEventParams(this.id);
}
