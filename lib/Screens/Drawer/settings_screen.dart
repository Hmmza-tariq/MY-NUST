import 'package:info_popup/info_popup.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mynust/Core/notice_board_provider.dart';
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
  String _selectedThemeOption = 'System default';
  final _radioThemeOptionsList = ['Light mode', 'Dark mode', 'System default'];
  String _selectedNoticeBoardOption = 'CEME';
  final _radioNoticeBoardOptionsList = [
    'CEME',
    'MCS',
    'SMME',
    'SEECS',
    'PNEC',
    'NBS',
    'SNS',
    'CAE',
    'NBC',
    'SCME',
    'MCE',
    'IESE'
  ];

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
    _loadNoticePreference();
    super.initState();
  }

  Future<void> _resetSettings(bool isLightMode) async {
    setState(() {
      _selectedThemeOption = 'System default';
      _selectedNoticeBoardOption = 'CEME';
      _enableBiometricAuth = false;
    });
    _setBiometricPreference(_enableBiometricAuth);
    _setNoticePreference(_selectedNoticeBoardOption);
    _setThemePreference(_selectedThemeOption, isLightMode);
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
    int option = 0;
    setState(() {
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
    });
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('theme');
    setState(() {
      _selectedThemeOption = value!;
    });
  }

  void _chooseThemeDialog(bool isLightMode) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor:
                isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            title: Center(
              child: Text(
                'Choose Theme mode',
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 16,
                    color: isLightMode ? Colors.black : Colors.white),
              ),
            ),
            content: SizedBox(
              height: 150.0,
              child: RadioGroup<String>.builder(
                direction: Axis.vertical,
                groupValue: _selectedThemeOption,
                horizontalAlignment: MainAxisAlignment.center,
                onChanged: (value) => setState(() {
                  _selectedThemeOption = value!;
                  _setThemePreference(_selectedThemeOption, isLightMode);
                }),
                items: _radioThemeOptionsList,
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

  Future<void> _setNoticePreference(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('noticeBoard', value);
    setState(() {
      Provider.of<NoticeBoardProvider>(context, listen: false)
          .setNoticeBoard(_selectedNoticeBoardOption);
    });
  }

  Future<void> _loadNoticePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('noticeBoard');
    setState(() {
      _selectedNoticeBoardOption = value!;
    });
    print('_selectedNoticeBoardOption: $_selectedNoticeBoardOption');
  }

  void _chooseNoticeBoard(bool isLightMode) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor:
                isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Choose School/College',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
            ),
            content: SizedBox(
              height: 450.0,
              child: SingleChildScrollView(
                child: RadioGroup<String>.builder(
                  direction: Axis.vertical,
                  groupValue: _selectedNoticeBoardOption,
                  horizontalAlignment: MainAxisAlignment.center,
                  onChanged: (value) => setState(() {
                    _selectedNoticeBoardOption = value!;

                    _setNoticePreference(_selectedNoticeBoardOption);
                  }),
                  items: _radioNoticeBoardOptionsList,
                  textStyle: TextStyle(
                      fontSize: 16,
                      color: isLightMode ? Colors.black : Colors.white),
                  itemBuilder: (item) => RadioButtonBuilder(
                    item.toString(),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InfoPopupWidget(
                  contentOffset: const Offset(0, 0),
                  arrowTheme: InfoPopupArrowTheme(
                    arrowDirection: ArrowDirection.down,
                    color: isLightMode
                        ? const Color.fromARGB(255, 199, 199, 199)
                        : const Color.fromARGB(255, 1, 54, 98),
                  ),
                  contentTheme: InfoPopupContentTheme(
                    infoContainerBackgroundColor: isLightMode
                        ? const Color.fromARGB(255, 199, 199, 199)
                        : const Color.fromARGB(255, 1, 54, 98),
                    infoTextStyle: TextStyle(
                      color:
                          isLightMode ? AppTheme.nearlyBlack : AppTheme.white,
                    ),
                    contentPadding: const EdgeInsets.all(6),
                    contentBorderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                    infoTextAlign: TextAlign.center,
                  ),
                  dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                  contentTitle:
                      "Need to add your School/College/Campus? Contact support.",
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
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
                      : 'Biometric not supported on your device',
                  textAlign: TextAlign.start,
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
                  textAlign: TextAlign.start,
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
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Choose Notice\nBoard',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 16,
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                  Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLightMode ? Colors.blue : Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
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
                        onTap: () => _chooseNoticeBoard(isLightMode),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Notice Board',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isLightMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
