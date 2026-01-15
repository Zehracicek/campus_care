import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';
import 'package:campus_care/features/domain/usecases/category_usecases.dart';
import 'package:flutter/foundation.dart';

class CategoryState {
  final List<MaintenanceCategoryEntity> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<MaintenanceCategoryEntity>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CategoryController extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCategoriesByDepartmentUseCase _getCategoriesByDepartmentUseCase;

  CategoryState _state = CategoryState();
  CategoryState get state => _state;

  CategoryController({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetCategoriesByDepartmentUseCase getCategoriesByDepartmentUseCase,
  }) : _getCategoriesUseCase = getCategoriesUseCase,
       _getCategoriesByDepartmentUseCase = getCategoriesByDepartmentUseCase;

  void _updateState(CategoryState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    final result = await _getCategoriesUseCase(params: NoParams());

    result.when(
      success: (categories) {
        _updateState(_state.copyWith(categories: categories, isLoading: false));
      },
      failure: (error) {
        _updateState(_state.copyWith(isLoading: false, error: error.message));
      },
    );
  }

  Future<void> loadCategoriesByDepartment(String departmentId) async {
    _updateState(_state.copyWith(isLoading: true, error: null));
    final result = await _getCategoriesByDepartmentUseCase(
      params: GetCategoriesByDepartmentParams(departmentId),
    );

    result.when(
      success: (categories) {
        _updateState(_state.copyWith(categories: categories, isLoading: false));
      },
      failure: (error) {
        _updateState(_state.copyWith(isLoading: false, error: error.message));
      },
    );
  }
}
