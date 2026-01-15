import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Bu cihaz içerisindeki kamerayı ve galeriyi kullanarak fotoğraf seçmeyi sağlar.
/// Service for handling image picking from camera or gallery
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw ImagePickerException('Kamera kullanılırken hata oluştu: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw ImagePickerException('Galeri kullanılırken hata oluştu: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw ImagePickerException(
        'Birden fazla fotoğraf seçilirken hata oluştu: $e',
      );
    }
  }

  /// Show bottom sheet to choose between camera and gallery
  /// Returns null if user cancels
  Future<File?> showImageSourceDialog({
    required Future<File?> Function() onCamera,
    required Future<File?> Function() onGallery,
  }) async {
    // This is just a helper method structure
    // The actual dialog will be shown in the UI layer
    throw UnimplementedError('Use showImageSourceBottomSheet in the UI layer');
  }
}

/// Custom exception for image picker errors
class ImagePickerException implements Exception {
  final String message;

  ImagePickerException(this.message);

  @override
  String toString() => message;
}
