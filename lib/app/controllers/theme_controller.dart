import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../resources/theme_manager.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  void toggleTheme(bool val) {
    isDarkMode.value = val;
  }

  void resetTheme() {
    isDarkMode.value = false;
  }

  ThemeData get theme => isDarkMode.value ? getDarkTheme() : getLightTheme();
}
