import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  final String key = "1111111111111111";
  late EncryptedSharedPreferences sharedPref;

  Future<void> initialize() async {
    try {
      // Initialize with the encryption key
      await EncryptedSharedPreferences.initialize(key);

      // Get the shared preferences instance
      sharedPref = EncryptedSharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing shared preferences: $e');
    }
  }

  Future<bool> clear() async {
    return sharedPref.clear();
  }

  void setBiometric(bool auth) {
    sharedPref.setBoolean('biometric', auth);
  }

  bool getBiometric() {
    return sharedPref.getBoolean('biometric') ?? false;
  }

  void setDarkMode(bool darkMode) {
    sharedPref.setBoolean('darkMode', darkMode);
  }

  bool getDarkMode() {
    return sharedPref.getBoolean('darkMode') ?? true;
  }

  void setCampus(String campus) {
    sharedPref.setString('campus', campus);
  }

  String getCampus() {
    return sharedPref.getString('campus') ?? 'CEME';
  }

  void setAutoFill(bool autoFill) {
    sharedPref.setBoolean('autoFill', autoFill);
  }

  bool getAutoFill() {
    return sharedPref.getBoolean('autoFill') ?? false;
  }

  void setCredentials(String id, String lmsPassword, String qalamPassword) {
    sharedPref.setString('id', id);
    sharedPref.setString('lmsPassword', lmsPassword);
    sharedPref.setString('qalamPassword', qalamPassword);
  }

  Map<String, String> getCredentials() {
    return {
      'id': sharedPref.getString('id') ?? '',
      'lmsPassword': sharedPref.getString('lmsPassword') ?? '',
      'qalamPassword': sharedPref.getString('qalamPassword') ?? '',
    };
  }
}
