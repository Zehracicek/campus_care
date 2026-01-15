import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/personel_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/views/create_personel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonelView extends ConsumerStatefulWidget {
  const PersonelView({super.key});

  @override
  ConsumerState<PersonelView> createState() => _PersonelViewState();
}

class _PersonelViewState extends ConsumerState<PersonelView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personelControllerProvider.notifier).streamPersonel();
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
        MaterialPageRoute(builder: (_) => const CreatePersonelView()),
      );
    } else {
      context.showErrorToast('Sadece adminler personel ekleyebilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final personelState = ref.watch(personelControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel'),
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
          await ref.read(personelControllerProvider.notifier).loadPersonel();
          await _loadAdminStatus();
        },
        child: _buildBody(personelState),
      ),
      floatingActionButton: !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Personel Ekle'),
            )
          : null,
    );
  }

  Widget _buildBody(StateHandler<List<PersonelEntity>> state) {
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
                  ref.read(personelControllerProvider.notifier).loadPersonel(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final personel = state.data ?? [];
    if (personel.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [_EmptyState()],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: personel.length,
      itemBuilder: (context, index) {
        return _PersonelCard(personel: personel[index]);
      },
    );
  }
}

class _PersonelCard extends StatelessWidget {
  final PersonelEntity personel;

  const _PersonelCard({required this.personel});

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        personel.position,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        personel.department,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    personel.email,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    personel.phone,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Icon(Icons.person_outline, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz personel bulunmuyor',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
