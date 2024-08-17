import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  final _progressList = <double>[].obs;

  double currentProgress(int index) {
    try {
      return _progressList[index];
    } catch (e) {
      _progressList.add(0.0);
      return 0;
    }
  }

  Future<void> download(String url, int index) async {
    if (!await _requestPermission(Permission.storage)) return;
    NotificationService notificationService = NotificationService();

    final fileName = url.split('/').last;

    Directory? downloadsDirectory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final filePath = '${downloadsDirectory!.path}/$fileName';
    debugPrint('File path: $filePath');
    final dio = Dio();

    try {
      await dio.download(url, filePath, onReceiveProgress: (count, total) {
        final progress = (count / total);
        _progressList[index] = progress;
        notificationService.createNotification(
            total.toInt(), (progress * 100).toInt(), index);
      });

      notificationService.createNotification(100, 100, index,
          completed: true, fileName: fileName);
    } on DioException catch (e) {
      debugPrint("Error downloading file: $e");
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    debugPrint('status: ${await permission.status}');
    if (await permission.isGranted) {
      return true;
    } else {
      debugPrint('Requesting permission: $permission');
      var result = await permission.request();
      debugPrint('result: $result');
      return result == PermissionStatus.granted;
    }
  }
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
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
