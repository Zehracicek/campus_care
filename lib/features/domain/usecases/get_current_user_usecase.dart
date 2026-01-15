import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/core/usecase/usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';

/// Mevcut kullanıcıyı getirme use case'i
class GetCurrentUserUseCase
    implements Usecase<Future<Result<UserEntity?>>, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<UserEntity?>> call({NoParams? params}) async {
    return await _repository.getCurrentUser();
  }
}
