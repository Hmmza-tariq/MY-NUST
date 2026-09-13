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

class SettingsController extends GetxController {
  AuthenticationController authenticationController = Get.find();
  ThemeController themeController = Get.find();

  Future<void> deleteAllSavedData() async {
    final sync = Get.find<AcademicSyncService>();
    await sync.disconnect();
    final database = Get.find<DatabaseController>();
    if (!await database.clear()) {
      throw StateError('Could not clear local app data');
    }
    await (await SharedPreferences.getInstance()).remove('cached_top_stories');
    final stories = Get.find<StoriesController>();
    stories.topStories.clear();
    stories.selectedCampus.value = database.getCampus();
    authenticationController.isBiometricEnabled.value = false;
    themeController.isDarkMode.value = false;
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
