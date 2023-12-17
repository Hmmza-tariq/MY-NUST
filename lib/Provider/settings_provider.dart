import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mynust/Provider/notice_board_provider.dart';
import 'package:mynust/Provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _supportState = false;
  bool _enableBiometricAuth = false;
  bool _autoFill = false;
  String _selectedThemeOption = 'System default';
  String _selectedNoticeBoardOption = 'CEME';
  SettingsProvider() {
    loadValues();
  }
  bool get supportState => _supportState;
  bool get enableBiometricAuth => _enableBiometricAuth;
  bool get autoFill => _autoFill;
  String get selectedThemeOption => _selectedThemeOption;
  String get selectedNoticeBoardOption => _selectedNoticeBoardOption;

  Future<void> loadValues() async {
    _supportState = await LocalAuthentication().isDeviceSupported();
    _enableBiometricAuth = await _loadBiometricPreference() ?? false;
    _autoFill = await _loadAutoPreference() ?? false;
    _selectedThemeOption = await _loadThemePreference();
    _selectedNoticeBoardOption = await _loadNoticePreference();
    // print(
    //     'loadValues _selectedNoticeBoardOption $_selectedNoticeBoardOption, _selectedThemeOption $_selectedThemeOption, _autoFill $_autoFill, _copyButton $_copyButton, _enableBiometricAuth $_enableBiometricAuth');
    notifyListeners();
  }

  void resetSettings(bool isLightMode, context) async {
    updateBiometricAuth(false);
    updateAutoFill(false);
    updateThemeOption('System default', isLightMode, context);
    updateNoticeBoardOption('CEME', context);
  }

//-------------------------------------------------------------------
  void updateBiometricAuth(bool value) {
    _enableBiometricAuth = value;
    _setBiometricPreference(value);
    notifyListeners();
  }

  void updateAutoFill(bool value) {
    _autoFill = value;
    _setAutoPreference(value);
    notifyListeners();
  }

  void updateThemeOption(String value, bool isLightMode, context) {
    _selectedThemeOption = value;
    _setThemePreference(value, isLightMode, context);
    notifyListeners();
  }

  void updateNoticeBoardOption(String value, context) {
    _selectedNoticeBoardOption = value;
    _setNoticePreference(value, context);
    notifyListeners();
  }

//-------------------------------------------------------------------
  Future<String> _loadNoticePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString('noticeBoard') ?? 'CEME';
    return value;
  }

  Future<bool?> _loadAutoPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoFill');
  }

  Future<String> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString('theme') ?? 'System default';
    return value;
  }

  Future<bool?> _loadBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled');
  }

//------------------------------------------------------------------

  void _setAutoPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoFill', value);
  }

  void _setNoticePreference(String value, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('noticeBoard', value);
    Provider.of<NoticeBoardProvider>(context, listen: false)
        .setNoticeBoard(_selectedNoticeBoardOption);
  }

  void _setThemePreference(String value, bool isLightMode, context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
    int option = 0;
    if (value == 'Light mode') {
      isLightMode = true;
      option = 1;
    } else if (value == 'Dark mode') {
      isLightMode = false;
      option = 2;
    } else {
      var brightness = MediaQuery.of(context).platformBrightness;
      isLightMode = brightness == Brightness.light;
    }
    Provider.of<ThemeProvider>(context, listen: false).setTheme(option);
  }

  void _setBiometricPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }
}
