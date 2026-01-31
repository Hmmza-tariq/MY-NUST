import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/color_manager.dart';

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
      backgroundColor: ColorManager.primary,
      textColor: ColorManager.white,
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
    if (message.toLowerCase().contains('internet')) {
      title = 'warning'.tr;
      message = 'internet_warning'.tr;
    }
    _showSnackbar(
      title: title ?? 'error'.tr,
      message: message,
      backgroundColor: ColorManager.error,
      textColor: ColorManager.white,
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
      backgroundColor: ColorManager.darkGrey,
      textColor: ColorManager.white,
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
      backgroundColor: ColorManager.secondary,
      textColor: ColorManager.white,
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
    Color backgroundColor = ColorManager.white,
    Color textColor = ColorManager.black,
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
      backgroundColor: backgroundColor,
      textColor: textColor,
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
        Get.snackbar(
          title,
          message ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: backgroundColor,
          colorText: textColor,
          icon: Icon(icon, color: textColor, size: 24),
          duration: duration,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeInBack,
          animationDuration: const Duration(milliseconds: 400),
        );
      } catch (e) {
        debugPrint('Error showing snackbar: $e');
      }
    });
  }
}
