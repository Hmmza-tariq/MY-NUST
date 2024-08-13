import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/loading.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:nust/app/services/authentication_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebController extends GetxController {
  String url = Get.parameters['url'] ?? '';
  var isLoading = true.obs;
  var isMonthlyBill = false.obs;
  late WebViewController webViewController;
  var status = 0.obs;
  AuthenticationService authenticationService = AuthenticationService();

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }

  Future<void> reload() async {
    webViewController.reload();
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
            if (url.contains("PaymentsSearchBill")) {
              isMonthlyBill.value = true;
            }
            runJavaScriptOnPageLoad(url);
          },
          onWebResourceError: (WebResourceError error) {
            isLoading.value = false;
            snackbar('Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            String url = request.url;
            debugPrint('url $url');
            if (shouldPreventNavigation(url)) {
              snackbar('Navigation to $url is not allowed.');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(url));
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

    if (authenticationService.autoFill) {
      autoFillLoginDetails(url);
    }
  }

  void autoFillLoginDetails(String url) {
    if (url.contains("lms.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var username = document.getElementById('username');
        var password = document.getElementById('password');
        if (username && password) {
          username.value = '${authenticationService.id}';
          password.value = '${authenticationService.pass}';
        }
      ''');
    } else if (url.contains("qalam.nust.edu.pk")) {
      webViewController.runJavaScript('''
        var login = document.getElementById('login');
        var password = document.getElementById('password');
        if (login && password) {
          login.value = '${authenticationService.id}';
          password.value = '${authenticationService.pass}';
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
