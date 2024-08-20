import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  final _progressList = <double>[].obs;
  List<Cookie> _cookies = [];

  final ReceivePort _port = ReceivePort();

  @override
  void onInit() {
    super.onInit();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int progress = data[2];

      int index = _getTaskIndex(id);
      if (index != -1) {
        _progressList[index] = progress / 100.0;
      }
    });
    FlutterDownloader.registerCallback(callback);
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.onClose();
  }

  void setCookies(List<Cookie> cookies) {
    _cookies = cookies;
  }

  Future<void> download(String url, int index) async {
    if (!await _requestPermission(Permission.storage)) return;

    final fileName = url.split('/').last;

    Directory? downloadsDirectory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final cookieHeader =
        _cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    debugPrint('downloading: $fileName');

    await FlutterDownloader.enqueue(
      url: url,
      headers: {'Cookie': cookieHeader},
      savedDir: downloadsDirectory!.path,
      fileName: fileName,
      showNotification: true,
      saveInPublicStorage: true,
      openFileFromNotification: true,
    ).then((id) {
      print('downloaded $id');
      // if (id != null) FlutterDownloader.open(taskId: id);
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    final plugin = DeviceInfoPlugin();
    late PermissionStatus storageStatus;
    if (Platform.isIOS) {
      storageStatus = await permission.request();
    } else {
      final android = await plugin.androidInfo;
      storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
    }
    print("notification permission: ${await Permission.notification.status}");
    if (await Permission.notification.status == PermissionStatus.denied) {
      await Permission.notification.request();
    }
    if (storageStatus == PermissionStatus.granted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  int _getTaskIndex(String taskId) {
    return -1;
  }
}

@pragma('vm:entry-point')
void callback(String id, int status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}
