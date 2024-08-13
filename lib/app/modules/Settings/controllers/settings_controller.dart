import 'package:get/get.dart';

class SettingsController extends GetxController {
  var isDarkMode = false.obs;
  var isBiometricEnabled = false.obs;
  var isAutofillEnabled = false.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
  }

  void toggleBiometric(bool value) {
    isBiometricEnabled.value = value;
  }

  void toggleAutofill(bool value) {
    isAutofillEnabled.value = value;
  }

  void resetSettings() {
    isDarkMode.value = false;
    isBiometricEnabled.value = false;
    isAutofillEnabled.value = false;
  }
}
