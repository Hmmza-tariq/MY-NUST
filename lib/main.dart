import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/services/notification_service.dart';
import 'app/modules/widgets/error_widget.dart';
import 'app/resources/theme_manager.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationsService().initNotifications();
  runApp(GetMaterialApp(
    title: "My Nust",
    debugShowCheckedModeBanner: false,
    theme: getApplicationTheme(),
    initialRoute: AppPages.INITIAL,
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
      details: details,
    );
  };
}
