import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/views/academic_calendar_view.dart';
import 'package:campus_care/features/presentation/views/create_maintenance_request_view.dart';
import 'package:campus_care/features/presentation/views/department_view.dart';
import 'package:campus_care/features/presentation/views/fixture_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/maintenance_request_controller.dart';

String _getUserDisplayName(dynamic user) {
  if (user?.displayName != null && user.displayName.isNotEmpty) {
    return user.displayName;
  }
  if (user?.email != null && user.email.isNotEmpty) {
    return user.email.split('@').first;
  }
  return 'Kullanıcı';
}

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Load user requests on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    if (user == null) return;

    final isAdmin = (user.roleId ?? '').toLowerCase() == 'admin';
    final controller = ref.read(maintenanceRequestControllerProvider.notifier);

    if (isAdmin) {
      await controller.loadRequests();
    } else {
      await controller.loadUserRequests(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider).data;
    final user = authState?.user;
    final maintanceProvider = ref.watch(maintenanceRequestControllerProvider);
    final maintanceData = maintanceProvider.data ?? MaintenanceRequestState();
    final requests = maintanceData.requests;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient and wave effect
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.waving_hand,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hoş Geldiniz',
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getUserDisplayName(user),
                                      style: context.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Aktif Kullanıcı',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dashboard Content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Quick Stats with animations
                _AnimatedStatsRow(requests: requests),

                const SizedBox(height: 24),

                // Quick Actions with better design
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hızlı İşlemler',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Tümü'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ModernQuickActionCard(
                        title: 'Yeni Talep',
                        subtitle: 'Talep oluştur',
                        icon: Icons.add_circle_outline,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF5C6FFF), Color(0xFF7B8CFF)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CreateMaintenanceRequestView(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),

                      const SizedBox(width: 12),

                      _ModernQuickActionCard(
                        title: 'Bölümler',
                        subtitle: 'Üniversite bölümleri',
                        icon: Icons.school,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DepartmentView(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _ModernQuickActionCard(
                        title: 'A. Takvim',
                        subtitle: 'Önemli tarihler',
                        icon: Icons.calendar_month,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AcademicCalendarView(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _ModernQuickActionCard(
                        title: 'Demirbaşlar',
                        subtitle: 'Envanter listesi',
                        icon: Icons.inventory_2,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6F00), Color(0xFFFFAB40)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FixtureView(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Activity with better design
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Aktiviteler',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (requests.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          DefaultTabController.of(context).animateTo(1);
                        },
                        child: const Text('Tümünü Gör'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (maintanceProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (requests.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz aktivite bulunmuyor',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._buildRecentRequests(requests),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateMaintenanceRequestView(),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF5C6FFF),
        elevation: 4,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Yeni Talep',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<Widget> _buildRecentRequests(List<MaintenanceRequestEntity> requests) {
    // Get last 5 requests sorted by creation date
    final recentRequests = requests.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limitedRequests = recentRequests.take(5).toList();

    return limitedRequests
        .map((request) => _ModernActivityCard(request: request))
        .toList();
  }
}

// New animated stats row widget
class _AnimatedStatsRow extends StatelessWidget {
  final List<MaintenanceRequestEntity> requests;

  const _AnimatedStatsRow({required this.requests});

  @override
  Widget build(BuildContext context) {
    final activeCount = requests
        .where(
          (r) =>
              r.status == MaintenanceStatus.pending ||
              r.status == MaintenanceStatus.assigned ||
              r.status == MaintenanceStatus.inProgress,
        )
        .length;

    final completedCount = requests
        .where((r) => r.status == MaintenanceStatus.completed)
        .length;

    final pendingCount = requests
        .where((r) => r.status == MaintenanceStatus.pending)
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ModernStatCard(
            title: 'Aktif',
            value: activeCount.toString(),
            icon: Icons.trending_up,
            gradient: const LinearGradient(
              colors: [Color(0xFF5C6FFF), Color(0xFF7B8CFF)],
            ),
          ),
          const SizedBox(width: 12),
          _ModernStatCard(
            title: 'Tamamlanan',
            value: completedCount.toString(),
            icon: Icons.check_circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            ),
          ),
          const SizedBox(width: 12),
          _ModernStatCard(
            title: 'Bekleyen',
            value: pendingCount.toString(),
            icon: Icons.hourglass_empty,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
            ),
          ),
        ],
      ),
    );
  }
}

// New modern stat card
class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// New modern quick action card
class _ModernQuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ModernQuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modern activity card
class _ModernActivityCard extends StatelessWidget {
  final MaintenanceRequestEntity request;

  const _ModernActivityCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor(request.status),
                _getStatusColor(request.status).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(request.status),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          request.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM, HH:mm').format(request.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(request.status),
            style: TextStyle(
              color: _getStatusColor(request.status),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Icons.hourglass_empty;
      case MaintenanceStatus.assigned:
        return Icons.assignment_ind;
      case MaintenanceStatus.inProgress:
        return Icons.build_circle;
      case MaintenanceStatus.completed:
        return Icons.check_circle;
      case MaintenanceStatus.cancelled:
        return Icons.cancel;
      case MaintenanceStatus.rejected:
        return Icons.block;
    }
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Colors.orange;
      case MaintenanceStatus.assigned:
        return Colors.blue[400]!;
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
        return 'İptal';
      case MaintenanceStatus.rejected:
        return 'Reddedildi';
    }
  }
}
