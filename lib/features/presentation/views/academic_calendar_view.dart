import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/state_handler.dart';
import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/views/create_academic_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AcademicCalendarView extends ConsumerStatefulWidget {
  const AcademicCalendarView({super.key});

  @override
  ConsumerState<AcademicCalendarView> createState() =>
      _AcademicCalendarViewState();
}

class _AcademicCalendarViewState extends ConsumerState<AcademicCalendarView> {
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(academicCalendarControllerProvider.notifier)
          .loadAcademicCalendars();
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
        MaterialPageRoute(builder: (_) => const CreateAcademicCalendarView()),
      );
    } else {
      context.showErrorToast('Sadece adminler takvim ekleyebilir');
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(academicCalendarControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akademik Takvim'),
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
              .read(academicCalendarControllerProvider.notifier)
              .loadAcademicCalendars();
          await _loadAdminStatus();
        },
        child: _buildBody(calendarState),
      ),
      floatingActionButton: !_isCheckingAdmin && _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _checkAdminAndNavigate,
              icon: const Icon(Icons.add),
              label: const Text('Takvim Ekle'),
            )
          : null,
    );
  }

  Widget _buildBody(StateHandler<List<AcademicCalendarEntity>> state) {
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
                  .read(academicCalendarControllerProvider.notifier)
                  .loadAcademicCalendars(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    final calendars = state.data ?? [];
    if (calendars.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [_EmptyState()],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: calendars.length,
      itemBuilder: (context, index) {
        return _AcademicCalendarCard(
          calendar: calendars[index],
          isAdmin: _isAdmin,
          onDelete: () => _confirmAndDelete(calendars[index].id),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(String id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin mi?'),
        content: const Text(
          'Bu takvim olayını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref
          .read(academicCalendarControllerProvider.notifier)
          .deleteAcademicCalendar(id);
      if (mounted) {
        context.showSuccessToast('Takvim olayı silindi');
      }
    }
  }
}

class _AcademicCalendarCard extends StatelessWidget {
  final AcademicCalendarEntity calendar;
  final bool isAdmin;
  final VoidCallback? onDelete;

  const _AcademicCalendarCard({
    required this.calendar,
    required this.isAdmin,
    this.onDelete,
  });

  String _getTypeLabel(AcademicCalendarType type) {
    switch (type) {
      case AcademicCalendarType.semesterStart:
        return 'Dönem Başlangıcı';
      case AcademicCalendarType.semesterEnd:
        return 'Dönem Sonu';
      case AcademicCalendarType.midterm:
        return 'Ara Sınavı';
      case AcademicCalendarType.finalExam:
        return 'Final Sınavı';
      case AcademicCalendarType.registration:
        return 'Kayıt';
      case AcademicCalendarType.addDrop:
        return 'Ekle/Bırak';
      case AcademicCalendarType.holiday:
        return 'Tatil';
      case AcademicCalendarType.other:
        return 'Diğer';
    }
  }

  Color _getTypeColor(AcademicCalendarType type) {
    switch (type) {
      case AcademicCalendarType.semesterStart:
        return Colors.green;
      case AcademicCalendarType.semesterEnd:
        return Colors.red;
      case AcademicCalendarType.midterm:
        return Colors.orange;
      case AcademicCalendarType.finalExam:
        return Colors.purple;
      case AcademicCalendarType.registration:
        return Colors.blue;
      case AcademicCalendarType.addDrop:
        return Colors.indigo;
      case AcademicCalendarType.holiday:
        return Colors.teal;
      case AcademicCalendarType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(AcademicCalendarType type) {
    switch (type) {
      case AcademicCalendarType.semesterStart:
        return Icons.calendar_month;
      case AcademicCalendarType.semesterEnd:
        return Icons.event_busy;
      case AcademicCalendarType.midterm:
        return Icons.school;
      case AcademicCalendarType.finalExam:
        return Icons.assignment;
      case AcademicCalendarType.registration:
        return Icons.how_to_reg;
      case AcademicCalendarType.addDrop:
        return Icons.edit;
      case AcademicCalendarType.holiday:
        return Icons.beach_access;
      case AcademicCalendarType.other:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', 'tr_TR');
    final startDate = dateFormat.format(calendar.startDate);
    final endDate = dateFormat.format(calendar.endDate);
    final color = _getTypeColor(calendar.type);

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
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(calendar.type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calendar.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getTypeLabel(calendar.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[400],
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              calendar.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$startDate - $endDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        Icon(Icons.calendar_month, size: 72, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Henüz takvim olayı bulunmuyor',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
