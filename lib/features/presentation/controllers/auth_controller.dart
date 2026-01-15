import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/usecases/auth_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthData extends Equatable {
  final UserEntity? user;

  const AuthData({this.user});

  AuthData copyWith({UserEntity? Function()? user}) {
    return AuthData(user: user != null ? user() : this.user);
  }

  @override
  List<Object?> get props => [user];
}

class AuthController extends StateNotifier<StateHandler<AuthData>> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthData get _currentData => state.data ?? const AuthData();

  AuthController(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
  ) : super(StateHandler.initial());

  Future<Result<UserEntity>> signIn(String email, String password) async {
    state = StateHandler.loading(data: _currentData);

    final result = await _signInUseCase.call(
      params: SignInParams(email: email, password: password),
    );

    result.when(
      success: (user) {
        state = StateHandler.success(
          data: _currentData.copyWith(user: () => user),
        );
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );

    return result;
  }

  Future<Result<UserEntity>> signUp(String email, String password) async {
    state = StateHandler.loading(data: _currentData);
    final result = await _signUpUseCase.call(
      params: SignUpParams(email: email, password: password),
    );

    result.when(
      success: (user) {
        state = StateHandler.success(
          data: _currentData.copyWith(user: () => user),
        );
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );

    return result;
  }

  Future<Result<void>> signOut() async {
    state = StateHandler.loading(data: _currentData);

    final result = await _signOutUseCase.call();

    result.when(
      success: (_) {
        state = StateHandler.initial();
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );

    return result;
  }

  Future<void> getCurrentUser() async {
    state = StateHandler.loading(data: _currentData);

    final result = await _getCurrentUserUseCase.call();

    result.when(
      success: (user) {
        if (user != null) {
          state = StateHandler.success(
            data: _currentData.copyWith(user: () => user),
          );
        } else {
          state = StateHandler.initial();
        }
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );
  }
}
