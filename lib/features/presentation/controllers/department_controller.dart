import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';
import 'package:campus_care/features/domain/repositories/department_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class DepartmentController
    extends StateNotifier<StateHandler<List<DepartmentEntity>>> {
  final DepartmentRepository _departmentRepository;

  DepartmentController(this._departmentRepository)
    : super(StateHandler.initial());

  Future<void> loadDepartments() async {
    state = StateHandler.loading();
    final result = await _departmentRepository.getAllDepartments();
    result.when(
      success: (departments) {
        if (departments.isEmpty) {
          state = StateHandler.empty();
        } else {
          state = StateHandler.success(data: departments);
        }
      },
      failure: (error) {
        state = StateHandler.error(message: error.message);
      },
    );
  }

  Future<void> createDepartment(DepartmentEntity department) async {
    final result = await _departmentRepository.createDepartment(department);
    result.when(success: (_) => loadDepartments(), failure: (_) {});
  }

  Future<Result<void>> deleteDepartment(String id) async {
    return await _departmentRepository.deleteDepartment(id);
  }
}
