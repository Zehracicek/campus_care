import 'package:campus_care/features/data/datasources/cloud/firebase_auth_datasource.dart';
import 'package:campus_care/features/data/repositories/auth_repository_impl.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';
import 'package:campus_care/features/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:campus_care/features/domain/usecases/get_current_user_usecase.dart';
import 'package:campus_care/features/domain/usecases/sign_in_with_email_and_password_usecase.dart';
import 'package:campus_care/features/domain/usecases/sign_out_usecase.dart';
import 'package:campus_care/features/domain/usecases/sign_up_with_email_and_password_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Firebase Auth Datasource provider
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthDatasourceImpl(firebaseAuth: firebaseAuth);
});

/// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDatasource = ref.watch(firebaseAuthDatasourceProvider);
  return AuthRepositoryImpl(
    authDatasource: authDatasource,
    firestore: ref.watch(firestoreProvider),
  );
});

/// Use Case Providers
final signInWithEmailAndPasswordUseCaseProvider =
    Provider<SignInWithEmailAndPasswordUseCase>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return SignInWithEmailAndPasswordUseCase(repository);
    });

final signUpWithEmailAndPasswordUseCaseProvider =
    Provider<SignUpWithEmailAndPasswordUseCase>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return SignUpWithEmailAndPasswordUseCase(repository);
    });

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final getAuthStateChangesUseCaseProvider = Provider<GetAuthStateChangesUseCase>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return GetAuthStateChangesUseCase(repository);
  },
);

/// Auth State Stream Provider - Kullanıcının oturum durumunu dinler
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final useCase = ref.watch(getAuthStateChangesUseCaseProvider);
  return useCase.call();
});

/// Current User Provider - Mevcut kullanıcıyı senkron olarak döndürür
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

/// Is Authenticated Provider - Kullanıcının oturum açıp açmadığını kontrol eder
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
