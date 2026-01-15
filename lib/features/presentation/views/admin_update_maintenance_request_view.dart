import 'dart:io';

import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/services/image_picker_service.dart';
import 'package:campus_care/core/services/photo_storage_service.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUpdateMaintenanceRequestView extends ConsumerStatefulWidget {
  final MaintenanceRequestEntity request;

  const AdminUpdateMaintenanceRequestView({super.key, required this.request});

  @override
  ConsumerState<AdminUpdateMaintenanceRequestView> createState() =>
      _AdminUpdateMaintenanceRequestViewState();
}

class _AdminUpdateMaintenanceRequestViewState
    extends ConsumerState<AdminUpdateMaintenanceRequestView> {
  final _noteController = TextEditingController();
  final _imagePickerService = ImagePickerService();
  final _photoStorageService = PhotoStorageService();
  final List<File> _newPhotos = [];
  late MaintenanceStatus _selectedStatus;
  bool _isSubmitting = false;

  List<String> get _existingPhotos => widget.request.photoUrls;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.request.status;
    _noteController.text = widget.request.adminNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Talebi Güncelle (Admin)',
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusCard(context),
                const SizedBox(height: 12),
                _buildNoteCard(context),
                const SizedBox(height: 12),
                _buildPhotosCard(context),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durum',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaintenanceStatus>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: MaintenanceStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_statusText(status)),
                );
              }).toList(),
              onChanged: (status) {
                if (status != null) {
                  setState(() => _selectedStatus = status);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Açıklama / Not',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Talep ile ilgili açıklama ekleyin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              minLines: 3,
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fotoğraflar',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_existingPhotos.isNotEmpty) ...[
              Text(
                'Mevcut Fotoğraflar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(_existingPhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_newPhotos.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni fotoğraflar ekleyin',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_newPhotos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeNewPhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final images = await _imagePickerService.pickMultipleFromGallery();
    if (images.isNotEmpty) {
      setState(() => _newPhotos.addAll(images));
    }
  }

  void _removeNewPhoto(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authControllerProvider).data ?? AuthData();
      final user = authState.user;
      if (user == null) {
        if (mounted) context.showErrorToast('Kullanıcı bilgisi bulunamadı');
        return;
      }

      List<String> uploadedUrls = [];
      if (_newPhotos.isNotEmpty) {
        final uploadResult = await _photoStorageService.uploadMultiplePhotos(
          _newPhotos,
          user.id,
        );
        uploadedUrls = uploadResult;
      }

      final updatedRequest = MaintenanceRequestEntity(
        id: widget.request.id,
        title: widget.request.title,
        description: widget.request.description,
        userId: widget.request.userId,
        categoryId: widget.request.categoryId,
        locationId: widget.request.locationId,
        roomId: widget.request.roomId,
        priority: widget.request.priority,
        status: _selectedStatus,
        createdAt: widget.request.createdAt,
        updatedAt: DateTime.now(),
        completedAt: _selectedStatus == MaintenanceStatus.completed
            ? DateTime.now()
            : widget.request.completedAt,
        photoUrls: [..._existingPhotos, ...uploadedUrls],
        adminNote: _noteController.text.trim().isEmpty
            ? widget.request.adminNote
            : _noteController.text.trim(),
      );

      final Result<MaintenanceRequestEntity> result = await ref
          .read(maintenanceRequestControllerProvider.notifier)
          .updateRequest(updatedRequest);

      if (!mounted) return;

      result.when(
        success: (data) {
          context.showSuccessToast('Talep güncellendi');
          Navigator.pop(context, data);
        },
        failure: (error) {
          context.showErrorToast(error.message);
        },
      );
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Güncelleme başarısız: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _statusText(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Bekliyor';
      case MaintenanceStatus.assigned:
        return 'Atandı';
      case MaintenanceStatus.inProgress:
        return 'Devam Ediyor';
      case MaintenanceStatus.completed:
        return 'Tamamlandı';
      case MaintenanceStatus.cancelled:
        return 'İptal';
      case MaintenanceStatus.rejected:
        return 'Reddedildi';
    }
  }
}
