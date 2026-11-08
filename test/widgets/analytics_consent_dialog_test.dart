import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/services/analytics_service.dart';
import 'package:nust/app/modules/widgets/analytics_consent_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/analytics_service_test.dart' show RecordingAnalytics;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'consent is optional and readable at 320px with large text in $brightness',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final backend = RecordingAnalytics();
      final service = AnalyticsService(backend: backend);
      await service.initialize();
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
          home: Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () =>
                          showAnalyticsConsent(context, service: service),
                      child: const Text('Open consent'))))));
      await tester.tap(find.text('Open consent'));
      await tester.pumpAndSettle();
      expect(find.text('Help improve My NUST?'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Enable analytics'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(service.enabled.value, false);
      expect(service.needsConsent, false);
      expect(backend.events, isEmpty);
      await tester.tap(find.text('Open consent'));
      await tester.pumpAndSettle();
      expect(find.text('Help improve My NUST?'), findsNothing);
    });
  }
}
