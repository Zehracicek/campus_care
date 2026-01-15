import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/maintenance_assignment_model.dart';
import 'package:campus_care/features/domain/entities/maintenance_assignment_entity.dart';
import 'package:campus_care/features/domain/repositories/maintenance_assignment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MaintenanceAssignmentRepositoryImpl
    implements MaintenanceAssignmentRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  MaintenanceAssignmentRepositoryImpl(this._firestore);

  @override
  Future<Result<MaintenanceAssignmentEntity?>> getAssignmentByRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceAssignments')
          .where('requestId', isEqualTo: requestId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return Success(null);
      }
      final assignment = MaintenanceAssignmentModel.fromJson(
        snapshot.docs.first.data(),
      ).toEntity();
      return Success(assignment);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<List<MaintenanceAssignmentEntity>>> getAssignmentsByUser(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('maintenanceAssignments')
          .where('assignedToId', isEqualTo: userId)
          .orderBy('assignedAt', descending: true)
          .get();
      final assignments = snapshot.docs
          .map(
            (doc) => MaintenanceAssignmentModel.fromJson(doc.data()).toEntity(),
          )
          .toList();
      return Success(assignments);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceAssignmentEntity>> createAssignment(
    MaintenanceAssignmentEntity assignment,
  ) async {
    try {
      final id = assignment.id.isEmpty ? _uuid.v4() : assignment.id;
      final assignmentWithId = MaintenanceAssignmentEntity(
        id: id,
        requestId: assignment.requestId,
        assignedToId: assignment.assignedToId,
        assignedById: assignment.assignedById,
        assignedAt: assignment.assignedAt,
        notes: assignment.notes,
      );
      final model = MaintenanceAssignmentModel.fromEntity(assignmentWithId);
      await _firestore
          .collection('maintenanceAssignments')
          .doc(id)
          .set(model.toJson());
      return Success(assignmentWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<MaintenanceAssignmentEntity>> updateAssignment(
    MaintenanceAssignmentEntity assignment,
  ) async {
    try {
      final model = MaintenanceAssignmentModel.fromEntity(assignment);
      await _firestore
          .collection('maintenanceAssignments')
          .doc(assignment.id)
          .update(model.toJson());
      return Success(assignment);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAssignment(String id) async {
    try {
      await _firestore.collection('maintenanceAssignments').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
