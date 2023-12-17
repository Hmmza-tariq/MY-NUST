import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await Firebase.initializeApp();

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    if (kDebugMode) {
      print('token: $fCMToken');
    }
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {}
