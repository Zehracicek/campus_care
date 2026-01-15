import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/maintenance_category_model.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_category_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MaintenanceCategoryRepositoryImpl
    implements MaintenanceCategoryRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MaintenanceCategoryRepositoryImpl(this._firestore);

  @override
  Future<Result<List<MaintenanceCategoryEntity>>> getAllCategories() async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceCategories')
          .get();
      final categories = snapshot.docs
          .map(
            (doc) => MaintenanceCategoryModel.fromJson(doc.data()).toEntity(),
          )
          .toList();
      return Success(categories);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceCategoryEntity>>> getCategoriesByDepartment(
    String departmentId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceCategories')
          .where('departmentId', isEqualTo: departmentId)
          .get();
      final categories = snapshot.docs
          .map(
            (doc) => MaintenanceCategoryModel.fromJson(doc.data()).toEntity(),
          )
          .toList();
      return Success(categories);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceCategoryEntity>> getCategoryById(String id) async {
    try {
      final doc = await _firestore
          .collection('maintenanceCategories')
          .doc(id)
          .get();
      if (!doc.exists) {
        return Failure(message: 'Category not found');
      }
      final category = MaintenanceCategoryModel.fromJson(
        doc.data()!,
      ).toEntity();
      return Success(category);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceCategoryEntity>> createCategory(
    MaintenanceCategoryEntity category,
  ) async {
    try {
      final id = category.id.isEmpty ? _uuid.v4() : category.id;
      final categoryWithId = MaintenanceCategoryEntity(
        id: id,
        name: category.name,
        description: category.description,
        icon: category.icon,
        departmentId: category.departmentId,
        estimatedHours: category.estimatedHours,
      );
      final model = MaintenanceCategoryModel.fromEntity(categoryWithId);
      await _firestore
          .collection('maintenanceCategories')
          .doc(id)
          .set(model.toJson());
      return Success(categoryWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceCategoryEntity>> updateCategory(
    MaintenanceCategoryEntity category,
  ) async {
    try {
      final model = MaintenanceCategoryModel.fromEntity(category);
      await _firestore
          .collection('maintenanceCategories')
          .doc(category.id)
          .update(model.toJson());
      return Success(category);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _firestore.collection('maintenanceCategories').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
