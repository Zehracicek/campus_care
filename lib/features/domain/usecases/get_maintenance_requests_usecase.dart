import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';

class GetMaintenanceRequestsUseCase
    implements FutureUseCase<Result<List<MaintenanceRequestEntity>>, NoParams> {
  final MaintenanceRequestRepository _repository;

  GetMaintenanceRequestsUseCase(this._repository);

  @override
  Future<Result<List<MaintenanceRequestEntity>>> call({NoParams? params}) {
    return _repository.getAllRequests();
  }
}

class GetRequestsByUserUseCase
    implements FutureUseCase<Result<List<MaintenanceRequestEntity>>, String> {
  final MaintenanceRequestRepository repository;

  GetRequestsByUserUseCase(this.repository);

  @override
  Future<Result<List<MaintenanceRequestEntity>>> call({String? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'User ID is required'));
    }
    return repository.getRequestsByUser(params);
  }
}

class GetRequestsByStatusUseCase
    implements
        FutureUseCase<
          Result<List<MaintenanceRequestEntity>>,
          MaintenanceStatus
        > {
  final MaintenanceRequestRepository repository;

  GetRequestsByStatusUseCase(this.repository);

  @override
  Future<Result<List<MaintenanceRequestEntity>>> call({
    MaintenanceStatus? params,
  }) {
    if (params == null) {
      return Future.value(Failure(message: 'Status is required'));
    }
    return repository.getRequestsByStatus(params);
  }
}
