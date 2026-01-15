import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';
import 'package:campus_care/features/domain/repositories/academic_calendar_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class AcademicCalendarController
    extends StateNotifier<StateHandler<List<AcademicCalendarEntity>>> {
  final AcademicCalendarRepository _repository;

  AcademicCalendarController(this._repository) : super(StateHandler.initial());

  Future<void> loadAcademicCalendars() async {
    state = StateHandler.loading();
    final result = await _repository.getAllAcademicCalendars();
    result.when(
      success: (calendars) => state = StateHandler.success(data: calendars),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }

  Future<void> createAcademicCalendar(AcademicCalendarEntity entity) async {
    final result = await _repository.createAcademicCalendar(entity);
    result.when(
      success: (_) => loadAcademicCalendars(),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }

  Future<void> updateAcademicCalendar(AcademicCalendarEntity entity) async {
    final result = await _repository.updateAcademicCalendar(entity);
    result.when(
      success: (_) => loadAcademicCalendars(),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }

  Future<void> deleteAcademicCalendar(String id) async {
    final result = await _repository.deleteAcademicCalendar(id);
    result.when(
      success: (_) => loadAcademicCalendars(),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }
}
