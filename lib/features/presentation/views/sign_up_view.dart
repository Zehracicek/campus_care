import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/features/domain/entities/user_entity.dart';
import 'package:campus_care/features/domain/usecases/user_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _adminCodeController;
  late final FocusNode _emailFocus;
  late final FocusNode _nameFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'user';
  final String _adminAccessCode = 'ADMIN-2025';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _adminCodeController = TextEditingController();
    _emailFocus = FocusNode();
    _nameFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      context.showErrorToast('Şartlar ve koşulları kabul etmelisiniz');
      return;
    }

    if (_selectedRole == 'admin' &&
        _adminCodeController.text.trim() != _adminAccessCode) {
      context.showErrorToast('Admin erişim kodu hatalı');
      return;
    }

    final authController = ref.read(authControllerProvider.notifier);
    final result = await authController.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    result.when(
      success: (user) async {
        final profile = UserEntity(
          id: user.id,
          email: user.email,
          displayName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : user.email,
          roleId: _selectedRole,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final profileResult = await ref
            .read(updateUserProfileUseCaseProvider)
            .call(params: UpdateUserProfileParams(profile));

        profileResult.when(
          success: (_) {
            context.showSuccessToast('Hesap başarıyla oluşturuldu');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            });
          },
          failure: (error) {
            context.showErrorToast(
              'Profil kaydedilirken hata: ${error.message}',
            );
          },
        );
      },
      failure: (error) {
        context.showErrorToast(error.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Logo/Title
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Başlık
                    Text(
                      'Campus Care',
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '🚀 Hemen başlayın!',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Beyaz arka plan kartı
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 50,
                            offset: const Offset(0, 25),
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Kayıt Ol',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hesap oluşturmak için bilgilerinizi girin',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Ad Soyad
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Ad Soyad',
                              hintText: 'Örn: Ayşe Yılmaz',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5C6FFF),
                                      Color(0xFF00D4FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5C6FFF),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ad soyad gereklidir';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _nameFocus.unfocus();
                              FocusScope.of(context).requestFocus(_emailFocus);
                            },
                          ),
                          const SizedBox(height: 14),

                          // Email Alanı
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'örnek@email.com',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5C6FFF),
                                      Color(0xFF00D4FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5C6FFF),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Email adresi gereklidir';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value!)) {
                                return 'Geçerli bir email adresi giriniz';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _emailFocus.unfocus();
                              FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocus);
                            },
                          ),
                          const SizedBox(height: 14),

                          // Şifre Alanı
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              hintText: '••••••••',
                              helperText:
                                  'En az 6 karakter, birer büyük harf ve rakam içermeli',
                              helperStyle: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5C6FFF),
                                      Color(0xFF00D4FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Şifre gereklidir';
                              }
                              if (value!.length < 6) {
                                return 'Şifre en az 6 karakterden oluşmalıdır';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Şifre en az bir büyük harf içermelidir';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Şifre en az bir rakam içermelidir';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _passwordFocus.unfocus();
                              FocusScope.of(
                                context,
                              ).requestFocus(_confirmPasswordFocus);
                            },
                          ),
                          const SizedBox(height: 14),
                          // Şifre Tekrar Alanı
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Şifre Tekrar',
                              hintText: '••••••••',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5C6FFF),
                                      Color(0xFF00D4FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5C6FFF),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Şifre tekrarı gereklidir';
                              }
                              if (value != _passwordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _confirmPasswordFocus.unfocus();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Rol Seçimi
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user,
                                    color: Color(0xFF5C6FFF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hesap Rolü',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rol seçimini yapın. Admin seçimi için erişim kodu gerekir.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleCard(
                                      title: 'Kullanıcı',
                                      subtitle: 'Standart yetkiler',
                                      icon: Icons.person,
                                      badge: 'Önerilen',
                                      isSelected: _selectedRole == 'user',
                                      onTap: () {
                                        setState(() => _selectedRole = 'user');
                                      },
                                      bulletPoints: const [
                                        'Talep oluşturma',
                                        'Duyuru ve bildirimleri görme',
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _RoleCard(
                                      title: 'Admin',
                                      subtitle: 'Yönetim yetkileri',
                                      icon: Icons.shield_moon,
                                      badge: 'Yetkili',
                                      isSelected: _selectedRole == 'admin',
                                      onTap: () {
                                        setState(() => _selectedRole = 'admin');
                                      },
                                      bulletPoints: const [
                                        'Duyuru yayınlama',
                                        'Talepleri yönetme',
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedRole == 'admin') ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF5C6FFF,
                                    ).withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF5C6FFF,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.key_outlined,
                                            color: Color(0xFF5C6FFF),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Admin erişim kodu gerekli',
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _adminCodeController,
                                        decoration: InputDecoration(
                                          labelText: 'Admin Erişim Kodu',
                                          hintText: 'Örn: ADMIN-2025',
                                          prefixIcon: const Icon(
                                            Icons.lock_clock_outlined,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (_selectedRole != 'admin')
                                            return null;
                                          if (value == null || value.isEmpty) {
                                            return 'Admin kodu gereklidir';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Şartlar ve Koşullar Onay
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFF5C6FFF),
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(fontSize: 12),
                                    children: [
                                      const TextSpan(text: 'Kabul ediyorum '),
                                      TextSpan(
                                        text: 'Şartlar ve Koşullar',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: const Color(0xFF5C6FFF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Kayıt Ol Butonu
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5C6FFF), Color(0xFF00D4FF)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5C6FFF,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Kayıt Ol',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Giriş Yap Bağlantısı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Zaten hesabınız var mı? ',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/signin');
                                },
                                child: Text(
                                  'Giriş Yap',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF5C6FFF),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> bulletPoints;
  final String badge;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.bulletPoints,
    required this.badge,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF5C6FFF) : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? const Color(0xFF5C6FFF).withValues(alpha: 0.07)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected
                        ? const Color(0xFF2E3A59)
                        : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
