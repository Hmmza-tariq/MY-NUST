import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modules/widgets/app_dialog.dart';
import '../modules/widgets/custom_snackbar.dart';
import '../services/analytics_service.dart';

class UpdateReminderPolicy {
  static bool shouldPrompt(
          {required DateTime now,
          required int version,
          int? lastVersion,
          DateTime? lastPrompt}) =>
      version != lastVersion ||
      lastPrompt == null ||
      now.difference(lastPrompt) >= const Duration(hours: 24);
}

/// Lookup starts on the first frame; reminders wait for a usable app surface.
class AppUpdateController extends GetxController with WidgetsBindingObserver {
  AppUpdateController({Future<int?> Function()? lookup, bool? supported})
      : _lookup = lookup ?? _playVersion,
        _supported = supported ?? Platform.isAndroid;
  final Future<int?> Function() _lookup;
  final bool _supported;
  final isUpdateAvailable = false.obs;
  final checking = false.obs;
  final statusText = 'Checks on launch'.obs;
  DateTime? _lastCheck;
  Future<void>? _runningFetch;
  int? _version;
  bool _lastFetchSucceeded = false;
  bool _ready = false;
  bool _prompting = false;

  static Future<int?> _playVersion() async {
    final info = await InAppUpdate.checkForUpdate();
    return info.updateAvailability == UpdateAvailability.updateAvailable
        ? info.availableVersionCode
        : null;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> preload() => checkForUpdates(allowPrompt: false);
  Future<void> start() async {
    _ready = true;
    await checkForUpdates();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AnalyticsService.instance.lifecycle(state);
    if (_ready && state == AppLifecycleState.resumed) checkForUpdates();
  }

  Future<void> _fetch({required bool force}) async {
    if (_runningFetch != null) {
      await _runningFetch;
      return;
    }
    final now = DateTime.now();
    if (!force &&
        _lastCheck != null &&
        now.difference(_lastCheck!) < const Duration(hours: 6)) {
      return;
    }
    _runningFetch = _load(now);
    try {
      await _runningFetch;
    } finally {
      _runningFetch = null;
    }
  }

  Future<void> _load(DateTime now) async {
    checking.value = true;
    _lastCheck =
        now; // Failed lookups are also throttled; manual checks can retry.
    try {
      _version = await _lookup().timeout(const Duration(seconds: 15));
      _lastFetchSucceeded = true;
      isUpdateAvailable.value = _version != null;
      statusText.value =
          _version == null ? 'You’re up to date' : 'New version available';
    } catch (_) {
      _lastFetchSucceeded = false;
      _version = null;
      isUpdateAvailable.value = false;
      statusText.value = 'Tap to check Google Play';
    } finally {
      checking.value = false;
    }
  }

  Future<void> checkForUpdates(
      {bool manual = false, bool allowPrompt = true}) async {
    if (_prompting) return;
    if (!_supported) {
      statusText.value = 'Google Play checks on Android';
      return;
    }
    await _fetch(force: manual);
    if (!_lastFetchSucceeded) {
      if (manual) {
        AppSnackbar.info(
            message: 'Could not check for updates. Try Google Play.');
      }
      return;
    }
    if (_version == null) {
      if (manual) AppSnackbar.info(message: 'You’re up to date');
      return;
    }
    if (!allowPrompt) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final version = _version!;
    if (!manual &&
        !UpdateReminderPolicy.shouldPrompt(
            now: now,
            version: version,
            lastVersion: prefs.getInt('update_prompt_version'),
            lastPrompt:
                DateTime.tryParse(prefs.getString('update_prompt_at') ?? ''))) {
      return;
    }
    final context = Get.context;
    if (context == null ||
        !context.mounted ||
        Get.isDialogOpen == true ||
        Get.isBottomSheetOpen == true) {
      return;
    }
    _prompting = true;
    try {
      await prefs.setInt('update_prompt_version', version);
      await prefs.setString('update_prompt_at', now.toIso8601String());
      if (!context.mounted) return;
      final confirmed = await showAppConfirmationDialog(
          context: context,
          title: 'Update available',
          message:
              'A newer My NUST version is available on Google Play. Update for the latest fixes and improvements.',
          confirmLabel: 'Update now',
          cancelLabel: 'Later',
          icon: Icons.system_update_alt_rounded);
      if (confirmed == true) {
        final opened = await launchUrl(
            Uri.https('play.google.com', '/store/apps/details',
                {'id': 'com.hexagone.mynust'}),
            mode: LaunchMode.externalApplication);
        if (!opened) {
          AppSnackbar.info(
              message: 'Could not open Google Play. Please try again.');
        }
      }
    } finally {
      _prompting = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
