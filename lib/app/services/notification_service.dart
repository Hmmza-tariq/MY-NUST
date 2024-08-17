import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    try {
      await Firebase.initializeApp();

      await _firebaseMessaging.requestPermission();
      final fCMToken = await _firebaseMessaging.getToken();
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      if (kDebugMode) {
        debugPrint('token: $fCMToken');
      }
    } catch (e) {
      debugPrint('error initializing notification: $e');
    }
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {}

class LocalNotificationManager {
  static final LocalNotificationManager _notificationService =
      LocalNotificationManager._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('ic_notification');

  factory LocalNotificationManager() {
    return _notificationService;
  }

  LocalNotificationManager._internal() {
    init();
  }

  void init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void createNotification(int count, int progress, int id,
      {bool completed = false, String? fileName}) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'progress_channel',
      'Progress Channel',
      channelDescription: 'Shows download progress',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: count,
      progress: progress,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String title =
        completed ? 'Download Complete' : 'Downloading ${fileName ?? 'file'}';
    String body = completed
        ? '$fileName has been downloaded successfully.'
        : 'Progress: $progress%';

    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: completed ? fileName : null,
    );
  }
}
