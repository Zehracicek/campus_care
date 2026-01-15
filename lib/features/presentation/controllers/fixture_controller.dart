import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/fixture_entity.dart';
import 'package:campus_care/features/domain/repositories/demirbas_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class FixtureController
    extends StateNotifier<StateHandler<List<FixtureEntity>>> {
  final FixtureRepository _repository;

  FixtureController(this._repository) : super(StateHandler.initial());

  Future<void> loadDemirbas() async {
    state = StateHandler.loading();
    final result = await _repository.getAllDemirbas();
    result.when(
      success: (items) => state = StateHandler.success(data: items),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }

  Future<Result<void>> createDemirbas({
    required String name,
    required String description,
    required int quantity,
    required String userId,
  }) async {
    final entity = FixtureEntity(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      quantity: quantity,
      createdAt: DateTime.now(),
      createdById: userId,
    );

    final result = await _repository.createDemirbas(entity);
    result.when(
      success: (_) => loadDemirbas(),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
    return result;
  }

  Future<void> deleteDemirbas(String id) async {
    final result = await _repository.deleteDemirbas(id);
    result.when(
      success: (_) => loadDemirbas(),
      failure: (error) => state = StateHandler.error(message: error.message),
    );
  }
}
