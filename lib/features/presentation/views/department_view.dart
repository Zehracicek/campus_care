import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/views/create_department_view.dart';
import 'package:campus_care/features/presentation/views/create_maintenance_request_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DepartmentView extends ConsumerStatefulWidget {
  const DepartmentView({super.key});

  @override
  ConsumerState<DepartmentView> createState() => _DepartmentViewState();
}

class _DepartmentViewState extends ConsumerState<DepartmentView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentControllerProvider.notifier).loadDepartments();
      _loadAdminStatus();
    });
  }

  Future<void> _loadAdminStatus() async {
    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    bool allowed = false;
    if (user != null) {
      allowed = (user.roleId ?? '').toLowerCase() == 'admin';
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
      if (mounted) context.showErrorToast('Lütfen giriş yapın');
      return;
    }

    if (_isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateDepartmentView()),
      );
    } else {
      context.showErrorToast('Sadece adminler bölüm ekleyebilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentState = ref.watch(departmentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bölümler'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(departmentControllerProvider.notifier)
              .loadDepartments();
          await _loadAdminStatus();
        },
        child: _buildBody(departmentState),
      ),
      floatingActionButton: !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Bölüm Ekle'),
            )
          : null,
    );
  }

  Widget _buildBody(StateHandler<List<DepartmentEntity>> state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref
                  .read(departmentControllerProvider.notifier)
                  .loadDepartments(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final departments = state.data ?? [];
    if (departments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [_EmptyState()],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        return _DepartmentCard(department: departments[index]);
      },
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final DepartmentEntity department;

  const _DepartmentCard({required this.department});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateMaintenanceRequestView(preSelectedDepartment: department),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                department.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Icon(Icons.school_outlined, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz bölüm bulunmuyor',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
