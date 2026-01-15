import 'package:campus_care/features/domain/entities/location_entity.dart';

class LocationModel {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String? buildingId;
  final Map<String, dynamic>? metadata;

  LocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.buildingId,
    this.metadata,
  });

  // Convert from Firestore document
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      buildingId: json['buildingId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'buildingId': buildingId,
      'metadata': metadata,
    };
  }

  // Convert to domain entity
  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      latitude: latitude,
      longitude: longitude,
      address: address,
      buildingId: buildingId,
      metadata: metadata,
    );
  }

  // Convert from domain entity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      buildingId: entity.buildingId,
      metadata: entity.metadata,
    );
  }
}
