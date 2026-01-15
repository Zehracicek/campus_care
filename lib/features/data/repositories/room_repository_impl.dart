import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/room_model.dart';
import 'package:campus_care/features/domain/entities/room_entity.dart';
import 'package:campus_care/features/domain/repositories/room_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  RoomRepositoryImpl(this._firestore);

  @override
  Future<Result<List<RoomEntity>>> getAllRooms() async {
    try {
      final snapshot = await _firestore.collection('rooms').get();
      final rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(rooms);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<RoomEntity>>> getRoomsByBuilding(String buildingId) async {
    try {
      final snapshot = await _firestore
          .collection('rooms')
          .where('buildingId', isEqualTo: buildingId)
          .get();
      final rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(rooms);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<RoomEntity>>> getRoomsByFloor(
    String buildingId,
    int floor,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('rooms')
          .where('buildingId', isEqualTo: buildingId)
          .where('floor', isEqualTo: floor)
          .get();
      final rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(rooms);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<RoomEntity>> getRoomById(String id) async {
    try {
      final doc = await _firestore.collection('rooms').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Room not found');
      }
      final room = RoomModel.fromJson(doc.data()!).toEntity();
      return Success(room);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<RoomEntity>> createRoom(RoomEntity room) async {
    try {
      final id = room.id.isEmpty ? _uuid.v4() : room.id;
      final roomWithId = RoomEntity(
        id: id,
        name: room.name,
        code: room.code,
        buildingId: room.buildingId,
        floor: room.floor,
        type: room.type,
      );
      final model = RoomModel.fromEntity(roomWithId);
      await _firestore.collection('rooms').doc(id).set(model.toJson());
      return Success(roomWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<RoomEntity>> updateRoom(RoomEntity room) async {
    try {
      final model = RoomModel.fromEntity(room);
      await _firestore.collection('rooms').doc(room.id).update(model.toJson());
      return Success(room);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteRoom(String id) async {
    try {
      await _firestore.collection('rooms').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
