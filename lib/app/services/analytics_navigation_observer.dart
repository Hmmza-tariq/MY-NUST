import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'analytics_service.dart';
import '../routes/app_pages.dart';

/// Fixed vocabulary: raw routes, titles and URLs never reach GA4.
class AnalyticsNavigationObserver extends NavigatorObserver {
  void _record(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final name = route.settings.name?.split('?').first;
    final screen = {
      Routes.HOME: 'home',
      Routes.SETTINGS: 'settings',
      Routes.HELP: 'help',
      Routes.ABOUT: 'about',
      Routes.GPA_CALCULATION: 'gpa_planner_cgpa',
      Routes.ABSOLUTES_CALCULATION: 'absolute_score_lecture',
    }[name];
    if (screen != null) AnalyticsService.instance.screen(screen);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _record(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _record(previousRoute);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _record(newRoute);
}

Future<T?>? openFeature<T>(String route, String feature,
    {String source = 'home', Map<String, String>? parameters}) {
  AnalyticsService.instance.featureOpen(featureName: feature, source: source);
  if (feature == 'help') {
    AnalyticsService.instance.helpOpen(source: source);
  }
  return Get.toNamed<T>(route, parameters: parameters);
}
