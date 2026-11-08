import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/services/analytics_service.dart';
import 'package:nust/app/modules/widgets/analytics_consent_dialog.dart';
import 'package:nust/app/modules/widgets/app_update_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/analytics_service_test.dart' show RecordingAnalytics;

void main() {
  late RecordingAnalytics backend;
  late AnalyticsService service;
  Future<void> initializeService() async {
    SharedPreferences.setMockInitialValues({});
    backend = RecordingAnalytics();
    service = AnalyticsService(backend: backend);
    await service.initialize();
  }

  Future<void> prompt(WidgetTester tester, {bool accessible = false}) async {
    await initializeService();
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(accessibleNavigation: accessible),
            child: child!),
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () =>
                        showAnalyticsConsent(context, service: service),
                    child: const Text('Ask'))))));
    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
  }

  testWidgets('five-second timeout closes without consent or events',
      (tester) async {
    await prompt(tester);
    expect(find.textContaining('Stays off unless enabled'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Help improve My NUST?'), findsNothing);
    expect(service.enabled.value, false);
    expect(service.needsConsent, false);
    expect(backend.events, isEmpty);
  });
  testWidgets('explicit enable is remembered', (tester) async {
    await prompt(tester);
    await tester.tap(find.text('Enable analytics'));
    await tester.pumpAndSettle();
    expect(service.enabled.value, true);
    expect(service.needsConsent, false);
    expect(backend.consentCalls.last, true);
  });
  testWidgets(
      'opening details cancels countdown and requires an explicit enable',
      (tester) async {
    await prompt(tester);
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Usage analytics'), findsOneWidget);
    expect(service.enabled.value, false);
    await tester.ensureVisible(find.text('Enable analytics'));
    await tester.tap(find.text('Enable analytics'));
    await tester.pumpAndSettle();
    expect(service.enabled.value, true);
  });
  testWidgets('accessible navigation omits the countdown', (tester) async {
    await prompt(tester, accessible: true);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Help improve My NUST?'), findsOneWidget);
    expect(find.textContaining('Closes in'), findsNothing);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(service.enabled.value, false);
  });
  testWidgets('backgrounding pauses countdown', (tester) async {
    await prompt(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Help improve My NUST?'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(service.enabled.value, false);
    expect(find.text('Help improve My NUST?'), findsNothing);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'compact cards and details fit narrow large-text layout in $brightness',
        (tester) async {
      await initializeService();
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!),
          home: Scaffold(
              body: SingleChildScrollView(
                  child: Column(children: [
            AnalyticsPreferenceTile(service: service),
            AppUpdateTile(
                checking: false,
                available: false,
                status: 'Checks on launch',
                onCheck: () {}),
          ])))));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Enable analytics'));
      await tester.pumpAndSettle();
      expect(find.text('What is shared with Google Firebase'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
    });
  }
}
