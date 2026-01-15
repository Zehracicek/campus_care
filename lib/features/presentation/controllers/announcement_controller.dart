import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';
import 'package:campus_care/features/domain/usecases/announcement_usecases.dart';
import 'package:flutter/foundation.dart';

class AnnouncementController extends ChangeNotifier {
  final GetAnnouncementsUseCase _getAnnouncementsUseCase;
  final CreateAnnouncementUseCase _createAnnouncementUseCase;
  final UpdateAnnouncementUseCase _updateAnnouncementUseCase;
  final DeleteAnnouncementUseCase _deleteAnnouncementUseCase;
  final StreamAnnouncementsUseCase _streamAnnouncementsUseCase;

  StateHandler<List<AnnouncementEntity>> _state = StateHandler.initial();
  StateHandler<List<AnnouncementEntity>> get state => _state;

  AnnouncementController({
    required GetAnnouncementsUseCase getAnnouncementsUseCase,
    required CreateAnnouncementUseCase createAnnouncementUseCase,
    required UpdateAnnouncementUseCase updateAnnouncementUseCase,
    required DeleteAnnouncementUseCase deleteAnnouncementUseCase,
    required StreamAnnouncementsUseCase streamAnnouncementsUseCase,
  }) : _getAnnouncementsUseCase = getAnnouncementsUseCase,
       _createAnnouncementUseCase = createAnnouncementUseCase,
       _updateAnnouncementUseCase = updateAnnouncementUseCase,
       _deleteAnnouncementUseCase = deleteAnnouncementUseCase,
       _streamAnnouncementsUseCase = streamAnnouncementsUseCase;

  void _updateState(StateHandler<List<AnnouncementEntity>> newState) {
    _state = newState;
    notifyListeners();
  }

  // Stream announcements in real-time
  void streamAnnouncements() {
    _updateState(StateHandler.loading());

    _streamAnnouncementsUseCase.call().listen(
      (announcements) {
        if (announcements.isEmpty) {
          _updateState(StateHandler.empty());
        } else {
          _updateState(StateHandler.success(data: announcements));
        }
      },
      onError: (error) {
        _updateState(StateHandler.error(message: error.toString()));
      },
    );
  }

  // Load announcements (one-time fetch)
  Future<void> loadAnnouncements() async {
    _updateState(StateHandler.loading());

    final result = await _getAnnouncementsUseCase(params: NoParams());

    result.when(
      success: (announcements) {
        if (announcements.isEmpty) {
          _updateState(StateHandler.empty());
        } else {
          _updateState(StateHandler.success(data: announcements));
        }
      },
      failure: (error) {
        _updateState(StateHandler.error(message: error.message));
      },
    );
  }

  // Create announcement
  Future<Result<AnnouncementEntity>> createAnnouncement(
    AnnouncementEntity announcement,
  ) async {
    final result = await _createAnnouncementUseCase(
      params: CreateAnnouncementParams(announcement),
    );

    result.when(success: (_) => loadAnnouncements(), failure: (_) {});

    return result;
  }

  // Update announcement
  Future<Result<AnnouncementEntity>> updateAnnouncement(
    AnnouncementEntity announcement,
  ) async {
    final result = await _updateAnnouncementUseCase(
      params: UpdateAnnouncementParams(announcement),
    );

    result.when(success: (_) => loadAnnouncements(), failure: (_) {});

    return result;
  }

  // Delete announcement
  Future<Result<void>> deleteAnnouncement(String id) async {
    final result = await _deleteAnnouncementUseCase(
      params: DeleteAnnouncementParams(id),
    );

    result.when(success: (_) => loadAnnouncements(), failure: (_) {});

    return result;
  }
}
