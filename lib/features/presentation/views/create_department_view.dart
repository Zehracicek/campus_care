import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/department_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateDepartmentView extends ConsumerStatefulWidget {
  const CreateDepartmentView({super.key});

  @override
  ConsumerState<CreateDepartmentView> createState() =>
      _CreateDepartmentViewState();
}

class _CreateDepartmentViewState extends ConsumerState<CreateDepartmentView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bölüm Oluştur'),
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
                label: 'Bölüm Adı',
                controller: _nameController,
                icon: Icons.business,
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
                maxLines: 4,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    final isAdmin = (user?.roleId ?? '').toLowerCase() == 'admin';

    if (user == null || !isAdmin) {
      if (mounted) {
        context.showErrorToast('Sadece adminler bölüm ekleyebilir');
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final department = DepartmentEntity(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      managerId: user.id,
      campusId: null,
    );

    try {
      await ref
          .read(departmentControllerProvider.notifier)
          .createDepartment(department);

      if (mounted) {
        context.showSuccessToast('Bölüm oluşturuldu');
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
