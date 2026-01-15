import 'dart:io';

import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/services/image_picker_service.dart';
import 'package:campus_care/core/services/location_service.dart';
import 'package:campus_care/core/services/photo_storage_service.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/widgets/location_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class EditMaintenanceRequestView extends ConsumerStatefulWidget {
  final MaintenanceRequestEntity request;

  const EditMaintenanceRequestView({super.key, required this.request});

  @override
  ConsumerState<EditMaintenanceRequestView> createState() => 
      _EditMaintenanceRequestViewState();
}

class _EditMaintenanceRequestViewState
    extends ConsumerState<EditMaintenanceRequestView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _imagePickerService = ImagePickerService();
  final _photoStorageService = PhotoStorageService();

  late MaintenancePriority _selectedPriority;
  bool _isSubmitting = false;
  final List<File> _selectedPhotos = [];
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.request.title);
    _descriptionController = TextEditingController(
      text: widget.request.description,
    );
    _selectedPriority = widget.request.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Talebi Düzenle',
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

          // Form Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title Field
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Talep Başlığı',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'Talep başlığını girin',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Lütfen bir başlık girin';
                                  }
                                  if (value.trim().length < 5) {
                                    return 'Başlık en az 5 karakter olmalıdır';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Açıklama',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: 'Talep detaylarını açıklayın',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Lütfen bir açıklama girin';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Açıklama en az 10 karakter olmalıdır';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Priority Selection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Öncelik Seviyesi',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: MaintenancePriority.values.map((
                                  priority,
                                ) {
                                  return ChoiceChip(
                                    label: Text(_getPriorityText(priority)),
                                    selected: _selectedPriority == priority,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedPriority = priority;
                                        });
                                      }
                                    },
                                    selectedColor: _getPriorityColor(
                                      priority,
                                    ).withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: _selectedPriority == priority
                                          ? _getPriorityColor(priority)
                                          : Colors.grey[700],
                                      fontWeight: _selectedPriority == priority
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location Selection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konum',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_selectedLocation != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedLocation!.address ??
                                                  'Konum seçildi',
                                              style: TextStyle(
                                                color: Colors.green[900],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: _showLocationPicker,
                                      ),
                                    ],
                                  ),
                                ),
                              if (_selectedLocation == null)
                                OutlinedButton.icon(
                                  onPressed: _showLocationPicker,
                                  icon: const Icon(Icons.location_on),
                                  label: const Text('Konum Seç'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Photos Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Fotoğraflar',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Ekle'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_selectedPhotos.isEmpty)
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Fotoğraf eklemek için tıklayın',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
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
                                    itemCount: _selectedPhotos.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            width: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: FileImage(
                                                  _selectedPhotos[index],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () => _removePhoto(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
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
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
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
                            : Text(
                                'Güncelle',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final images = await _imagePickerService.pickMultipleFromGallery();
    if (images.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(images);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerWidget(
        onLocationSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      context.showErrorToast('Lütfen bir konum seçin');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authControllerProvider).data ?? AuthData();
      final user = authState.user;

      if (user == null) {
        if (mounted) {
          context.showErrorToast('Kullanıcı bilgisi bulunamadı');
        }
        return;
      }

      // Upload photos if any selected
      // TODO: Store photoUrls in entity when photo field is added
      // ignore: unused_local_variable
      List<String> photoUrls = [];
      if (_selectedPhotos.isNotEmpty) {
        try {
          photoUrls = await _photoStorageService.uploadMultiplePhotos(
            _selectedPhotos,
            user.id,
          );
        } catch (e) {
          if (mounted) {
            context.showErrorToast('Fotoğraflar yüklenirken hata oluştu: $e');
          }
          return;
        }
      }

      final updatedRequest = MaintenanceRequestEntity(
        id: widget.request.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: widget.request.status,
        priority: _selectedPriority,
        userId: widget.request.userId,
        categoryId: widget.request.categoryId,
        locationId: _selectedLocation != null
            ? '${_selectedLocation!.latitude},${_selectedLocation!.longitude}'
            : widget.request.locationId,
        roomId: widget.request.roomId,
        createdAt: widget.request.createdAt,
        updatedAt: DateTime.now(),
        completedAt: widget.request.completedAt,
        photoUrls: [...widget.request.photoUrls, ...photoUrls],
        adminNote: widget.request.adminNote,
      );

      final result = await ref
          .read(maintenanceRequestControllerProvider.notifier)
          .updateRequest(updatedRequest);

      if (!mounted) return;

      result.when(
        success: (_) {
          context.showSuccessToast('Talep başarıyla güncellendi');
          Navigator.pop(context, updatedRequest);
        },
        failure: (error) {
          context.showErrorToast(error.message);
        },
      );
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Color _getPriorityColor(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return Colors.green;
      case MaintenancePriority.medium:
        return Colors.orange;
      case MaintenancePriority.high:
        return Colors.red;
      case MaintenancePriority.urgent:
        return Colors.deepPurple;
    }
  }

  String _getPriorityText(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return 'Düşük';
      case MaintenancePriority.medium:
        return 'Orta';
      case MaintenancePriority.high:
        return 'Yüksek';
      case MaintenancePriority.urgent:
        return 'Acil';
    }
  }
}
