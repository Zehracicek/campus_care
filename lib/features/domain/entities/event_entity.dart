import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location; // human-readable address or label
  final double? latitude;
  final double? longitude;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;
  final bool isActive;
  final List<String> photoUrls;

  const EventEntity({
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
    this.isActive = true,
    this.photoUrls = const [],
  });

  EventEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    double? latitude,
    double? longitude,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
    bool? isActive,
    List<String>? photoUrls,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    eventDate,
    location,
    latitude,
    longitude,
    createdById,
    createdByName,
    createdAt,
    isActive,
    photoUrls,
  ];
}
