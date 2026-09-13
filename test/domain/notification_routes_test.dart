import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/routes/app_pages.dart';
import 'package:nust/app/services/notification_service.dart';

void main() {
  test('notification routes safely handle missing and known page values', () {
    expect(NotificationsService.routeForPage(null), Routes.HOME);
    expect(NotificationsService.routeForPage('news'), Routes.HOME);
    expect(NotificationsService.routeForPage('gpa'), Routes.GPA_CALCULATION);
    expect(NotificationsService.routeForPage('absolutes'),
        Routes.ABSOLUTES_CALCULATION);
  });
}
