import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/features/domain/entities/maintenance_request_entity.dart';
import 'package:campus_care/features/presentation/views/create_maintenance_request_view.dart';
import 'package:campus_care/features/presentation/views/maintenance_request_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/maintenance_request_controller.dart';

class MaintenanceRequestsView extends ConsumerStatefulWidget {
  const MaintenanceRequestsView({super.key});

  @override
  ConsumerState<MaintenanceRequestsView> createState() =>
      _MaintenanceRequestsViewState();
}

class _MaintenanceRequestsViewState
    extends ConsumerState<MaintenanceRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load requests on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bakım Talepleri'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Bekliyor'),
            Tab(text: 'Devam Ediyor'),
            Tab(text: 'Tamamlandı'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList('all'),
          _buildRequestsList('pending'),
          _buildRequestsList('in_progress'),
          _buildRequestsList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateMaintenanceRequestView(),
            ),
          ).then((_) => _loadRequests());
        },
        backgroundColor: const Color(0xFF5C6FFF),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Talep'),
      ),
    );
  }

  Widget _buildRequestsList(String status) {
    final controller = ref.watch(maintenanceRequestControllerProvider);
    final controllerState = controller.data ?? MaintenanceRequestState();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              controller.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _filterRequests(controllerState.requests, status);

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: filteredRequests.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  message: status == 'all'
                      ? 'Henüz talep bulunmuyor'
                      : 'Bu durumda talep bulunmuyor',
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(filteredRequests[index]);
              },
            ),
    );
  }

  List<MaintenanceRequestEntity> _filterRequests(
    List<MaintenanceRequestEntity> requests,
    String status,
  ) {
    if (status == 'all') return requests;

    MaintenanceStatus? filterStatus;
    switch (status) {
      case 'pending':
        filterStatus = MaintenanceStatus.pending;
        break;
      case 'in_progress':
        filterStatus = MaintenanceStatus.inProgress;
        break;
      case 'completed':
        filterStatus = MaintenanceStatus.completed;
        break;
    }

    if (filterStatus == null) return requests;
    return requests.where((r) => r.status == filterStatus).toList();
  }

  Widget _buildRequestCard(MaintenanceRequestEntity request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaintenanceRequestDetailView(request: request),
            ),
          ).then((_) => _loadRequests());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPriorityChip(request.priority),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(MaintenanceStatus status) {
    Color color;
    String text;

    switch (status) {
      case MaintenanceStatus.pending:
        color = Colors.orange;
        text = 'Bekliyor';
        break;
      case MaintenanceStatus.assigned:
        color = Colors.blue[300]!;
        text = 'Atandı';
        break;
      case MaintenanceStatus.inProgress:
        color = Colors.blue;
        text = 'Devam Ediyor';
        break;
      case MaintenanceStatus.completed:
        color = Colors.green;
        text = 'Tamamlandı';
        break;
      case MaintenanceStatus.cancelled:
        color = Colors.red;
        text = 'İptal';
        break;
      case MaintenanceStatus.rejected:
        color = Colors.red[300]!;
        text = 'Reddedildi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(MaintenancePriority priority) {
    Color color;
    String text;

    switch (priority) {
      case MaintenancePriority.low:
        color = Colors.green;
        text = 'Düşük';
        break;
      case MaintenancePriority.medium:
        color = Colors.orange;
        text = 'Orta';
        break;
      case MaintenancePriority.high:
        color = Colors.red;
        text = 'Yüksek';
        break;
      case MaintenancePriority.urgent:
        color = Colors.deepPurple;
        text = 'Acil';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
