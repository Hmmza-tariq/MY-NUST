import 'package:nust/app/services/analytics_service.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/routes/app_pages.dart';

class AuthenticationController extends GetxController {
  var isAutofillEnabled = false.obs;
  var isBiometricEnabled = false.obs;
  var id = "".obs;
  var lmsPassword = ''.obs;
  var qalamPassword = ''.obs;
  var supportState = false.obs;
  RxString page = AppPages.INITIAL.obs;
  DatabaseController databaseController = Get.find();

  @override
  void onInit() async {
    super.onInit();
    isBiometricEnabled.value = databaseController.getBiometric();
    isAutofillEnabled.value = databaseController.getAutoFill();
    Map<String, String> temp = databaseController.getCredentials();
    id.value = temp['id'] ?? '';
    lmsPassword.value = temp['lmsPassword'] ?? '';
    qalamPassword.value = temp['qalamPassword'] ?? '';
    supportState.value = await LocalAuthentication().isDeviceSupported();
  }

  void toggleBiometric(bool value) {
    isBiometricEnabled.value = value;
    databaseController.setBiometric(value);
    AnalyticsService.instance.settingToggle(
        settingName: 'biometric_auth', newValue: value ? 'on' : 'off');
    AnalyticsService.instance.property('biometric_enabled', value.toString());
  }

  Future<void> toggleAutofill(bool value) async {
    isAutofillEnabled.value = value;
    await databaseController.setAutoFill(value);
  }

  Future<void> setCredentials(
      String id, String lmsPassword, String qalamPassword) async {
    this.id.value = id;
    this.lmsPassword.value = lmsPassword;
    this.qalamPassword.value = qalamPassword;
    await databaseController.setCredentials(id, lmsPassword, qalamPassword);
  }

  void resetSettings() {
    isBiometricEnabled.value = false;
    isAutofillEnabled.value = false;
    id.value = '';
    lmsPassword.value = '';
    qalamPassword.value = '';
    databaseController.setBiometric(false);
    databaseController.setAutoFill(false);
    databaseController.setCredentials('', '', '');
  }

  Future<bool> authenticate() async {
    try {
      var auth = LocalAuthentication();
      bool authenticated = await auth.authenticate(
          localizedReason: 'Biometric authentication is enabled',
          // options: const AuthenticationOptions(
          // useErrorDialogs: false,
          // stickyAuth: false,
          biometricOnly: false
          // )
          );
      AnalyticsService.instance
          .biometricAuth(status: authenticated ? 'success' : 'cancelled');
      if (authenticated) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      AnalyticsService.instance.biometricAuth(status: 'not_available');
      debugPrint('Biometric authentication unavailable.');
      return false;
    }
  }
}
