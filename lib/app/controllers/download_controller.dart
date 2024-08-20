import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class DownloadControllerAndroid extends GetxController {
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
    if (!await _requestPermission(ph.Permission.storage)) return;

    final fileName = url.split('/').last;

    Directory? downloadsDirectory = await getExternalStorageDirectory();

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

  Future<bool> _requestPermission(ph.Permission permission) async {
    final plugin = DeviceInfoPlugin();
    late ph.PermissionStatus storageStatus;

    final android = await plugin.androidInfo;
    storageStatus = android.version.sdkInt < 33
        ? await ph.Permission.storage.request()
        : ph.PermissionStatus.granted;

    print(
        "notification permission: ${await ph.Permission.notification.status}");
    if (await ph.Permission.notification.status == ph.PermissionStatus.denied) {
      await ph.Permission.notification.request();
    }
    if (storageStatus == ph.PermissionStatus.granted) {
      return true;
    } else {
      var result = await permission.request();
      return result == ph.PermissionStatus.granted;
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

class DownloadControllerIOS extends GetxController {
  final _progressList = <double>[].obs;
  final Map<String, int> _taskIndexMap = {};
  List<Cookie> _cookies = [];

  @override
  void onInit() {
    super.onInit();
    _initDownloader();
  }

  void _initDownloader() {
    bd.FileDownloader().trackTasks();

    bd.FileDownloader().updates.listen((update) {
      if (update is bd.TaskStatusUpdate) {
        int index = _getTaskIndex(update.task.taskId);
        if (index != -1 && update.status == bd.TaskStatus.complete) {
          _progressList[index] = 1.0;
        }
      } else if (update is bd.TaskProgressUpdate) {
        int index = _getTaskIndex(update.task.taskId);
        if (index != -1) {
          _progressList[index] = update.progress;
        }
      }
    });
  }

  void setCookies(List<Cookie> cookies) {
    _cookies = cookies;
  }

  Future<void> download(String url, int index) async {
    if (!await _requestPermission()) return;

    final fileName = url.split('/').last;

    Directory? downloadsDirectory = await getDownloadsDirectory();

    if (downloadsDirectory == null) {
      debugPrint('Could not access the Downloads directory');
      return;
    }

    final cookieHeader =
        _cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    debugPrint('downloading: $fileName');

    final task = bd.DownloadTask(
      url: url,
      headers: {'Cookie': cookieHeader},
      filename: fileName,
      directory: downloadsDirectory.path,
      updates: bd.Updates.statusAndProgress,
      metaData: 'data for index $index',
    );

    _progressList.add(0.0);
    _taskIndexMap[task.taskId] = index;

    await bd.FileDownloader().download(
      task,
      onProgress: (progress) {
        int taskIndex = _getTaskIndex(task.taskId);
        if (taskIndex != -1) {
          _progressList[taskIndex] = progress;
        }
        print('Progress: ${progress * 100}%');
      },
      onStatus: (status) {
        // Get.snackbar('Download Status ${status.toString()}',
        //     "File: $fileName, progress: ${_progressList[index]}");
      },
    );
    bd.FileDownloader().configureNotification(
        running: bd.TaskNotification('Downloading', 'file: $fileName'),
        complete: bd.TaskNotification('Download complete', 'file: $fileName'),
        error: bd.TaskNotification('Download failed', 'file: $fileName'),
        paused: bd.TaskNotification('Download paused', 'file: $fileName'),
        progressBar: true);
  }

  Future<bool> _requestPermission() async {
    var permissionType = bd.PermissionType.notifications;
    var status = await bd.FileDownloader().permissions.status(permissionType);
    if (status != bd.PermissionStatus.granted) {
      status = await bd.FileDownloader().permissions.request(permissionType);
      debugPrint('Permission for $permissionType was $status');
    }

    permissionType = bd.PermissionType.iosAddToPhotoLibrary;
    status = await bd.FileDownloader().permissions.status(permissionType);
    if (status != bd.PermissionStatus.granted) {
      status = await bd.FileDownloader().permissions.request(permissionType);
      debugPrint('Permission for $permissionType was $status');
    }

    return status == bd.PermissionStatus.granted;
  }

  int _getTaskIndex(String taskId) {
    return _taskIndexMap[taskId] ?? -1;
  }
}
