import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';

class CreateMaintenanceRequestParams {
  final MaintenanceRequestEntity request;

  CreateMaintenanceRequestParams(this.request);
}

class CreateMaintenanceRequestUseCase
    implements
        FutureUseCase<
          Result<MaintenanceRequestEntity>,
          CreateMaintenanceRequestParams
        > {
  final MaintenanceRequestRepository _repository;

  CreateMaintenanceRequestUseCase(this._repository);

  @override
  Future<Result<MaintenanceRequestEntity>> call({
    CreateMaintenanceRequestParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'CreateMaintenanceRequestParams is required'),
      );
    }
    return _repository.createRequest(params.request);
  }
}
