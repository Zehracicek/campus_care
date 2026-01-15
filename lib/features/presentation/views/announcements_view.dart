import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/announcement_entity.dart';
import 'package:campus_care/features/presentation/views/create_announcement_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/app_providers.dart';
import '../controllers/auth_controller.dart';

class AnnouncementsView extends ConsumerStatefulWidget {
  const AnnouncementsView({super.key});

  @override
  ConsumerState<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends ConsumerState<AnnouncementsView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(announcementControllerProvider).streamAnnouncements();
      _loadAdminStatus();
    });
  }

  Future<void> _loadAdminStatus() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    bool allowed = false;
    if (user != null) {
      allowed = user.roleId?.toLowerCase() == 'admin';
    }

    if (mounted) {
      setState(() {
        _isAdmin = allowed;
        _isCheckingAdmin = false;
      });
    }
  }

  Future<void> _checkAdminAndNavigate() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    if (user == null) {
      if (mounted) {
        context.showErrorToast('Lütfen giriş yapın');
      }
      return;
    }

    if (_isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateAnnouncementView()),
      );
    } else {
      context.showErrorToast('Sadece adminler duyuru oluşturabilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementController = ref.watch(announcementControllerProvider);
    final announcementState = announcementController.state;
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyurular'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          announcementController.loadAnnouncements();
          await _loadAdminStatus();
        },
        child: announcementState.when(
          initial: () => const Center(child: Text('Duyurular yükleniyor...')),
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _EmptyStateWidget(
                icon: Icons.campaign_outlined,
                message: 'Henüz duyuru bulunmuyor',
              ),
            ],
          ),
          success: (announcements) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return _AnnouncementCard(
                announcement: announcement,
                onDelete: _isAdmin
                    ? () => _showDeleteDialog(announcement)
                    : null,
              );
            },
          ),
          error: (message, error) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ErrorStateWidget(
                message: message,
                onRetry: () => announcementController.loadAnnouncements(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: user != null && !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Duyuru'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  void _showDeleteDialog(AnnouncementEntity announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyuruyu Sil'),
        content: const Text('Bu duyuruyu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref
                  .read(announcementControllerProvider)
                  .deleteAnnouncement(announcement.id);

              if (mounted) {
                result.when(
                  success: (_) => context.showSuccessToast('Duyuru silindi'),
                  failure: (error) =>
                      context.showErrorToast('Hata: ${error.message}'),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final VoidCallback? onDelete;

  const _AnnouncementCard({required this.announcement, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.campaign,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                          'tr',
                        ).format(announcement.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  announcement.authorName ?? 'Yönetici',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateWidget({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
