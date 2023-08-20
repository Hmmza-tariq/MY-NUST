import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Core/app_Theme.dart';
import '../Provider/internet_provider.dart';
import '../Screens/Web view/online_file_screen.dart';
import 'hex_color.dart';
import '../Core/internet_manager.dart';

class WebsiteView extends StatefulWidget {
  const WebsiteView({super.key, required this.initialUrl});
  final String initialUrl;
  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  final GlobalKey webViewKey = GlobalKey();
  late WebViewController webViewController;
  double progress = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    InternetManager.startStreaming(context);
    InternetManager.checkInternet(context);
    initializeWebView();
  }

  void initializeWebView() async {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int newProgress) {
            setState(() {
              _isLoading = true;
              progress = newProgress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error!',
                message: 'Check Internet connection',
                contentType: ContentType.failure,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          },
          onNavigationRequest: (NavigationRequest request) async {
            String url = request.url;
            List<String> downloadableExtensions = [
              '.pdf',
              '.docx',
              '.pptx',
              '.ppt',
              '.docs',
              '.doc',
              '.ppt'
            ];

            bool isDownloadable = downloadableExtensions
                .any((ext) => url.toLowerCase().endsWith(ext));
            if (Uri.parse(url).host != (Uri.parse(widget.initialUrl).host)) {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message:
                      'Cannot move outside the current domain, Navigation blocked!',
                  contentType: ContentType.warning,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
              return NavigationDecision.prevent;
            } else if (isDownloadable) {
              Navigator.push<dynamic>(
                  context,
                  PageTransition(
                      duration: const Duration(milliseconds: 500),
                      type: PageTransitionType.rightToLeft,
                      alignment: Alignment.bottomCenter,
                      child: OnlineFileScreen(url: url.toString()),
                      inheritTheme: true,
                      ctx: context));

              return NavigationDecision.prevent;
            } else if (url.contains("lms.nust.edu.pk/portal/pluginfile.php")) {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: 'Cannot open file due to LMS privacy!',
                  contentType: ContentType.warning,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);

              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    webViewController.runJavaScript(
        "navigator.userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';");
    webViewController.runJavaScriptReturningResult(
        "navigator.userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3';");
    webViewController.setUserAgent(
        "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101  Firefox/40.1");
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Provider.of<InternetProvider>(context).isConnected
        ? WillPopScope(
            onWillPop: () async {
              if (await webViewController.canGoBack()) {
                webViewController.goBack();
                return false;
              } else {
                return true;
              }
            },
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                        child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                            child: GestureDetector(
                                onDoubleTap: () => webViewController.reload(),
                                child: WebViewWidget(
                                    controller: webViewController))),
                        Visibility(
                          visible: (progress <= 0.8) ? _isLoading : false,
                          child: LoadingAnimationWidget.hexagonDots(
                            size: 40,
                            color: HexColor('#0F6FC5'),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ))
        : Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Waiting for internet connection...',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: AppTheme.fontName,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  child: Image.asset('assets/images/Error.png'),
                ),
                ElevatedButton(
                    onPressed: () {
                      InternetManager.checkInternet(context);
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: AppTheme.fontName,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ))
              ],
            ),
          );
  }
}
