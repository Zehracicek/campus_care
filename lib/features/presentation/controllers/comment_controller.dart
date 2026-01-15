import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/comment_entity.dart';
import 'package:campus_care/features/domain/usecases/comment_usecases.dart';
import 'package:flutter_riverpod/legacy.dart';

class CommentState {
  final List<CommentEntity> comments;

  CommentState({this.comments = const []});

  CommentState copyWith({List<CommentEntity>? comments}) {
    return CommentState(comments: comments ?? this.comments);
  }
}

class CommentController extends StateNotifier<StateHandler<CommentState>> {
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;

  CommentState get _currentData => state.data ?? CommentState();

  CommentController(this._getCommentsUseCase, this._addCommentUseCase)
    : super(StateHandler.initial());

  Future<void> loadComments(String requestId) async {
    state = StateHandler.loading(data: _currentData);
    final result = await _getCommentsUseCase(
      params: GetCommentsParams(requestId),
    );

    result.when(
      success: (comments) {
        state = StateHandler.success(
          data: _currentData.copyWith(comments: comments),
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

  Future<Result<CommentEntity>> addComment(CommentEntity comment) async {
    final result = await _addCommentUseCase(params: AddCommentParams(comment));

    result.when(
      success: (newComment) {
        state = StateHandler.success(
          data: _currentData.copyWith(
            comments: [..._currentData.comments, newComment],
          ),
        );
      },
      failure: (_) {
        // Do nothing, just return the failure
      },
    );

    return result;
  }
}
