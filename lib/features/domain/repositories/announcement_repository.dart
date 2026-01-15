import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  /// Get all announcements (active only by default)
  Future<Result<List<AnnouncementEntity>>> getAllAnnouncements({
    bool activeOnly = true,
  });

  /// Get an announcement by ID
  Future<Result<AnnouncementEntity>> getAnnouncementById(String id);

  /// Create a new announcement (admin only)
  Future<Result<AnnouncementEntity>> createAnnouncement(
    AnnouncementEntity announcement,
  );

  /// Update an announcement (admin only)
  Future<Result<AnnouncementEntity>> updateAnnouncement(
    AnnouncementEntity announcement,
  );

  /// Delete an announcement (admin only)
  Future<Result<void>> deleteAnnouncement(String id);

  /// Stream announcements (real-time updates)
  Stream<List<AnnouncementEntity>> streamAnnouncements({
    bool activeOnly = true,
  });
}
