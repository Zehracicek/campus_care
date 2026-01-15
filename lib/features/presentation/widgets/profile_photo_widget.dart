import 'dart:io';

import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/services/image_picker_service.dart';
import 'package:campus_care/core/services/photo_storage_service.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/user_usecases.dart';

/// Widget for uploading profile photo
class ProfilePhotoWidget extends ConsumerStatefulWidget {
  final dynamic user;

  const ProfilePhotoWidget({super.key, required this.user});

  @override
  ConsumerState<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends ConsumerState<ProfilePhotoWidget> {
  final _imagePickerService = ImagePickerService();
  final _photoStorageService = PhotoStorageService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage:
              widget.user?.photoUrl != null && widget.user!.photoUrl!.isNotEmpty
              ? NetworkImage(widget.user!.photoUrl!)
              : null,
          child: widget.user?.photoUrl == null || widget.user!.photoUrl!.isEmpty
              ? Text(
                  _getAvatarLetter(widget.user),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C6FFF),
                  ),
                )
              : null,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5C6FFF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, size: 16),
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: _showPhotoOptions,
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kameradan Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (widget.user?.photoUrl != null &&
                widget.user!.photoUrl!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Fotoğrafı Kaldır',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final photo = await _imagePickerService.pickFromCamera();

      if (photo != null && mounted) {
        await _uploadProfilePhoto(photo);
        await _loadAdminStatus();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf çekilirken hata oluştu: $e');
      }
    }
  }

  Future<void> _loadAdminStatus() async {
    ref.read(authControllerProvider.notifier).getCurrentUser();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final photo = await _imagePickerService.pickFromGallery();

      if (photo != null && mounted) {
        await _uploadProfilePhoto(photo);
        await _loadAdminStatus();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf seçilirken hata oluştu: $e');
      }
    }
  }

  Future<void> _uploadProfilePhoto(File photo) async {
    if (widget.user == null) return;

    try {
      context.showInfoToast('Fotoğraf yükleniyor...');

      final photoUrl = await _photoStorageService.updateProfilePhoto(
        photo,
        widget.user.id,
        widget.user.photoUrl,
      );

      // Update user profile with new photo URL
      final updatedUser = UserEntity(
        id: widget.user.id,
        email: widget.user.email,
        displayName: widget.user.displayName,
        photoUrl: photoUrl,
        phone: widget.user.phone,
        roleId: widget.user.roleId,
        departmentId: widget.user.departmentId,
        createdAt: widget.user.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await ref
          .read(updateUserProfileUseCaseProvider)
          .call(params: UpdateUserProfileParams(updatedUser));

      if (mounted) {
        result.when(
          success: (_) {
            context.showSuccessToast('Profil fotoğrafı güncellendi');
            ref.invalidate(authControllerProvider);
            _loadAdminStatus();
          },
          failure: (failure) {
            context.showErrorToast(failure.message);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf yüklenirken hata oluştu: $e');
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    if (widget.user == null) return;

    try {
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fotoğrafı Kaldır'),
          content: const Text(
            'Profil fotoğrafınızı kaldırmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Kaldır'),
            ),
          ],
        ),
      );

      if (shouldRemove != true || !mounted) return;

      context.showInfoToast('Fotoğraf kaldırılıyor...');

      // Delete photo from Firebase Storage
      if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
        await _photoStorageService.deletePhoto(widget.user.photoUrl!);
      }

      // Update user profile
      final updatedUser = UserEntity(
        id: widget.user.id,
        email: widget.user.email,
        displayName: widget.user.displayName,
        photoUrl: null,
        phone: widget.user.phone,
        roleId: widget.user.roleId,
        departmentId: widget.user.departmentId,
        createdAt: widget.user.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await ref
          .read(updateUserProfileUseCaseProvider)
          .call(params: UpdateUserProfileParams(updatedUser));

      if (mounted) {
        result.when(
          success: (_) {
            context.showSuccessToast('Profil fotoğrafı kaldırıldı');
            ref.invalidate(authControllerProvider);
            _loadAdminStatus();
          },
          failure: (failure) {
            context.showErrorToast(failure.message);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf kaldırılırken hata oluştu: $e');
      }
    }
  }

  String _getAvatarLetter(dynamic user) {
    if (user?.displayName != null && user.displayName.isNotEmpty) {
      return user.displayName.substring(0, 1).toUpperCase();
    }
    if (user?.email != null && user.email.isNotEmpty) {
      return user.email.substring(0, 1).toUpperCase();
    }
    return 'K';
  }
}
