import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class CreateFixtureView extends ConsumerStatefulWidget {
  const CreateFixtureView({super.key});

  @override
  ConsumerState<CreateFixtureView> createState() => _CreateFixtureViewState();
}

class _CreateFixtureViewState extends ConsumerState<CreateFixtureView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    if (user == null) {
      context.showErrorToast('Lütfen giriş yapın');
      return;
    }

    setState(() => _submitting = true);

    final result = await ref
        .read(fixtureControllerProvider.notifier)
        .createDemirbas(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
          userId: user.id,
        );

    setState(() => _submitting = false);

    result.when(
      success: (_) {
        if (mounted) {
          Navigator.pop(context, true);
          context.showSuccessToast('Demirbaş oluşturuldu');
        }
      },
      failure: (error) => context.showErrorToast(error.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demirbaş Ekle'),
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
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık zorunlu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Açıklama zorunlu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Adet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Adet zorunlu';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty < 0) {
                    return 'Geçerli bir adet girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_submitting ? 'Kaydediliyor...' : 'Kaydet'),
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
