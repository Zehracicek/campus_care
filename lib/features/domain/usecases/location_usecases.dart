import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/core/usecase/no_params.dart';
import 'package:campus_care/features/domain/entities/building_entity.dart';
import 'package:campus_care/features/domain/entities/campus_entity.dart';
import 'package:campus_care/features/domain/entities/room_entity.dart';
import 'package:campus_care/features/domain/repositories/building_repository.dart';
import 'package:campus_care/features/domain/repositories/campus_repository.dart';
import 'package:campus_care/features/domain/repositories/room_repository.dart';

class GetAllCampusesUseCase
    implements FutureUseCase<Result<List<CampusEntity>>, NoParams> {
  final CampusRepository _repository;

  GetAllCampusesUseCase(this._repository);

  @override
  Future<Result<List<CampusEntity>>> call({NoParams? params}) {
    return _repository.getAllCampuses();
  }
}

class GetBuildingsByCampusParams {
  final String campusId;

  GetBuildingsByCampusParams(this.campusId);
}

class GetBuildingsByCampusUseCase
    implements
        FutureUseCase<
          Result<List<BuildingEntity>>,
          GetBuildingsByCampusParams
        > {
  final BuildingRepository _repository;

  GetBuildingsByCampusUseCase(this._repository);

  @override
  Future<Result<List<BuildingEntity>>> call({
    GetBuildingsByCampusParams? params,
  }) {
    if (params == null) {
      return Future.value(
        Failure(message: 'GetBuildingsByCampusParams is required'),
      );
    }
    return _repository.getBuildingsByCampus(params.campusId);
  }
}

class GetRoomsByBuildingParams {
  final String buildingId;

  GetRoomsByBuildingParams(this.buildingId);
}

class GetRoomsByBuildingUseCase
    implements
        FutureUseCase<Result<List<RoomEntity>>, GetRoomsByBuildingParams> {
  final RoomRepository _repository;

  GetRoomsByBuildingUseCase(this._repository);

  @override
  Future<Result<List<RoomEntity>>> call({GetRoomsByBuildingParams? params}) {
    if (params == null) {
      return Future.value(
        Failure(message: 'GetRoomsByBuildingParams is required'),
      );
    }
    return _repository.getRoomsByBuilding(params.buildingId);
  }
}
