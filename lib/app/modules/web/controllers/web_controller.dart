import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/modules/widgets/loading.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controllers/download_controller.dart';

class WebController extends GetxController {
  String url = Get.parameters['url'] ?? '';
  var isLoading = true.obs;
  var isError = false.obs;
  var canPop = false.obs;
  var queryRan = false.obs;
  late WebViewController webViewController;
  var status = 0.obs;
  AuthenticationController authenticationController = Get.find();
  InternetController internetController = Get.find();
  final DownloadControllerAndroid downloadControllerAndroid =
      Get.put(DownloadControllerAndroid());
  final DownloadControllerIOS downloadControllerIOS =
      Get.put(DownloadControllerIOS());
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
    downloadControllerIOS.dispose();
  }

  void initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(ColorManager.background1)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int newProgress) {
            status.value = newProgress;
          },
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) async {
            isLoading.value = false;
            isError.value = false;
            runJavaScriptOnPageLoad(url);
            final cookies = await cookieManager.getCookies(url);
            downloadControllerAndroid.setCookies(cookies);
            downloadControllerIOS.setCookies(cookies);
          },
          onWebResourceError: (WebResourceError error) {
            isError.value = true;
            isLoading.value = false;
            debugPrint('Error: ${error.errorCode} - ${error.description}');
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
      )
      ..enableZoom(false);

    if (!internetController.isOnline.value) {
      isError.value = true;
      isLoading.value = false;
      internetController.noInternetDialog(reload);
    } else {
      webViewController.loadRequest(Uri.parse(url));
      canPop.value = false;
    }

    checkInternet();
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
        uri.path.endsWith('.pptx') ||
        uri.path.endsWith('.jpg')) {
      // Get.snackbar(
      //   "Downloading",
      //   "${url.split('/').last} is being downloaded",
      //   backgroundColor: ColorManager.primary.withValues(alpha: 0.4),
      //   colorText: ColorManager.secondary,
      // );
      if (Platform.isAndroid) {
        downloadControllerAndroid.download(url, 0);
      } else {
        downloadControllerIOS.download(url, 0);
      }
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
      if (await webViewController.currentUrl() == null) {
        webViewController.loadRequest(Uri.parse(url));
      } else {
        await webViewController.reload();
      }
      isLoading.value = false;
      isError.value = false;
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
          viewport.setAttribute("content", "width=600");
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
    print('kuickpay query ran');
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
}
