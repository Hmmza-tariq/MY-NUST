import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool? isLightMode;
  Color primaryColor = AppTheme.chipBackground;

  ThemeProvider(int option) {
    setTheme(option);
  }

  static ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    primarySwatch: Colors.blue,
    splashColor: const Color.fromARGB(128, 80, 143, 244),
    textTheme: AppTheme.textTheme,
  );

  void setTheme(int option) {
    if (option == 1) {
      isLightMode = true;
    } else if (option == 2) {
      isLightMode = false;
    } else {
      isLightMode = null;
    }

    notifyListeners();
  }
}

enum ThemeModeOption {
  light,
  dark,
  systemDefault,
}
