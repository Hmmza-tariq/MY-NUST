import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class NotificationsService {
  static String? fcmToken;
  factory NotificationsService() => _instance;
  static final NotificationsService _instance =
      NotificationsService._internal();
  NotificationsService._internal();
  static const channel = AndroidNotificationChannel(
    'default_channel_id',
    'Academic updates',
    description: 'News and updates from My NUST',
    importance: Importance.high,
  );
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initialization;
  bool _listenersRegistered = false;
  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      // Prepare the plugin and stable channel before the first foreground message.
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('notification_icon'),
          iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload == null) return;
          try {
            final data = jsonDecode(response.payload!);
            if (data is Map) _openPage(data['page']?.toString());
          } on FormatException {/* Ignore malformed or legacy payloads. */}
        },
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      if (Platform.isIOS) {
        await _fcm.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
      }
      if (!_listenersRegistered) {
        FirebaseMessaging.onMessage.listen((message) async {
          if (!Platform.isAndroid) return;
          try {
            await showNotification(message);
          } catch (_) {
            debugPrint('Could not display foreground notification.');
          }
        });
        FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
        _fcm.onTokenRefresh.listen((token) {
          fcmToken = token;
        });
        _listenersRegistered = true;
      }
      final permission =
          await _fcm.requestPermission(alert: true, badge: true, sound: true);
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) handleMessage(initialMessage);
      fcmToken = await _fcm.getToken().timeout(const Duration(seconds: 20));
      if (fcmToken != null) {
        await _fcm.subscribeToTopic('all').timeout(const Duration(seconds: 20));
        // Never log tokens or message/account contents.
        debugPrint(
            'FCM ready: ${permission.authorizationStatus.name}; token registered; topic all.');
      }
    } catch (_) {
      _initialization = null;
      debugPrint('Notification setup incomplete; retry on next app launch.');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    // Data-only messages need not contain a visible notification or Android object.
    if (notification == null) return;
    await _local.show(
      id: (message.messageId?.hashCode ??
              DateTime.now().millisecondsSinceEpoch) &
          0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
            'default_channel_id', 'Academic updates',
            channelDescription: 'News and updates from My NUST',
            icon: 'notification_icon',
            importance: Importance.high,
            priority: Priority.high),
      ),
      payload: jsonEncode({'page': message.data['page']?.toString()}),
    );
  }

  void handleMessage(RemoteMessage message) =>
      _openPage(message.data['page']?.toString());
  static String routeForPage(String? page) {
    if (page?.contains('gpa') == true) return Routes.GPA_CALCULATION;
    if (page?.contains('absolutes') == true) {
      return Routes.ABSOLUTES_CALCULATION;
    }
    return Routes.HOME;
  }

  void _openPage(String? page) => Get.toNamed(routeForPage(page));
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);
}
