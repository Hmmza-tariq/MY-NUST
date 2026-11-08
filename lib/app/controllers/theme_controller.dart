import 'package:nust/app/services/analytics_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nust/app/controllers/database_controller.dart';

import '../resources/theme_manager.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  DatabaseController databaseController = Get.find();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = databaseController.getDarkMode();
  }

  void toggleTheme(bool val) {
    isDarkMode.value = val;
    databaseController.setDarkMode(val);
    AnalyticsService.instance
        .settingToggle(settingName: 'dark_mode', newValue: val ? 'on' : 'off');
    AnalyticsService.instance.property('theme_mode', val ? 'dark' : 'light');
  }

  void resetTheme() {
    isDarkMode.value = false;
    databaseController.setDarkMode(false);
  }

  ThemeData get theme => isDarkMode.value ? getDarkTheme() : getLightTheme();
}
