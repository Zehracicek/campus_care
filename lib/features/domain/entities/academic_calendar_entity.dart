import 'package:equatable/equatable.dart';

enum AcademicCalendarType {
  semesterStart,
  semesterEnd,
  midterm,
  finalExam,
  registration,
  addDrop,
  holiday,
  other,
}

class AcademicCalendarEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final AcademicCalendarType type;
  final DateTime createdAt;
  final String createdById;

  const AcademicCalendarEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.createdAt,
    required this.createdById,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    type,
    createdAt,
    createdById,
  ];
}
