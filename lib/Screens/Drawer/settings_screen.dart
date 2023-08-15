import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_radio_button/group_radio_button.dart';
import '../../Core/app_theme.dart';
import 'package:flutter/material.dart';

import '../../Core/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late final LocalAuthentication auth;
  bool _supportState = false;
  bool _enableBiometricAuth = false;
  String _selectedOption = 'System default';
  final _radioOptionsList = ['Light mode', 'Dark mode', 'System default'];

  //--------------------------------------------------------------------------

  @override
  void initState() {
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) => setState(() {
          _supportState = isSupported;
        }));
    _loadBiometricPreference().then((value) {
      setState(() {
        _enableBiometricAuth = value ?? false;
      });
    });
    _loadThemePreference();
    super.initState();
  }

  Future<void> _resetSettings(bool isLightMode) async {
    setState(() {
      _selectedOption = 'System default';
      _enableBiometricAuth = false;
    });
    _setBiometricPreference(_enableBiometricAuth);
    _setThemePreference(_selectedOption, isLightMode);
  }

  void _resetDialog(BuildContext context, bool isLightMode) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Confirm Reset',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text('Are you sure you want to reset settings?',
              style: TextStyle(
                  fontSize: 14,
                  color: isLightMode ? Colors.black : Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 14,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _resetSettings(isLightMode);
                Navigator.of(context).pop();
              },
              child: const Text('Reset',
                  style: TextStyle(fontSize: 14, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _clearSharedPrefs(BuildContext context, bool isLightMode) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Confirm Clear',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text(
              'It includes your GPA, Tasks, Id / Pass etc... \nAre you sure you want to clear all data? ',
              style: TextStyle(
                  fontSize: 14,
                  color: isLightMode ? Colors.black : Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 14,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Clear',
                  style: TextStyle(fontSize: 14, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

//--------------------------------------------------------------------------
  Future<void> _setBiometricPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  Future<bool?> _loadBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled');
  }

//--------------------------------------------------------------------------

  Future<void> _setThemePreference(String value, bool isLightMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
    setState(() {
      if (value == 'Light mode') {
        isLightMode = true;
      } else if (value == 'Dark mode') {
        isLightMode = false;
      } else {
        var brightness = MediaQuery.of(context).platformBrightness;
        isLightMode = brightness == Brightness.light;
      }
    });
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('theme');
    setState(() {
      _selectedOption = value!;
    });
  }

  void _handleRadioValueChanged(String? value, bool isLightMode) {
    setState(() {
      _selectedOption = value!;
      _setThemePreference(_selectedOption, isLightMode);
    });
  }

  void _chooseThemeDialog(bool isLightMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor:
                isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            title: Text(
              'Choose Theme Mode',
              style: TextStyle(
                  fontSize: 16,
                  color: isLightMode ? Colors.black : Colors.white),
            ),
            content: SizedBox(
              height: 150.0,
              child: RadioGroup<String>.builder(
                direction: Axis.vertical,
                groupValue: _selectedOption,
                horizontalAlignment: MainAxisAlignment.center,
                onChanged: (value) => setState(() {
                  int option = 0;
                  if (value == 'Light mode') {
                    option = 1;
                  } else if (value == 'Dark mode') {
                    option = 2;
                  }
                  themeProvider.setTheme(option);
                  _handleRadioValueChanged(value, isLightMode);
                }),
                items: _radioOptionsList,
                textStyle: TextStyle(
                    fontSize: 16,
                    color: isLightMode ? Colors.black : Colors.white),
                itemBuilder: (item) => RadioButtonBuilder(
                  item.toString(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }
//--------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      body: SafeArea(
        top: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top, left: 16, right: 16),
              child: Image.asset('assets/images/settings.png'),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top, left: 20, right: 20),
              child: SwitchListTile(
                title: Text(
                  _supportState
                      ? 'Enable biometric authentication'
                      : 'Biometric not supported',
                  style: TextStyle(
                      fontSize: 16,
                      color: _supportState
                          ? isLightMode
                              ? Colors.black
                              : Colors.white
                          : Colors.grey),
                ),
                value: _enableBiometricAuth,
                onChanged: _supportState
                    ? (bool value) {
                        setState(() {
                          _enableBiometricAuth = value;
                        });
                        _setBiometricPreference(value);
                      }
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Choose theme',
                  style: TextStyle(
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.blue : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    boxShadow: !isLightMode
                        ? null
                        : <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(1, 1),
                                blurRadius: 2.0),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _chooseThemeDialog(isLightMode),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Theme',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isLightMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Center(
                child: Container(
                  width: 140,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.blue : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    boxShadow: !isLightMode
                        ? null
                        : <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(4, 4),
                                blurRadius: 8.0),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _resetDialog(context, isLightMode),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Reset Settings',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isLightMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Center(
                child: Container(
                  width: 140,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLightMode ? Colors.blue : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    boxShadow: !isLightMode
                        ? null
                        : <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(4, 4),
                                blurRadius: 8.0),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _clearSharedPrefs(context, isLightMode),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Clear Data',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isLightMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
