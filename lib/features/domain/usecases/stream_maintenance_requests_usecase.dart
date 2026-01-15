import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/core/usecase/stream_usecase.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';

class StreamMaintenanceRequestsUseCase
    implements StreamUseCase<Result<List<MaintenanceRequestEntity>>, NoParams> {
  final MaintenanceRequestRepository _repository;

  StreamMaintenanceRequestsUseCase(this._repository);

  @override
  Stream<Result<List<MaintenanceRequestEntity>>> call({NoParams? params}) {
    return _repository.streamRequests();
  }
}
