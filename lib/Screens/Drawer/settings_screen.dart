import 'package:info_popup/info_popup.dart';
import 'package:mynust/Core/credentials.dart';
import 'package:mynust/Provider/settings_provider.dart';
import 'package:mynust/Screens/Home/home_drawer_list.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_radio_button/group_radio_button.dart';
import '../../Core/app_theme.dart';
import 'package:flutter/material.dart';

import '../../Provider/theme_provider.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  String _selectedThemeOption = 'System default';
  final List<String> _radioThemeOptionsList = [
    'Light mode',
    'Dark mode',
    'System default'
  ];
  String _selectedNoticeBoardOption = 'CEME';
  final List<String> _radioNoticeBoardOptionsList = [
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
    'IESE',
    'NICE',
    'IGIS',
    'ASAB',
    'SADA',
    'S3H'
  ];

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
                Provider.of<SettingsProvider>(context, listen: false)
                    .resetSettings(isLightMode, context);
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1.0).animate(a1),
            child: AlertDialog(
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Hexagon().saveTextValues('', '', '');
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear',
                      style: TextStyle(fontSize: 14, color: Colors.red)),
                ),
              ],
            ));
      },
    );
  }

  void _chooseThemeDialog(bool isLightMode, context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _selectedThemeOption = settingsProvider.selectedThemeOption;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1.0).animate(a1),
            child: StatefulBuilder(
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
                      settingsProvider.updateThemeOption(
                          _selectedThemeOption, isLightMode, context);
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
            }));
      },
    );
  }

  void _chooseNoticeBoard(bool isLightMode, context) {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _selectedNoticeBoardOption = settingsProvider.selectedNoticeBoardOption;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1.0).animate(a1),
            child: StatefulBuilder(
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
                        settingsProvider.updateNoticeBoardOption(
                            _selectedNoticeBoardOption, context);
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
                          color: isLightMode
                              ? AppTheme.nearlyBlack
                              : AppTheme.white,
                        ),
                        contentPadding: const EdgeInsets.all(6),
                        contentBorderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        infoTextAlign: TextAlign.center,
                      ),
                      dismissTriggerBehavior:
                          PopupDismissTriggerBehavior.anyWhere,
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
            }));
      },
    );
  }

  void _addData(bool isLightMode, context) {
    bool hideId = true, hideLMSPass = true, hideQalamPass = true;
    TextEditingController idController = TextEditingController();
    TextEditingController lMSPassController = TextEditingController();
    TextEditingController qalamPassController = TextEditingController();
    idController.text = Hexagon.getAuthor();
    lMSPassController.text = Hexagon.getPrivacy1();
    qalamPassController.text = Hexagon.getPrivacy2();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1.0).animate(a1),
            child: AlertDialog(
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
                  InfoPopupWidget(
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
                    dismissTriggerBehavior:
                        PopupDismissTriggerBehavior.anyWhere,
                    contentTitle:
                        'Your ID and passwords are saved locally on your device in highly encrypted form. We take your data security seriously. However, please be aware that any issues related to this data are beyond our control. It is your responsibility to keep your device secure and ensure the safety of your login credentials.',
                    child: const Icon(
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
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            decoration: InputDecoration(
                              labelText: 'ID',
                              labelStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hideId = !hideId;
                              });
                            },
                            icon: Icon(
                                hideId
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: lMSPassController,
                            keyboardType: hideLMSPass
                                ? TextInputType.visiblePassword
                                : TextInputType.name,
                            obscureText: hideLMSPass,
                            style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            decoration: InputDecoration(
                              labelText: 'LMS Password',
                              labelStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hideLMSPass = !hideLMSPass;
                              });
                            },
                            icon: Icon(
                                hideLMSPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: qalamPassController,
                            keyboardType: hideQalamPass
                                ? TextInputType.visiblePassword
                                : TextInputType.name,
                            obscureText: hideQalamPass,
                            style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Qalam Password',
                              labelStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hideQalamPass = !hideQalamPass;
                              });
                            },
                            icon: Icon(
                                hideQalamPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    isLightMode ? Colors.black : Colors.white),
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
                    Hexagon().saveTextValues(idController.text,
                        lMSPassController.text, qalamPassController.text);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;

    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);

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
        body: Builder(builder: (context) {
          return SafeArea(
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
                          settingsProvider.supportState
                              ? 'Enable biometric authentication'
                              : 'Biometric not supported on your device',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 16,
                              color: settingsProvider.supportState
                                  ? isLightMode
                                      ? Colors.black
                                      : Colors.white
                                  : Colors.grey),
                        ),
                        value: settingsProvider.enableBiometricAuth,
                        onChanged: settingsProvider.supportState
                            ? (bool value) {
                                settingsProvider.updateBiometricAuth(value);
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
                          'Autofill ID/ Pass',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 16,
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                        value: settingsProvider.autoFill,
                        onChanged: (bool value) {
                          settingsProvider.updateAutoFill(value);
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
                              onTap: () => _addData(isLightMode, context),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'ID/Pass',
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
                              onTap: () =>
                                  _chooseThemeDialog(isLightMode, context),
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
                              onTap: () =>
                                  _chooseNoticeBoard(isLightMode, context),
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
                            onTap: () =>
                                _clearSharedPrefs(context, isLightMode),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Clear Data',
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
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
