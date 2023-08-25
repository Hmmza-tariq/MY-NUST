// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Core/notification_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Components/toasts.dart';
import '../../Core/app_Theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OnlineFileScreen extends StatefulWidget {
  const OnlineFileScreen({super.key, required this.url});
  final String url;
  @override
  State<OnlineFileScreen> createState() => _OnlineFileScreenState();
}

class _OnlineFileScreenState extends State<OnlineFileScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String _title = "";
  late String _filePath;
  late CancelToken _cancelToken;
  bool _permissionGranted = true;
  double _progress = 0.0;
  bool _isPDF = false;

  @override
  void initState() {
    super.initState();
    checkPermission();

    Uri uri = Uri.parse(widget.url);
    _title = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'download';
    if (widget.url.toLowerCase().endsWith(".pdf")) {
      _isPDF = true;
    } else {
      startDownload(widget.url);
    }
  }

  @override
  void dispose() {
    //IsolateNameServer.removePortNameMapping('downloader_send_port');
    // isDownloading ? cancelDownload() : null;
    super.dispose();
  }

  openFile() {
    OpenFile.open(_filePath);
  }

  void checkPermission() async {
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    setState(() {
      _permissionGranted = hasStoragePermission;
    });
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
    try {
      if (_permissionGranted) {
        _cancelToken = CancelToken();
        var storePath = await getPath();
        _filePath = '$storePath/$_title';
        setState(() {
          _isDownloading = true;

          NotificationService()
              .showNotification(title: 'Downloading', body: _title);
          _progress = 0;
        });
        await Dio().download(url, _filePath, onReceiveProgress: (count, total) {
          setState(() {
            _progress = (count / total);
          });
        }, cancelToken: _cancelToken);
      } else {
        _progress = 1;
      }
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  cancelDownload() {
    _cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
            backgroundColor: AppTheme.white,
            appBar: AppBar(
              title: Text(_title),
              actions: [
                _isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          LoadingAnimationWidget.hexagonDots(
                            size: 36,
                            color: AppTheme.darkGrey,
                          ),
                          Text(
                            '${(_progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    : IconButton(
                        onPressed: () => _isDownloaded
                            ? openFile()
                            : startDownload(widget.url),
                        icon: Icon(_isDownloaded
                            ? Icons.file_open_rounded
                            : Icons.download_rounded))
              ],
            ),
            body: _isPDF
                ? SfPdfViewer.network(
                    widget.url,
                    onDocumentLoadFailed: (details) {
                      if (kDebugMode) {
                        print('ERROR: ${details.description}');
                      }
                      Toast().errorToast(context,
                          'Navigation blocked due to current sites privacy');
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
                          'Downloading: $_title',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ))));
  }
}

  // final ReceivePort _port = ReceivePort();
  // late var taskId;
  
  // Future<void> downloadFile(String url, [String? filename]) async {
  //   filePath = (await getTemporaryDirectory()).path;
  //   var hasStoragePermission = await Permission.storage.isGranted;
  //   if (!hasStoragePermission) {
  //     final status = await Permission.storage.request();
  //     hasStoragePermission = status.isGranted;
  //   }
  //   // print('downloadFile: $url');
  //   if (hasStoragePermission) {
  //     taskId = await FlutterDownloader.enqueue(
  //         url: url,
  //         headers: {},
  //         savedDir: filePath,
  //         saveInPublicStorage: true,
  //         fileName: filename);
  //     final snackBar = SnackBar(
  //       elevation: 0,
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.transparent,
  //       content: AwesomeSnackbarContent(
  //         title: 'Downloading in progress',
  //         message: "Check notification",
  //         contentType: ContentType.help,
  //       ),
  //     );
  //     ScaffoldMessenger.of(context)
  //       ..hideCurrentSnackBar()
  //       ..showSnackBar(snackBar);
  //   }
  // }

  // @pragma('vm:entry-point')
  // static void downloadCallback(
  //     String id, DownloadTaskStatus status, int progress) {
  //   final SendPort? send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send?.send([id, status, progress]);
  // }


    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, 'downloader_send_port');
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data[1];
    //   progress = data[2];
    //   if (kDebugMode) {
    //     print("Download progress: $progress%, id $id");
    //   }
    //   if (status == DownloadTaskStatus.complete) {
    //   } else {
    //     FlutterDownloader.remove(taskId: taskId);
    //   }
    // });
    // FlutterDownloader.registerCallback(downloadCallback);
