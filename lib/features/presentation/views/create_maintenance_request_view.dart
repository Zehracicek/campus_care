import 'dart:io';

import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/core/services/image_picker_service.dart';
import 'package:campus_care/core/services/location_service.dart';
import 'package:campus_care/core/services/photo_storage_service.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/widgets/location_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateMaintenanceRequestView extends ConsumerStatefulWidget {
  final DepartmentEntity? preSelectedDepartment;

  const CreateMaintenanceRequestView({super.key, this.preSelectedDepartment});

  @override
  ConsumerState<CreateMaintenanceRequestView> createState() =>
      _CreateMaintenanceRequestViewState();
}

class _CreateMaintenanceRequestViewState
    extends ConsumerState<CreateMaintenanceRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePickerService = ImagePickerService();
  final _photoStorageService = PhotoStorageService();

  MaintenancePriority _selectedPriority = MaintenancePriority.medium;
  bool _isSubmitting = false;
  final List<File> _selectedPhotos = [];
  LocationData? _selectedLocation;
  MaintenanceCategoryEntity? _selectedCategory;
  DepartmentEntity? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentControllerProvider.notifier).loadDepartments();
      if (widget.preSelectedDepartment != null) {
        setState(() {
          _selectedDepartment = widget.preSelectedDepartment;
        });
      }
    });
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
                'Yeni Talep Oluştur',
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
                                decoration: const InputDecoration(
                                  hintText: 'Örn: Klima arızası',
                                  prefixIcon: Icon(Icons.title),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen bir başlık girin';
                                  }
                                  if (value.length < 3) {
                                    return 'Başlık en az 3 karakter olmalı';
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
                                decoration: const InputDecoration(
                                  hintText: 'Problemi detaylı açıklayın...',
                                  prefixIcon: Icon(Icons.description),
                                ),
                                maxLines: 5,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen bir açıklama girin';
                                  }
                                  if (value.length < 10) {
                                    return 'Açıklama en az 10 karakter olmalı';
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
                                'Öncelik Durumu',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: MaintenancePriority.values
                                    .map(
                                      (priority) =>
                                          _buildPriorityChip(priority),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Department Selection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bölüm',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDepartmentDropdown(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // // Category Selection
                      // Card(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Kategori',
                      //           style: context.textTheme.titleMedium?.copyWith(
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //         const SizedBox(height: 12),
                      //         if (_selectedCategory != null) ...<Widget>[
                      //           Container(
                      //             padding: const EdgeInsets.all(12),
                      //             decoration: BoxDecoration(
                      //               color: AppTheme.primaryColor.withValues(alpha:
                      //                 0.1,
                      //               ),
                      //               borderRadius: BorderRadius.circular(8),
                      //               border: Border.all(
                      //                 color: AppTheme.primaryColor,
                      //                 width: 1,
                      //               ),
                      //             ),
                      //             child: Row(
                      //               children: [
                      //                 Container(
                      //                   padding: const EdgeInsets.all(8),
                      //                   decoration: BoxDecoration(
                      //                     color: AppTheme.primaryColor
                      //                         .withValues(alpha:0.2),
                      //                     borderRadius: BorderRadius.circular(
                      //                       8,
                      //                     ),
                      //                   ),
                      //                   child: Icon(
                      //                     _getCategoryIcon(
                      //                       _selectedCategory!.icon,
                      //                     ),
                      //                     color: AppTheme.primaryColor,
                      //                     size: 24,
                      //                   ),
                      //                 ),
                      //                 const SizedBox(width: 12),
                      //                 Expanded(
                      //                   child: Column(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Text(
                      //                         _selectedCategory!.name,
                      //                         style: context.textTheme.bodyLarge
                      //                             ?.copyWith(
                      //                               fontWeight: FontWeight.bold,
                      //                             ),
                      //                       ),
                      //                       if (_selectedCategory!
                      //                           .description
                      //                           .isNotEmpty)
                      //                         Text(
                      //                           _selectedCategory!.description,
                      //                           style:
                      //                               context.textTheme.bodySmall,
                      //                           maxLines: 1,
                      //                           overflow: TextOverflow.ellipsis,
                      //                         ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 IconButton(
                      //                   icon: const Icon(Icons.close, size: 20),
                      //                   onPressed: () {
                      //                     setState(() {
                      //                       _selectedCategory = null;
                      //                     });
                      //                   },
                      //                   padding: EdgeInsets.zero,
                      //                   constraints: const BoxConstraints(),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           const SizedBox(height: 12),
                      //         ],
                      //         OutlinedButton.icon(
                      //           onPressed: _openCategorySelection,
                      //           icon: const Icon(Icons.category),
                      //           label: Text(
                      //             _selectedCategory == null
                      //                 ? 'Kategori Seç'
                      //                 : 'Kategoriyi Değiştir',
                      //           ),
                      //           style: OutlinedButton.styleFrom(
                      //             minimumSize: const Size.fromHeight(48),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),

                      // st SizedBox(height: 16),

                      // Location Section
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
                              if (_selectedLocation != null) ...<Widget>[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedLocation!.address ??
                                              'Konum seçildi',
                                          style: context.textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _selectedLocation = null;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              OutlinedButton.icon(
                                onPressed: _openLocationPicker,
                                icon: const Icon(Icons.location_on),
                                label: Text(
                                  _selectedLocation == null
                                      ? 'Konum Seç'
                                      : 'Konumu Değiştir',
                                ),
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
                                children: [
                                  Text(
                                    'Fotoğraflar',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (_selectedPhotos.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_selectedPhotos.length}',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_selectedPhotos.isNotEmpty) _buildPhotoGrid(),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _showImageSourceBottomSheet,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Fotoğraf Ekle'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Talep Oluştur',
                                style: TextStyle(
                                  fontSize: 16,
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

  Widget _buildDepartmentDropdown() {
    return Consumer(
      builder: (context, ref, _) {
        final departmentState = ref.watch(departmentControllerProvider);

        if (departmentState.isLoading) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (departmentState.error != null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'Bölümler yüklenemedi: ${departmentState.error}',
              style: TextStyle(color: Colors.red[600]),
            ),
          );
        }

        final departments = departmentState.data ?? [];

        if (departments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text('Bölüm yok', style: TextStyle(color: Colors.grey[600])),
          );
        }

        return DropdownButton<DepartmentEntity>(
          value: _selectedDepartment,
          isExpanded: true,
          hint: Text('Bölüm seçin', style: TextStyle(color: Colors.grey[600])),
          items: departments
              .map(
                (dept) => DropdownMenuItem<DepartmentEntity>(
                  value: dept,
                  child: Text(dept.name),
                ),
              )
              .toList(),
          onChanged: (DepartmentEntity? newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
        );
      },
    );
  }

  Widget _buildPriorityChip(MaintenancePriority priority) {
    final isSelected = _selectedPriority == priority;
    final color = _getPriorityColor(priority);

    return ChoiceChip(
      label: Text(_getPriorityText(priority)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPriority = priority;
          });
        }
      },
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedPhotos.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedPhotos[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotos.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Fotoğraf Seç',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Yeni fotoğraf çek'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Galeriden seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerWidget(
          initialLocation: _selectedLocation,
          onLocationSelected: (location) {
            setState(() {
              _selectedLocation = location;
            });
            context.showSuccessToast('Konum seçildi');
          },
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final photo = await _imagePickerService.pickFromCamera();
      if (photo != null) {
        setState(() {
          _selectedPhotos.add(photo);
        });
        if (mounted) {
          context.showSuccessToast('Fotoğraf eklendi');
        }
      }
    } on ImagePickerException catch (e) {
      if (mounted) {
        context.showErrorToast(e.message);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf eklenirken hata oluştu');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final photo = await _imagePickerService.pickFromGallery();
      if (photo != null) {
        setState(() {
          _selectedPhotos.add(photo);
        });
        if (mounted) {
          context.showSuccessToast('Fotoğraf eklendi');
        }
      }
    } on ImagePickerException catch (e) {
      if (mounted) {
        context.showErrorToast(e.message);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Fotoğraf eklenirken hata oluştu');
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authControllerProvider).data;
      final user = authState?.user;

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

      final newRequest = MaintenanceRequestEntity(
        id: '', // Firestore will generate
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: MaintenanceStatus.pending,
        priority: _selectedPriority,
        userId: user.id,
        categoryId: _selectedCategory?.id ?? '',
        locationId: _selectedLocation != null
            ? '${_selectedLocation!.latitude},${_selectedLocation!.longitude}'
            : '',
        roomId: _selectedDepartment?.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: null,
        photoUrls: photoUrls,
        adminNote: null,
      );

      final controller = ref.read(
        maintenanceRequestControllerProvider.notifier,
      );
      final result = await controller.createRequest(newRequest);

      if (!mounted) return;

      result.when(
        success: (data) {
          context.showSuccessToast('Talep başarıyla oluşturuldu');
          AppRoutes.pop(context);
        },
        failure: (error) {
          context.showErrorToast(error.message);
        },
      );
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
