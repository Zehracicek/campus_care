import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/datasources/cloud/firebase_auth_datasource.dart';
import 'package:campus_care/features/data/models/user_model.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// AuthRepository'nin Firebase ile implementasyonu
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required FirebaseFirestore firestore,
  }) : _authDatasource = authDatasource,
       _firestore = firestore;

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDatasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final enriched = await _mergeProfile(user);
      return Success(enriched);
    } catch (e) {
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ErrorType.authentication,
      );
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDatasource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      final enriched = await _mergeProfile(user);
      return Success(enriched);
    } catch (e) {
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ErrorType.authentication,
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authDatasource.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ErrorType.authentication,
      );
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user == null) return const Success(null);
      final enriched = await _mergeProfile(user);
      return Success(enriched);
    } catch (e) {
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        type: ErrorType.authentication,
      );
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _authDatasource.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _mergeProfile(user);
    });
  }

  /// Firestore'daki kullanıcı profilini çekip auth bilgisini zenginleştirir.
  Future<UserEntity> _mergeProfile(UserModel authUser) async {
    try {
      final doc = await _firestore.collection('users').doc(authUser.id).get();
      if (doc.exists) {
        final profile = UserModel.fromJson(doc.data()!).toEntity();
        // auth user'dan eksik alan varsa profile ile birleştir
        return profile.copyWith(
          email: profile.email.isNotEmpty ? profile.email : authUser.email,
          displayName: profile.displayName ?? authUser.name,
          phone: profile.phone ?? authUser.phone,
        );
      }
    } catch (_) {
      // Profil yoksa auth bilgisini döndür
    }
    return authUser.toEntity();
  }
}
