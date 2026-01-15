import 'package:campus_care/features/presentation/views/sign_in_view.dart';
import 'package:campus_care/features/presentation/views/sign_up_view.dart';
import 'package:flutter/material.dart';

/// Kimlik doğrulama akışı - Her zaman giriş ekranını gösterir
class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignInView();
  }
}

/// Giriş/Kayıt seçim ekranı (opsiyonel)
class AuthSelectionView extends StatelessWidget {
  const AuthSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Title
              Text(
                'Campus Care',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Hoş geldiniz',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),

              // Giriş Yap Butonu
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const SignInView()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 16),

              // Kayıt Ol Butonu
              OutlinedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const SignUpView()));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
