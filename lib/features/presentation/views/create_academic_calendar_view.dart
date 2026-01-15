import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/academic_calendar_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CreateAcademicCalendarView extends ConsumerStatefulWidget {
  const CreateAcademicCalendarView({super.key});

  @override
  ConsumerState<CreateAcademicCalendarView> createState() =>
      _CreateAcademicCalendarViewState();
}

class _CreateAcademicCalendarViewState
    extends ConsumerState<CreateAcademicCalendarView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AcademicCalendarType _selectedType = AcademicCalendarType.other;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
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
        title: const Text('Takvim Olayı Oluştur'),
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
                icon: Icons.title,
                validator: (v) => v == null || v.trim().length < 3
                    ? 'En az 3 karakter girin'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Açıklama',
                controller: _descriptionController,
                icon: Icons.description,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Açıklama girin' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 12),
              _buildDatePicker(
                label: 'Başlangıç Tarihi',
                selectedDate: _selectedStartDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedStartDate = date;
                    if (_selectedEndDate == null ||
                        _selectedEndDate!.isBefore(date)) {
                      _selectedEndDate = date;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDatePicker(
                label: 'Bitiş Tarihi',
                selectedDate: _selectedEndDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedEndDate = date;
                  });
                },
              ),
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
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
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

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text(
                  'Tür',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButton<AcademicCalendarType>(
              value: _selectedType,
              isExpanded: true,
              items: AcademicCalendarType.values
                  .map(
                    (type) => DropdownMenuItem<AcademicCalendarType>(
                      value: type,
                      child: Text(_getTypeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('d MMMM yyyy', 'tr_TR')
                              .format(selectedDate)
                          : 'Tarih Seçin',
                      style: TextStyle(
                        color: selectedDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStartDate == null || _selectedEndDate == null) {
      context.showErrorToast('Lütfen başlangıç ve bitiş tarihlerini girin');
      return;
    }

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    final isAdmin = (user?.roleId ?? '').toLowerCase() == 'admin';

    if (user == null || !isAdmin) {
      if (mounted) {
        context.showErrorToast('Sadece adminler takvim ekleyebilir');
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final calendar = AcademicCalendarEntity(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _selectedStartDate!,
      endDate: _selectedEndDate!,
      type: _selectedType,
      createdAt: DateTime.now(),
      createdById: user.id,
    );

    try {
      await ref
          .read(academicCalendarControllerProvider.notifier)
          .createAcademicCalendar(calendar);

      if (mounted) {
        context.showSuccessToast('Takvim olayı oluşturuldu');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Bir hata oluştu: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
