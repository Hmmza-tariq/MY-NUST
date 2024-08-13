import 'package:get/get.dart';

import '../modules/Help/bindings/help_binding.dart';
import '../modules/Help/views/help_view.dart';
import '../modules/Settings/bindings/settings_binding.dart';
import '../modules/Settings/views/settings_view.dart';
import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/gpa_calculation/bindings/gpa_calculation_binding.dart';
import '../modules/gpa_calculation/views/gpa_calculation_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/web/bindings/web_binding.dart';
import '../modules/web/views/web_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.WEB,
      page: () => const WebView(),
      binding: WebBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HELP,
      page: () => const HelpView(),
      binding: HelpBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.GPA_CALCULATION,
      page: () => const GpaCalculationView(),
      binding: GpaCalculationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
