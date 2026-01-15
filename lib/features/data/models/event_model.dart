import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final double? latitude;
  final double? longitude;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;
  final bool isActive;
  final List<String> photoUrls;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.latitude,
    this.longitude,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.isActive,
    this.photoUrls = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    double? parseFallbackLat;
    double? parseFallbackLng;
    final locationValue = json['location'] as String? ?? '';
    if (locationValue.contains(',')) {
      final parts = locationValue.split(',');
      if (parts.length == 2) {
        parseFallbackLat = double.tryParse(parts[0]);
        parseFallbackLng = double.tryParse(parts[1]);
      }
    }

    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      location: locationValue,
      latitude: (json['latitude'] as num?)?.toDouble() ?? parseFallbackLat,
      longitude: (json['longitude'] as num?)?.toDouble() ?? parseFallbackLng,
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isActive: json['isActive'] as bool? ?? true,
      photoUrls:
          (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'photoUrls': photoUrls,
    };
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      location: location,
      latitude: latitude,
      longitude: longitude,
      createdById: createdById,
      createdByName: createdByName,
      createdAt: createdAt,
      isActive: isActive,
      photoUrls: photoUrls,
    );
  }

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      eventDate: entity.eventDate,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdById: entity.createdById,
      createdByName: entity.createdByName,
      createdAt: entity.createdAt,
      isActive: entity.isActive,
      photoUrls: entity.photoUrls,
    );
  }
}
