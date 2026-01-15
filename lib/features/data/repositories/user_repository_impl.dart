import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/user_model.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<Result<UserEntity>> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) {
        return const Failure(message: 'User not found');
      }
      final user = UserModel.fromJson(doc.data()!).toEntity();
      return Success(user);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<UserEntity>>> getUsersByRole(String roleId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('roleId', isEqualTo: roleId)
          .get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(users);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<UserEntity>>> getUsersByDepartment(
    String departmentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: departmentId)
          .get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(users);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(model.toJson(), SetOptions(merge: true));
      return Success(user);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<UserEntity>>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(users);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
