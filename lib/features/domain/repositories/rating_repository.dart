import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/rating_entity.dart';

abstract class RatingRepository {
  Future<Result<List<RatingEntity>>> getRatingsByRequest(String requestId);
  Future<Result<RatingEntity?>> getUserRatingForRequest({
    required String requestId,
    required String userId,
  });
  Future<Result<void>> addRating(RatingEntity rating);
  Future<Result<void>> updateRating(RatingEntity rating);
  Future<Result<void>> deleteRating(String ratingId);
}
