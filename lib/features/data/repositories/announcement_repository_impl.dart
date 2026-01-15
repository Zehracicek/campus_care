import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/data/models/announcement_model.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';
import 'package:campus_care/features/domain/repositories/announcement_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  AnnouncementRepositoryImpl(this._firestore);

  @override
  Future<Result<List<AnnouncementEntity>>> getAllAnnouncements({
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore.collection('announcements');

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      final announcements = snapshot.docs
          .map(
            (doc) => AnnouncementModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      return Success(announcements);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<AnnouncementEntity>> getAnnouncementById(String id) async {
    try {
      final doc = await _firestore.collection('announcements').doc(id).get();
      if (!doc.exists) {
        return const Failure(message: 'Duyuru bulunamadı');
      }
      final announcement = AnnouncementModel.fromJson(doc.data()!).toEntity();
      return Success(announcement);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<AnnouncementEntity>> createAnnouncement(
    AnnouncementEntity announcement,
  ) async {
    try {
      final id = announcement.id.isEmpty ? _uuid.v4() : announcement.id;
      final announcementWithId = AnnouncementEntity(
        id: id,
        title: announcement.title,
        content: announcement.content,
        authorId: announcement.authorId,
        authorName: announcement.authorName,
        createdAt: announcement.createdAt,
        updatedAt: announcement.updatedAt,
        isActive: announcement.isActive,
      );
      final model = AnnouncementModel.fromEntity(announcementWithId);
      await _firestore.collection('announcements').doc(id).set(model.toJson());
      return Success(announcementWithId);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<AnnouncementEntity>> updateAnnouncement(
    AnnouncementEntity announcement,
  ) async {
    try {
      final model = AnnouncementModel.fromEntity(announcement);
      await _firestore
          .collection('announcements')
          .doc(announcement.id)
          .update(model.toJson());
      return Success(announcement);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Future<Result<void>> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Failure(message: e.toString());
    }
  }

  @override
  Stream<List<AnnouncementEntity>> streamAnnouncements({
    bool activeOnly = true,
  }) {
    Query query = _firestore.collection('announcements');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AnnouncementModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ).toEntity(),
              )
              .toList(),
        );
  }
}
