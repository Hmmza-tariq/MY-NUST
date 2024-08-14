import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebController extends GetxController {
  String url = Get.parameters['url'] ?? '';
  var isLoading = true.obs;
  var isError = false.obs;
  late WebViewController webViewController;
  var status = 0.obs;
  AuthenticationController authenticationController = Get.find();
  InternetController internetController = Get.find();
  @override
  void onInit() {
    super.onInit();
    initializeWebView();
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
          onPageFinished: (String url) {
            isLoading.value = false;
            isError.value = false;
            runJavaScriptOnPageLoad(url);
          },
          onWebResourceError: (WebResourceError error) {
            isError.value = true;
            isLoading.value = false;
            debugPrint('Error: ${error.errorCode} - ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            String url = request.url;
            debugPrint('url $url');
            if (shouldPreventNavigation(url)) {
              // snackbar('Navigation to $url is not allowed.');
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
    }

    checkInternet();
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

    if (authenticationController.autoFill) {
      autoFillLoginDetails(url);
    }
  }

  void autoFillLoginDetails(String url) {
    if (url.contains("lms.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var username = document.getElementById('username');
        var password = document.getElementById('password');
        if (username && password) {
          username.value = '${authenticationController.id}';
          password.value = '${authenticationController.pass}';
        }
      ''');
    } else if (url.contains("qalam.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var login = document.getElementById('login');
        var password = document.getElementById('password');
        if (login && password) {
          login.value = '${authenticationController.id}';
          password.value = '${authenticationController.pass}';
        }
      ''');
    }
  }

  bool shouldPreventNavigation(String url) {
    final Uri uri = Uri.parse(url);
    if (uri.host == 'nust.edu.pk' || uri.host.endsWith('.nust.edu.pk')) {
      return false;
    }
    return true;
  }
}
