import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Firebase üzerindeki fotoğrafların yüklenmesi ve yönetilmesini sağlar.
/// Service for uploading and managing photos in Firebase Storage
class PhotoStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a photo to Firebase Storage
  /// Returns the download URL
  Future<String> uploadPhoto(File photo, String userId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
      final String storagePath = 'maintenance_requests/$userId/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(
        photo,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw PhotoStorageException('Fotoğraf yüklenirken hata oluştu: $e');
    }
  }

  /// Upload multiple photos
  /// Returns list of download URLs
  Future<List<String>> uploadMultiplePhotos(
    List<File> photos,
    String userId,
  ) async {
    try {
      final List<String> downloadUrls = [];

      for (final photo in photos) {
        final url = await uploadPhoto(photo, userId);
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw PhotoStorageException('Fotoğraflar yüklenirken hata oluştu: $e');
    }
  }

  /// Delete a photo from Firebase Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw PhotoStorageException('Fotoğraf silinirken hata oluştu: $e');
    }
  }

  /// Delete multiple photos
  Future<void> deleteMultiplePhotos(List<String> photoUrls) async {
    try {
      for (final url in photoUrls) {
        await deletePhoto(url);
      }
    } catch (e) {
      throw PhotoStorageException('Fotoğraflar silinirken hata oluştu: $e');
    }
  }

  /// Get photo reference
  Reference getPhotoReference(String photoUrl) {
    return _storage.refFromURL(photoUrl);
  }

  /// Upload a profile photo to Firebase Storage
  /// Returns the download URL
  Future<String> uploadProfilePhoto(File photo, String userId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_profile.jpg';
      final String storagePath = 'users/$userId/profile/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(
        photo,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile_photo',
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw PhotoStorageException(
        'Profil fotoğrafı yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Delete old profile photo and upload new one
  /// Returns the new download URL
  Future<String> updateProfilePhoto(
    File newPhoto,
    String userId,
    String? oldPhotoUrl,
  ) async {
    try {
      // Delete old photo if exists
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        try {
          await deletePhoto(oldPhotoUrl);
        } catch (e) {
          // Continue even if old photo deletion fails
          print('Eski profil fotoğrafı silinemedi: $e');
        }
      }

      // Upload new photo
      return await uploadProfilePhoto(newPhoto, userId);
    } catch (e) {
      throw PhotoStorageException(
        'Profil fotoğrafı güncellenirken hata oluştu: $e',
      );
    }
  }

  /// Upload an event photo to Firebase Storage
  /// Returns the download URL
  Future<String> uploadEventPhoto(File photo, String eventId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
      final String storagePath = 'events/$eventId/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(
        photo,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'eventId': eventId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw PhotoStorageException(
        'Etkinlik fotoğrafı yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Upload multiple event photos
  /// Returns list of download URLs
  Future<List<String>> uploadMultipleEventPhotos(
    List<File> photos,
    String eventId,
  ) async {
    try {
      final List<String> downloadUrls = [];

      for (final photo in photos) {
        final url = await uploadEventPhoto(photo, eventId);
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw PhotoStorageException(
        'Etkinlik fotoğrafları yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Upload an announcement photo to Firebase Storage
  /// Returns the download URL
  Future<String> uploadAnnouncementPhoto(
    File photo,
    String announcementId,
  ) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
      final String storagePath = 'announcements/$announcementId/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(
        photo,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'announcementId': announcementId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw PhotoStorageException(
        'Duyuru fotoğrafı yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Upload multiple announcement photos
  /// Returns list of download URLs
  Future<List<String>> uploadMultipleAnnouncementPhotos(
    List<File> photos,
    String announcementId,
  ) async {
    try {
      final List<String> downloadUrls = [];

      for (final photo in photos) {
        final url = await uploadAnnouncementPhoto(photo, announcementId);
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw PhotoStorageException(
        'Duyuru fotoğrafları yüklenirken hata oluştu: $e',
      );
    }
  }
}

/// Custom exception for photo storage errors
class PhotoStorageException implements Exception {
  final String message;

  PhotoStorageException(this.message);

  @override
  String toString() => message;
}
