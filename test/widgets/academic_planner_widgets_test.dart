import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/modules/widgets/academic_sync_sheet.dart';
import 'package:nust/app/modules/widgets/gpa_impact_summary.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final width in [320.0, 800.0]) {
      testWidgets('planner panels $brightness at $width with large text',
          (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final scheme = ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: brightness);
        Widget host(Widget child) => MaterialApp(
            theme: ThemeData(colorScheme: scheme, useMaterial3: true),
            home: MediaQuery(
                data: MediaQueryData(
                    size: Size(width, 1200),
                    textScaler: const TextScaler.linear(1.5)),
                child: Scaffold(
                    body: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: child)))));
        await tester.pumpWidget(host(const GpaImpactSummary(
            sgpa: 3.39,
            termLabel: 'Semester 9 (spring-2026)',
            currentCgpa: 3.10,
            projectedCgpa: 3.15)));
        expect(find.text('Semester SGPA'), findsOneWidget);
        expect(find.text('CGPA projection'), findsOneWidget);
        expect(
            tester
                .widget<ColoredBox>(
                    find.byKey(const ValueKey('semester-sgpa-panel')))
                .color,
            scheme.tertiaryContainer);
        expect(tester.takeException(), isNull);
        var imported = false;
        await tester.pumpWidget(host(AcademicSyncSheet(
            termCount: 13,
            courseCount: 61,
            busy: false,
            onReset: () {},
            onSync: () => imported = true,
            onOpenPortal: () {})));
        expect(find.byType(Card), findsNothing);
        expect(find.text('Import saved results'), findsNothing);
        expect(find.text('Sync with Qalam'), findsOneWidget);
        await tester.tap(find.text('Sync with Qalam'));
        expect(imported, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('SGPA panel scrolls out of the course list', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ListView(children: [
      const GpaImpactSummary(
          sgpa: 3.39,
          termLabel: 'Semester 9',
          currentCgpa: 3.1,
          projectedCgpa: 3.15),
      for (var i = 0; i < 20; i++)
        SizedBox(height: 100, child: Text('Course $i')),
    ]))));
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Semester SGPA').hitTestable(), findsNothing);
  });
}
