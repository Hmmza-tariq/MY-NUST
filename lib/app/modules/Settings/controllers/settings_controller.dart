import 'package:get/get.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';

class SettingsController extends GetxController {
  AuthenticationController authenticationController = Get.find();
  ThemeController themeController = Get.find();

  void resetSettings() {
    themeController.resetTheme();
    authenticationController.resetSettings();
  }
}
