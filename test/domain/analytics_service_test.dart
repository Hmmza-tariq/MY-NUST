import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/services/analytics_service.dart';
import 'package:nust/app/controllers/app_update_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingAnalytics implements AnalyticsBackend {
  final events = <(String, Map<String, Object>)>[];
  final properties = <String, String>{};
  final screens = <String>[];
  final consentCalls = <bool>[];
  int resets = 0;
  bool failEvents = false;
  bool failEnable = false;
  @override
  Future<void> consent(bool enabled) async {
    consentCalls.add(enabled);
    if (enabled && failEnable) throw StateError('unavailable');
  }

  @override
  Future<void> event(String name, Map<String, Object> parameters) async {
    if (failEvents) throw StateError('unavailable');
    events.add((name, parameters));
  }

  @override
  Future<void> property(String name, String value) async {
    properties[name] = value;
  }

  @override
  Future<void> screen(String name) async {
    screens.add(name);
  }

  @override
  Future<void> reset() async {
    resets++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingAnalytics backend;
  late AnalyticsService analytics;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    backend = RecordingAnalytics();
    analytics = AnalyticsService(backend: backend);
    await analytics.initialize();
  });
  test('no SDK events, properties or screens before opt-in; decline persists',
      () async {
    expect(analytics.needsConsent, true);
    analytics.featureOpen(featureName: 'qalam', source: 'home');
    analytics.screen('qalam_webview');
    analytics.property('university', 'nust');
    await analytics.settled;
    expect(backend.events, isEmpty);
    expect(backend.screens, isEmpty);
    expect(backend.properties, isEmpty);
    await analytics.setEnabled(false);
    expect(analytics.needsConsent, false);
    expect(backend.consentCalls, everyElement(false));
    final next = AnalyticsService(backend: backend);
    await next.initialize();
    expect(next.enabled.value, false);
    expect(next.needsConsent, false);
  });
  test(
      'opt-in emits one cold launch, fixed user properties and booleans as strings',
      () async {
    analytics.launchSource('notification');
    analytics.property('portal_connected', 'true');
    analytics.property('university', 'nust');
    analytics.property('student_id', 'unsafe');
    await analytics.setEnabled(true);
    analytics.recordLaunch();
    analytics.lifecycle(AppLifecycleState.resumed);
    analytics.featureOpen(featureName: 'qalam', source: 'home');
    await analytics.settled;
    expect(backend.events.where((e) => e.$1 == 'app_open').length, 1);
    expect(backend.events.first.$2,
        {'launch_source': 'notification', 'portal_connected': 'true'});
    expect(
        backend.properties, {'portal_connected': 'true', 'university': 'nust'});
    expect(backend.events.last.$1, 'feature_open');
    expect(backend.events.last.$2, {'feature_name': 'qalam', 'source': 'home'});
  });
  test('withdrawal stops events immediately, drops queued events and resets ID',
      () async {
    await analytics.setEnabled(true);
    await analytics.settled;
    backend.events.clear();
    analytics.featureOpen(featureName: 'lms', source: 'home');
    final revoked = analytics.setEnabled(false);
    analytics.featureOpen(featureName: 'qalam', source: 'home');
    await revoked;
    await analytics.settled;
    expect(backend.events, isEmpty);
    expect(backend.resets, 1);
    expect(backend.consentCalls.last, false);
    final next = AnalyticsService(backend: backend);
    await next.initialize();
    expect(next.enabled.value, false);
  });
  test(
      'rejects arbitrary fields, personal values, URLs and academic measurements',
      () {
    for (final forbidden in [
      'username',
      'password',
      'email',
      'cms_id',
      'gpa',
      'grade',
      'marks',
      'attendance',
      'invoice',
      'feedback_text',
      'url'
    ]) {
      expect(
          AnalyticsService.validate('feature_open',
              {'feature_name': 'lms', 'source': 'home', forbidden: 'unsafe'}),
          null);
    }
    expect(
        AnalyticsService.validate(
            'feature_open', {'feature_name': 'student@example.com'}),
        null);
    expect(AnalyticsService.validate('cgpa_calculate', {'semester_count': 3.5}),
        null);
    expect(AnalyticsService.validate('portal_open', {'logged_in': true}),
        {'logged_in': 'true'});
    expect(
        AnalyticsService.validate('update_click', {'update_id': 'student_123'}),
        null);
    expect(
        AnalyticsService.validate(
            'update_click', {'link_domain': 'qalam.nust.edu.pk'}),
        null);
    expect(AnalyticsService.validate('first_open', {}), null);
    expect(AnalyticsService.validate('custom_event', {}), null);
  });
  test('schema covers all 36 events and follows Firebase naming and limits',
      () {
    expect(AnalyticsService.schema.length, 36);
    for (final event in AnalyticsService.schema.entries) {
      expect(event.key, matches(RegExp(r'^[a-z][a-z0-9_]{0,39}$')));
      expect(event.value.length, lessThanOrEqualTo(25));
      for (final key in event.value.keys) {
        expect(key, matches(RegExp(r'^[a-z][a-z0-9_]{0,39}$')));
      }
    }
  });
  test(
      'banner impression throttles and optional backend failures do not break app',
      () async {
    await analytics.setEnabled(true);
    await analytics.settled;
    backend.events.clear();
    analytics.bannerView();
    analytics.bannerView();
    await analytics.settled;
    expect(backend.events.where((e) => e.$1 == 'cred_banner_view').length, 1);
    backend.failEvents = true;
    analytics.featureOpen(featureName: 'settings', source: 'home');
    await analytics.settled;
    backend.failEvents = false;
    analytics.featureOpen(featureName: 'about', source: 'home');
    await analytics.settled;
    expect(backend.events.last.$1, 'feature_open');
  });
  test('failed opt-in stays disabled', () async {
    backend.failEnable = true;
    expect(await analytics.setEnabled(true), false);
    expect(analytics.enabled.value, false);
    expect(backend.consentCalls.last, false);
    analytics.featureOpen(featureName: 'lms', source: 'home');
    await analytics.settled;
    expect(backend.events, isEmpty);
  });
  test('only fixed screen names pass, raw portal paths never pass', () async {
    await analytics.setEnabled(true);
    await analytics.settled;
    analytics.screen('/web?url=https://qalam.nust.edu.pk/student/123');
    analytics.screen('qalam_webview');
    await analytics.settled;
    expect(backend.screens, ['qalam_webview']);
  });
  test(
      'reminders repeat after 24h and a different version can prompt immediately',
      () {
    final now = DateTime.utc(2026, 11, 9);
    expect(UpdateReminderPolicy.shouldPrompt(now: now, version: 40), true);
    expect(
        UpdateReminderPolicy.shouldPrompt(
            now: now,
            version: 40,
            lastVersion: 40,
            lastPrompt: now.subtract(const Duration(hours: 23))),
        false);
    expect(
        UpdateReminderPolicy.shouldPrompt(
            now: now,
            version: 40,
            lastVersion: 40,
            lastPrompt: now.subtract(const Duration(hours: 24))),
        true);
    expect(
        UpdateReminderPolicy.shouldPrompt(
            now: now, version: 41, lastVersion: 40, lastPrompt: now),
        true);
    expect(
        UpdateReminderPolicy.shouldPrompt(
            now: now,
            version: 40,
            lastVersion: 40,
            lastPrompt: now.add(const Duration(hours: 1))),
        false);
  });
}
