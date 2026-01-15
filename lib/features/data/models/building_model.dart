import 'package:campus_care/features/domain/entities/building_entity.dart';

class BuildingModel {
  final String id;
  final String name;
  final String code;
  final String campusId;
  final int floorCount;
  final String? locationId;

  BuildingModel({
    required this.id,
    required this.name,
    required this.code,
    required this.campusId,
    required this.floorCount,
    this.locationId,
  });

  // Convert from Firestore document
  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      campusId: json['campusId'] as String,
      floorCount: json['floorCount'] as int,
      locationId: json['locationId'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'campusId': campusId,
      'floorCount': floorCount,
      'locationId': locationId,
    };
  }

  // Convert to domain entity
  BuildingEntity toEntity() {
    return BuildingEntity(
      id: id,
      name: name,
      code: code,
      campusId: campusId,
      floorCount: floorCount,
      locationId: locationId,
    );
  }

  // Convert from domain entity
  factory BuildingModel.fromEntity(BuildingEntity entity) {
    return BuildingModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      campusId: entity.campusId,
      floorCount: entity.floorCount,
      locationId: entity.locationId,
    );
  }
}
