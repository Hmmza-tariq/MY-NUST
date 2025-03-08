import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/app_update_controller.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/stories_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:quick_actions/quick_actions.dart';
import 'app/modules/widgets/error_widget.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  Future<String> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await dotenv.load(fileName: ".env");

    final dbController = Get.put(DatabaseController(), permanent: true);
    await dbController.initialize();
    Get.put(InternetController(), permanent: true);
    Get.put(AppUpdateController(), permanent: true);
    Get.put(StoriesController(), permanent: true);

    final authenticationController =
        Get.put(AuthenticationController(), permanent: true);

    bool isAuthenticated = false;
    if (authenticationController.isBiometricEnabled.value == true) {
      isAuthenticated = await authenticationController.authenticate();
    } else {
      isAuthenticated = true;
    }
    await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
    String page = AppPages.INITIAL;
    try {
      const QuickActions quickActions = QuickActions();
      await quickActions.initialize((String shortcutType) {
        if (shortcutType == 'gpa') {
          page = Routes.GPA_CALCULATION;
        } else if (shortcutType == 'absolutes') {
          page = Routes.ABSOLUTES_CALCULATION;
        } else if (shortcutType == 'lms') {
          page = Routes.WEB;
          dbController.setData('url', dotenv.env['LMS_URL'] ?? '');
        } else if (shortcutType == 'qalam') {
          page = Routes.WEB;
          dbController.setData('url', dotenv.env['QALAM_URL'] ?? '');
        }
      });

      quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
          type: 'lms',
          localizedTitle: 'LMS',
          localizedSubtitle: 'Open LMS',
          icon: 'lms',
        ),
        const ShortcutItem(
          type: 'qalam',
          localizedTitle: 'Qalam',
          localizedSubtitle: 'Open Qalam',
          icon: 'qalam',
        ),
        const ShortcutItem(
          type: 'gpa',
          localizedTitle: 'Calculate GPA',
          localizedSubtitle: 'Calculate your GPA',
          icon: 'gpa',
        ),
        const ShortcutItem(
          type: 'absolutes',
          localizedTitle: 'Calculate Absolutes',
          localizedSubtitle: 'Calculate your Absolutes',
          icon: 'absolutes',
        ),
      ]);
    } catch (e) {
      debugPrint('Error setting quick actions: $e');
    }

    authenticationController.page.value = page;

    return isAuthenticated ? page : AppPages.AUTHENTICATE;
  }

  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  String page = await init();

  runApp(GetMaterialApp(
    title: "My Nust",
    debugShowCheckedModeBanner: false,
    theme: Get.put(ThemeController(), permanent: true).theme,
    initialRoute: page,
    getPages: AppPages.routes,
    scrollBehavior: const MaterialScrollBehavior().copyWith(
      dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown
      },
    ),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: child!,
      );
    },
  ));
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorScreen(
      width: 10,
      height: 10,
      details: details.exceptionAsString(),
    );
  };
}
