import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/data/academic_results.dart';
import 'package:nust/app/modules/widgets/academic_home_summary.dart';
import 'package:nust/app/modules/widgets/portal_sync_setup_dialog.dart';

void main() {
  for (final saved in [false, true]) {
    testWidgets(
        'connection banner offers correct action with saved credentials=$saved',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(320, 800), textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                  body: AcademicConnectionBanner(
                      hasCredentials: saved,
                      syncing: false,
                      onPressed: () => tapped = true)))));
      expect(find.text('Official CGPA'), findsNothing);
      await tester.tap(find.text(saved ? 'Sync stats' : 'Add credentials'));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('connection banner disables repeated sync without a spinner',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicConnectionBanner(
                hasCredentials: true,
                syncing: true,
                onPressed: () => tapped = true))));
    await tester.tap(find.text('Syncing…'));
    expect(tapped, isFalse);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('sync does not add a snapshot spinner or course invoice counts',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicHomeSummary(
                data: const AcademicDashboardData(
                    stats: AcademicStats(cgpa: 3.39)),
                syncing: true,
                onOpen: () {}))));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('unpaid challans'), findsNothing);
    expect(find.byIcon(Icons.dashboard_customize_outlined), findsOneWidget);
  });
  testWidgets('snapshot details remain accessible before first sync',
      (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicHomeSummary(
                data: const AcademicDashboardData(),
                syncing: false,
                onOpen: () => opened = true))));
    expect(find.text('Academic snapshot'), findsOneWidget);
    await tester.tap(find.byTooltip('Academic details'));
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('snapshot does not duplicate course attendance warnings',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicHomeSummary(
                data: const AcademicDashboardData(
                    stats: AcademicStats(cgpa: 3.2),
                    attendance: [
                      AcademicItem(
                          title: 'Calculus',
                          detail: '70%',
                          meta: {'atRisk': true, 'percent': 70})
                    ]),
                syncing: false,
                onOpen: () {}))));
    expect(
        find.textContaining('Calculus · Attendance below 75%'), findsNothing);
    expect(find.text('Earned credits'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final brightness in Brightness.values) {
    for (final width in [320.0, 800.0]) {
      testWidgets('stats layout $brightness at $width with large text',
          (tester) async {
        tester.view.physicalSize = Size(width, 1300);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: brightness),
                useMaterial3: true),
            home: MediaQuery(
                data: MediaQueryData(
                    size: Size(width, 1300),
                    textScaler: const TextScaler.linear(1.5)),
                child: Scaffold(
                    body: SingleChildScrollView(
                        child: AcademicHomeSummary(
                            data: AcademicDashboardData(
                                stats: const AcademicStats(
                                    cgpa: 3.39,
                                    earnedCredits: 136,
                                    inProgressCredits: 3),
                                statsSyncedAt: DateTime(2026, 9, 12)),
                            syncing: false,
                            onOpen: () {}))))));
        expect(find.text('3.39'), findsOneWidget);
        expect(find.text('Official CGPA'), findsOneWidget);
        expect(find.text('Earned credits'), findsNothing);
        expect(find.text('In-progress credits'), findsNothing);
        expect(find.text('Open Qalam'), findsNothing);
        expect(find.byTooltip('Academic details'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('setup dialog explains opt-in privacy and offers decline',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showPortalSyncSetup(context),
                    child: const Text('Setup'))))));
    await tester.tap(find.text('Setup'));
    await tester.pumpAndSettle();
    expect(find.text('Enable automatic sync'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.textContaining('sync does not upload them to our servers'),
        findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Enable automatic sync'), findsNothing);
  });
}
