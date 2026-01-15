import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/services/location_service.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../widgets/location_picker_widget.dart';

class CreateEventView extends ConsumerStatefulWidget {
  const CreateEventView({super.key});

  @override
  ConsumerState<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends ConsumerState<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  LocationData? _selectedLocation;
  DateTime? _selectedDateTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Oluştur'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: 'Başlık',
                controller: _titleController,
                validator: (v) => v == null || v.trim().length < 3
                    ? 'En az 3 karakter girin'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Açıklama',
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => v == null || v.trim().length < 10
                    ? 'En az 10 karakter girin'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildLocationPicker(context),
              const SizedBox(height: 12),
              _buildDateTimePicker(context),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: const Icon(Icons.save),
                label: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tarih ve Saat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Seçilmedi'
                        : DateFormat(
                            'dd MMM yyyy, HH:mm',
                            'tr',
                          ).format(_selectedDateTime!),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(now),
                    );
                    if (time == null) return;
                    setState(() {
                      _selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seç'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konum', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedLocation == null
                          ? 'Haritadan konum seçin'
                          : _selectedLocation!.address?.isNotEmpty == true
                          ? '${_selectedLocation!.latitude.toStringAsFixed(6)},${_selectedLocation!.longitude.toStringAsFixed(6)} (${_selectedLocation!.address})'
                          : '${_selectedLocation!.latitude.toStringAsFixed(6)},${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openLocationPicker(context),
                    icon: const Icon(Icons.map),
                    label: const Text('Seç'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationPickerWidget(
        initialLocation: _selectedLocation,
        onLocationSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      context.showErrorToast('Tarih ve saat seçin');
      return;
    }

    if (_selectedLocation == null) {
      context.showErrorToast('Konum seçin');
      return;
    }

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    final isAdmin = (user?.roleId ?? '').toLowerCase() == 'admin';
    if (user == null || !isAdmin) {
      context.showErrorToast('Sadece adminler etkinlik ekleyebilir');
      return;
    }

    setState(() => _isSubmitting = true);

    final latitude = _selectedLocation!.latitude;
    final longitude = _selectedLocation!.longitude;
    final locationString = _selectedLocation!.address?.trim().isNotEmpty == true
        ? _selectedLocation!.address!
        : '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

    final event = EventEntity(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      eventDate: _selectedDateTime!,
      location: locationString,
      latitude: latitude,
      longitude: longitude,
      createdById: user.id,
      createdByName: user.displayName ?? user.email,
      createdAt: DateTime.now(),
      isActive: true,
    );

    final result = await ref
        .read(eventControllerProvider.notifier)
        .createEvent(event);

    if (!mounted) return;

    result.when(
      success: (_) {
        context.showSuccessToast('Etkinlik oluşturuldu');
        Navigator.pop(context);
      },
      failure: (error) {
        context.showErrorToast(error.message);
      },
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
