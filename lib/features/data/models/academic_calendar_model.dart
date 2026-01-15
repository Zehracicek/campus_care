import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';

class AcademicCalendarModel extends AcademicCalendarEntity {
  const AcademicCalendarModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.type,
    required super.createdAt,
    required super.createdById,
  });

  factory AcademicCalendarModel.fromJson(Map<String, dynamic> json) {
    return AcademicCalendarModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : DateTime.now(),
      type: _parseType(json['type']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      createdById: json['createdById'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
    };
  }

  static AcademicCalendarType _parseType(dynamic typeStr) {
    if (typeStr == null) return AcademicCalendarType.other;

    final str = typeStr.toString().toLowerCase();
    for (final type in AcademicCalendarType.values) {
      if (type.toString().split('.').last.toLowerCase() == str) {
        return type;
      }
    }
    return AcademicCalendarType.other;
  }
}
