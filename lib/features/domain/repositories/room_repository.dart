import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/room_entity.dart';

abstract class RoomRepository {
  /// Get all rooms
  Future<Result<List<RoomEntity>>> getAllRooms();

  /// Get rooms by building
  Future<Result<List<RoomEntity>>> getRoomsByBuilding(String buildingId);

  /// Get rooms by floor
  Future<Result<List<RoomEntity>>> getRoomsByFloor(
    String buildingId,
    int floor,
  );

  /// Get a room by ID
  Future<Result<RoomEntity>> getRoomById(String id);

  /// Create a new room
  Future<Result<RoomEntity>> createRoom(RoomEntity room);

  /// Update a room
  Future<Result<RoomEntity>> updateRoom(RoomEntity room);

  /// Delete a room
  Future<Result<void>> deleteRoom(String id);
}
