import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/controllers/download_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/domain/portal/portal_load_state.dart';
import 'package:nust/app/domain/portal/portal_url_classifier.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebController extends GetxController {
  static const platform = MethodChannel('com.hexagone.mynust/webview');

  final AuthenticationController authenticationController = Get.find();
  final InternetController internetController = Get.find();
  final ThemeController themeController = Get.find();
  final DatabaseController databaseController = Get.find();
  final DownloadController downloadController = Get.put(DownloadController());

  String url = Get.parameters['url'] ?? '';
  final phase = PortalPhase.initializing.obs;
  final isLoading = true.obs;
  final isError = false.obs;
  final initError = false.obs;
  final errorMessage = 'Unable to load this page.'.obs;
  final canPop = false.obs;
  final queryRan = false.obs;
  final isWebViewInitialized = false.obs;
  final status = 0.obs;
  final pageTitle = 'Portal'.obs;
  final currentUrl = ''.obs;
  final isAppBarExpanded = true.obs;
  WebViewController? webViewController;

  StreamSubscription<bool>? _connectionSubscription;
  Timer? _slowTimer;
  Timer? _timeoutTimer;
  String _activeUrl = '';

  @override
  void onInit() {
    super.onInit();
    initializeWebView();
  }

  Future<void> initializeWebView() async {
    if (isWebViewInitialized.value && webViewController != null) {
      await reload();
      return;
    }
    _setPhase(PortalPhase.initializing);
    try {
      if (url.isEmpty) url = await databaseController.getData('url');
      final uri = Uri.tryParse(url);
      if (uri == null || !PortalUrlClassifier.isAllowedPage(url)) {
        _fail('The portal address is missing or invalid.');
        return;
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(themeController.theme.scaffoldBackgroundColor)
        ..enableZoom(true)
        ..addJavaScriptChannel(
          'PortalBridge',
          onMessageReceived: (message) => _handlePortalMessage(message.message),
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (value) => status.value = value,
            onPageStarted: _onPageStarted,
            onPageFinished: _onPageFinished,
            onWebResourceError: _onWebResourceError,
            onNavigationRequest: _onNavigationRequest,
          ),
        );
      webViewController = controller;
      isWebViewInitialized.value = true;

      if (Platform.isAndroid) {
        AndroidWebViewController.enableDebugging(kDebugMode);
        final android = controller.platform as AndroidWebViewController;
        await android.setMediaPlaybackRequiresUserGesture(false);
      }

      _watchConnectivity();
      if (!internetController.isOnline.value) {
        _setPhase(PortalPhase.offline);
        return;
      }
      await controller.loadRequest(uri);
    } catch (error, stackTrace) {
      debugPrint('WebView initialization failed: $error\n$stackTrace');
      _fail('The portal could not be started. Please try again.');
    }
  }

  void _onPageStarted(String value) {
    canPop.value = false;
    _activeUrl = value;
    currentUrl.value = _formatUrl(value);
    status.value = 0;
    _setPhase(PortalPhase.loading);
    _startLoadTimers();
  }

  Future<void> _onPageFinished(String value) async {
    _cancelLoadTimers();
    _activeUrl = value;
    currentUrl.value = _formatUrl(value);
    status.value = 100;
    _setPhase(PortalPhase.ready);
    try {
      final title = await webViewController?.getTitle();
      pageTitle.value =
          title?.trim().isNotEmpty == true ? title!.trim() : 'Portal';
      await _installPortalBridge();
      runJavaScriptOnPageLoad(value);
    } catch (error) {
      debugPrint('Post-load setup skipped: $error');
    }
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('WebView error ${error.errorCode}: ${error.description}');
    if (error.isForMainFrame == false) return;
    _cancelLoadTimers();
    if (!internetController.isOnline.value ||
        error.errorType == WebResourceErrorType.hostLookup) {
      _setPhase(PortalPhase.offline);
      return;
    }
    _fail('The portal did not respond. Retry here or open it in your browser.');
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    switch (PortalUrlClassifier.classify(request.url)) {
      case PortalNavigationKind.page:
        return NavigationDecision.navigate;
      case PortalNavigationKind.download:
        await _startDownload(request.url);
        return NavigationDecision.prevent;
      case PortalNavigationKind.external:
        await openInBrowser(request.url);
        return NavigationDecision.prevent;
      case PortalNavigationKind.unsupported:
        AppSnackbar.error(
            message: 'This link type is not supported in the app.');
        return NavigationDecision.prevent;
    }
  }

  Future<void> _handlePortalMessage(String value) async {
    if (value == 'print') {
      await openInBrowser(_activeUrl.isEmpty ? url : _activeUrl);
      AppSnackbar.info(
        title: 'Opened in browser',
        message:
            'Use the browser print or download control to save the challan.',
      );
      return;
    }
    final kind = PortalUrlClassifier.classify(value);
    if (kind == PortalNavigationKind.download) {
      await _startDownload(value);
    } else if (kind == PortalNavigationKind.page) {
      await webViewController?.loadRequest(Uri.parse(value));
    } else if (kind == PortalNavigationKind.external) {
      await openInBrowser(value);
    } else {
      AppSnackbar.error(
        message:
            'This document cannot be saved directly. Opening the portal in your browser.',
      );
      await openInBrowser(_activeUrl.isEmpty ? url : _activeUrl);
    }
  }

  Future<void> _startDownload(String downloadUrl) async {
    if (downloadUrl.startsWith('blob:') || downloadUrl.startsWith('data:')) {
      AppSnackbar.info(
        title: 'Browser download required',
        message:
            'This document is generated by the portal. Opening it in your browser.',
      );
      await openInBrowser(_activeUrl.isEmpty ? url : _activeUrl);
      return;
    }
    final cookieHeader = await _nativeCookies(downloadUrl);
    await downloadController.download(
      downloadUrl,
      cookieHeader: cookieHeader,
      referer: _activeUrl,
    );
  }

  Future<String> _nativeCookies(String value) async {
    try {
      return await platform
              .invokeMethod<String>('getCookies', {'url': value}) ??
          '';
    } catch (error) {
      debugPrint('Native cookies unavailable: $error');
      return '';
    }
  }

  Future<void> _installPortalBridge() async {
    await webViewController?.runJavaScript(r'''
      (function () {
        if (window.__myNustBridgeInstalled) return;
        window.__myNustBridgeInstalled = true;
        window.open = function (target) {
          if (target) PortalBridge.postMessage(new URL(target, location.href).href);
          return null;
        };
        window.print = function () { PortalBridge.postMessage('print'); };
        function keepFormsInPortal(root) {
          var forms = (root || document).querySelectorAll('form[target="_blank"]');
          forms.forEach(function (form) { form.target = '_self'; });
        }
        keepFormsInPortal(document);
        new MutationObserver(function () { keepFormsInPortal(document); })
          .observe(document.documentElement, { childList: true, subtree: true });
        document.addEventListener('click', function (event) {
          var anchor = event.target && event.target.closest
            ? event.target.closest('a[href]') : null;
          if (!anchor) return;
          if (anchor.hasAttribute('download') || anchor.target === '_blank') {
            event.preventDefault();
            PortalBridge.postMessage(anchor.href);
          }
        }, true);
      })();
    ''');
  }

  void _watchConnectivity() {
    _connectionSubscription?.cancel();
    _connectionSubscription = internetController.isOnline.listen((online) {
      if (!online) {
        _setPhase(PortalPhase.offline);
      } else if (phase.value == PortalPhase.offline) {
        reload();
      }
    });
  }

  void _startLoadTimers() {
    _cancelLoadTimers();
    _slowTimer = Timer(const Duration(seconds: 12), () {
      if (phase.value == PortalPhase.loading) _setPhase(PortalPhase.slow);
    });
    _timeoutTimer = Timer(const Duration(seconds: 45), () {
      if (phase.value == PortalPhase.loading ||
          phase.value == PortalPhase.slow) {
        errorMessage.value =
            'The portal is still loading. You can keep waiting, retry, or open it in your browser.';
        _setPhase(PortalPhase.slow);
      }
    });
  }

  void _cancelLoadTimers() {
    _slowTimer?.cancel();
    _timeoutTimer?.cancel();
  }

  void _setPhase(PortalPhase value) {
    phase.value = value;
    isLoading.value = value.isBusy;
    isError.value = value == PortalPhase.offline;
    initError.value = value == PortalPhase.failed;
  }

  void _fail(String message) {
    errorMessage.value = message;
    _setPhase(PortalPhase.failed);
  }

  Future<void> reload() async {
    if (!internetController.isOnline.value) {
      _setPhase(PortalPhase.offline);
      return;
    }
    final controller = webViewController;
    if (controller == null) {
      await initializeWebView();
      return;
    }
    _setPhase(PortalPhase.loading);
    final existingUrl = await controller.currentUrl();
    if (existingUrl == null) {
      await controller.loadRequest(Uri.parse(url));
    } else {
      await controller.reload();
    }
  }

  Future<void> openInBrowser([String? value]) async {
    final target = value ?? (_activeUrl.isEmpty ? url : _activeUrl);
    final uri = Uri.tryParse(target);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppSnackbar.error(message: 'Could not open this link in your browser.');
    }
  }

  Future<void> goBack() async {
    final controller = webViewController;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    } else {
      canPop.value = true;
      await Future<void>.delayed(Duration.zero);
      Get.back();
    }
  }

  Future<void> goForward() async {
    final controller = webViewController;
    if (controller != null && await controller.canGoForward()) {
      await controller.goForward();
    }
  }

  void runJavaScriptOnPageLoad(String value) {
    if (authenticationController.isAutofillEnabled.value) {
      autoFillLoginDetails(value);
    } else if (value.contains('kuickpay')) {
      kuickPayQuery();
    }
  }

  void autoFillLoginDetails(String value) {
    String? userSelector;
    String? passwordSelector;
    String? password;
    if (value.contains('lms.nust.edu.pk')) {
      userSelector = 'username';
      passwordSelector = 'password';
      password = authenticationController.lmsPassword.value;
    } else if (value.contains('qalam.nust.edu.pk')) {
      userSelector = 'login';
      passwordSelector = 'password';
      password = authenticationController.qalamPassword.value;
    }
    if (userSelector == null || passwordSelector == null) return;
    webViewController?.runJavaScript('''
      (function () {
        var user = document.getElementById(${jsonEncode(userSelector)});
        var pass = document.getElementById(${jsonEncode(passwordSelector)});
        if (user && pass) {
          user.value = ${jsonEncode(authenticationController.id.value)};
          pass.value = ${jsonEncode(password)};
          user.dispatchEvent(new Event('input', { bubbles: true }));
          pass.dispatchEvent(new Event('input', { bubbles: true }));
        }
      })();
    ''');
  }

  void kuickPayQuery() {
    if (queryRan.value) return;
    webViewController?.runJavaScript(r'''
      (function () {
        var institution = document.getElementById('MainContent_cboInstitution');
        var searchBy = document.getElementById('MainContent_cboSearchBy');
        if (institution) {
          institution.value = '04490';
          institution.dispatchEvent(new Event('change', { bubbles: true }));
        }
        if (searchBy) {
          searchBy.value = 'RegistrationNumber';
          searchBy.dispatchEvent(new Event('change', { bubbles: true }));
        }
      })();
    ''');
    queryRan.value = true;
  }

  bool shouldPreventNavigation(String value) =>
      !PortalUrlClassifier.isAllowedPage(value);

  String _formatUrl(String value) {
    final host = Uri.tryParse(value)?.host.toLowerCase() ?? '';
    if (host.contains('lms.nust.edu.pk')) return 'LMS Portal';
    if (host.contains('qalam.nust.edu.pk')) return 'Qalam Portal';
    if (host.contains('kuickpay.com')) return 'Fee Portal';
    return host.isEmpty ? 'Portal' : host;
  }

  void toggleAppBar() => isAppBarExpanded.toggle();

  @override
  void onClose() {
    _cancelLoadTimers();
    _connectionSubscription?.cancel();
    super.onClose();
  }
}
