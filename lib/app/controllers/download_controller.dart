import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  final _progressList = <double>[].obs;

  double currentProgress(int index) {
    if (index >= _progressList.length) {
      _progressList
          .addAll(List.generate(index - _progressList.length + 1, (_) => 0.0));
    }
    return _progressList[index];
  }

  Future<void> download(String url, int index) async {
    if (!await _requestPermission(Permission.storage)) return;
    LocalNotificationManager notificationService = LocalNotificationManager();

    final fileName = url.split('/').last;

    // Get the path to the "Downloads" directory
    Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
    final filePath = '${downloadsDirectory.path}/$fileName';
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
      debugPrint("DioException caught: ${e.type}, ${e.message}");
      if (e.response != null) {
        debugPrint("Response data: ${e.response?.data}");
        debugPrint("Response headers: ${e.response?.headers}");
        debugPrint("Response request: ${e.response?.requestOptions}");
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }
}
