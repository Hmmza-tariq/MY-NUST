// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Core/notification_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Core/app_Theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OnlineFileScreen extends StatefulWidget {
  const OnlineFileScreen({super.key, required this.url});
  final String url;
  @override
  State<OnlineFileScreen> createState() => _OnlineFileScreenState();
}

class _OnlineFileScreenState extends State<OnlineFileScreen> {
  final ReceivePort _port = ReceivePort();
  late var taskId;

  bool fileExists = false;
  bool isDownloading = false;
  bool isDownloaded = false;
  String title = "";
  late String filePath;
  late CancelToken cancelToken;
  bool isPermission = false;
  bool permissionGranted = false;
  double progress = 0.0;
  bool isPDF = false;

  @override
  void initState() {
    super.initState();
    CheckPermission();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      progress = data[2];
      if (kDebugMode) {
        print("Download progress: $progress%, id $id");
      }

      if (status == DownloadTaskStatus.complete) {
      } else {
        FlutterDownloader.remove(taskId: taskId);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
    Uri uri = Uri.parse(widget.url);
    title = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'download';
    if (widget.url.toLowerCase().endsWith(".pdf")) {
      isPDF = true;
    } else {
      startDownload(widget.url);
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    // isDownloading ? cancelDownload() : null;
    super.dispose();
  }

  openFile() {
    OpenFile.open(filePath);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void CheckPermission() async {
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    setState(() {
      permissionGranted = hasStoragePermission;
    });
  }

  Future<void> downloadFile(String url, [String? filename]) async {
    filePath = (await getTemporaryDirectory()).path;
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    // print('downloadFile: $url');
    if (hasStoragePermission) {
      taskId = await FlutterDownloader.enqueue(
          url: url,
          headers: {},
          savedDir: filePath,
          saveInPublicStorage: true,
          fileName: filename);
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Downloading in progress',
          message: "Check notification",
          contentType: ContentType.help,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  Future<String> getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/files");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  startDownload(String url) async {
    checkFileExit();
    cancelToken = CancelToken();
    var storePath = await getPath();
    filePath = '$storePath/$title';
    setState(() {
      isDownloading = true;
      NotificationService().showNotification(title: 'Downloading', body: title);
      progress = 0;
    });

    try {
      if (!fileExists) {
        await Dio().download(url, filePath, onReceiveProgress: (count, total) {
          setState(() {
            progress = (count / total);
          });
        }, cancelToken: cancelToken);
      } else {
        progress = 1;
      }
      setState(() {
        isDownloading = false;
        isDownloaded = true;
        fileExists = true;
        // openFile();
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
    }
  }

  checkFileExit() async {
    var storePath = await getPath();
    filePath = '$storePath/$title';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  cancelDownload() {
    cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
            backgroundColor: AppTheme.white,
            appBar: AppBar(
              title: Text(title),
              actions: [
                isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          LoadingAnimationWidget.hexagonDots(
                            size: 36,
                            color: AppTheme.darkGrey,
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    : IconButton(
                        onPressed: () => isDownloaded
                            ? openFile()
                            : startDownload(widget.url),
                        icon: Icon(isDownloaded
                            ? Icons.file_open_rounded
                            : Icons.download_rounded))
              ],
            ),
            body: isPDF
                ? SfPdfViewer.network(
                    widget.url,
                    onDocumentLoadFailed: (details) {
                      if (kDebugMode) {
                        print('ERROR: ${details.description}');
                      }
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: 'Error',
                          message:
                              "Navigation blocked due to current sites privacy",
                          contentType: ContentType.failure,
                        ),
                      );

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                      Navigator.pop(context);
                    },
                  )
                : Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Preview not available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Downloading: $title',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ))));
  }
}
