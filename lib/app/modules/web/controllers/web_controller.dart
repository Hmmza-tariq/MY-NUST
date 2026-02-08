import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/controllers/internet_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';
import 'package:nust/app/resources/color_manager.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/download_controller.dart';

class WebController extends GetxController {
  static const platform = MethodChannel('com.hexagone.mynust/webview');

  String url = Get.parameters['url'] ?? '';
  var isLoading = true.obs;
  var isError = false.obs;
  var initError = false.obs;
  var errorMessage = "Failed to load webpage".obs;
  var canPop = false.obs;
  var queryRan = false.obs;
  WebViewController? webViewController;
  var isWebViewInitialized = false.obs;
  var status = 0.obs;
  var pageTitle = ''.obs;
  var currentUrl = ''.obs;
  var isAppBarExpanded = false.obs;
  var sslErrorDetected = false.obs;
  var emptyPageDetected = false.obs;
  var sslDialogShown = false;
  AuthenticationController authenticationController = Get.find();
  InternetController internetController = Get.find();
  final DownloadController downloadController = Get.put(DownloadController());
  // final cookieManager = WebviewCookieManager();
  ThemeController themeController = Get.find();
  DatabaseController databaseController = Get.find();

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

  void initializeWebView() async {
    try {
      // Clear SSL preferences on Android
      if (Platform.isAndroid) {
        try {
          await platform.invokeMethod('clearSslPreferences');
          debugPrint('Cleared SSL preferences');
        } catch (e) {
          debugPrint('Could not clear SSL preferences: $e');
        }
      }

      if (url.isEmpty) {
        await databaseController.getData('url').then((value) {
          url = value;
        });
      }

      if (url.isEmpty) {
        initError.value = true;
        errorMessage.value = "No URL provided";
        isLoading.value = false;
        return;
      }
      final String userAgent = Platform.isAndroid
          ? 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
          : 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';

      final wvc = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(ColorManager.background1)
        ..setUserAgent(userAgent)
        ..enableZoom(false)
        // Add JavaScript channel for error handling
        ..addJavaScriptChannel(
          'ErrorHandler',
          onMessageReceived: (JavaScriptMessage message) {
            debugPrint('JS Error: ${message.message}');
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int newProgress) {
              status.value = newProgress;
            },
            onPageStarted: (String url) {
              isLoading.value = true;
              initError.value = false;
              currentUrl.value = _formatUrl(url);
              sslDialogShown = false; // Reset dialog flag for new page
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              debugPrint('Page finished loading: $url');
              isLoading.value = false;
              isError.value = false;
              initError.value = false;
              currentUrl.value = _formatUrl(url);

              // Get page title safely
              try {
                final title = await webViewController?.getTitle();
                pageTitle.value = title ?? 'NUST Portal';
                debugPrint('Page title: $title');
              } catch (e) {
                debugPrint('Error getting page title: $e');
                pageTitle.value = 'NUST Portal';
              }

              // Check if page actually has content
              try {
                final html =
                    await webViewController?.runJavaScriptReturningResult(
                        'document.body.innerHTML.length');
                debugPrint('Page content length: $html characters');

                final contentLength = int.tryParse(html.toString()) ?? 0;

                if (contentLength == 0) {
                  debugPrint(
                      'WARNING: Page appears to be empty despite onPageFinished');
                  emptyPageDetected.value = true;

                  // Wait longer to see if it's just a temporary state or real error
                  // Many pages initially load empty then populate
                  Future.delayed(const Duration(seconds: 2), () async {
                    if (!emptyPageDetected.value)
                      return; // Content loaded since then

                    // Double-check content length after delay
                    try {
                      final recheckHtml =
                          await webViewController?.runJavaScriptReturningResult(
                              'document.body.innerHTML.length');
                      final recheckLength =
                          int.tryParse(recheckHtml.toString()) ?? 0;

                      if (recheckLength == 0) {
                        debugPrint(
                            'Page still empty after 2 seconds - showing error dialog');
                        _showSslErrorDialog();
                      } else {
                        debugPrint(
                            'Page loaded successfully after delay: $recheckLength characters');
                        emptyPageDetected.value = false;
                      }
                    } catch (e) {
                      debugPrint('Error rechecking page content: $e');
                    }
                  });
                } else {
                  emptyPageDetected.value = false;
                  sslErrorDetected.value = false;
                }
              } catch (e) {
                debugPrint('Could not check page content: $e');
              }

              // Inject error handling JavaScript
              try {
                await webViewController?.runJavaScript('''
                  // Override console.error to send to Flutter
                  (function() {
                    var originalError = console.error;
                    console.error = function() {
                      try {
                        ErrorHandler.postMessage(Array.from(arguments).join(' '));
                      } catch(e) {}
                      originalError.apply(console, arguments);
                    };
                    
                    // Add global error handler to catch uncaught errors
                    window.addEventListener('error', function(e) {
                      try {
                        ErrorHandler.postMessage('Global Error: ' + e.message + ' at ' + e.filename + ':' + e.lineno);
                      } catch(err) {}
                      return false;
                    });
                  })();
                ''');
              } catch (e) {
                debugPrint('Error injecting JavaScript: $e');
              }

              runJavaScriptOnPageLoad(url);

              // Note: Cookie management temporarily disabled due to package compatibility
              // If you need cookie support, consider using webview_flutter's built-in WebViewCookieManager

              // Apply CSS fixes to prevent display issues
              applyRenderingFixes();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint(
                  'WebView Error: ${error.errorCode} - ${error.description} - Type: ${error.errorType} - isMainFrame: ${error.isForMainFrame}');

              // Handle SSL errors - only show error if it's for the main frame and critical
              if (error.errorCode == -2 ||
                  error.errorCode == -202 ||
                  error.description.toLowerCase().contains('ssl') ||
                  error.description.toLowerCase().contains('certificate')) {
                debugPrint(
                    'SSL/Certificate error detected - Error code: ${error.errorCode}');
                sslErrorDetected.value = true;

                // Only show error for main frame SSL errors, and even then, just log it
                // Many university sites have SSL issues with sub-resources but work fine
                if (error.isForMainFrame ?? false) {
                  debugPrint(
                      'SSL error on main frame - allowing page to continue loading');
                  debugPrint(
                      'If page appears empty, user will be offered to open in external browser');
                }
                // Don't prevent loading for SSL errors on sub-resources
                return;
              }

              if (error.errorCode == -1 ||
                  error.errorType == WebResourceErrorType.hostLookup) {
                // Network related errors - only for main frame
                if (error.isForMainFrame ?? true) {
                  isError.value = true;
                  isLoading.value = false;
                }
              } else if (error.errorType ==
                      WebResourceErrorType.javaScriptExceptionOccurred ||
                  error.errorType ==
                      WebResourceErrorType.webContentProcessTerminated) {
                // Rendering or JavaScript errors - only for main frame
                if (error.isForMainFrame ?? true) {
                  initError.value = true;
                  errorMessage.value = "Rendering error: ${error.description}";
                  isLoading.value = false;
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) async {
              String url = request.url;

              if (await handleFileDownload(request)) {
                return NavigationDecision.prevent;
              }

              if (shouldPreventNavigation(url)) {
                debugPrint('Preventing navigation to $url');
                AppSnackbar.error(
                    message: 'Navigation to external sites is not allowed');
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        );

      // Set the controller after full configuration
      webViewController = wvc;
      isWebViewInitialized.value = true;

      // Android-specific configuration for SSL and mixed content
      if (Platform.isAndroid) {
        try {
          final androidController = wvc.platform as AndroidWebViewController;
          // Enable debugging to see detailed logs
          AndroidWebViewController.enableDebugging(true);
          // Allow mixed content (HTTP content in HTTPS pages)
          await androidController.setMediaPlaybackRequiresUserGesture(false);

          // Clear SSL preferences and cache to avoid cached failures
          try {
            await androidController.clearCache();
            debugPrint('Cleared WebView cache');
          } catch (e) {
            debugPrint('Could not clear cache: $e');
          }

          debugPrint('Android WebView configured with debugging enabled');
        } catch (e) {
          debugPrint('Error configuring Android WebView: $e');
        }
      }

      if (!internetController.isOnline.value) {
        isError.value = true;
        isLoading.value = false;
        internetController.noInternetDialog(reload);
      } else {
        wvc.loadRequest(Uri.parse(url));
        canPop.value = false;

        // Add timeout to detect stuck loading - increased to 45 seconds for slower connections
        Future.delayed(const Duration(seconds: 45), () {
          if (isLoading.value) {
            debugPrint('Loading timeout detected after 45 seconds');
            initError.value = true;
            errorMessage.value =
                "The page is taking too long to load.\n\nThis might be due to:\n• Slow network connection\n• Server not responding\n• SSL/Certificate problems\n\nTip: Try using your mobile data instead of WiFi, or vice versa.\n\nTap 'Try Again' to retry.";
            isLoading.value = false;
          }
        });
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
    final wvc = webViewController;
    if (wvc == null) return;

    wvc.runJavaScript('''
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
      // Extract cookies right before download (only when needed)
      await _extractCookiesForDownloads();
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
    final wvc = webViewController;
    if (wvc == null) {
      debugPrint('Cannot reload: WebViewController not initialized');
      return;
    }

    if (internetController.isOnline.value) {
      isLoading.value = true;
      initError.value = false;
      isError.value = false;

      if (await wvc.currentUrl() == null) {
        wvc.loadRequest(Uri.parse(url));
      } else {
        await wvc.reload();
      }

      // Add timeout for reload as well - increased to 45 seconds
      Future.delayed(const Duration(seconds: 45), () {
        if (isLoading.value) {
          debugPrint('Reload timeout detected after 45 seconds');
          initError.value = true;
          errorMessage.value =
              "The page is taking too long to load.\n\nThis might be due to:\n• Slow network connection\n• Server not responding\n• SSL/Certificate problems\n\nTip: Try using your mobile data instead of WiFi, or vice versa.\n\nTap 'Try Again' to retry.";
          isLoading.value = false;
        }
      });
    } else {
      isError.value = true;
      internetController.noInternetDialog(reload);
    }
  }

  void runJavaScriptOnPageLoad(String url) {
    final wvc = webViewController;
    if (wvc == null) return;

    if (url.contains("lms")) {
      wvc.runJavaScript('''
        // Set viewport
        var viewport = document.querySelector("meta[name=viewport]");
        if (viewport) {
          viewport.setAttribute("content", "width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes");
        } else {
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        
        // Add CSS to fit content to screen width
        var style = document.createElement('style');
        style.innerHTML = `
          body {
            width: 100% !important;
            max-width: 100vw !important;
            overflow-x: hidden !important;
          }
          
          .container, .container-fluid, #page {
            max-width: 100% !important;
            width: 100% !important;
            padding-left: 10px !important;
            padding-right: 10px !important;
          }
          
          img {
            max-width: 100% !important;
            height: auto !important;
          }
          
          table {
            max-width: 100% !important;
            overflow-x: auto !important;
            display: block !important;
          }
          
          iframe {
            max-width: 100% !important;
          }
          
          /* Fix for large header/logo */
          .navbar, .navbar-brand img {
            max-width: 100% !important;
            height: auto !important;
          }
        `;
        document.head.appendChild(style);
      ''');
    }

    if (authenticationController.isAutofillEnabled.value) {
      autoFillLoginDetails(url);
    } else if (url.contains("kuickpay")) {
      kuickPayQuery();
    }
  }

  void autoFillLoginDetails(String url) {
    final wvc = webViewController;
    if (wvc == null) return;

    if (url.contains("lms.nust.edu.pk")) {
      wvc.runJavaScript('''
        var username = document.getElementById('username');
        var password = document.getElementById('password');
        if (username && password) {
          username.value = '${authenticationController.id}';
          password.value = '${authenticationController.lmsPassword}';
        }
      ''');
    } else if (url.contains("qalam.nust.edu.pk")) {
      wvc.runJavaScript('''
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
    final wvc = webViewController;
    if (wvc == null || queryRan.value) {
      return;
    }
    wvc.runJavaScript('''
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
    final wvc = webViewController;
    if (wvc == null) return;

    for (var entry in settings.entries) {
      try {
        wvc.runJavaScript('window.navigator.${entry.key} = ${entry.value};');
      } catch (e) {
        debugPrint('Error setting ${entry.key}: $e');
      }
    }
  }

  String _formatUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('lms.nust.edu.pk')) {
        return 'LMS Portal';
      } else if (uri.host.contains('qalam.nust.edu.pk')) {
        return 'Qalam Portal';
      } else if (uri.host.contains('kuickpay.com')) {
        return 'Fee Portal';
      } else if (uri.host.contains('nust.edu.pk')) {
        return uri.host.replaceAll('.nust.edu.pk', '').toUpperCase();
      }
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  Future<void> goForward() async {
    final wvc = webViewController;
    if (wvc == null) return;

    if (await wvc.canGoForward()) {
      await wvc.goForward();
    }
  }

  void toggleAppBar() {
    isAppBarExpanded.value = !isAppBarExpanded.value;
  }

  Future<void> _extractCookiesForDownloads() async {
    // Only called right before a file download - not on every page load
    try {
      final wvc = webViewController;
      if (wvc == null) return;

      // Wrap in browser-level try-catch to prevent uncaught SecurityErrors
      final cookieString = await wvc
          .runJavaScriptReturningResult(
            '(function(){try{return document.cookie}catch(e){return ""}})()')
          .timeout(const Duration(seconds: 2));

      if (cookieString.toString().isNotEmpty &&
          cookieString.toString() != '""' &&
          cookieString.toString() != 'null') {
        String cleanCookieString =
            cookieString.toString().replaceAll('"', '').trim();

        if (cleanCookieString.isNotEmpty) {
          final List<Cookie> cookies = [];
          final cookiePairs = cleanCookieString.split(';');

          for (final pair in cookiePairs) {
            final parts = pair.trim().split('=');
            if (parts.length >= 2) {
              final cookie = Cookie(parts[0], parts.sublist(1).join('='));
              cookies.add(cookie);
            }
          }

          if (cookies.isNotEmpty) {
            downloadController.setCookies(cookies);
          }
        }
      }
    } catch (e) {
      // Silently fail - downloads will work without cookies in most cases
    }
  }

  void _showSslErrorDialog() {
    // Don't show multiple dialogs
    if ((Get.isDialogOpen ?? false) || sslDialogShown) return;

    sslDialogShown = true;

    Get.dialog(
      AlertDialog(
        title: const Text('Cannot Load Page',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This page failed to load due to SSL certificate issues.',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is a known issue with this website. The site works fine in regular web browsers.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'What would you like to do?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              sslDialogShown = false;
              reload(); // Try again
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              sslDialogShown = false;

              try {
                final uri = Uri.parse(url);
                debugPrint('Attempting to launch URL: $url');

                // Try launching directly without canLaunchUrl check
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );

                if (!launched) {
                  debugPrint('Failed to launch URL');
                  AppSnackbar.error(
                    message:
                        'Could not open browser. Please try manually: $url',
                  );
                }
              } catch (e) {
                debugPrint('Error launching URL: $e');
                AppSnackbar.error(
                  message: 'Error launching URL: $e',
                );
              }
            },
            child: const Text('Open in Browser'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              sslDialogShown = false;
              Get.back(); // Go back to previous screen
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
