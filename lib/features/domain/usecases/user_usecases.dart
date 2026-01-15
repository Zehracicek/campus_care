import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/user_repository.dart';

class GetUserByIdParams {
  final String userId;

  GetUserByIdParams(this.userId);
}

class GetUserByIdUseCase
    implements FutureUseCase<Result<UserEntity>, GetUserByIdParams> {
  final UserRepository _repository;

  GetUserByIdUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({GetUserByIdParams? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'GetUserByIdParams is required'));
    }
    return _repository.getUserById(params.userId);
  }
}

class UpdateUserProfileParams {
  final UserEntity user;

  UpdateUserProfileParams(this.user);
}

class UpdateUserProfileUseCase
    implements FutureUseCase<Result<UserEntity>, UpdateUserProfileParams> {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({UpdateUserProfileParams? params}) {
    if (params == null) {
      return Future.value(
        Failure(message: 'UpdateUserProfileParams is required'),
      );
    }
    return _repository.updateUserProfile(params.user);
  }
}
