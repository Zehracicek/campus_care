import 'package:campus_care/features/presentation/views/auth_flow.dart';
import 'package:campus_care/features/presentation/views/main_navigation_view.dart';
import 'package:campus_care/features/presentation/views/sign_in_view.dart';
import 'package:campus_care/features/presentation/views/sign_up_view.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const AuthFlow(),
          settings: settings,
        );
      case signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInView(),
          settings: settings,
        );
      case signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpView(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationView(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  // Navigation methods
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  // Helper methods
  static Future<void> navigateToHome(BuildContext context) {
    return pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static Future<void> navigateToSignIn(BuildContext context) {
    return pushReplacementNamed(context, signIn);
  }
}
