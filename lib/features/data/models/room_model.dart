import 'package:campus_care/features/domain/entities/room_entity.dart';

class RoomModel {
  final String id;
  final String name;
  final String code;
  final String buildingId;
  final int floor;
  final String? type;

  RoomModel({
    required this.id,
    required this.name,
    required this.code,
    required this.buildingId,
    required this.floor,
    this.type,
  });

  // Convert from Firestore document
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      buildingId: json['buildingId'] as String,
      floor: json['floor'] as int,
      type: json['type'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'buildingId': buildingId,
      'floor': floor,
      'type': type,
    };
  }

  // Convert to domain entity
  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      name: name,
      code: code,
      buildingId: buildingId,
      floor: floor,
      type: type ?? '',
    );
  }

  // Convert from domain entity
  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      buildingId: entity.buildingId,
      floor: entity.floor,
      type: entity.type,
    );
  }
}
