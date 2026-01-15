import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';

abstract class MaintenanceCategoryRepository {
  /// Get all categories
  Future<Result<List<MaintenanceCategoryEntity>>> getAllCategories();

  /// Get categories by department
  Future<Result<List<MaintenanceCategoryEntity>>> getCategoriesByDepartment(
    String departmentId,
  );

  /// Get a category by ID
  Future<Result<MaintenanceCategoryEntity>> getCategoryById(String id);

  /// Create a new category
  Future<Result<MaintenanceCategoryEntity>> createCategory(
    MaintenanceCategoryEntity category,
  );

  /// Update a category
  Future<Result<MaintenanceCategoryEntity>> updateCategory(
    MaintenanceCategoryEntity category,
  );

  /// Delete a category
  Future<Result<void>> deleteCategory(String id);
}
