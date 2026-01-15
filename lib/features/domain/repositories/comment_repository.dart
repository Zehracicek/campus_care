import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  /// Get comments by request
  Future<Result<List<CommentEntity>>> getCommentsByRequest(String requestId);

  /// Get a comment by ID
  Future<Result<CommentEntity>> getCommentById(String id);

  /// Create a new comment
  Future<Result<CommentEntity>> createComment(CommentEntity comment);

  /// Update a comment
  Future<Result<CommentEntity>> updateComment(CommentEntity comment);

  /// Delete a comment
  Future<Result<void>> deleteComment(String id);

  /// Stream comments for real-time updates
  Stream<Result<List<CommentEntity>>> streamCommentsByRequest(String requestId);
}
