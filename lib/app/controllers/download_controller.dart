import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum DownloadStartResult { accepted, permissionDenied, failed }

class DownloadController extends GetxController {
  final progress = <String, double>{}.obs;
  final ReceivePort _port = ReceivePort();
  StreamSubscription<dynamic>? _iosUpdates;
  final bool _isAndroid = Platform.isAndroid;

  @override
  void onInit() {
    super.onInit();
    _isAndroid ? _initAndroid() : _initIOS();
  }

  void _initAndroid() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    _port.listen((dynamic data) {
      if (data is! List || data.length < 3) return;
      final id = data[0] as String;
      final status = data[1] as int;
      progress[id] = (data[2] as int) / 100;
      if (status == DownloadTaskStatus.complete.index) {
        _showComplete();
      } else if (status == DownloadTaskStatus.failed.index) {
        _showFailure();
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _initIOS() {
    bd.FileDownloader().trackTasks();
    _iosUpdates = bd.FileDownloader().updates.listen((update) {
      if (update is bd.TaskProgressUpdate) {
        progress[update.task.taskId] = update.progress;
      } else if (update is bd.TaskStatusUpdate) {
        if (update.status == bd.TaskStatus.complete) _showComplete();
        if (update.status == bd.TaskStatus.failed) _showFailure();
      }
    });
  }

  Future<DownloadStartResult> download(
    String url, {
    String cookieHeader = '',
    String? referer,
    String? suggestedFileName,
  }) async {
    try {
      if (!await _requestPermission()) {
        AppSnackbar.error(message: 'Download permission was not granted');
        return DownloadStartResult.permissionDenied;
      }
      final uri = Uri.parse(url);
      final fileName = _safeFileName(
        suggestedFileName ??
            (uri.pathSegments.isEmpty ? 'download' : uri.pathSegments.last),
      );
      final headers = <String, String>{
        if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        if (referer != null && referer.isNotEmpty) 'Referer': referer,
      };
      final accepted = _isAndroid
          ? await _downloadAndroid(uri, fileName, headers)
          : await _downloadIOS(uri, fileName, headers);
      if (!accepted) {
        _showFailure();
        return DownloadStartResult.failed;
      }
      AppSnackbar.info(title: 'Downloading', message: fileName);
      return DownloadStartResult.accepted;
    } catch (error, stackTrace) {
      debugPrint('Download could not start: $error\n$stackTrace');
      _showFailure();
      return DownloadStartResult.failed;
    }
  }

  Future<bool> _downloadAndroid(
    Uri uri,
    String fileName,
    Map<String, String> headers,
  ) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return false;
    final id = await FlutterDownloader.enqueue(
      url: uri.toString(),
      headers: headers,
      savedDir: directory.path,
      fileName: fileName,
      showNotification: true,
      saveInPublicStorage: true,
      openFileFromNotification: true,
    );
    if (id == null) return false;
    progress[id] = 0;
    return true;
  }

  Future<bool> _downloadIOS(
    Uri uri,
    String fileName,
    Map<String, String> headers,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final task = bd.DownloadTask(
      url: uri.toString(),
      headers: headers,
      filename: fileName,
      directory: directory.path,
      updates: bd.Updates.statusAndProgress,
    );
    bd.FileDownloader().configureNotification(
      running: bd.TaskNotification('Downloading', fileName),
      complete: bd.TaskNotification('Download complete', fileName),
      error: bd.TaskNotification('Download failed', fileName),
      paused: bd.TaskNotification('Download paused', fileName),
      tapOpensFile: true,
      progressBar: true,
    );
    final accepted = await bd.FileDownloader().enqueue(task);
    if (accepted) progress[task.taskId] = 0;
    return accepted;
  }

  Future<bool> _requestPermission() async {
    if (!_isAndroid) {
      final status = await bd.FileDownloader()
          .permissions
          .status(bd.PermissionType.notifications);
      if (status != bd.PermissionStatus.granted) {
        await bd.FileDownloader()
            .permissions
            .request(bd.PermissionType.notifications);
      }
      return true;
    }

    final android = await DeviceInfoPlugin().androidInfo;
    if (android.version.sdkInt >= 33) {
      if (await ph.Permission.notification.isDenied) {
        await ph.Permission.notification.request();
      }
      return true;
    }
    return (await ph.Permission.storage.request()).isGranted;
  }

  String _safeFileName(String raw) {
    final decoded = Uri.decodeComponent(raw).trim();
    final safe = decoded.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? 'download' : safe;
  }

  void _showComplete() =>
      AppSnackbar.success(message: 'Download completed successfully');

  void _showFailure() => AppSnackbar.error(
        message: 'Download failed. Use “Open in browser” as a fallback.',
      );

  @override
  void onClose() {
    _iosUpdates?.cancel();
    _port.close();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    if (!_isAndroid) bd.FileDownloader().destroy();
    super.onClose();
  }
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  IsolateNameServer.lookupPortByName('downloader_send_port')
      ?.send([id, status, progress]);
}
