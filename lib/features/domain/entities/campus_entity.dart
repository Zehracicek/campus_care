import 'package:equatable/equatable.dart';

class CampusEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;

  const CampusEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    description,
  ];
}
