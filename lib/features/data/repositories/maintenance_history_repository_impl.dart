import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/maintenance_history_model.dart';
import 'package:campus_care/features/domain/entities/maintenance_history_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_history_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MaintenanceHistoryRepositoryImpl implements MaintenanceHistoryRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MaintenanceHistoryRepositoryImpl(this._firestore);

  @override
  Future<Result<List<MaintenanceHistoryEntity>>> getHistoryByRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceHistory')
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: false)
          .get();
      final history = snapshot.docs
          .map((doc) => MaintenanceHistoryModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(history);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceHistoryEntity>> createHistory(
    MaintenanceHistoryEntity history,
  ) async {
    try {
      final id = history.id.isEmpty ? _uuid.v4() : history.id;
      final historyWithId = MaintenanceHistoryEntity(
        id: id,
        requestId: history.requestId,
        userId: history.userId,
        action: history.action,
        oldStatus: history.oldStatus,
        newStatus: history.newStatus,
        notes: history.notes,
        timestamp: history.timestamp,
      );
      final model = MaintenanceHistoryModel.fromEntity(historyWithId);
      await _firestore
          .collection('maintenanceHistory')
          .doc(id)
          .set(model.toJson());
      return Success(historyWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceHistoryEntity>>> getHistoryByUser(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceHistory')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final history = snapshot.docs
          .map((doc) => MaintenanceHistoryModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(history);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
