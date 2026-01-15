import 'package:campus_care/features/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication datasource
/// Email ve şifre ile giriş, kayıt ve oturum yönetimi sağlar
abstract class FirebaseAuthDatasource {
  /// Email ve şifre ile giriş yapar
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Email ve şifre ile yeni kullanıcı kaydı yapar
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Kullanıcının oturumunu kapatır
  Future<void> signOut();

  /// Mevcut oturum açmış kullanıcıyı döndürür
  Future<UserModel?> getCurrentUser();

  /// Kullanıcının oturum durumunu dinler
  Stream<UserModel?> authStateChanges();
}

/// Firebase Authentication datasource implementasyonu
class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Kullanıcı bilgisi alınamadı');
      }

      final user = userCredential.user!;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber,
        roleId: null,
        departmentId: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Giriş yapılırken bir hata oluştu: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      final user = userCredential.user!;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber,
        roleId: null,
        departmentId: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Kayıt olunurken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapılırken bir hata oluştu: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber,
        roleId: null,
        departmentId: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    } catch (e) {
      throw Exception('Kullanıcı bilgisi alınırken bir hata oluştu: $e');
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber,
        roleId: null,
        departmentId: null,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
    });
  }

  /// Firebase Auth hatalarını anlamlı mesajlara çevirir
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı');
      case 'wrong-password':
        return Exception('Hatalı şifre');
      case 'email-already-in-use':
        return Exception('Bu e-posta adresi zaten kullanımda');
      case 'invalid-email':
        return Exception('Geçersiz e-posta adresi');
      case 'weak-password':
        return Exception('Şifre çok zayıf. Daha güçlü bir şifre kullanın');
      case 'operation-not-allowed':
        return Exception('Bu işlem şu anda kullanılamıyor');
      case 'user-disabled':
        return Exception('Bu hesap devre dışı bırakılmış');
      case 'too-many-requests':
        return Exception('Çok fazla deneme. Lütfen daha sonra tekrar deneyin');
      case 'network-request-failed':
        return Exception('Ağ bağlantısı hatası');
      case 'invalid-credential':
        return Exception('Geçersiz kimlik bilgileri');
      default:
        return Exception('Bir hata oluştu: ${e.message ?? e.code}');
    }
  }
}
