import '../../../core/resources/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Email ve şifre ile giriş yapar
  Future<Result<UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Email ve şifre ile yeni kullanıcı kaydı yapar
  Future<Result<UserEntity>> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Kullanıcının oturumunu kapatır
  Future<Result<void>> signOut();

  /// Mevcut oturum açmış kullanıcıyı döndürür
  Future<Result<UserEntity?>> getCurrentUser();

  /// Kullanıcının oturum durumunu dinler
  Stream<UserEntity?> authStateChanges();
}
