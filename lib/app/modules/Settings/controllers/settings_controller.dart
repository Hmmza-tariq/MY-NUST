import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';

class SettingsController extends GetxController {
  var isBiometricEnabled = false.obs;
  var isAutofillEnabled = false.obs;
  ThemeController themeController = Get.find();
  void toggleBiometric(bool value) {
    isBiometricEnabled.value = value;
  }

  void toggleAutofill(bool value) {
    isAutofillEnabled.value = value;
  }

  void resetSettings() {
    themeController.resetTheme();
    isBiometricEnabled.value = false;
    isAutofillEnabled.value = false;
  }
}
