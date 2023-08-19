import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Screens/Web%20view/pdf_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'error_widget.dart';
import 'hex_color.dart';
import '../Core/app_Theme.dart';
import '../Core/internet_manager.dart';
import '../Core/theme_provider.dart';

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
    startStreaming(context);
    checkInternet(context);
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
            }
            if (url.toLowerCase().endsWith(".pdf") ||
                url.toLowerCase().endsWith(".docx") ||
                url.toLowerCase().endsWith(".pptx") ||
                url.toLowerCase().endsWith(".docs") ||
                url.toLowerCase().endsWith(".ppt")) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfScreen(
                    url: url.toString(),
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
    return isConnected
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
        : const ErrorScreen(errorName: "Waiting for internet connection...");
  }

  void errorDialog(String reason) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: const Text(
            'Error!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Text(
            reason,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isLightMode ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
