import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Components/toasts.dart';
import 'package:mynust/Core/credentials.dart';
import 'package:mynust/Provider/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Core/app_Theme.dart';
import '../../Provider/internet_provider.dart';
import 'online_file_screen.dart';
import '../../Components/hex_color.dart';
import '../../Core/internet_manager.dart';

class WebsiteView extends StatefulWidget {
  const WebsiteView({super.key, required this.initialUrl});
  final String initialUrl;
  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  final GlobalKey webViewKey = GlobalKey();
  double progress = 0.0;
  bool _isLoading = false, _autoFill = false, first = true;

  @override
  void initState() {
    super.initState();
    _loadAutoPreference().then((value) {
      setState(() {
        _autoFill = value ?? false;
      });
      Hexagon().loadTextValues();
      InternetManager.startStreaming(context);
      InternetManager.checkInternet(context);
      initializeWebView();
    });
  }

  Future<bool?> _loadAutoPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoFill');
  }

  void initializeWebView() async {
    InternetProvider ip = Provider.of<InternetProvider>(context, listen: false);
    ip.webViewController = WebViewController()
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
            // print('url $url');
            if (widget.initialUrl.contains("PaymentsSearchBill")) {
              ip.webViewController.runJavaScript('''
          document.getElementById("MainContent_cboInstitution").value = "04490";
          document.getElementById("MainContent_cboSearchBy").value = "RegistrationNumber";
          ''');
              Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                if (first) {
                  first = false;
                  ip.webViewController.runJavaScript('''
          document.getElementById("MainContent_btnSubmit").click();
          ''');
                }
              });
            }
            if (!widget.initialUrl.contains("qalam.nust")) {
              ip.webViewController.runJavaScript('''
          var viewport = document.querySelector("meta[name=viewport]");
          viewport.setAttribute("content", "width=450"); 
          ''');
            }
            if (_autoFill) {
              String id = Hexagon.getAuthor();
              String pass = '';
              if (widget.initialUrl.contains("lms.nust.edu.pk")) {
                pass = Hexagon.getPrivacy1();
                ip.webViewController.runJavaScript('''
          var viewport = document.querySelector("meta[name=viewport]");
          viewport.setAttribute("content", "width=600"); 
            document.getElementById('username').value = '$id';
            document.getElementById('password').value = '$pass';
                ''');
              }
              if (widget.initialUrl.contains("qalam.nust.edu.pk")) {
                pass = Hexagon.getPrivacy2();
                ip.webViewController.runJavaScript(''' 
          document.getElementById('login').value = '$id';
          document.getElementById('password').value = '$pass';
                ''');
              }
            }

            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            Toast().errorToast(context, '');
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
            if (widget.initialUrl.contains("VoucherView")) {
              ip.webViewController.runJavaScript('''
          var viewport = document.getElementById("Pe95bdc0067064a1381dc73ba7a3445e1_1_oReportCell");
          viewport.setAttribute("content", "width=10"); 

          ''');
            }
            bool isDownloadable = downloadableExtensions
                .any((ext) => url.toLowerCase().endsWith(ext));
            if (Uri.parse(url).host != (Uri.parse(widget.initialUrl).host)) {
              Toast().errorToast(
                  context, 'Cannot move outside the current domain');
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
              Toast()
                  .errorToast(context, 'Cannot open file due to LMS privacy!');
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    InternetProvider ip = Provider.of<InternetProvider>(context, listen: false);
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Stack(
      children: [
        WillPopScope(
            onWillPop: () async {
              if (await ip.webViewController.canGoBack()) {
                ip.webViewController.goBack();
                return false;
              } else {
                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      isLightMode ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor:
                      isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                  systemNavigationBarIconBrightness:
                      isLightMode ? Brightness.dark : Brightness.light,
                ));
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
                                onDoubleTap: () =>
                                    ip.webViewController.reload(),
                                child: WebViewWidget(
                                    controller: ip.webViewController))),
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
            )),
        Visibility(
            visible: !Provider.of<InternetProvider>(context, listen: true)
                .isConnected,
            child: Container(
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
                    child: Image.asset('assets/images/error.png'),
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
            ))
      ],
    );
  }
}
