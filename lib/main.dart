import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mynust/Provider/internet_provider.dart';
import 'package:mynust/Provider/notice_board_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'Components/error_widget.dart';
import 'Components/hex_color.dart';
import 'Core/app_Theme.dart';
import 'Provider/assessment_provider.dart';
import 'Provider/gpa_provider.dart';
import 'Core/notification_service.dart';
import 'Provider/theme_provider.dart';
import 'Screens/Home/home_drawer_list.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await FlutterDownloader.initialize(ignoreSsl: false);

  MobileAds.instance.initialize();
  RequestConfiguration requestConfiguration =
      RequestConfiguration(testDeviceIds: ["57A34DAFAF346A59AC6C4D1CED65FC5A"]);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  NotificationService().initNotification();
  tz.initializeTimeZones();

  final sp = await SharedPreferences.getInstance();

  final String? noticeBoard = sp.getString('noticeBoard');

  final String? themeMode = sp.getString('theme');
  int option = themeMode != null
      ? themeMode == 'Light mode'
          ? 1
          : themeMode == 'Dark mode'
              ? 2
              : 0
      : 0;

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(option),
          ),
          ChangeNotifierProvider<NoticeBoardProvider>(
            create: (_) => NoticeBoardProvider(noticeBoard ?? 'CEME'),
          ),
          ChangeNotifierProvider<GpaProvider>(
            create: (_) => GpaProvider(),
          ),
          ChangeNotifierProvider<AssessmentProvider>(
            create: (_) => AssessmentProvider(),
          ),
          ChangeNotifierProvider<InternetProvider>(
            create: (_) => InternetProvider(),
          ),
        ],
        child: const MyApp(),
      )));

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const ErrorScreen(
      errorName: 'Internal Error',
    );
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocalAuthentication auth;
  bool locked = false;
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    _loadBiometricPreference().then((value) {
      setState(() {
        locked = value ?? false;
      });
      if (locked) {
        auth = LocalAuthentication();
        _authenticate();
      } else {
        locked = false;
      }
    });
    FlutterNativeSplash.remove();
  }

  Future<bool?> _loadBiometricPreference() async {
    prefs = await SharedPreferences.getInstance();

    return prefs.getBool('biometric_enabled');
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
          localizedReason: 'Biometric authentication is enabled',
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: true));
      if (authenticated) {
        setState(() {
          locked = false;
          FlutterNativeSplash.remove();
        });
      } else {
        SystemNavigator.pop();
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        title: 'My Nust',
        debugShowCheckedModeBanner: false,
        theme: ThemeProvider.theme,
        home: UpgradeAlert(
          upgrader: Upgrader(
              shouldPopScope: () => true,
              canDismissDialog: true,
              durationUntilAlertAgain: const Duration(days: 1),
              dialogStyle: UpgradeDialogStyle.cupertino),
          child: locked
              ? Scaffold(
                  backgroundColor: HexColor('#0263B5'),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        height: 300,
                        child: Image.asset('assets/images/appLogo.png'),
                      ),
                    ),
                  ),
                )
              : const NavigationHomeScreen(),
        ));
  }
}
