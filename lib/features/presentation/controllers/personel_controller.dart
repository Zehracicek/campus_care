import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/personel_entity.dart';
import 'package:campus_care/features/domain/usecases/personel_usecases.dart';
import 'package:flutter_riverpod/legacy.dart';

class PersonelController
    extends StateNotifier<StateHandler<List<PersonelEntity>>> {
  final GetPersonelUseCase _getPersonelUseCase;
  final CreatePersonelUseCase _createPersonelUseCase;
  final UpdatePersonelUseCase _updatePersonelUseCase;
  final DeletePersonelUseCase _deletePersonelUseCase;
  final StreamPersonelUseCase _streamPersonelUseCase;

  PersonelController(
    this._getPersonelUseCase,
    this._createPersonelUseCase,
    this._updatePersonelUseCase,
    this._deletePersonelUseCase,
    this._streamPersonelUseCase,
  ) : super(StateHandler.initial());

  void streamPersonel() {
    state = StateHandler.loading();
    _streamPersonelUseCase().listen(
      (personel) {
        if (personel.isEmpty) {
          state = StateHandler.empty();
        } else {
          state = StateHandler.success(data: personel);
        }
      },
      onError: (error) {
        state = StateHandler.error(message: error.toString());
      },
    );
  }

  Future<void> loadPersonel() async {
    state = StateHandler.loading();
    try {
      final personel = await _getPersonelUseCase();
      if (personel.isEmpty) {
        state = StateHandler.empty();
      } else {
        state = StateHandler.success(data: personel);
      }
    } catch (e) {
      state = StateHandler.error(message: e.toString());
    }
  }

  Future<void> createPersonel(PersonelEntity personel) async {
    try {
      await _createPersonelUseCase(params: CreatePersonelParams(personel));
      await loadPersonel();
    } catch (e) {
      state = StateHandler.error(message: e.toString());
    }
  }

  Future<void> updatePersonel(PersonelEntity personel) async {
    try {
      await _updatePersonelUseCase(params: UpdatePersonelParams(personel));
      await loadPersonel();
    } catch (e) {
      state = StateHandler.error(message: e.toString());
    }
  }

  Future<void> deletePersonel(String id) async {
    try {
      await _deletePersonelUseCase(params: DeletePersonelParams(id));
      await loadPersonel();
    } catch (e) {
      state = StateHandler.error(message: e.toString());
    }
  }
}
