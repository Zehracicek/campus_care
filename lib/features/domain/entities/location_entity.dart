import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String? buildingId;
  final Map<String, dynamic>? metadata;

  const LocationEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.buildingId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    latitude,
    longitude,
    address,
    buildingId,
    metadata,
  ];
}
