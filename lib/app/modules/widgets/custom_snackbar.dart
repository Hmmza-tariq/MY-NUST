import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A utility class for showing consistent snackbars across the app
class AppSnackbar {
  /// Show a success snackbar
  static void success({
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title ?? 'success'.tr,
      message: message,
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      textColor: Get.theme.colorScheme.onInverseSurface,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// Show an error snackbar
  static void error({
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackbar(
      title: title ?? 'error'.tr,
      message: message,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      textColor: Get.theme.colorScheme.onErrorContainer,
      icon: Icons.error,
      duration: duration,
    );
  }

  /// Show an info snackbar
  static void info({
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title ?? 'info'.tr,
      message: message,
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      textColor: Get.theme.colorScheme.onInverseSurface,
      icon: Icons.info,
      duration: duration,
    );
  }

  /// Show a warning snackbar
  static void warning({
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title ?? 'warning'.tr,
      message: message,
      backgroundColor: Get.theme.colorScheme.tertiaryContainer,
      textColor: Get.theme.colorScheme.onTertiaryContainer,
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// Dismiss all active snackbars
  static void dismiss() {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    } catch (e) {
      debugPrint('Error dismissing snackbar: $e');
    }
  }

  /// Show a custom snackbar with full control
  static void custom({
    required String title,
    String? message,
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double borderWidth = 0,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
    bool isDismissible = true,
    bool showProgressIndicator = false,
    VoidCallback? onTap,
    TextButton? mainButton,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor ?? Get.theme.colorScheme.inverseSurface,
      textColor: textColor ?? Get.theme.colorScheme.onInverseSurface,
      icon: Icons.notifications,
      duration: duration,
    );
  }

  /// Internal method to show snackbar using GetX
  static void _showSnackbar({
    required String title,
    String? message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Use Future.microtask to ensure we're not in a build phase
    Future.microtask(() {
      try {
        final scheme = Get.theme.colorScheme;
        Get.rawSnackbar(
          messageText: Text(message?.isNotEmpty == true ? message! : title,
              style: Get.theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onInverseSurface)),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: scheme.inverseSurface,
          icon: Icon(icon, color: scheme.inversePrimary, size: 22),
          duration: duration,
          margin: const EdgeInsets.all(16),
          borderRadius: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          forwardAnimationCurve: Curves.easeOutCubic,
          reverseAnimationCurve: Curves.easeInCubic,
          animationDuration: const Duration(milliseconds: 250),
        );
      } catch (e) {
        debugPrint('Error showing snackbar: $e');
      }
    });
  }
}
