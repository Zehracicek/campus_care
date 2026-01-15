import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/rating_entity.dart';
import 'package:campus_care/features/domain/repositories/rating_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class RatingState {
  final List<RatingEntity> ratings;
  final RatingEntity? userRating;
  final double averageRating;
  final int totalRatings;

  RatingState({
    this.ratings = const [],
    this.userRating,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  RatingState copyWith({
    List<RatingEntity>? ratings,
    RatingEntity? userRating,
    bool clearUserRating = false,
    double? averageRating,
    int? totalRatings,
  }) {
    return RatingState(
      ratings: ratings ?? this.ratings,
      userRating: clearUserRating ? null : userRating ?? this.userRating,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }
}

class RatingController extends StateNotifier<StateHandler<RatingState>> {
  final RatingRepository _repository;

  RatingController(this._repository) : super(StateHandler.initial());

  Future<void> loadRatings(String requestId, String userId) async {
    state = StateHandler.loading();

    final ratingsResult = await _repository.getRatingsByRequest(requestId);
    final userRatingResult = await _repository.getUserRatingForRequest(
      requestId: requestId,
      userId: userId,
    );

    if (ratingsResult is Success<List<RatingEntity>>) {
      final ratings = ratingsResult.data;
      final average = ratings.isEmpty
          ? 0.0
          : ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                ratings.length;

      RatingEntity? userRating;
      if (userRatingResult is Success<RatingEntity?>) {
        userRating = userRatingResult.data;
      }

      state = StateHandler.success(
        data: RatingState(
          ratings: ratings,
          userRating: userRating,
          averageRating: average,
          totalRatings: ratings.length,
        ),
      );
    } else if (ratingsResult is Failure<List<RatingEntity>>) {
      state = StateHandler.error(message: ratingsResult.message);
    }
  }

  Future<Result<void>> addRating({
    required String requestId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    final ratingEntity = RatingEntity(
      id: '',
      requestId: requestId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addRating(ratingEntity);

    if (result is Success) {
      await loadRatings(requestId, userId);
    }

    return result;
  }

  Future<Result<void>> updateRating({
    required String ratingId,
    required String requestId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    final ratingEntity = RatingEntity(
      id: ratingId,
      requestId: requestId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final result = await _repository.updateRating(ratingEntity);

    if (result is Success) {
      await loadRatings(requestId, userId);
    }

    return result;
  }

  Future<Result<void>> deleteRating(
    String ratingId,
    String requestId,
    String userId,
  ) async {
    final result = await _repository.deleteRating(ratingId);

    if (result is Success) {
      await loadRatings(requestId, userId);
    }

    return result;
  }
}
