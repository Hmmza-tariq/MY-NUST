import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/modules/widgets/custom_loading.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controllers/download_controller.dart';

class WebController extends GetxController {
  String url = Get.parameters['url'] ?? '';
  var isLoading = true.obs;
  var isError = false.obs;
  var initError = false.obs;
  var errorMessage = "Failed to load webpage".obs;
  var canPop = false.obs;
  var queryRan = false.obs;
  late WebViewController webViewController;
  var status = 0.obs;
  AuthenticationController authenticationController = Get.find();
  InternetController internetController = Get.find();
  final DownloadController downloadController = Get.put(DownloadController());
  final cookieManager = WebviewCookieManager();
  ThemeController themeController = Get.find();

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }

  @override
  void onClose() {
    super.onClose();
    downloadController.dispose();
  }

  void initializeWebView() {
    try {
      final String userAgent = Platform.isAndroid
          ? 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
          : 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';

      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(ColorManager.background1)
        ..setUserAgent(userAgent)
        ..enableZoom(true)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int newProgress) {
              status.value = newProgress;
            },
            onPageStarted: (String url) {
              isLoading.value = true;
              initError.value = false;
            },
            onPageFinished: (String url) async {
              isLoading.value = false;
              isError.value = false;
              initError.value = false;
              runJavaScriptOnPageLoad(url);
              final cookies = await cookieManager.getCookies(url);
              downloadController.setCookies(cookies);

              // Apply CSS fixes to prevent display issues
              applyRenderingFixes();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint(
                  'WebView Error: ${error.errorCode} - ${error.description}');

              if (error.errorCode == -1 ||
                  error.errorType == WebResourceErrorType.hostLookup) {
                // Network related errors
                isError.value = true;
                isLoading.value = false;
              } else if (error.errorType ==
                      WebResourceErrorType.javaScriptExceptionOccurred ||
                  error.errorType ==
                      WebResourceErrorType.webContentProcessTerminated) {
                // Rendering or JavaScript errors
                initError.value = true;
                errorMessage.value = "Rendering error: ${error.description}";
                isLoading.value = false;
              }
            },
            onNavigationRequest: (NavigationRequest request) async {
              String url = request.url;

              if (await handleFileDownload(request)) {
                return NavigationDecision.prevent;
              }

              if (shouldPreventNavigation(url)) {
                debugPrint('Preventing navigation to $url');
                errorSnackbar('Navigation to external sites is not allowed');
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        );

      webViewController.loadRequest(Uri.parse(url));

      if (!internetController.isOnline.value) {
        isError.value = true;
        isLoading.value = false;
        internetController.noInternetDialog(reload);
      } else {
        webViewController.loadRequest(Uri.parse(url));
        canPop.value = false;
      }

      checkInternet();
    } catch (e) {
      debugPrint('Error initializing webview: $e');
      initError.value = true;
      errorMessage.value = "Failed to initialize WebView: $e";
      isLoading.value = false;
    }
  }

  void applyRenderingFixes() {
    // Apply CSS fixes to prevent rendering glitches
    webViewController.runJavaScript('''
      var selectElement = document.getElementById("MainContent_cboInstitution");
      for (var i = 0; i < selectElement.options.length; i++) {
        if (selectElement.options[i].value === "04490") {
            selectElement.selectedIndex = i; 
        if ("createEvent" in document) {
            var evt = document.createEvent("HTMLEvents");
            evt.initEvent("change", false, true);
            selectElement.dispatchEvent(evt);
        } else {
            selectElement.fireEvent("onchange");
        }
        break;
        }
    } 
    var selectElement = document.getElementById("MainContent_cboSearchBy"); 
    for (var i = 0; i < selectElement.options.length; i++) {
        if (selectElement.options[i].value === "RegistrationNumber") {
            selectElement.selectedIndex = i;

            if ("createEvent" in document) {
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("change", false, true);
                selectElement.dispatchEvent(evt);
            } else {
                selectElement.fireEvent("onchange");
            }

            break;
        }
    }
    ''');
  }

  Future<bool> handleFileDownload(NavigationRequest request) async {
    String url = request.url;
    final Uri uri = Uri.parse(url);
    if (uri.path.endsWith('.pdf') ||
        uri.path.endsWith('.docx') ||
        uri.path.endsWith('.ppt') ||
        uri.path.endsWith('.jpg') ||
        uri.path.endsWith('.jpeg') ||
        uri.path.endsWith('.png') ||
        uri.path.endsWith('.pptx')) {
      downloadController.download(url, 0);
      return true;
    }
    return false;
  }

  void checkInternet() {
    internetController.isOnline.listen(
      (isOnline) async {
        if (isOnline) {
          isError.value = false;
          if (isError.value) {
            await reload();
          }
        } else {
          isError.value = true;
          internetController.noInternetDialog(reload);
        }
      },
    );
  }

  Future<void> reload() async {
    if (internetController.isOnline.value) {
      isLoading.value = true;
      initError.value = false;
      if (await webViewController.currentUrl() == null) {
        webViewController.loadRequest(Uri.parse(url));
      } else {
        await webViewController.reload();
      }
    } else {
      isError.value = true;
      internetController.noInternetDialog(reload);
    }
  }

  void runJavaScriptOnPageLoad(String url) {
    if (url.contains("lms")) {
      webViewController.runJavaScript('''
        var viewport = document.querySelector("meta[name=viewport]");
        if (viewport) {
          viewport.setAttribute("content", "width=device-width, initial-scale=1.0, maximum-scale=1.0");
        } else {
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
      ''');
    }

    if (authenticationController.isAutofillEnabled.value) {
      autoFillLoginDetails(url);
    } else if (url.contains("kuickpay")) {
      kuickPayQuery();
    }
  }

  void autoFillLoginDetails(String url) {
    if (url.contains("lms.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var username = document.getElementById('username');
        var password = document.getElementById('password');
        if (username && password) {
          username.value = '${authenticationController.id}';
          password.value = '${authenticationController.lmsPassword}';
        }
      ''');
    } else if (url.contains("qalam.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var login = document.getElementById('login');
        var password = document.getElementById('password');
        if (login && password) {
          login.value = '${authenticationController.id}';
          password.value = '${authenticationController.qalamPassword}';
        }
      ''');
    }
  }

  void kuickPayQuery() {
    if (queryRan.value) {
      return;
    }
    webViewController.runJavaScript('''
      var selectElement = document.getElementById("MainContent_cboInstitution");
      for (var i = 0; i < selectElement.options.length; i++) {
        if (selectElement.options[i].value === "04490") {
            selectElement.selectedIndex = i; 
        if ("createEvent" in document) {
            var evt = document.createEvent("HTMLEvents");
            evt.initEvent("change", false, true);
            selectElement.dispatchEvent(evt);
        } else {
            selectElement.fireEvent("onchange");
        }
        break;
        }
    } 
    var selectElement = document.getElementById("MainContent_cboSearchBy"); 
    for (var i = 0; i < selectElement.options.length; i++) {
        if (selectElement.options[i].value === "RegistrationNumber") {
            selectElement.selectedIndex = i;

            if ("createEvent" in document) {
                var evt = document.createEvent("HTMLEvents");
                evt.initEvent("change", false, true);
                selectElement.dispatchEvent(evt);
            } else {
                selectElement.fireEvent("onchange");
            }

            break;
        }
    }
      ''');
    queryRan.value = true;
  }

  bool shouldPreventNavigation(String url) {
    final Uri uri = Uri.parse(url);
    if (uri.host == 'nust.edu.pk' ||
        uri.host.endsWith('.nust.edu.pk') ||
        uri.host == 'app.kuickpay.com') {
      return false;
    }
    return true;
  }

  void setCustomSettings(Map<String, dynamic> settings) {
    for (var entry in settings.entries) {
      try {
        webViewController
            .runJavaScript('window.navigator.${entry.key} = ${entry.value};');
      } catch (e) {
        debugPrint('Error setting ${entry.key}: $e');
      }
    }
  }
}
