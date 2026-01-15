import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/core/usecase/usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';

/// Auth durumu değişikliklerini dinleme use case'i
class GetAuthStateChangesUseCase
    implements Usecase<Stream<UserEntity?>, NoParams> {
  final AuthRepository _repository;

  GetAuthStateChangesUseCase(this._repository);

  @override
  Stream<UserEntity?> call({NoParams? params}) {
    return _repository.authStateChanges();
  }
}
