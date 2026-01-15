import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/photo_model.dart';
import 'package:campus_care/features/domain/entities/photo_entity.dart';
import 'package:campus_care/features/domain/repositories/photo_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  PhotoRepositoryImpl(this._firestore);

  @override
  Future<Result<List<PhotoEntity>>> getPhotosByRequest(String requestId) async {
    try {
      final snapshot = await _firestore
          .collection('photos')
          .where('requestId', isEqualTo: requestId)
          .orderBy('uploadedAt', descending: false)
          .get();
      final photos = snapshot.docs
          .map((doc) => PhotoModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(photos);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<PhotoEntity>>> getPhotosByType(
    String requestId,
    PhotoType type,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('photos')
          .where('requestId', isEqualTo: requestId)
          .where('type', isEqualTo: type.name)
          .orderBy('uploadedAt', descending: false)
          .get();
      final photos = snapshot.docs
          .map((doc) => PhotoModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(photos);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<PhotoEntity>> getPhotoById(String id) async {
    try {
      final doc = await _firestore.collection('photos').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Photo not found');
      }
      final photo = PhotoModel.fromJson(doc.data()!).toEntity();
      return Success(photo);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<PhotoEntity>> createPhoto(PhotoEntity photo) async {
    try {
      final id = photo.id.isEmpty ? _uuid.v4() : photo.id;
      final photoWithId = PhotoEntity(
        id: id,
        requestId: photo.requestId,
        url: photo.url,
        type: photo.type,
        uploadedBy: photo.uploadedBy,
        uploadedAt: photo.uploadedAt,
      );
      final model = PhotoModel.fromEntity(photoWithId);
      await _firestore.collection('photos').doc(id).set(model.toJson());
      return Success(photoWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deletePhoto(String id) async {
    try {
      await _firestore.collection('photos').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<String>> uploadPhotoFile(
    String filePath,
    String requestId,
  ) async {
    try {
      // Firebase Storage integration will be implemented when camera module is added
      // For now, return a placeholder
      return Failure(message: 'Photo upload not yet implemented');
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
