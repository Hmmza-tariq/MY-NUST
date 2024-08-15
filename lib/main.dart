import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/app_update_controller.dart';
import 'package:nust/app/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/campus_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/services/notification_service.dart';
import 'app/modules/widgets/error_widget.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationsService().initNotifications();

  DatabaseController databaseController = Get.put(DatabaseController());
  await databaseController.initialize();

  ThemeController themeController = Get.put(ThemeController());
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  Get.put(InternetController());
  Get.put(AppUpdateController());
  Get.put(CampusController());

  bool authenticated = false;
  if (authenticationController.isBiometricEnabled.value == true) {
    authenticated = await authenticationController.authenticate();
  } else {
    authenticated = true;
  }

  runApp(GetMaterialApp(
    title: "My Nust",
    debugShowCheckedModeBanner: false,
    theme: themeController.theme,
    initialRoute: authenticated ? AppPages.INITIAL : AppPages.AUTHENTICATE,
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
      details: details.exceptionAsString(),
    );
  };
}
