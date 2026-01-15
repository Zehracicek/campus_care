import 'package:campus_care/features/domain/entities/campus_entity.dart';

class CampusModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;

  CampusModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  // Convert from Firestore document
  factory CampusModel.fromJson(Map<String, dynamic> json) {
    return CampusModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
    };
  }

  // Convert to domain entity
  CampusEntity toEntity() {
    return CampusEntity(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description ?? '',
    );
  }

  // Convert from domain entity
  factory CampusModel.fromEntity(CampusEntity entity) {
    return CampusModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      description: entity.description,
    );
  }
}
