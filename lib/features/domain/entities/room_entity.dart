import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String buildingId;
  final int floor;
  final String type;

  const RoomEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.buildingId,
    required this.floor,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, code, buildingId, floor, type];
}
