import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/comment_model.dart';
import 'package:campus_care/features/domain/entities/comment_entity.dart';
import 'package:campus_care/features/domain/repositories/comment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CommentRepositoryImpl(this._firestore);

  @override
  Future<Result<List<CommentEntity>>> getCommentsByRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: false)
          .get();
      final comments = snapshot.docs
          .map((doc) => CommentModel.fromJson(doc.data()).toEntity())
          .toList();
      return Success(comments);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CommentEntity>> getCommentById(String id) async {
    try {
      final doc = await _firestore.collection('comments').doc(id).get();
      if (!doc.exists) {
        return Failure(message: 'Comment not found');
      }
      final comment = CommentModel.fromJson(doc.data()!).toEntity();
      return Success(comment);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CommentEntity>> createComment(CommentEntity comment) async {
    try {
      final id = comment.id.isEmpty ? _uuid.v4() : comment.id;
      final commentWithId = CommentEntity(
        id: id,
        requestId: comment.requestId,
        userId: comment.userId,
        text: comment.text,
        createdAt: comment.createdAt,
      );
      final model = CommentModel.fromEntity(commentWithId);
      await _firestore.collection('comments').doc(id).set(model.toJson());
      return Success(commentWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<CommentEntity>> updateComment(CommentEntity comment) async {
    try {
      final model = CommentModel.fromEntity(comment);
      await _firestore
          .collection('comments')
          .doc(comment.id)
          .update(model.toJson());
      return Success(comment);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteComment(String id) async {
    try {
      await _firestore.collection('comments').doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<Result<List<CommentEntity>>> streamCommentsByRequest(
    String requestId,
  ) {
    try {
      return _firestore
          .collection('comments')
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
            final comments = snapshot.docs
                .map((doc) => CommentModel.fromJson(doc.data()).toEntity())
                .toList();
            return Success(comments);
          });
    } catch (e) {
      return Stream.value(Failure(message: e.toString()));
    }
  }
}
