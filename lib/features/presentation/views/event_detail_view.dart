import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class EventDetailView extends StatelessWidget {
  final EventEntity event;

  const EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final parsedLatLng = _resolveLatLng(event);
    final isActive = event.isActive;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Etkinlik Detayı',
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
                _buildHeaderCard(context, isActive),
                const SizedBox(height: 16),
                _buildInfoCard(context, parsedLatLng),
                const SizedBox(height: 16),
                _buildDescriptionCard(context),
                const SizedBox(height: 16),
                _buildLocationCard(context, parsedLatLng),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isActive) {
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Aktif' : 'Pasif',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, LatLng? latLng) {
    final locationText = _formatLocationText(event, latLng);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Tarih',
              value: DateFormat(
                'dd MMM yyyy, HH:mm',
                'tr',
              ).format(event.eventDate),
            ),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.place, label: 'Konum', value: locationText),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person,
              label: 'Oluşturan',
              value: event.createdByName,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.schedule,
              label: 'Oluşturulma',
              value: DateFormat(
                'dd MMM yyyy, HH:mm',
                'tr',
              ).format(event.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
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
            Text(
              event.description,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, LatLng? position) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Haritada Gör',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (position != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: position,
                      initialZoom: 15,
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
                            point: position,
                            width: 40,
                            height: 40,
                            child: const Icon(
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
                        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
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
                'Konum harita formatında değil',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  LatLng? _resolveLatLng(EventEntity entity) {
    if (entity.latitude != null && entity.longitude != null) {
      return LatLng(entity.latitude!, entity.longitude!);
    }
    final parsed = _parseLatLngString(entity.location);
    return parsed;
  }

  LatLng? _parseLatLngString(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String _formatLocationText(EventEntity entity, LatLng? latLng) {
    if (entity.location.trim().isNotEmpty) {
      return entity.location;
    }
    if (latLng != null) {
      return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    }
    return 'Konum bilgisi yok';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
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
}
