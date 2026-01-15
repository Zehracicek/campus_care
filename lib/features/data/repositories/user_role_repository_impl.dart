import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/user_role_model.dart';
import 'package:campus_care/features/domain/entities/user_role_entity.dart';
import 'package:campus_care/features/domain/repositories/user_role_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserRoleRepositoryImpl implements UserRoleRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  UserRoleRepositoryImpl(this._firestore);

  @override
  Future<Result<List<UserRoleEntity>>> getAllRoles() async {
    try {
      final snapshot = await _firestore.collection('userRoles').get();
      final roles = snapshot.docs
          .map((doc) => UserRoleModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(roles);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<UserRoleEntity>> getRoleById(String id) async {
    try {
      final doc = await _firestore.collection('userRoles').doc(id).get();
      if (!doc.exists) {
        return const Failure(message: 'Role not found');
      }
      final role = UserRoleModel.fromJson(doc.data()!).toEntity();
      return Success(role);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<UserRoleEntity>> createRole(UserRoleEntity role) async {
    try {
      final id = role.id.isEmpty ? _uuid.v4() : role.id;
      final roleWithId = UserRoleEntity(
        id: id,
        name: role.name,
        description: role.description,
        permissions: role.permissions,
      );
      final model = UserRoleModel.fromEntity(roleWithId);
      await _firestore.collection('userRoles').doc(id).set(model.toJson());
      return Success(roleWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<UserRoleEntity>> updateRole(UserRoleEntity role) async {
    try {
      final model = UserRoleModel.fromEntity(role);
      await _firestore
          .collection('userRoles')
          .doc(role.id)
          .update(model.toJson());
      return Success(role);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteRole(String id) async {
    try {
      await _firestore.collection('userRoles').doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
