// import 'package:firebase_messaging/firebase_messaging.dart';

// class FirebaseApi {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     // print("Handling a background message");
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     await _firebaseMessaging.getToken();
//     // print('token $FCMToken');
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     initPushNotifications();
//   }

//   void handleMessage(RemoteMessage? message) {
//     // if (message == null) return;
//     // if (message.data == 'qalam_screen') {
//     //   navigatorKey.currentState?.pushNamed('/qalam_screen');
//     // } else if (message.data == 'lms_screen') {
//     //   navigatorKey.currentState?.pushNamed('/lms_screen');
//     // } else if (message.data == 'notice_board') {
//     //   navigatorKey.currentState?.pushNamed('notice_board');
//     // }
//   }

//   Future initPushNotifications() async {
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//   }
// }
