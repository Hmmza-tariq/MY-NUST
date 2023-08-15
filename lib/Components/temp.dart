// import 'dart:isolate';
// import 'dart:ui';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:MyNust/Screens/Web%20view/pdf_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// import '../../Components/error_widget.dart';
// import '../../Components/hex_color.dart';
// import '../../Core/app_Theme.dart';
// import '../../Core/internet_manager.dart';
// import '../../Core/theme_provider.dart';

// class WebsiteView extends StatefulWidget {
//   const WebsiteView({super.key, required this.initialUrl});
//   final String initialUrl;
//   @override
//   State<WebsiteView> createState() => _WebsiteViewState();
// }

// class _WebsiteViewState extends State<WebsiteView> {
//   final GlobalKey webViewKey = GlobalKey();
//   InAppWebViewController? webViewController;
//   final ReceivePort _port = ReceivePort();
//   PullToRefreshController? refreshController;
//   bool _isLoading = false;
//   double progress = 0.0;
//   var urlController = TextEditingController();
//   late var taskId;
//   String desktopUserAgent =
//       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36";

//   @override
//   void initState() {
//     super.initState();
//     startStreaming(context);
//     checkInternet(context);
//     refreshController = PullToRefreshController(
//         onRefresh: () {
//           setState(() {});
//           checkInternet(context);
//           webViewController!.reload();
//         },
//         options: PullToRefreshOptions(
//             color: Colors.white, backgroundColor: HexColor('#0F6FC5')));
//     IsolateNameServer.registerPortWithName(
//         _port.sendPort, 'downloader_send_port');
//     _port.listen((dynamic data) {
//       String id = data[0];
//       DownloadTaskStatus status = data[1];
//       int progress = data[2];
//       if (kDebugMode) {
//         print("Download progress: $progress%");
//       }
//       if (status == DownloadTaskStatus.complete) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Download $id completed!"),
//         ));
//       } else {
//         errorDialog("Downloading failed due to privacy.");
//         FlutterDownloader.remove(taskId: taskId);
//       }
//     });
//     FlutterDownloader.registerCallback(downloadCallback);
//   }

//   @override
//   void dispose() {
//     IsolateNameServer.removePortNameMapping('downloader_send_port');
//     super.dispose();
//   }

//   @pragma('vm:entry-point')
//   static void downloadCallback(
//       String id, DownloadTaskStatus status, int progress) {
//     final SendPort? send =
//         IsolateNameServer.lookupPortByName('downloader_send_port');
//     send?.send([id, status, progress]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Uri initialUri = Uri.parse(widget.initialUrl);

//     return isConnected
//         ? WillPopScope(
//             onWillPop: () async {
//               if (await webViewController!.canGoBack()) {
//                 webViewController!.goBack();
//                 return false;
//               } else {
//                 return true;
//               }
//             },
//             child: Scaffold(
//               body: SafeArea(
//                 child: Column(
//                   children: [
//                     Expanded(
//                         child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           child: InAppWebView(
//                             initialOptions: InAppWebViewGroupOptions(
//                               android: AndroidInAppWebViewOptions(
//                                 useHybridComposition: true,
//                               ),
//                               crossPlatform: InAppWebViewOptions(
//                                 userAgent: desktopUserAgent,
//                                 preferredContentMode:
//                                     UserPreferredContentMode.DESKTOP,
//                                 clearCache: true,
//                                 javaScriptEnabled: true,
//                                 allowFileAccessFromFileURLs: true,
//                                 allowUniversalAccessFromFileURLs: true,
//                                 useOnDownloadStart: true,
//                                 mediaPlaybackRequiresUserGesture: true,
//                                 useShouldOverrideUrlLoading: true,
//                                 horizontalScrollBarEnabled: false,
//                               ),
//                             ),
//                             onLoadStart: (controller, url) {
//                               var currentUrl = url.toString();
//                               Uri currentUri = Uri.parse(currentUrl);
//                               print(
//                                   'currentUri: $currentUri, initialUri: $initialUri, currentUrl: $currentUrl');
//                               (initialUri.host != currentUri.host)
//                                   ? errorDialog(
//                                       "Cannot go outside the current domain.")
//                                   : setState(() {
//                                       _isLoading = true;
//                                       urlController.text = currentUrl;
//                                     });
//                             },
//                             onLoadStop: (controller, url) {
//                               refreshController!.endRefreshing();
//                               setState(() {
//                                 _isLoading = false;
//                               });
//                             },
//                             onLoadError: (controller, url, code, message) {
//                               errorDialog("Unknown Error occurred");
//                               Navigator.pop(context);
//                             },
//                             onProgressChanged: (controller, progress) {
//                               if (progress == 100) {
//                                 refreshController!.endRefreshing();
//                               }
//                               setState(() {
//                                 this.progress = progress / 100;
//                               });
//                             },
//                             pullToRefreshController: refreshController,
//                             onWebViewCreated: (controller) =>
//                                 webViewController = controller,
//                             initialUrlRequest:
//                                 URLRequest(url: Uri.parse(widget.initialUrl)),
//                             onDownloadStartRequest:
//                                 (controller, request) async {
//                               print(
//                                   'url: ${request.url},name: ${request.suggestedFilename!}');
//                               (request.url.path
//                                           .toLowerCase()
//                                           .endsWith(".pdf") ||
//                                       request.suggestedFilename!
//                                           .toLowerCase()
//                                           .endsWith(".pdf"))
//                                   ? await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => PdfScreen(
//                                           url: request.url.toString(),
//                                           name: request.suggestedFilename,
//                                         ),
//                                       ),
//                                     )
//                                   : await downloadFile(request.url.toString(),
//                                       request.suggestedFilename);
//                             },
//                           ),
//                         ),
//                         Visibility(
//                           visible: (progress <= 0.8) ? _isLoading : false,
//                           child: LoadingAnimationWidget.hexagonDots(
//                             size: 40,
//                             color: HexColor('#0F6FC5'),
//                           ),
//                         ),
//                       ],
//                     )),
//                   ],
//                 ),
//               ),
//             ))
//         : const ErrorScreen(errorName: "Waiting for internet connection...");
//   }

//   Future<void> downloadFile(String url, [String? filename]) async {
//     var hasStoragePermission = await Permission.storage.isGranted;
//     if (!hasStoragePermission) {
//       final status = await Permission.storage.request();
//       hasStoragePermission = status.isGranted;
//     }
//     // print('downloadFile: $url');
//     if (hasStoragePermission) {
//       taskId = await FlutterDownloader.enqueue(
//           url: url,
//           headers: {},
//           savedDir: (await getTemporaryDirectory()).path,
//           saveInPublicStorage: true,
//           fileName: filename);
//     }
//   }

//   void errorDialog(String reason) {
//     ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
//     bool isLightMode = themeProvider.isLightMode ??
//         MediaQuery.of(context).platformBrightness == Brightness.light;
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//           backgroundColor:
//               isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
//           title: const Text(
//             'Error!',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
//           ),
//           content: Text(
//             reason,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: isLightMode ? Colors.black : Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('OK',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color: isLightMode ? Colors.black : Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
