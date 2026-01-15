import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/usecase.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Email ve şifre ile kayıt olma use case'i
class SignUpWithEmailAndPasswordUseCase
    implements Usecase<Future<Result<UserEntity>>, SignUpParams> {
  final AuthRepository _repository;

  SignUpWithEmailAndPasswordUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call({SignUpParams? params}) async {
    if (params == null) {
      return const Failure(
        message: 'Email ve şifre gereklidir',
        type: ErrorType.validation,
      );
    }

    // Basit validasyonlar
    if (params.email.isEmpty || !params.email.contains('@')) {
      return const Failure(
        message: 'Geçerli bir email adresi giriniz',
        type: ErrorType.validation,
      );
    }

    if (params.password.length < 6) {
      return const Failure(
        message: 'Şifre en az 6 karakter olmalıdır',
        type: ErrorType.validation,
      );
    }

    return await _repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

/// SignUp parametreleri
class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
