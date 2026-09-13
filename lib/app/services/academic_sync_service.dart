import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/database_controller.dart';
import '../data/academic_dashboard.dart';
import '../domain/portal/portal_endpoints.dart';
import '../domain/portal/portal_snapshot_parser.dart';
import '../modules/Authentication/controllers/authentication_controller.dart';

/// Runs a small, sequential, read-only portal sync using the credentials that
/// the student explicitly saved for portal autofill.
class AcademicSyncService extends GetxService with WidgetsBindingObserver {
  final DatabaseController _database = Get.find();
  final AuthenticationController _authentication = Get.find();

  final data = const AcademicDashboardData().obs;
  final isSyncing = false.obs;
  final statusText = 'Not synced yet'.obs;
  final qalamAuthenticated = false.obs;
  final qalamAttempted = false.obs;
  final automaticEnabled = false.obs;
  final connectionBannerHidden = false.obs;
  final credentialsRejected = false.obs;
  DateTime? _lastOpenSync;
  bool _cancelled = false;
  bool _hadErrors = false;
  final Set<String> _failedPortals = {};
  bool _qalamSignInRejected = false;
  Completer<void>? _syncDone;

  WebViewController? _controller;
  Completer<void>? _portalCompleter;
  String _portal = '';
  bool _submittedLogin = false;
  final List<String> _pendingUrls = [];
  final Set<String> _visitedUrls = {};
  Timer? _timeout;

  @override
  void onInit() {
    super.onInit();
    reloadCache();
    automaticEnabled.value = _database.getAcademicAutoSync();
    connectionBannerHidden.value = _database.getConnectionBannerHidden();
    // Existing automatic-sync opt-in also enables its required autofill gate.
    if (automaticEnabled.value) _authentication.toggleAutofill(true);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> setAutomaticSync(bool enabled) async {
    await _authentication.toggleAutofill(enabled);
    automaticEnabled.value = enabled;
    await _database.setAcademicAutoSync(enabled);
    if (!enabled) {
      _cancelled = true;
      _finishPortal();
    }
  }

  Future<void> hideConnectionBanner() async {
    await _database.setConnectionBannerHidden(true);
    connectionBannerHidden.value = true;
  }

  Future<void> saveConnection(
      String id, String lmsPassword, String qalamPassword) async {
    // Finish any attempt using the old password before starting the new one.
    _cancelled = true;
    _finishPortal();
    if (isSyncing.value) await _syncDone?.future;
    await _authentication.setCredentials(id, lmsPassword, qalamPassword);
    await setAutomaticSync(true);
    credentialsRejected.value = false;
    _lastOpenSync = null;
  }

  Future<void> syncOnOpen() async {
    if (!automaticEnabled.value || !canAutoSync || isSyncing.value) return;
    final now = DateTime.now();
    // Avoid repeated authentication when a file picker/dialog briefly resumes
    // the app. Cold launches always sync; returning after a minute syncs again.
    if (_lastOpenSync != null &&
        now.difference(_lastOpenSync!).inSeconds < 60) {
      return;
    }
    _lastOpenSync = now;
    await syncSavedPortals();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncOnOpen();
  }

  bool get canAutoSync =>
      _authentication.isAutofillEnabled.value &&
      _authentication.id.value.trim().isNotEmpty &&
      (_authentication.qalamPassword.value.isNotEmpty ||
          _authentication.lmsPassword.value.isNotEmpty);

  bool get canSyncQalam =>
      _authentication.isAutofillEnabled.value &&
      _authentication.id.value.trim().isNotEmpty &&
      _authentication.qalamPassword.value.isNotEmpty;

  void reloadCache() {
    data.value = AcademicDashboardData.fromMap(
      _database.getAcademicDashboard(),
    );
  }

  Future<void> syncSavedPortals() async {
    if (isSyncing.value) return;
    if (!canAutoSync) {
      statusText.value =
          'Enable portal connection and save your student ID and password in Settings.';
      return;
    }
    _cancelled = false;
    _hadErrors = false;
    _failedPortals.clear();
    _qalamSignInRejected = false;
    credentialsRejected.value = false;
    _syncDone = Completer<void>();
    isSyncing.value = true;
    statusText.value = 'Connecting securely…';
    try {
      qalamAttempted.value = true;
      qalamAuthenticated.value = false;
      if (_authentication.qalamPassword.value.isNotEmpty) {
        await _syncPortal('qalam', PortalEndpoints.qalam);
      }
      if (!_cancelled && _authentication.lmsPassword.value.isNotEmpty) {
        await _syncPortal('lms', PortalEndpoints.lms);
      }
      statusText.value = _cancelled
          ? 'Portal connection paused. Saved data is kept.'
          : credentialsRejected.value
              ? '${_qalamSignInRejected ? 'Qalam' : 'LMS'} rejected the saved login. Check your ID/password in Settings. Cached data is kept.'
              : !qalamAuthenticated.value
                  ? _authentication.qalamPassword.value.isEmpty
                      ? 'Qalam password is not saved. Add it in Settings.'
                      : _qalamSignInRejected
                          ? 'Qalam sign-in failed. Update its saved password in Settings.'
                          : 'Could not reach Qalam. Cached summaries are kept.'
                  : _hadErrors
                      ? '${_failedPortals.map((p) => p == 'qalam' ? 'Qalam' : 'LMS').join(' and ')} could not fully sync. Cached summaries are kept. Open the official portal or retry.'
                      : 'Sync complete';
    } catch (error) {
      debugPrint('Background academic sync stopped: $error');
      statusText.value = 'Open a portal to finish connecting';
    } finally {
      _timeout?.cancel();
      isSyncing.value = false;
      await _database.setData('academicLastStatus', statusText.value);
      reloadCache();
      _syncDone?.complete();
    }
  }

  Future<void> disconnect() async {
    _cancelled = true;
    _finishPortal();
    if (isSyncing.value) await _syncDone?.future;
    await setAutomaticSync(false);
    await _authentication.setCredentials('', '', '');
    await WebViewCookieManager().clearCookies();
    await _database
        .saveAcademicDashboard(const AcademicDashboardData().toMap());
    await _database.setData('academicLastStatus', 'Not connected');
    qalamAttempted.value = false;
    qalamAuthenticated.value = false;
    credentialsRejected.value = false;
    statusText.value = 'Not connected';
    reloadCache();
  }

  Future<void> _syncPortal(String portal, String url) async {
    _portal = portal;
    _submittedLogin = false;
    _pendingUrls.clear();
    _visitedUrls.clear();
    _portalCompleter = Completer<void>();
    statusText.value = 'Syncing ${portal == 'qalam' ? 'Qalam' : 'LMS'}…';

    final controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (identical(_controller, controller)) _onPageFinished(url);
        },
        onWebResourceError: (error) {
          if (identical(_controller, controller) &&
              error.isForMainFrame != false) {
            _hadErrors = true;
            _failedPortals.add(_portal);
            _finishPortal();
          }
        },
      ));
    _controller = controller;
    _timeout = Timer(const Duration(seconds: 45), _onTimeout);
    await controller.loadRequest(Uri.parse(url));
    await _portalCompleter!.future;
  }

  Future<void> _onPageFinished(String url) async {
    final controller = _controller;
    if (controller == null) return;
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 45), _onTimeout);
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? '';
    final isLogin = path.contains('login') || path.contains('signin');
    if (isLogin) {
      if (_submittedLogin) {
        final markup = _javascriptString(
            await controller.runJavaScriptReturningResult(
                'document.documentElement.outerHTML'));
        if (!loginWasRejected(markup)) {
          return; // Duplicate callbacks are not failed logins.
        }
        _hadErrors = true;
        credentialsRejected.value = true;
        if (_portal == 'qalam') _qalamSignInRejected = true;
        statusText.value =
            '${_portal == 'qalam' ? 'Qalam' : 'LMS'} sign-in failed. Update the saved credentials.';
        _finishPortal();
        return;
      }
      _submittedLogin = true;
      await _submitSavedLogin();
      return;
    }

    if (_portal == 'qalam') {
      qalamAuthenticated.value = true;
    }

    final normalizedUrl = uri?.replace(fragment: '').toString() ?? url;
    if (!_visitedUrls.add(normalizedUrl)) return;
    try {
      if (path.startsWith('/student/results')) {
        await controller.runJavaScript(r'''
          (function() {
            var tab = Array.from(document.querySelectorAll('a,button')).find(function(e) {
              return /previous courses/i.test(e.textContent || '');
            });
            if (tab) tab.click();
          })();
        ''');
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
      final result = await controller.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      );
      final markup = _javascriptString(result);
      if (!identical(_controller, controller)) return;
      final updated = PortalSnapshotParser.merge(
        current: data.value,
        url: url,
        markup: markup,
      );
      await _database.saveAcademicDashboard(updated.toMap());
      data.value = updated;
      await _discoverRelevantPages();
    } catch (error) {
      _hadErrors = true;
      _failedPortals.add(_portal);
      debugPrint('Academic page capture failed: $error');
    }
    await _openNextPageOrFinish();
  }

  static bool loginWasRejected(String markup) {
    final document = html.parse(markup);
    for (final element in document.querySelectorAll('script,style')) {
      element.remove();
    }
    return RegExp(
      r'(wrong login/password|invalid (?:login|username|password|credentials)|incorrect (?:login|username|password)|authentication failed|login failed)',
      caseSensitive: false,
    ).hasMatch(document.body?.text ?? '');
  }

  Future<void> _discoverRelevantPages() async {
    if (_portal == 'qalam') {
      if (_visitedUrls.length == 1) {
        _pendingUrls.addAll(const [
          'https://qalam.nust.edu.pk/student/attendance',
          'https://qalam.nust.edu.pk/student/class/schedule',
          'https://qalam.nust.edu.pk/student/invoices',
          'https://qalam.nust.edu.pk/student/messinvoices',
          'https://qalam.nust.edu.pk/student/results/',
        ]);
      }
      // Qalam contains other links with "schedule" in their names, including
      // enrolment windows. They are deliberately not crawled as class data.
      return;
    }
    final result = await _controller?.runJavaScriptReturningResult(r'''
      JSON.stringify(Array.from(document.querySelectorAll('a[href]')).map(function (a) {
        return { text: (a.innerText || a.getAttribute('aria-label') || '').trim(), url: a.href };
      }).filter(function (item) {
        var value = (item.text + ' ' + item.url).toLowerCase();
        return /attendance|time.?table|schedule|invoice|challan|assignment|quiz|deadline|calendar|(?:^|\W)fee(?:\W|$)/.test(value);
      }).slice(0, 16))
    ''');
    if (result == null) return;
    final raw = _javascriptString(result);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return;
    for (final item in decoded.whereType<Map>()) {
      final candidate = Uri.tryParse(item['url']?.toString() ?? '');
      if (candidate == null || candidate.scheme != 'https') continue;
      final allowedHost = candidate.host == 'lms.nust.edu.pk';
      final normalized = candidate.replace(fragment: '').toString();
      if (allowedHost &&
          !_visitedUrls.contains(normalized) &&
          !_pendingUrls.contains(normalized)) {
        _pendingUrls.add(normalized);
      }
    }
  }

  Future<void> _openNextPageOrFinish() async {
    if (_pendingUrls.isEmpty || _visitedUrls.length >= 8) {
      _finishPortal();
      return;
    }
    final next = _pendingUrls.removeAt(0);
    await _controller?.loadRequest(Uri.parse(next));
  }

  Future<void> _submitSavedLogin() async {
    final id = jsonEncode(_authentication.id.value);
    final password = jsonEncode(_portal == 'qalam'
        ? _authentication.qalamPassword.value
        : _authentication.lmsPassword.value);
    final userSelector = _portal == 'qalam' ? 'login' : 'username';
    await _controller?.runJavaScript('''
      (function () {
        var attempts = 0;
        function fillAndSubmit() {
          var user = document.getElementById('$userSelector');
          var pass = document.getElementById('password');
          if (!user || !pass) {
            if (++attempts < 5) setTimeout(fillAndSubmit, 250);
            return;
          }
          var setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
          setter.call(user, $id);
          setter.call(pass, $password);
          ['input', 'change'].forEach(function (name) {
            user.dispatchEvent(new Event(name, { bubbles: true }));
            pass.dispatchEvent(new Event(name, { bubbles: true }));
          });
          setTimeout(function () {
            var form = pass.form || user.form;
            var button = form && form.querySelector('button[type="submit"], input[type="submit"]');
            if (button) button.click(); else if (form) form.submit();
          }, 350);
        }
        fillAndSubmit();
      })();
    ''');
  }

  String _javascriptString(Object value) {
    if (value is! String) return value.toString();
    if (value.startsWith('"')) {
      try {
        return jsonDecode(value) as String;
      } catch (_) {}
    }
    return value;
  }

  void _finishPortal() {
    _timeout?.cancel();
    _controller = null;
    final completer = _portalCompleter;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  void _onTimeout() {
    _hadErrors = true;
    _failedPortals.add(_portal);
    _finishPortal();
  }

  @override
  void onClose() {
    _timeout?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
