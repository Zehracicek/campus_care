import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:campus_care/features/presentation/views/create_event_view.dart';
import 'package:campus_care/features/presentation/views/event_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/app_providers.dart';
import '../controllers/auth_controller.dart';

class EventsView extends ConsumerStatefulWidget {
  const EventsView({super.key});

  @override
  ConsumerState<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<EventsView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show all events, including older ones without an isActive flag
      ref
          .read(eventControllerProvider.notifier)
          .streamEvents(activeOnly: false);
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
        MaterialPageRoute(builder: (_) => const CreateEventView()),
      );
    } else {
      context.showErrorToast('Sadece adminler etkinlik ekleyebilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
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
              .read(eventControllerProvider.notifier)
              .loadEvents(activeOnly: false);
          await _loadAdminStatus();
        },
        child: _buildBody(eventState),
      ),
      floatingActionButton: !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Etkinlik Ekle'),
            )
          : null,
    );
  }

  Widget _buildBody(StateHandler<List<EventEntity>> state) {
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
                  .read(eventControllerProvider.notifier)
                  .loadEvents(activeOnly: false),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final events = state.data ?? [];
    if (events.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [_EmptyState()],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _EventCard(event: events[index]);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailView(event: event)),
        );
      },
      borderRadius: BorderRadius.circular(12),
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
                      Icons.event,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
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
                          ).format(event.eventDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Oluşturan: ${event.createdByName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
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
        Icon(Icons.event_busy, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz etkinlik bulunmuyor',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
