import 'package:nust/app/services/analytics_service.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/services/academic_sync_service.dart';
import 'package:nust/app/routes/app_pages.dart';
import 'package:nust/app/modules/gpa_calculation/controllers/gpa_calculation_controller.dart';
import 'package:nust/app/modules/absolutes_calculation/controllers/absolutes_calculation_controller.dart';
import 'package:nust/app/controllers/stories_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../downloads/controllers/downloads_controller.dart';

enum SavedDataCategory { portal, gpa, absolute, downloads, preferences }

class SettingsController extends GetxController {
  AuthenticationController authenticationController = Get.find();
  ThemeController themeController = Get.find();

  Future<void> deleteSelectedData(Set<SavedDataCategory> selected) async {
    if (selected.contains(SavedDataCategory.downloads)) {
      final downloads = Get.isRegistered<DownloadsController>()
          ? Get.find<DownloadsController>()
          : DownloadsController();
      await downloads.deleteAllManagedFiles();
    }
    if (selected.length == SavedDataCategory.values.length) {
      await deleteAllSavedData();
      return;
    }
    final database = Get.find<DatabaseController>();
    if (selected.contains(SavedDataCategory.portal)) {
      await Get.find<AcademicSyncService>().disconnect();
    }
    if (selected.contains(SavedDataCategory.gpa)) {
      await database.clearGpaPlanner();
      Get.delete<GpaCalculationController>(force: true);
    }
    if (selected.contains(SavedDataCategory.absolute)) {
      await database.clearAbsolutePlanner();
      Get.delete<AbsolutesCalculationController>(force: true);
    }
    if (selected.contains(SavedDataCategory.preferences)) {
      await AnalyticsService.instance.setEnabled(false);
      database.setCampus('CEME');
      database.setBiometric(false);
      database.setDarkMode(false);
      await database.setConnectionBannerHidden(false);
      await (await SharedPreferences.getInstance())
          .remove('cached_top_stories');
      themeController.resetTheme();
      authenticationController.isBiometricEnabled.value = false;
      Get.find<AcademicSyncService>().connectionBannerHidden.value = false;
      final stories = Get.find<StoriesController>();
      stories.topStories.clear();
      stories.selectedCampus.value = database.getCampus();
    }
    Get.offAllNamed(Routes.HOME);
  }

  Future<void> deleteAllSavedData() async {
    final sync = Get.find<AcademicSyncService>();
    await sync.disconnect();
    final database = Get.find<DatabaseController>();
    await AnalyticsService.instance.setEnabled(false);
    if (!await database.clear()) {
      throw StateError('Could not clear local app data');
    }
    await (await SharedPreferences.getInstance()).clear();
    await AnalyticsService.instance.setEnabled(false);
    final stories = Get.find<StoriesController>();
    stories.topStories.clear();
    stories.selectedCampus.value = database.getCampus();
    authenticationController.isBiometricEnabled.value = false;
    themeController.isDarkMode.value = database.getDarkMode();
    sync.connectionBannerHidden.value = false;
    sync.reloadCache();
    // Remove in-memory planner copies as well as persisted entries.
    Get.delete<GpaCalculationController>(force: true);
    Get.delete<AbsolutesCalculationController>(force: true);
    Get.offAllNamed(Routes.HOME);
  }

  void resetSettings() {
    themeController.resetTheme();
    authenticationController.resetSettings();
  }
}
