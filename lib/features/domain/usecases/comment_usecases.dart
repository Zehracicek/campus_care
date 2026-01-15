import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/usecase/future_usecase.dart';
import 'package:campus_care/features/domain/entities/comment_entity.dart';
import 'package:campus_care/features/domain/repositories/comment_repository.dart';

class GetCommentsParams {
  final String requestId;

  GetCommentsParams(this.requestId);
}

class GetCommentsUseCase
    implements FutureUseCase<Result<List<CommentEntity>>, GetCommentsParams> {
  final CommentRepository _repository;

  GetCommentsUseCase(this._repository);

  @override
  Future<Result<List<CommentEntity>>> call({GetCommentsParams? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'GetCommentsParams is required'));
    }
    return _repository.getCommentsByRequest(params.requestId);
  }
}

class AddCommentParams {
  final CommentEntity comment;

  AddCommentParams(this.comment);
}

class AddCommentUseCase
    implements FutureUseCase<Result<CommentEntity>, AddCommentParams> {
  final CommentRepository _repository;

  AddCommentUseCase(this._repository);

  @override
  Future<Result<CommentEntity>> call({AddCommentParams? params}) {
    if (params == null) {
      return Future.value(Failure(message: 'AddCommentParams is required'));
    }
    return _repository.createComment(params.comment);
  }
}
