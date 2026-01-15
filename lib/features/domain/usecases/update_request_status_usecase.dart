import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';

class UpdateRequestStatusParams {
  final String requestId;
  final MaintenanceStatus status;

  UpdateRequestStatusParams({required this.requestId, required this.status});
}

class UpdateRequestStatusUseCase
    implements
        FutureUseCase<
          Result<MaintenanceRequestEntity>,
          UpdateRequestStatusParams
        > {
  final MaintenanceRequestRepository _repository;

  UpdateRequestStatusUseCase(this._repository);

  @override
  Future<Result<MaintenanceRequestEntity>> call({
    UpdateRequestStatusParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'UpdateRequestStatusParams is required'),
      );
    }
    return _repository.updateRequestStatus(params.requestId, params.status);
  }
}
