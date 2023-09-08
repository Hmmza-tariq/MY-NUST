import 'package:info_popup/info_popup.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mynust/Core/credentials.dart';
import 'package:mynust/Provider/notice_board_provider.dart';
import 'package:mynust/Screens/Home/home_drawer_list.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_radio_button/group_radio_button.dart';
import '../../Core/app_theme.dart';
import 'package:flutter/material.dart';

import '../../Provider/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late final LocalAuthentication auth;
  bool _supportState = false,
      _enableBiometricAuth = false,
      _copyButton = false,
      _autoFill = false;
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
    auth.isDeviceSupported().then((bool isSupported) => setState(() async {
          _supportState = isSupported || await auth.canCheckBiometrics;
        }));
    _loadBiometricPreference().then((value) {
      setState(() {
        _enableBiometricAuth = value ?? false;
      });
    });
    _loadCopyPreference().then((value) {
      setState(() {
        _copyButton = value ?? false;
      });
    });
    _loadAutoPreference().then((value) {
      setState(() {
        _autoFill = value ?? false;
      });
    });
    Hexagon().loadTextValues();
    _loadThemePreference();
    _loadNoticePreference();
    super.initState();
  }

  Future<void> _resetSettings(bool isLightMode) async {
    setState(() {
      _selectedThemeOption = 'System default';
      _selectedNoticeBoardOption = 'CEME';
      _enableBiometricAuth = false;
      _copyButton = false;
      _autoFill = false;
    });
    _setBiometricPreference(_enableBiometricAuth);
    _setCopyPreference(_copyButton);
    _setAutoPreference(_copyButton);
    _setAutoPreference(_autoFill);
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
            actionsAlignment: MainAxisAlignment.spaceBetween,
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Back',
                    style: TextStyle(
                        fontSize: 14,
                        color: isLightMode ? Colors.black : Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

//--------------------------------------------------------------------------

  Future<void> _setCopyPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('copyButton', value);
  }

  Future<bool?> _loadCopyPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('copyButton');
  }
//--------------------------------------------------------------------------

  Future<void> _setAutoPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoFill', value);
  }

  Future<bool?> _loadAutoPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoFill');
  }

  void _addData(bool isLightMode) {
    bool hideId = true, hidePass = true;
    TextEditingController idController = TextEditingController();
    TextEditingController passController = TextEditingController();
    idController.text = Hexagon.getAuthor();
    passController.text = Hexagon.getPrivacy();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Credentials',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? Colors.black : Colors.white),
              ),
              const InfoPopupWidget(
                contentOffset: Offset(-15, 0),
                arrowTheme: InfoPopupArrowTheme(
                  arrowDirection: ArrowDirection.down,
                  color: Colors.grey,
                ),
                contentTheme: InfoPopupContentTheme(
                  infoContainerBackgroundColor: Colors.grey,
                  infoTextStyle: TextStyle(color: Colors.white),
                  contentPadding: EdgeInsets.all(6),
                  contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                  infoTextAlign: TextAlign.center,
                ),
                dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                contentTitle:
                    'Your ID and password are saved locally on your device in highly encrypted form. We take your data security seriously. However, please be aware that any issues related to this data are beyond our control. It is your responsibility to keep your device secure and ensure the safety of your login credentials.',
                child: Icon(
                  Icons.info_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: idController,
                        keyboardType: hideId
                            ? TextInputType.visiblePassword
                            : TextInputType.name,
                        obscureText: hideId,
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        decoration: InputDecoration(
                          labelText: 'ID',
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            hideId = !hideId;
                          });
                        },
                        icon: Icon(
                            hideId ? Icons.visibility_off : Icons.visibility,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: passController,
                        keyboardType: hidePass
                            ? TextInputType.visiblePassword
                            : TextInputType.name,
                        obscureText: hidePass,
                        style: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Pass',
                          labelStyle: TextStyle(
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                      )),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            hidePass = !hidePass;
                          });
                        },
                        icon: Icon(
                            hidePass ? Icons.visibility_off : Icons.visibility,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                Hexagon()
                    .saveTextValues(idController.text, passController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

//--------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 500),
            type: PageTransitionType.rightToLeft,
            alignment: Alignment.bottomCenter,
            child: const NavigationHomeScreen(),
            inheritTheme: true,
            ctx: context,
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16),
                  child: Image.asset('assets/images/settings.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SwitchListTile(
                      title: Text(
                        'Show ID/ Pass to copy in LMS and Qalam',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                      value: _copyButton,
                      onChanged: (bool value) {
                        setState(() {
                          _copyButton = value;
                        });
                        _setCopyPreference(value);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SwitchListTile(
                      title: Text(
                        'Autofill ID/ Pass',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 16,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                      value: _autoFill,
                      onChanged: (bool value) {
                        setState(() {
                          _autoFill = value;
                        });
                        _setAutoPreference(value);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Add ID/ Pass  ',
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
                            onTap: () => _addData(isLightMode),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isLightMode
                                        ? Colors.white
                                        : Colors.black,
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
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
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
                            onTap: () => _chooseThemeDialog(isLightMode),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Theme',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isLightMode
                                        ? Colors.white
                                        : Colors.black,
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
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
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
                                    color: isLightMode
                                        ? Colors.white
                                        : Colors.black,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 140,
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
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 140,
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
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
