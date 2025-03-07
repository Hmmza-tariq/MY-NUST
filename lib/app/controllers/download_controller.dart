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

class DownloadController extends GetxController {
  final _progressList = <double>[].obs;
  final Map<String, int> _taskIndexMap = {};
  List<Cookie> _cookies = [];
  final bool _isAndroid = Platform.isAndroid;
  final ReceivePort _port = ReceivePort();

  @override
  void onInit() {
    super.onInit();
    if (_isAndroid) {
      _initAndroid();
    } else {
      _initIOS();
    }
  }

  void _initAndroid() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];

      int index = _getTaskIndex(id);
      if (index != -1) {
        _progressList[index] = progress / 100.0;

        if (status == DownloadTaskStatus.complete.index) {
          _showSuccessSnackbar();
        }
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _initIOS() {
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

  @override
  void onClose() {
    if (_isAndroid) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    } else {
      bd.FileDownloader().destroy();
    }
    super.onClose();
  }

  void setCookies(List<Cookie> cookies) {
    _cookies = cookies;
  }

  Future<void> download(String url, int index) async {
    _showDownloadingSnackbar();
    if (_isAndroid) {
      await _downloadAndroid(url, index);
    } else {
      await _downloadIOS(url, index);
    }
  }

  Future<void> _downloadAndroid(String url, int index) async {
    if (!await _requestPermission()) return;

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
      openFileFromNotification: false,
    ).then((id) {
      if (id != null) {
        _progressList.add(0.0);
        _taskIndexMap[id] = index;
      }
    });
  }

  Future<void> _downloadIOS(String url, int index) async {
    if (!await _requestPermission()) return;

    final fileName = url.split('/').last;
    Directory? downloadsDirectory = await getApplicationDocumentsDirectory();

    final cookieHeader =
        _cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    debugPrint('downloading: $fileName directory: ${downloadsDirectory.path}');

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
    bd.FileDownloader().configureNotification(
        running: bd.TaskNotification('Downloading', 'file: $fileName'),
        complete: bd.TaskNotification('Download complete', 'file: $fileName'),
        error: bd.TaskNotification('Download failed', 'file: $fileName'),
        paused: bd.TaskNotification('Download paused', 'file: $fileName'),
        tapOpensFile: true,
        progressBar: true);
    await bd.FileDownloader().download(
      task,
      onProgress: (progress) {
        int taskIndex = _getTaskIndex(task.taskId);
        if (taskIndex != -1) {
          _progressList[taskIndex] = progress;
        }
      },
      onStatus: (status) {
        if (status == bd.TaskStatus.complete) {
          _showSuccessSnackbar();
        }
      },
    );
  }

  Future<bool> _requestPermission() async {
    if (_isAndroid) {
      return await _requestAndroidPermission();
    } else {
      return await _requestIOSPermission();
    }
  }

  Future<bool> _requestAndroidPermission() async {
    final plugin = DeviceInfoPlugin();
    late ph.PermissionStatus storageStatus;

    final android = await plugin.androidInfo;
    storageStatus = android.version.sdkInt < 33
        ? await ph.Permission.storage.request()
        : ph.PermissionStatus.granted;

    if (await ph.Permission.notification.status == ph.PermissionStatus.denied) {
      await ph.Permission.notification.request();
    }
    if (storageStatus == ph.PermissionStatus.granted) {
      return true;
    } else {
      var result = await ph.Permission.storage.request();
      return result == ph.PermissionStatus.granted;
    }
  }

  Future<bool> _requestIOSPermission() async {
    var notificationPermission = await bd.FileDownloader()
        .permissions
        .status(bd.PermissionType.notifications);
    if (notificationPermission != bd.PermissionStatus.granted) {
      notificationPermission = await bd.FileDownloader()
          .permissions
          .request(bd.PermissionType.notifications);
    }

    var storageStatus = await ph.Permission.storage.status;
    if (storageStatus != ph.PermissionStatus.granted) {
      storageStatus = await ph.Permission.storage.request();
    }

    return storageStatus.isGranted;
  }

  int _getTaskIndex(String taskId) {
    return _taskIndexMap[taskId] ?? -1;
  }

  // Helper method to show downloading snackbar
  void _showDownloadingSnackbar() {
    Get.snackbar(
      'Downloading',
      'File download started',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[900],
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 2),
    );
  }

  // Helper method to show success snackbar
  void _showSuccessSnackbar() {
    Get.snackbar(
      'Success',
      'Download completed successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 2),
    );
  }
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}
