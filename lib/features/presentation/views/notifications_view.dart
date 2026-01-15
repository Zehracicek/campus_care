import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    if (user != null) {
      await ref.read(notificationControllerProvider).loadNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationController = ref.watch(notificationControllerProvider);
    final notificationState = notificationController.state;
    final authState = ref.watch(authControllerProvider).data ?? AuthData();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bildirimler'),
            if (notificationState.unreadCount > 0)
              Text(
                '${notificationState.unreadCount} okunmamış',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () async {
                if (authState.user != null) {
                  await notificationController.markAllAsRead(
                    authState.user!.id,
                  );
                  if (mounted) {
                    context.showSuccessToast(
                      'Tüm bildirimler okundu olarak işaretlendi',
                    );
                  }
                }
              },
              tooltip: 'Tümünü okundu işaretle',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child:
            notificationState.isLoading &&
                notificationState.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notificationState.notifications.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _EmptyStateWidget(
                    icon: Icons.notifications_none,
                    message: 'Henüz bildirim bulunmuyor',
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notificationState.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationState.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () async {
                      if (!notification.isRead && authState.user != null) {
                        await notificationController.markAsRead(
                          notification.id,
                          authState.user!.id,
                        );
                      }
                      // TODO: Navigate to related request if requestId exists
                      if (notification.requestId != null) {
                        context.showInfoToast(
                          'Talebe git: ${notification.requestId}',
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead
          ? null
          : AppTheme.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForType(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: _getColorForType(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.requestCreated:
        return Icons.add_circle_outline;
      case NotificationType.requestAssigned:
        return Icons.assignment_ind;
      case NotificationType.requestStatusChanged:
        return Icons.change_circle_outlined;
      case NotificationType.requestCompleted:
        return Icons.check_circle_outline;
      case NotificationType.commentAdded:
        return Icons.comment;
      case NotificationType.other:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.requestCreated:
        return Colors.blue;
      case NotificationType.requestAssigned:
        return Colors.indigo;
      case NotificationType.requestStatusChanged:
        return Colors.amber;
      case NotificationType.requestCompleted:
        return Colors.green;
      case NotificationType.commentAdded:
        return Colors.purple;
      case NotificationType.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
    }
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateWidget({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
