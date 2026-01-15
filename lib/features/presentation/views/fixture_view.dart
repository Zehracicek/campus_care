import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/fixture_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/views/create_fixture_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FixtureView extends ConsumerStatefulWidget {
  const FixtureView({super.key});

  @override
  ConsumerState<FixtureView> createState() => _FixtureViewState();
}

class _FixtureViewState extends ConsumerState<FixtureView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixtureControllerProvider.notifier).loadDemirbas();
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
        MaterialPageRoute(builder: (_) => const CreateFixtureView()),
      );
    } else {
      context.showErrorToast('Sadece adminler demirbaş ekleyebilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fixtureControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demirbaşlar'),
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
          await ref.read(fixtureControllerProvider.notifier).loadDemirbas();
          await _loadAdminStatus();
        },
        child: _buildBody(state),
      ),
      floatingActionButton: !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Demirbaş Ekle'),
            )
          : null,
    );
  }

  Widget _buildBody(StateHandler<List<FixtureEntity>> state) {
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
              onPressed: () =>
                  ref.read(fixtureControllerProvider.notifier).loadDemirbas(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final items = state.data ?? [];
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [_EmptyState()],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _DemirbasCard(item: items[index]);
      },
    );
  }
}

class _DemirbasCard extends StatelessWidget {
  final FixtureEntity item;

  const _DemirbasCard({required this.item});

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
                    Icons.inventory_2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Adet: ${item.quantity}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
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
        Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz demirbaş yok',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
