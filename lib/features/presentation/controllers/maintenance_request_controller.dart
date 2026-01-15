import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/domain/usecases/create_maintenance_request_usecase.dart';
import 'package:campus_care/features/domain/usecases/get_maintenance_requests_usecase.dart';
import 'package:campus_care/features/domain/usecases/stream_maintenance_requests_usecase.dart';
import 'package:campus_care/features/domain/usecases/update_maintenance_request_usecase.dart';
import 'package:campus_care/features/domain/usecases/update_request_status_usecase.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/resources/state_handler.dart';

class MaintenanceRequestState {
  final List<MaintenanceRequestEntity> requests;

  MaintenanceRequestState({this.requests = const []});

  MaintenanceRequestState copyWith({List<MaintenanceRequestEntity>? requests}) {
    return MaintenanceRequestState(requests: requests ?? this.requests);
  }
}

class MaintenanceRequestController
    extends StateNotifier<StateHandler<MaintenanceRequestState>> {
  final GetMaintenanceRequestsUseCase _getRequestsUseCase;
  final GetRequestsByUserUseCase _getRequestsByUserUseCase;
  final CreateMaintenanceRequestUseCase _createRequestUseCase;
  final UpdateMaintenanceRequestUseCase _updateRequestUseCase;
  final UpdateRequestStatusUseCase _updateStatusUseCase;
  final StreamMaintenanceRequestsUseCase _streamRequestsUseCase;

  MaintenanceRequestState get _currentData =>
      state.data ?? MaintenanceRequestState();

  MaintenanceRequestController(
    this._getRequestsUseCase,
    this._getRequestsByUserUseCase,
    this._createRequestUseCase,
    this._updateRequestUseCase,
    this._updateStatusUseCase,
    this._streamRequestsUseCase,
  ) : super(StateHandler.initial());

  Future<void> loadRequests() async {
    state = StateHandler.loading(data: _currentData);
    final result = await _getRequestsUseCase();

    result.when(
      success: (requests) {
        state = StateHandler.success(
          data: _currentData.copyWith(requests: requests),
        );
      },
      failure: (error) {
        state = StateHandler.error(
          message: error.message,
          error: error.message,
          data: _currentData,
        );
      },
    );
  }

  Future<void> loadUserRequests(String userId) async {
    state = StateHandler.loading(data: _currentData);

    final result = await _getRequestsByUserUseCase(params: userId);

    result.when(
      success: (requests) {
        state = StateHandler.success(
          data: _currentData.copyWith(requests: requests),
        );
      },
      failure: (error) {
        state = StateHandler.error(
          message: error.message,
          error: error.message,
          data: _currentData,
        );
      },
    );
  }

  Future<Result<MaintenanceRequestEntity>> createRequest(
    MaintenanceRequestEntity request,
  ) async {
    final result = await _createRequestUseCase(
      params: CreateMaintenanceRequestParams(request),
    );

    result.when(
      success: (newRequest) {
        state = StateHandler.success(
          data: _currentData.copyWith(
            requests: [newRequest, ..._currentData.requests],
          ),
        );
      },
      failure: (_) {
        // Do nothing, just return the failure
      },
    );

    return result;
  }

  Future<Result<MaintenanceRequestEntity>> updateRequestStatus(
    String requestId,
    MaintenanceStatus status,
  ) async {
    final result = await _updateStatusUseCase(
      params: UpdateRequestStatusParams(requestId: requestId, status: status),
    );

    result.when(
      success: (updatedRequest) {
        final updatedList = _currentData.requests.map((req) {
          return req.id == requestId ? updatedRequest : req;
        }).toList();
        state = StateHandler.success(
          data: _currentData.copyWith(requests: updatedList),
        );
      },
      failure: (_) {},
    );

    return result;
  }

  Future<Result<MaintenanceRequestEntity>> updateRequest(
    MaintenanceRequestEntity request,
  ) async {
    final result = await _updateRequestUseCase(
      params: UpdateMaintenanceRequestParams(request),
    );

    result.when(
      success: (updatedRequest) {
        final updatedList = _currentData.requests.map((req) {
          return req.id == request.id ? updatedRequest : req;
        }).toList();
        state = StateHandler.success(
          data: _currentData.copyWith(requests: updatedList),
        );
      },
      failure: (_) {},
    );

    return result;
  }

  void streamRequests() {
    _streamRequestsUseCase().listen((result) {
      result.when(
        success: (requests) {
          state = StateHandler.success(
            data: _currentData.copyWith(requests: requests),
          );
        },
        failure: (error) {
          state = StateHandler.error(
            message: error.message,
            data: _currentData,
          );
        },
      );
    });
  }
}
