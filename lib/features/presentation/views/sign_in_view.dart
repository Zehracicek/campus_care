import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);
    final result = await authController.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        context.showSuccessToast('Başarıyla giriş yaptınız');
        // Ana sayfaya yönlendir
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        });
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
          // Gradient background with decorative elements
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                        '👋 Tekrar hoş geldiniz!',
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
                            'Giriş Yap',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hesabınıza erişmek için bilgilerinizi girin',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 16),
                          // Şifre Alanı
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
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
                                return 'Şifre gereklidir';
                              }
                              if (value!.length < 6) {
                                return 'Şifre en az 6 karakterden oluşmalıdır';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _passwordFocus.unfocus();
                            },
                          ),

                          const SizedBox(height: 20),
                          // Giriş Yap Butonu
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
                              onPressed: authState.isLoading ? null : _signIn,
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
                                          'Giriş Yap',
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
                          const SizedBox(height: 16),
                          // Kayıt Ol Bağlantısı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hesabınız yok mu? ',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/signup');
                                },
                                child: Text(
                                  'Kayıt Ol',
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
