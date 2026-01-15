import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

///https://www.youtube.com/watch?v=yHriTrnlGUQ&list=PLjyxas0TsCpnjpzCv3rnsX3LjS9G2K05f&index=7

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  //Admin erişim kodu ADMIN-2025
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Campus Care',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
