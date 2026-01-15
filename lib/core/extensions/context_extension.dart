import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

extension MediaQueryExtension on BuildContext {
  /// Returns the MediaQuery data for the current context.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the height of the device.
  double get height => mediaQuery.size.height;

  /// Returns the width of the device.
  double get width => mediaQuery.size.width;

  /// Returns the aspect ratio of the device.
  double get aspectRatio => mediaQuery.size.aspectRatio;

  /// Returns the device pixel ratio.
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Returns the screen orientation.
  Orientation get orientation => mediaQuery.orientation;

  /// Returns a percentage of the screen height with device-specific scaling.
  double heightPercentage(double percentage) {
    final shortestSide = mediaQuery.size.shortestSide;
    final isTablet = shortestSide >= 600;
    final scaleFactor = isTablet
        ? 0.7
        : 1.0; // Tablet uses 70% of phone scaling
    return height * percentage * scaleFactor;
  }

  /// Returns a percentage of the screen width with device-specific scaling.
  double widthPercentage(double percentage) {
    final shortestSide = mediaQuery.size.shortestSide;
    final isTablet = shortestSide >= 600;
    final scaleFactor = isTablet
        ? 0.7
        : 1.0; // Tablet uses 70% of phone scaling
    return width * percentage * scaleFactor;
  }

  /// Commonly used height values as percentages of the screen height.
  double get lowValue => heightPercentage(0.01);
  double get defaultValue => heightPercentage(0.02);
  double get highValue => heightPercentage(0.05);
  double get veryHigh1x => heightPercentage(0.1);
  double get veryHigh2x => heightPercentage(0.2);
  double get veryHigh3x => heightPercentage(0.3);
  double get veryHigh4x => heightPercentage(0.4);
  double get veryHigh5x => heightPercentage(0.5);
}

extension PaddingExtension on BuildContext {
  /// Generates EdgeInsets with symmetric or all-side paddings based on percentages.
  EdgeInsets allPadding(double percentage) =>
      EdgeInsets.all(heightPercentage(percentage));
  EdgeInsets symmetricPadding({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) => EdgeInsets.symmetric(
    horizontal: widthPercentage(horizontal),
    vertical: heightPercentage(vertical),
  );

  EdgeInsets onlyPadding({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => EdgeInsets.only(
    left: widthPercentage(left),
    top: heightPercentage(top),
    right: widthPercentage(right),
    bottom: heightPercentage(bottom),
  );

  /// Predefined padding values for common use cases.
  EdgeInsets get paddingLow => allPadding(0.01);
  EdgeInsets get paddingDefault => allPadding(0.02);
  EdgeInsets get paddingHigh => allPadding(0.05);
  EdgeInsets get paddingHorizontalLow => symmetricPadding(horizontal: 0.01);
  EdgeInsets get paddingHorizontalDefault => symmetricPadding(horizontal: 0.02);
  EdgeInsets get paddingHorizontalHigh => symmetricPadding(horizontal: 0.05);
  EdgeInsets get paddingVerticalLow => symmetricPadding(vertical: 0.01);
  EdgeInsets get paddingVerticalDefault => symmetricPadding(vertical: 0.02);
  EdgeInsets get paddingVerticalHigh => symmetricPadding(vertical: 0.05);
  EdgeInsets get paddingLeftLow => onlyPadding(left: 0.01);
  EdgeInsets get paddingLeftDefault => onlyPadding(left: 0.02);
  EdgeInsets get paddingLeftHigh => onlyPadding(left: 0.05);
  EdgeInsets get paddingRightLow => onlyPadding(right: 0.01);
  EdgeInsets get paddingRightDefault => onlyPadding(right: 0.02);
  EdgeInsets get paddingRightHigh => onlyPadding(right: 0.05);
  EdgeInsets get paddingTopLow => onlyPadding(top: 0.01);
  EdgeInsets get paddingTopDefault => onlyPadding(top: 0.02);
  EdgeInsets get paddingTopHigh => onlyPadding(top: 0.05);
  EdgeInsets get paddingBottomLow => onlyPadding(bottom: 0.01);
  EdgeInsets get paddingBottomDefault => onlyPadding(bottom: 0.02);
  EdgeInsets get paddingBottomHigh => onlyPadding(bottom: 0.05);
}

extension ThemeExtension on BuildContext {
  /// Access theme-related properties and methods easily.
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  Brightness get brightness => theme.brightness;
}

// extension LocaleExtension on BuildContext {
//   /// Get localized strings from the AppLocalizations class.
//   AppLocalizations? get locale => AppLocalizations.of(this);
// }

/// Adds responsive text size utilities.
extension TextSizeExtension on BuildContext {
  /// Returns a responsive font size based on the screen width.
  double responsiveTextSize(double size) => widthPercentage(size / 100);
}

/// Adds easy access to commonly used colors from the theme.
extension ColorSchemeExtension on BuildContext {
  Color get primaryColor => theme.colorScheme.primary;
  Color get secondaryColor => theme.colorScheme.secondary;
  Color get backgroundColor => theme.colorScheme.surface;
  Color get surfaceColor => theme.colorScheme.surface;
  Color get errorColor => theme.colorScheme.error;
  Color get onPrimaryColor => theme.colorScheme.onPrimary;
}

/// Adds a helper to show SnackBars easily.
extension SnackbarExtension on BuildContext {
  /// Displays a SnackBar with the given message.
  void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}

/// Adds navigation helpers for easier route management.
extension NavigationExtension on BuildContext {
  /// Push a new route.
  Future<T?> navigateTo<T>(Widget page) =>
      Navigator.push(this, MaterialPageRoute(builder: (context) => page));

  /// Pop the current route.
  void pop([dynamic result]) => Navigator.pop(this, result);

  /// Replace the current route with a new one.
  Future<T?> replaceWith<T>(Widget page) => Navigator.pushReplacement(
    this,
    MaterialPageRoute(builder: (context) => page),
  );
}

/// Adds helpers for checking device orientation.
extension OrientationExtension on BuildContext {
  /// Returns true if the device is in portrait mode.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Returns true if the device is in landscape mode.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Returns true if the device is a tablet.
  bool get isTablet {
    final shortestSide = mediaQuery.size.shortestSide;
    return shortestSide >= 600;
  }

  double appBarSize({bool isExtended = false}) {
    return (isExtended ? 100 : 50);
  }

  /// Returns true if the device is a phone.
  bool get isPhone {
    final shortestSide = mediaQuery.size.shortestSide;
    return shortestSide < 600;
  }
}

/// Adds helpers to show custom dialogs easily.
extension DialogExtension on BuildContext {
  /// Displays a custom dialog with the given title and content.
  Future<void> showCustomDialog({
    required String title,
    required String content,
  }) async {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Adds helpers for safe area paddings.
extension SafeAreaExtension on BuildContext {
  /// Returns the safe area insets for the current context.
  EdgeInsets get safePadding => mediaQuery.padding;

  /// Returns the top padding of the safe area.
  double get safeTopPadding => mediaQuery.padding.top;

  /// Returns the bottom padding of the safe area.
  double get safeBottomPadding => mediaQuery.padding.bottom;
}

/// Adds platform-specific helpers.
extension PlatformExtension on BuildContext {
  /// Returns true if the platform is Android.
  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;

  /// Returns true if the platform is iOS.
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;
}

/// Adds accessibility helpers.
extension AccessibilityExtension on BuildContext {
  /// Returns true if a screen reader is enabled.
  bool get isScreenReaderEnabled => mediaQuery.accessibleNavigation;
}

/// Adds utilities for DateTime formatting using Intl.
extension DateTimeExtension on DateTime {
  /// Formats the date to a readable string with a default pattern of 'dd/MM/yyyy'.
  String format({String pattern = 'dd/MM/yyyy'}) =>
      DateFormat(pattern).format(this);

  /// Formats the time to a readable string with a default pattern of 'HH:mm'.
  String formatTime({String pattern = 'HH:mm'}) =>
      DateFormat(pattern).format(this);

  /// Formats both date and time to a readable string.
  String formatDateTime({String pattern = 'dd/MM/yyyy HH:mm'}) =>
      DateFormat(pattern).format(this);

  /// Checks if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  /// Checks if the date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.year == year &&
        yesterday.month == month &&
        yesterday.day == day;
  }

  /// Checks if the date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return tomorrow.year == year &&
        tomorrow.month == month &&
        tomorrow.day == day;
  }

  /// Returns a friendly string like 'Today', 'Yesterday', or the formatted date.
  String toFriendlyString() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    return format();
  }
}

extension ToastNotificationExtension on BuildContext {
  /// Shows a success toast notification
  void showSuccessToast(
    String message, {
    String title = 'Başarılı',
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: this,
      title: Text(title),
      description: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// Shows an error toast notification
  void showErrorToast(
    String message, {
    String title = 'Hata',
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: this,
      title: Text(title),
      description: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// Shows an info toast notification
  void showInfoToast(
    String message, {
    String title = 'Bilgi',
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: this,
      title: Text(title),
      description: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// Shows a warning toast notification
  void showWarningToast(
    String message, {
    String title = 'Uyarı',
    Duration duration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: this,
      title: Text(title),
      description: Text(message),
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      alignment: Alignment.topRight,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  /// Legacy methods for backward compatibility
  void showSuccessSnackBar(String message) => showSuccessToast(message);

  void showErrorSnackBar(String message) => showErrorToast(message);

  void showInfoSnackBar(String message) => showInfoToast(message);

  void showWarningSnackBar(String message) => showWarningToast(message);
}
