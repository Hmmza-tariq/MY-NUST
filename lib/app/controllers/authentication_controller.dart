import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nust/app/controllers/database_controller.dart';

class AuthenticationController extends GetxController {
  var isAutofillEnabled = false.obs;
  var isBiometricEnabled = false.obs;
  String id = "htariq.ce43ceme";
  String pass = 'Ht@#ceme9890';
  var supportState = false.obs;

  DatabaseController databaseController = Get.find();

  @override
  void onInit() async {
    super.onInit();
    isBiometricEnabled.value = databaseController.getBiometric();
    isAutofillEnabled.value = databaseController.getAutoFill();
    supportState.value = await LocalAuthentication().isDeviceSupported();
  }

  void toggleBiometric(bool value) {
    isBiometricEnabled.value = value;
    databaseController.setBiometric(value);
  }

  void toggleAutofill(bool value) {
    isAutofillEnabled.value = value;
    databaseController.setAutoFill(value);
  }

  void resetSettings() {
    isBiometricEnabled.value = false;
    isAutofillEnabled.value = false;
    databaseController.setBiometric(false);
    databaseController.setAutoFill(false);
  }

  Future<bool> authenticate() async {
    try {
      var auth = LocalAuthentication();
      bool authenticated = await auth.authenticate(
          localizedReason: 'Biometric authentication is enabled',
          options: const AuthenticationOptions(
              useErrorDialogs: false, stickyAuth: false, biometricOnly: false));
      if (authenticated) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error authenticating user: $e');
      return false;
    }
  }
}
