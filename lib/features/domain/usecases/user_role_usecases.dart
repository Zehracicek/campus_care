import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/user_role_entity.dart';
import 'package:campus_care/features/domain/repositories/user_role_repository.dart';

// Get role by ID use case
class GetRoleByIdUseCase
    implements FutureUseCase<Result<UserRoleEntity>, String> {
  final UserRoleRepository _repository;

  GetRoleByIdUseCase(this._repository);

  @override
  Future<Result<UserRoleEntity>> call({String? params}) {
    if (params == null) {
      return Future.value(const Failure(message: 'Role ID is required'));
    }
    return _repository.getRoleById(params);
  }
}
