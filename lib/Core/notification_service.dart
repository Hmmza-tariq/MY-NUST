import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_logo');
    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notification.initialize(settings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            priority: Priority.high, importance: Importance.max));
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return _notification.show(id, title, body, await notificationDetails());
  }

  Future<void> requestNotificationPermission() async {
    await _notification
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission() ??
        false;
  }

  Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payLoad,
      required DateTime scheduledNotificationDateTime}) async {
    requestNotificationPermission();
    return _notification.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotification(int id) async {
    // final List<PendingNotificationRequest> pendingNotificationRequests =
    //     await _notification.pendingNotificationRequests();
    // for (var pendingRequest in pendingNotificationRequests) {
    //   _notification.cancel(pendingRequest.id);
    // }
    await _notification.cancel(id);
  }
}
