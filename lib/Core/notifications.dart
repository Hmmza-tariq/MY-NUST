import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $FCMToken');

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    // if (message == null) return;
    print('Message: $message');
    // Assuming you have a navigator key for navigating to the desired page
    // navigatorKey.currentState?.pushNamed('/${message.data['route']}');
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessage.listen(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
