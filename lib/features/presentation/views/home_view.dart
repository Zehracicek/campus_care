import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final user = authState.user;
    final notifier = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa'), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoş geldiniz, ${user?.displayName ?? user?.email}!',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await notifier.signOut();

                if (context.mounted) {
                  result.when(
                    success: (_) {},
                    failure: (error) {
                      context.showErrorSnackBar(error.message);
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
