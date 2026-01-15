import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/core/usecase/usecase.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';

/// Oturumu kapatma use case'i
class SignOutUseCase implements Usecase<Future<Result<void>>, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<Result<void>> call({NoParams? params}) async {
    return await _repository.signOut();
  }
}
