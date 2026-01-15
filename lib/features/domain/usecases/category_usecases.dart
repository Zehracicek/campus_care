import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_category_repository.dart';

class GetCategoriesUseCase
    implements
        FutureUseCase<Result<List<MaintenanceCategoryEntity>>, NoParams> {
  final MaintenanceCategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<Result<List<MaintenanceCategoryEntity>>> call({NoParams? params}) {
    return _repository.getAllCategories();
  }
}

class GetCategoriesByDepartmentParams {
  final String departmentId;

  GetCategoriesByDepartmentParams(this.departmentId);
}

class GetCategoriesByDepartmentUseCase
    implements
        FutureUseCase<
          Result<List<MaintenanceCategoryEntity>>,
          GetCategoriesByDepartmentParams
        > {
  final MaintenanceCategoryRepository _repository;

  GetCategoriesByDepartmentUseCase(this._repository);

  @override
  Future<Result<List<MaintenanceCategoryEntity>>> call({
    GetCategoriesByDepartmentParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'GetCategoriesByDepartmentParams is required'),
      );
    }
    return _repository.getCategoriesByDepartment(params.departmentId);
  }
}
