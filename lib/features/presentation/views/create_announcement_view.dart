import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class CreateAnnouncementView extends ConsumerStatefulWidget {
  final AnnouncementEntity? announcement;

  const CreateAnnouncementView({super.key, this.announcement});

  @override
  ConsumerState<CreateAnnouncementView> createState() =>
      _CreateAnnouncementViewState();
}

class _CreateAnnouncementViewState
    extends ConsumerState<CreateAnnouncementView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isCheckingAccess = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      _titleController.text = widget.announcement!.title;
      _contentController.text = widget.announcement!.content;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAdminAccess();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.announcement != null;

  Future<void> _verifyAdminAccess() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        context.showErrorToast('Lütfen giriş yapın');
        Navigator.pop(context);
      }
      return;
    }

    bool allowed = false;
    if (user.roleId?.toLowerCase() == 'admin') {
      allowed = true;
    }
    setState(() {
      _isAdmin = allowed;
      _isCheckingAccess = false;
    });
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        context.showErrorToast('Kullanıcı bilgisi bulunamadı');
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final announcement = AnnouncementEntity(
      id: _isEditing ? widget.announcement!.id : '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorId: user.id,
      authorName: user.displayName ?? user.email,
      createdAt: _isEditing ? widget.announcement!.createdAt : DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
      isActive: true,
    );

    final Result result;
    if (_isEditing) {
      result = await ref
          .read(announcementControllerProvider)
          .updateAnnouncement(announcement);
    } else {
      result = await ref
          .read(announcementControllerProvider)
          .createAnnouncement(announcement);
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    result.when(
      success: (_) {
        context.showSuccessToast(
          _isEditing ? 'Duyuru güncellendi' : 'Duyuru başarıyla oluşturuldu',
        );
        Navigator.pop(context);
      },
      failure: (error) {
        context.showErrorToast('Hata: ${error.message}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                _isEditing ? 'Duyuruyu Düzenle' : 'Yeni Duyuru',
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
                                'Duyuru Başlığı',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  hintText: 'Örn: Önemli Duyuru',
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(),
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

                      // Content Field
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duyuru İçeriği',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _contentController,
                                decoration: const InputDecoration(
                                  hintText: 'Duyuru içeriğini yazın...',
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 10,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen duyuru içeriği girin';
                                  }
                                  if (value.length < 10) {
                                    return 'İçerik en az 10 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Card
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Bu duyuru tüm kullanıcılara görünür olacaktır.',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting || !_isAdmin
                              ? null
                              : _submitAnnouncement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEditing ? 'Güncelle' : 'Yayınla',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
}
