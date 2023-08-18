// ignore_for_file: use_build_context_synchronously

import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Core/app_Theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key, required this.url});
  final String url;
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final ReceivePort _port = ReceivePort();
  // ignore: prefer_typing_uninitialized_variables
  late var taskId;
  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (kDebugMode) {
        print("Download progress: $progress%, id $id");
      }

      if (status == DownloadTaskStatus.complete) {
      } else {
        FlutterDownloader.remove(taskId: taskId);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> downloadFile(String url, [String? filename]) async {
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
          savedDir: (await getTemporaryDirectory()).path,
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

  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(widget.url);
    List<String> pathSegments = uri.pathSegments;
    String title = pathSegments.isNotEmpty ? pathSegments.last : 'unknown';
    return SafeArea(
        top: true,
        child: Scaffold(
            backgroundColor: AppTheme.white,
            appBar: AppBar(
              title: Text(title),
              actions: [
                IconButton(
                    onPressed: () => downloadFile(widget.url, title),
                    icon: const Icon(Icons.download_rounded))
              ],
            ),
            body: SfPdfViewer.network(
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
                    message: "Navigation blocked due to current sites privacy",
                    contentType: ContentType.failure,
                  ),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
                Navigator.pop(context);
              },
            )));
  }
}
