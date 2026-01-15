import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:campus_care/features/domain/usecases/event_usecases.dart';
import 'package:flutter_riverpod/legacy.dart';

class EventController extends StateNotifier<StateHandler<List<EventEntity>>> {
  final GetEventsUseCase _getEventsUseCase;
  final CreateEventUseCase _createEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;
  final StreamEventsUseCase _streamEventsUseCase;

  EventController(
    this._getEventsUseCase,
    this._createEventUseCase,
    this._updateEventUseCase,
    this._deleteEventUseCase,
    this._streamEventsUseCase,
  ) : super(StateHandler.initial());

  void streamEvents({bool activeOnly = false}) {
    state = StateHandler.loading();
    _streamEventsUseCase(activeOnly: activeOnly).listen(
      (events) {
        if (events.isEmpty) {
          state = StateHandler.empty();
        } else {
          state = StateHandler.success(data: events);
        }
      },
      onError: (error) {
        state = StateHandler.error(message: error.toString());
      },
    );
  }

  Future<void> loadEvents({bool activeOnly = false}) async {
    state = StateHandler.loading();
    final result = await _getEventsUseCase(activeOnly: activeOnly);
    result.when(
      success: (events) {
        if (events.isEmpty) {
          state = StateHandler.empty();
        } else {
          state = StateHandler.success(data: events);
        }
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );
  }

  Future<Result<EventEntity>> createEvent(EventEntity event) async {
    final result = await _createEventUseCase(params: CreateEventParams(event));
    result.when(success: (_) => loadEvents(), failure: (_) {});
    return result;
  }

  Future<Result<EventEntity>> updateEvent(EventEntity event) async {
    final result = await _updateEventUseCase(params: UpdateEventParams(event));
    result.when(success: (_) => loadEvents(), failure: (_) {});
    return result;
  }

  Future<Result<void>> deleteEvent(String id) async {
    final result = await _deleteEventUseCase(params: DeleteEventParams(id));
    result.when(success: (_) => loadEvents(), failure: (_) {});
    return result;
  }
}
