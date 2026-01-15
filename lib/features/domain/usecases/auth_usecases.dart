import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/core/usecase/stream_usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';

// Sign In UseCase
class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

class SignInUseCase implements FutureUseCase<Result<UserEntity>, SignInParams> {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({SignInParams? params}) async {
    return await _repository.signInWithEmailAndPassword(
      params!.email,
      params.password,
    );
  }
}

// Sign Up UseCase
class SignUpParams {
  final String email;
  final String password;

  SignUpParams({required this.email, required this.password});
}

class SignUpUseCase implements FutureUseCase<Result<UserEntity>, SignUpParams> {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({SignUpParams? params}) async {
    return await _repository.signUpWithEmailAndPassword(
      params!.email,
      params.password,
    );
  }
}

// Sign Out UseCase
class SignOutUseCase implements FutureUseCase<Result<void>, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<Result<void>> call({NoParams? params}) async {
    return await _repository.signOut();
  }
}

// Get Current User UseCase
class GetCurrentUserUseCase
    implements FutureUseCase<Result<UserEntity?>, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<UserEntity?>> call({NoParams? params}) async {
    return await _repository.getCurrentUser();
  }
}

// Auth State Changes UseCase
class AuthStateChangesUseCase implements StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  AuthStateChangesUseCase(this._repository);

  @override
  Stream<UserEntity?> call({NoParams? params}) {
    return _repository.authStateChanges();
  }
}
