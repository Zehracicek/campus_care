import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/views/edit_maintenance_request_view.dart';
import 'package:campus_care/features/presentation/widgets/comments_widget.dart';
import 'package:campus_care/features/presentation/widgets/ratings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/providers/app_providers.dart';
import 'admin_update_maintenance_request_view.dart';

class MaintenanceRequestDetailView extends ConsumerWidget {
  final MaintenanceRequestEntity request;

  const MaintenanceRequestDetailView({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'Talep Detayı',
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

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status Card
                _buildStatusCard(context),
                const SizedBox(height: 16),

                // Details Card
                _buildDetailsCard(context),
                const SizedBox(height: 16),

                if ((request.adminNote ?? '').isNotEmpty) ...[
                  _buildAdminNoteCard(context),
                  const SizedBox(height: 16),
                ],

                if (request.photoUrls.isNotEmpty) ...[
                  _buildPhotosCard(context),
                  const SizedBox(height: 16),
                ],

                // Location Card
                _buildLocationCard(context),
                const SizedBox(height: 16),

                // Actions
                _buildActionsCard(context, ref),
                const SizedBox(height: 32),
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
            Row(
              children: [
                _getStatusIcon(request.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            request.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(request.status),
                          style: TextStyle(
                            color: _getStatusColor(request.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPriorityColor(
                  request.priority,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: _getPriorityColor(request.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPriorityText(request.priority),
                    style: TextStyle(
                      color: _getPriorityColor(request.priority),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
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
            Text(request.description, style: context.textTheme.bodyMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Oluşturulma',
              DateFormat('dd MMM yyyy, HH:mm').format(request.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.update,
              'Son Güncelleme',
              DateFormat('dd MMM yyyy, HH:mm').format(request.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNoteCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yönetici Notu',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(request.adminNote ?? '-', style: context.textTheme.bodyMedium),
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
            Text(
              'Fotoğraflar',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: request.photoUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(request.photoUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    // Parse location from locationId (format: "latitude,longitude")
    double? latitude;
    double? longitude;

    if (request.locationId.isNotEmpty) {
      final parts = request.locationId.split(',');
      if (parts.length == 2) {
        latitude = double.tryParse(parts[0]);
        longitude = double.tryParse(parts[1]);
      }
    }

    final hasLocation = latitude != null && longitude != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Konum Bilgisi',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasLocation) ...[
              // Mini Map
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.campus_care',
                        maxNativeZoom: 19,
                        maxZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Text(
                'Konum bilgisi mevcut değil',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final currentUser = authState.user;
    final isOwner = currentUser?.id == request.userId;
    final isAdmin = (currentUser?.roleId ?? '').toLowerCase() == 'admin';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CommentsWidget(requestId: request.id),
                );
              },
              icon: const Icon(Icons.comment),
              label: const Text('Yorumlar'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => RatingsWidget(requestId: request.id),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Değerlendirmeler'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<MaintenanceRequestEntity>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminUpdateMaintenanceRequestView(request: request),
                    ),
                  );

                  if (result != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MaintenanceRequestDetailView(request: result),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Talebi Güncelle (Admin)'),
              ),
            ],
            if (isOwner && request.status == MaintenanceStatus.pending) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<MaintenanceRequestEntity>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditMaintenanceRequestView(request: request),
                    ),
                  );

                  if (result != null && context.mounted) {
                    // Refresh the view with updated data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MaintenanceRequestDetailView(request: result),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Düzenle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(child: Text(value, style: context.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _getStatusIcon(MaintenanceStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MaintenanceStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case MaintenanceStatus.assigned:
        icon = Icons.assignment_ind;
        color = Colors.blue[300]!;
        break;
      case MaintenanceStatus.inProgress:
        icon = Icons.build_circle;
        color = Colors.blue;
        break;
      case MaintenanceStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case MaintenanceStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case MaintenanceStatus.rejected:
        icon = Icons.block;
        color = Colors.red[300]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Colors.orange;
      case MaintenanceStatus.assigned:
        return Colors.blue[300]!;
      case MaintenanceStatus.inProgress:
        return Colors.blue;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.cancelled:
        return Colors.red;
      case MaintenanceStatus.rejected:
        return Colors.red[300]!;
    }
  }

  String _getStatusText(MaintenanceStatus status) {
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
        return 'İptal Edildi';
      case MaintenanceStatus.rejected:
        return 'Reddedildi';
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
