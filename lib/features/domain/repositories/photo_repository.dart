import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/photo_entity.dart';

abstract class PhotoRepository {
  /// Get photos by request
  Future<Result<List<PhotoEntity>>> getPhotosByRequest(String requestId);

  /// Get photos by type
  Future<Result<List<PhotoEntity>>> getPhotosByType(
    String requestId,
    PhotoType type,
  );

  /// Get a photo by ID
  Future<Result<PhotoEntity>> getPhotoById(String id);

  /// Create a new photo (upload)
  Future<Result<PhotoEntity>> createPhoto(PhotoEntity photo);

  /// Delete a photo
  Future<Result<void>> deletePhoto(String id);

  /// Upload photo file to storage
  Future<Result<String>> uploadPhotoFile(String filePath, String requestId);
}
