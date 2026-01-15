import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/fixture_entity.dart';

abstract class FixtureRepository {
  Future<Result<List<FixtureEntity>>> getAllDemirbas();
  Future<Result<void>> createDemirbas(FixtureEntity entity);
  Future<Result<void>> deleteDemirbas(String id);
}
