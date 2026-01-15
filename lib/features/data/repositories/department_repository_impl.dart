import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/department_model.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';
import 'package:campus_care/features/domain/repositories/department_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  DepartmentRepositoryImpl(this._firestore);

  @override
  Future<Result<List<DepartmentEntity>>> getAllDepartments() async {
    try {
      final snapshot = await _firestore.collection('departments').get();
      final departments = snapshot.docs
          .map((doc) => DepartmentModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(departments);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<DepartmentEntity>>> getDepartmentsByCampus(
    String campusId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('departments')
          .where('campusId', isEqualTo: campusId)
          .get();
      final departments = snapshot.docs
          .map((doc) => DepartmentModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(departments);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<DepartmentEntity>> getDepartmentById(String id) async {
    try {
      final doc = await _firestore.collection('departments').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Department not found');
      }
      final department = DepartmentModel.fromJson(doc.data()!).toEntity();
      return Success(department);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<DepartmentEntity>> createDepartment(
    DepartmentEntity department,
  ) async {
    try {
      final id = department.id.isEmpty ? _uuid.v4() : department.id;
      final departmentWithId = DepartmentEntity(
        id: id,
        name: department.name,
        description: department.description,
        managerId: department.managerId,
        campusId: department.campusId,
      );
      final model = DepartmentModel.fromEntity(departmentWithId);
      await _firestore.collection('departments').doc(id).set(model.toJson());
      return Success(departmentWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<DepartmentEntity>> updateDepartment(
    DepartmentEntity department,
  ) async {
    try {
      final model = DepartmentModel.fromEntity(department);
      await _firestore
          .collection('departments')
          .doc(department.id)
          .update(model.toJson());
      return Success(department);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteDepartment(String id) async {
    try {
      await _firestore.collection('departments').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
