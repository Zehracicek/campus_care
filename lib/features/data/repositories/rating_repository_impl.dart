import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/rating_model.dart';
import 'package:campus_care/features/domain/entities/rating_entity.dart';
import 'package:campus_care/features/domain/repositories/rating_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore;

  RatingRepositoryImpl(this._firestore);

  @override
  Future<Result<List<RatingEntity>>> getRatingsByRequest(
    String requestId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('requestId', isEqualTo: requestId)
          .orderBy('createdAt', descending: true)
          .get();

      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Success(ratings);
    } catch (e) {
      return Failure(message: 'Değerlendirmeler yüklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<RatingEntity?>> getUserRatingForRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('requestId', isEqualTo: requestId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Success(null);
      }

      final rating = RatingModel.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });

      return Success(rating);
    } catch (e) {
      return Failure(
        message: 'Kullanıcı değerlendirmesi yüklenemedi: ${e.toString()}',
      );
    }
  }

  @override
  Future<Result<void>> addRating(RatingEntity rating) async {
    try {
      final model = RatingModel(
        id: rating.id,
        requestId: rating.requestId,
        userId: rating.userId,
        rating: rating.rating,
        comment: rating.comment,
        createdAt: rating.createdAt,
      );

      await _firestore.collection('ratings').add(model.toJson());
      return Success(null);
    } catch (e) {
      return Failure(message: 'Değerlendirme eklenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateRating(RatingEntity rating) async {
    try {
      final model = RatingModel(
        id: rating.id,
        requestId: rating.requestId,
        userId: rating.userId,
        rating: rating.rating,
        comment: rating.comment,
        createdAt: rating.createdAt,
      );

      await _firestore
          .collection('ratings')
          .doc(rating.id)
          .update(model.toJson());
      return Success(null);
    } catch (e) {
      return Failure(message: 'Değerlendirme güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteRating(String ratingId) async {
    try {
      await _firestore.collection('ratings').doc(ratingId).delete();
      return Success(null);
    } catch (e) {
      return Failure(message: 'Değerlendirme silinemedi: ${e.toString()}');
    }
  }
}
