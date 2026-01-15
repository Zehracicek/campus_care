import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Email ve şifre ile giriş yapma use case'i
class SignInWithEmailAndPasswordUseCase
    implements Usecase<Future<Result<UserEntity>>, SignInParams> {
  final AuthRepository _repository;

  SignInWithEmailAndPasswordUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({SignInParams? params}) async {
    if (params == null) {
      return const Failure(
        message: 'Email ve şifre gereklidir',
        type: ErrorType.validation,
      );
    }

    return await _repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

/// SignIn parametreleri
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
