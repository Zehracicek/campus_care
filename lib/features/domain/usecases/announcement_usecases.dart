import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';
import 'package:campus_care/features/domain/repositories/announcement_repository.dart';

// Get all announcements
class GetAnnouncementsUseCase
    implements FutureUseCase<Result<List<AnnouncementEntity>>, NoParams> {
  final AnnouncementRepository _repository;

  GetAnnouncementsUseCase(this._repository);

  @override
  Future<Result<List<AnnouncementEntity>>> call({NoParams? params}) {
    return _repository.getAllAnnouncements();
  }
}

// Get announcement by ID
class GetAnnouncementByIdParams {
  final String id;

  GetAnnouncementByIdParams(this.id);
}

class GetAnnouncementByIdUseCase
    implements
        FutureUseCase<Result<AnnouncementEntity>, GetAnnouncementByIdParams> {
  final AnnouncementRepository _repository;

  GetAnnouncementByIdUseCase(this._repository);

  @override
  Future<Result<AnnouncementEntity>> call({GetAnnouncementByIdParams? params}) {
    if (params == null) {
      return Future.value(
        const Failure(message: 'GetAnnouncementByIdParams is required'),
      );
    }
    return _repository.getAnnouncementById(params.id);
  }
}

// Create announcement
class CreateAnnouncementParams {
  final AnnouncementEntity announcement;

  CreateAnnouncementParams(this.announcement);
}

class CreateAnnouncementUseCase
    implements
        FutureUseCase<Result<AnnouncementEntity>, CreateAnnouncementParams> {
  final AnnouncementRepository _repository;

  CreateAnnouncementUseCase(this._repository);

  @override
  Future<Result<AnnouncementEntity>> call({CreateAnnouncementParams? params}) {
    if (params == null) {
      return Future.value(
        const Failure(message: 'CreateAnnouncementParams is required'),
      );
    }
    return _repository.createAnnouncement(params.announcement);
  }
}

// Update announcement
class UpdateAnnouncementParams {
  final AnnouncementEntity announcement;

  UpdateAnnouncementParams(this.announcement);
}

class UpdateAnnouncementUseCase
    implements
        FutureUseCase<Result<AnnouncementEntity>, UpdateAnnouncementParams> {
  final AnnouncementRepository _repository;

  UpdateAnnouncementUseCase(this._repository);

  @override
  Future<Result<AnnouncementEntity>> call({UpdateAnnouncementParams? params}) {
    if (params == null) {
      return Future.value(
        const Failure(message: 'UpdateAnnouncementParams is required'),
      );
    }
    return _repository.updateAnnouncement(params.announcement);
  }
}

// Delete announcement
class DeleteAnnouncementParams {
  final String id;

  DeleteAnnouncementParams(this.id);
}

class DeleteAnnouncementUseCase
    implements FutureUseCase<Result<void>, DeleteAnnouncementParams> {
  final AnnouncementRepository _repository;

  DeleteAnnouncementUseCase(this._repository);

  @override
  Future<Result<void>> call({DeleteAnnouncementParams? params}) {
    if (params == null) {
      return Future.value(
        const Failure(message: 'DeleteAnnouncementParams is required'),
      );
    }
    return _repository.deleteAnnouncement(params.id);
  }
}

// Stream announcements
class StreamAnnouncementsUseCase {
  final AnnouncementRepository _repository;

  StreamAnnouncementsUseCase(this._repository);

  Stream<List<AnnouncementEntity>> call() {
    return _repository.streamAnnouncements();
  }
}
