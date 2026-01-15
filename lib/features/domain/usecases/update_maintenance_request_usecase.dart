import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';

class UpdateMaintenanceRequestParams {
  final MaintenanceRequestEntity request;

  UpdateMaintenanceRequestParams(this.request);
}

class UpdateMaintenanceRequestUseCase
    implements
        FutureUseCase<
          Result<MaintenanceRequestEntity>,
          UpdateMaintenanceRequestParams
        > {
  final MaintenanceRequestRepository _repository;

  UpdateMaintenanceRequestUseCase(this._repository);

  @override
  Future<Result<MaintenanceRequestEntity>> call({
    UpdateMaintenanceRequestParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'UpdateMaintenanceRequestParams is required'),
      );
    }
    return _repository.updateRequest(params.request);
  }
}
