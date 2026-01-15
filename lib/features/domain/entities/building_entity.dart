import 'package:equatable/equatable.dart';

class BuildingEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String campusId;
  final int floorCount;
  final String? locationId;

  const BuildingEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.campusId,
    required this.floorCount,
    this.locationId,
  });

  @override
  List<Object?> get props => [id, name, code, campusId, floorCount, locationId];
}
