import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AnalyticsBackend {
  Future<void> consent(bool enabled);
  Future<void> reset();
  Future<void> event(String name, Map<String, Object> parameters);
  Future<void> property(String name, String value);
  Future<void> screen(String name);
}

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalytics get _sdk => FirebaseAnalytics.instance;
  @override
  Future<void> consent(bool enabled) async {
    // Disable before changing consent; advertising is always denied.
    await _sdk.setAnalyticsCollectionEnabled(false);
    await _sdk.setConsent(
        analyticsStorageConsentGranted: enabled,
        adStorageConsentGranted: false,
        adUserDataConsentGranted: false,
        adPersonalizationSignalsConsentGranted: false);
    await _sdk.setUserProperty(name: 'allow_personalized_ads', value: 'false');
    if (enabled) await _sdk.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> reset() => _sdk.resetAnalyticsData();
  @override
  Future<void> event(String name, Map<String, Object> parameters) =>
      name == 'share'
          ? _sdk.logShare(
              contentType: 'app', itemId: 'app_invite', method: 'system_share')
          : name == 'app_open'
              ? _sdk.logAppOpen(parameters: parameters)
              : _sdk.logEvent(name: name, parameters: parameters);
  @override
  Future<void> property(String name, String value) =>
      _sdk.setUserProperty(name: name, value: value);
  @override
  Future<void> screen(String name) =>
      _sdk.logScreenView(screenName: name, screenClass: name);
}

/// The only analytics entry point. No arbitrary strings or payloads reach Firebase.
class AnalyticsService {
  AnalyticsService({AnalyticsBackend? backend})
      : _backend = backend ?? FirebaseAnalyticsBackend();
  static final instance = AnalyticsService();
  static const consentKey = 'analytics_consent_v1';
  final AnalyticsBackend _backend;
  final enabled = ValueNotifier<bool>(false);
  SharedPreferences? _prefs;
  Future<void> _queue = Future.value();
  String _launchSource = 'direct';
  bool _opened = false;
  DateTime? _backgroundAt;
  bool _bannerViewed = false;
  final Map<String, String> _properties = {};
  String? _screen;
  bool get needsConsent => _prefs != null && !_prefs!.containsKey(consentKey);
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final allowed = _prefs!.getBool(consentKey) == true;
    await _backend.consent(allowed);
    enabled.value = allowed;
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    return _queue = _queue.then((_) => operation()).catchError((Object error) {
      // Never print backend errors: they may contain payloads or identifiers.
      debugPrint('Optional analytics operation unavailable.');
    });
  }

  Future<void> get settled => _queue;
  Future<bool> setEnabled(bool allowed) async {
    enabled.value = false;
    var success = false;
    await _enqueue(() async {
      try {
        await _backend.consent(false);
        if (!allowed) await _backend.reset();
        if (_prefs == null || !await _prefs!.setBool(consentKey, allowed)) {
          throw StateError('Could not save analytics choice');
        }
        if (allowed) await _backend.consent(true);
        enabled.value = allowed;
        success = true;
      } catch (_) {
        // Fail closed even if a plugin or preference write fails partway through.
        await _backend.consent(false);
      }
    });
    if (enabled.value) {
      for (final entry in _properties.entries) {
        property(entry.key, entry.value);
      }
      if (_screen != null) screen(_screen!);
      recordLaunch();
    }
    return success;
  }

  void launchSource(String source) {
    if (!_opened &&
        const ['direct', 'notification', 'deep_link'].contains(source)) {
      _launchSource = source;
    }
  }

  void recordLaunch() {
    if (_opened || !enabled.value) return;
    _opened = true;
    appOpen(
        launchSource: _launchSource,
        portalConnected: _properties['portal_connected'] == 'true');
  }

  void lifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _backgroundAt = DateTime.now();
    if (state == AppLifecycleState.resumed &&
        _backgroundAt != null &&
        DateTime.now().difference(_backgroundAt!) >=
            const Duration(minutes: 30)) {
      _bannerViewed = false;
    }
  }

  void bannerView() {
    if (_bannerViewed || !enabled.value) return;
    _bannerViewed = true;
    credBannerView(placement: 'home');
  }

  static const properties = <String, List<String>>{
    'portal_connected': ['true', 'false'],
    'credentials_added': ['true', 'false'],
    'cred_banner_dismissed': ['true', 'false'],
    'theme_mode': ['dark', 'light', 'system'],
    'biometric_enabled': ['true', 'false'],
    'university': ['nust'],
  };
  void property(String name, String value) {
    if (!(properties[name]?.contains(value) ?? false)) return;
    _properties[name] = value;
    if (enabled.value) {
      unawaited(_enqueue(() async {
        if (enabled.value) await _backend.property(name, value);
      }));
    }
  }

  static const screens = <String>[
    "home",
    "lms_webview",
    "qalam_webview",
    "credentials",
    "gpa_planner_cgpa",
    "gpa_planner_sgpa",
    "sgpa_add_course_popup",
    "absolute_score_lecture",
    "absolute_score_lab",
    "absolute_score_both",
    "abs_add_assessment",
    "abs_result",
    "latest_updates",
    "settings",
    "help",
    "about"
  ];
  void screen(String name) {
    if (!screens.contains(name)) return;
    _screen = name;
    if (enabled.value) {
      unawaited(_enqueue(() async {
        if (enabled.value) await _backend.screen(name);
      }));
    }
  }

  static const schema = <String, Map<String, List<String>>>{
    "app_open": {
      "launch_source": ["direct", "notification", "deep_link"],
      "portal_connected": ["true", "false"]
    },
    "cred_banner_view": {
      "placement": ["home"]
    },
    "cred_banner_click": {
      "placement": ["home"]
    },
    "cred_banner_menu_open": {
      "placement": ["home"]
    },
    "cred_banner_dismiss": {
      "dismiss_type": ["dont_show_again"]
    },
    "credentials_save": {
      "status": ["success", "fail"],
      "error_type": ["invalid_credentials", "network", "portal_down", "other"],
      "source": ["banner", "settings", "gpa_sync"]
    },
    "feature_open": {
      "feature_name": [
        "lms",
        "qalam",
        "gpa_planner",
        "absolute_score",
        "latest_updates",
        "settings",
        "help",
        "about"
      ],
      "source": ["home", "side_menu", "settings", "notification"]
    },
    "portal_open": {
      "portal": ["lms", "qalam"],
      "logged_in": ["true", "false"],
      "load_time_ms": ["#number"]
    },
    "portal_error": {
      "portal": ["lms", "qalam"],
      "error_type": [
        "timeout",
        "network",
        "login_failed",
        "page_changed",
        "other"
      ]
    },
    "gpa_tab_switch": {
      "tab": ["cgpa", "sgpa"]
    },
    "cgpa_semester_add": {
      "semester_count": ["#number"]
    },
    "cgpa_semester_delete": {
      "semester_count": ["#number"]
    },
    "cgpa_calculate": {
      "semester_count": ["#number"],
      "input_method": ["manual", "qalam_sync", "from_sgpa"],
      "status": ["success", "validation_error"]
    },
    "cgpa_download_image": {
      "semester_count": ["#number"],
      "status": ["success", "permission_denied", "fail"]
    },
    "qalam_sync_start": {
      "source": ["gpa_planner"],
      "credentials_added": ["true", "false"]
    },
    "qalam_sync_complete": {
      "status": ["success", "fail"],
      "error_type": [
        "invalid_credentials",
        "network",
        "timeout",
        "parse_error",
        "other"
      ],
      "semesters_synced": ["#number"],
      "duration_ms": ["#number"]
    },
    "sgpa_course_add_click": {
      "course_count": ["#number"]
    },
    "sgpa_course_add": {
      "course_count": ["#number"],
      "credit_hours": ["#number"]
    },
    "sgpa_course_add_cancel": {
      "course_count": ["#number"]
    },
    "sgpa_course_delete": {
      "course_count": ["#number"]
    },
    "sgpa_calculate": {
      "course_count": ["#number"],
      "status": ["success", "validation_error"]
    },
    "sgpa_add_to_cgpa": {
      "course_count": ["#number"]
    },
    "abs_tab_switch": {
      "course_type": ["lecture", "lab", "both"]
    },
    "abs_assessment_add_click": {
      "course_type": ["lecture", "lab", "both"]
    },
    "abs_assessment_add": {
      "course_type": ["lecture", "lab", "both"],
      "assessment_type": ["quiz", "assignment", "mid", "final", "lab", "other"],
      "assessment_count": ["#number"]
    },
    "abs_result_view": {
      "course_type": ["lecture", "lab", "both"],
      "assessment_count": ["#number"]
    },
    "abs_result_done": {
      "course_type": ["lecture", "lab", "both"]
    },
    "abs_result_download": {
      "course_type": ["lecture", "lab", "both"],
      "status": ["success", "permission_denied", "fail"]
    },
    "update_click": {
      "update_id": ["#id"],
      "update_category": ["news", "event", "notice", "other"],
      "position": ["#number"],
      "link_domain": ["#domain"]
    },
    "setting_toggle": {
      "setting_name": ["dark_mode", "biometric_auth", "portal_connection"],
      "new_value": ["on", "off"]
    },
    "biometric_auth": {
      "status": ["success", "fail", "cancelled", "not_available"]
    },
    "help_open": {
      "source": ["home", "settings", "side_menu"]
    },
    "support_contact_click": {
      "channel": ["email", "whatsapp", "other"]
    },
    "feedback_submit": {
      "channel": ["in_app", "email"],
      "feedback_type": ["bug", "suggestion", "other (if available)"]
    },
    "share": {
      "method": ["system_share"],
      "content_type": ["app"],
      "item_id": ["app_invite"]
    },
    "play_store_click": {
      "source": ["about"],
      "intent": ["rate", "view"]
    }
  };

  /// Returns null for any unknown key, unsafe value, or out-of-contract payload.
  static Map<String, Object>? validate(
      String name, Map<String, Object?> input) {
    final spec = schema[name];
    if (spec == null || input.length > 25) return null;
    final out = <String, Object>{};
    for (final entry in input.entries) {
      if (entry.value == null) continue;
      final allowed = spec[entry.key];
      if (allowed == null) return null;
      final value = entry.value is bool ? entry.value.toString() : entry.value!;
      if (allowed.contains('#number')) {
        if (value is! int || value < 0 || value > 86400000) return null;
      } else if (allowed.contains('#id')) {
        // Only locally derived opaque IDs; never portal identifiers or headlines.
        if (value is! String ||
            !RegExp(r'^news_[0-9a-f]{16}$').hasMatch(value)) {
          return null;
        }
      } else if (allowed.contains('#domain')) {
        if (value is! String ||
            !const ['nust.edu.pk', 'www.nust.edu.pk'].contains(value)) {
          return null;
        }
      } else if (value is! String || !allowed.contains(value)) {
        return null;
      }
      out[entry.key] = value;
    }
    return out;
  }

  void _event(String name, Map<String, Object?> parameters) {
    if (!enabled.value) return;
    final safe = validate(name, parameters);
    if (safe == null) return;
    unawaited(_enqueue(() async {
      if (enabled.value) await _backend.event(name, safe);
    }));
  }

  void appOpen({String? launchSource, bool? portalConnected}) => _event(
      'app_open',
      {'launch_source': launchSource, 'portal_connected': portalConnected});
  void credBannerView({String? placement}) =>
      _event('cred_banner_view', {'placement': placement});
  void credBannerClick({String? placement}) =>
      _event('cred_banner_click', {'placement': placement});
  void credBannerMenuOpen({String? placement}) =>
      _event('cred_banner_menu_open', {'placement': placement});
  void credBannerDismiss({String? dismissType}) =>
      _event('cred_banner_dismiss', {'dismiss_type': dismissType});
  void credentialsSave({String? status, String? errorType, String? source}) =>
      _event('credentials_save',
          {'status': status, 'error_type': errorType, 'source': source});
  void featureOpen({String? featureName, String? source}) =>
      _event('feature_open', {'feature_name': featureName, 'source': source});
  void portalOpen({String? portal, bool? loggedIn, int? loadTimeMs}) => _event(
      'portal_open',
      {'portal': portal, 'logged_in': loggedIn, 'load_time_ms': loadTimeMs});
  void portalError({String? portal, String? errorType}) =>
      _event('portal_error', {'portal': portal, 'error_type': errorType});
  void gpaTabSwitch({String? tab}) => _event('gpa_tab_switch', {'tab': tab});
  void cgpaSemesterAdd({int? semesterCount}) =>
      _event('cgpa_semester_add', {'semester_count': semesterCount});
  void cgpaSemesterDelete({int? semesterCount}) =>
      _event('cgpa_semester_delete', {'semester_count': semesterCount});
  void cgpaCalculate(
          {int? semesterCount, String? inputMethod, String? status}) =>
      _event('cgpa_calculate', {
        'semester_count': semesterCount,
        'input_method': inputMethod,
        'status': status
      });
  void cgpaDownloadImage({int? semesterCount, String? status}) => _event(
      'cgpa_download_image',
      {'semester_count': semesterCount, 'status': status});
  void qalamSyncStart({String? source, bool? credentialsAdded}) => _event(
      'qalam_sync_start',
      {'source': source, 'credentials_added': credentialsAdded});
  void qalamSyncComplete(
          {String? status,
          String? errorType,
          int? semestersSynced,
          int? durationMs}) =>
      _event('qalam_sync_complete', {
        'status': status,
        'error_type': errorType,
        'semesters_synced': semestersSynced,
        'duration_ms': durationMs
      });
  void sgpaCourseAddClick({int? courseCount}) =>
      _event('sgpa_course_add_click', {'course_count': courseCount});
  void sgpaCourseAdd({int? courseCount, int? creditHours}) => _event(
      'sgpa_course_add',
      {'course_count': courseCount, 'credit_hours': creditHours});
  void sgpaCourseAddCancel({int? courseCount}) =>
      _event('sgpa_course_add_cancel', {'course_count': courseCount});
  void sgpaCourseDelete({int? courseCount}) =>
      _event('sgpa_course_delete', {'course_count': courseCount});
  void sgpaCalculate({int? courseCount, String? status}) =>
      _event('sgpa_calculate', {'course_count': courseCount, 'status': status});
  void sgpaAddToCgpa({int? courseCount}) =>
      _event('sgpa_add_to_cgpa', {'course_count': courseCount});
  void absTabSwitch({String? courseType}) =>
      _event('abs_tab_switch', {'course_type': courseType});
  void absAssessmentAddClick({String? courseType}) =>
      _event('abs_assessment_add_click', {'course_type': courseType});
  void absAssessmentAdd(
          {String? courseType, String? assessmentType, int? assessmentCount}) =>
      _event('abs_assessment_add', {
        'course_type': courseType,
        'assessment_type': assessmentType,
        'assessment_count': assessmentCount
      });
  void absResultView({String? courseType, int? assessmentCount}) => _event(
      'abs_result_view',
      {'course_type': courseType, 'assessment_count': assessmentCount});
  void absResultDone({String? courseType}) =>
      _event('abs_result_done', {'course_type': courseType});
  void absResultDownload({String? courseType, String? status}) => _event(
      'abs_result_download', {'course_type': courseType, 'status': status});
  void updateClick(
          {String? updateId,
          String? updateCategory,
          int? position,
          String? linkDomain}) =>
      _event('update_click', {
        'update_id': updateId,
        'update_category': updateCategory,
        'position': position,
        'link_domain': linkDomain
      });
  void settingToggle({String? settingName, String? newValue}) => _event(
      'setting_toggle', {'setting_name': settingName, 'new_value': newValue});
  void biometricAuth({String? status}) =>
      _event('biometric_auth', {'status': status});
  void helpOpen({String? source}) => _event('help_open', {'source': source});
  void supportContactClick({String? channel}) =>
      _event('support_contact_click', {'channel': channel});
  void feedbackSubmit({String? channel, String? feedbackType}) => _event(
      'feedback_submit', {'channel': channel, 'feedback_type': feedbackType});
  void share({String? method, String? contentType, String? itemId}) => _event(
      'share',
      {'method': method, 'content_type': contentType, 'item_id': itemId});
  void playStoreClick({String? source, String? intent}) =>
      _event('play_store_click', {'source': source, 'intent': intent});
}
