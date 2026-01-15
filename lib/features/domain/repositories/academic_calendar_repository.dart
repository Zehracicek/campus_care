import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';

abstract class AcademicCalendarRepository {
  Future<Result<List<AcademicCalendarEntity>>> getAllAcademicCalendars();
  Stream<Result<List<AcademicCalendarEntity>>> streamAcademicCalendars();
  Future<Result<void>> createAcademicCalendar(AcademicCalendarEntity entity);
  Future<Result<void>> updateAcademicCalendar(AcademicCalendarEntity entity);
  Future<Result<void>> deleteAcademicCalendar(String id);
}
