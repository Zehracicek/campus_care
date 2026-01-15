import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/photo_entity.dart';
import 'package:campus_care/features/domain/repositories/photo_repository.dart';

class GetPhotosParams {
  final String requestId;

  GetPhotosParams(this.requestId);
}

class GetPhotosUseCase
    implements FutureUseCase<Result<List<PhotoEntity>>, GetPhotosParams> {
  final PhotoRepository _repository;

  GetPhotosUseCase(this._repository);

  @override
  Future<Result<List<PhotoEntity>>> call({GetPhotosParams? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'GetPhotosParams is required'));
    }
    return _repository.getPhotosByRequest(params.requestId);
  }
}

class UploadPhotoParams {
  final PhotoEntity photo;

  UploadPhotoParams(this.photo);
}

class UploadPhotoUseCase
    implements FutureUseCase<Result<PhotoEntity>, UploadPhotoParams> {
  final PhotoRepository _repository;

  UploadPhotoUseCase(this._repository);

  @override
  Future<Result<PhotoEntity>> call({UploadPhotoParams? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'UploadPhotoParams is required'));
    }
    return _repository.createPhoto(params.photo);
  }
}
