import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/presentation/widgets/profile_photo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile Header with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      ProfilePhotoWidget(user: user),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? 'Kullanıcı',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Account Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Hesap Ayarları',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              _ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Profil Bilgileri',
                subtitle: 'Ad, soyad ve iletişim bilgileri',
                onTap: () {
                  context.showInfoToast(
                    'Profil düzenleme ekranı yakında eklenecek',
                  );
                },
              ),

              _ProfileMenuItem(
                icon: Icons.security_outlined,
                title: 'Güvenlik',
                subtitle: 'Şifre değiştirme ve güvenlik ayarları',
                onTap: () {
                  context.showInfoToast('Güvenlik ayarları yakında eklenecek');
                },
              ),

              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Bildirim Tercihleri',
                subtitle: 'Push bildirimleri ve e-posta ayarları',
                onTap: () {
                  context.showInfoToast('Bildirim ayarları yakında eklenecek');
                },
              ),

              const SizedBox(height: 24),

              // App Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Uygulama',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              _ProfileMenuItem(
                icon: Icons.language_outlined,
                title: 'Dil',
                subtitle: 'Türkçe',
                onTap: () {
                  context.showInfoToast('Dil ayarları yakında eklenecek');
                },
              ),

              _ProfileMenuItem(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Aydınlık mod',
                onTap: () {
                  context.showInfoToast('Tema ayarları yakında eklenecek');
                },
              ),

              _ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Hakkında',
                subtitle: 'Versiyon 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),

              const SizedBox(height: 24),

              // Sign Out
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Çıkış Yap'),
                        content: const Text(
                          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Çıkış Yap'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut == true && context.mounted) {
                      final result = await ref
                          .read(authControllerProvider.notifier)
                          .signOut();

                      if (context.mounted) {
                        switch (result) {
                          case Success():
                            context.showSuccessToast('Başarıyla çıkış yapıldı');
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.signIn,
                              (route) => false,
                            );
                          case Failure(:final message):
                            context.showErrorToast(message);
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış Yap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Campus Care',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, color: Colors.white, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Campus Care, kampüs bakım ve onarım taleplerini yönetmek için geliştirilmiş modern bir mobil uygulamadır.',
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF5C6FFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF5C6FFF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
