import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/data/demo_academic_dashboard.dart';
import 'package:nust/app/modules/widgets/academic_agenda_rows.dart';
import 'package:nust/app/modules/widgets/active_course_cards.dart';

void main() {
  testWidgets('agenda taps identify the exact lecture and deadline',
      (tester) async {
    final now = DateTime(2026, 9, 14, 8);
    final lecture = AcademicItem(
        title: 'Math lecture',
        detail: '',
        date: now,
        url: '/student/course/info/123');
    final deadline = AcademicItem(
        title: 'Quiz activity',
        detail: '',
        date: now.add(const Duration(days: 1)),
        url: '/mod/quiz/view.php?id=42');
    AcademicItem? selected;
    bool? isDeadline;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicAgendaRows(
      data: AcademicDashboardData(timetable: [lecture], deadlines: [deadline]),
      now: now,
      onOpen: (item, deadline) {
        selected = item;
        isDeadline = deadline;
      },
    ))));
    await tester.tap(find.text('Math lecture'));
    expect(selected, same(lecture));
    expect(isDeadline, isFalse);
    await tester.tap(find.text('Quiz activity'));
    expect(selected, same(deadline));
    expect(isDeadline, isTrue);
  });
  test('today includes exact dates and recurring weekdays, not other days', () {
    final monday = DateTime(2026, 9, 14);
    expect(
        AcademicAgendaRows.isToday(
            const AcademicItem(
                title: 'Math', detail: '', meta: {'day': 'Monday'}),
            monday),
        isTrue);
    expect(
        AcademicAgendaRows.isToday(
            const AcademicItem(
                title: 'Math', detail: '', meta: {'day': 'Tuesday'}),
            monday),
        isFalse);
    expect(
        AcademicAgendaRows.isToday(
            AcademicItem(
                title: 'Math',
                detail: '',
                date: monday.add(const Duration(days: 1))),
            monday),
        isFalse);
  });
  test('border supports exact half, three-quarter and full perimeter', () {
    for (final progress in [0.0, .5, .75, 1.0]) {
      final painter = AttendanceBorderPainter(
          progress: progress, color: Colors.blue, track: Colors.grey);
      final metric =
          painter.borderPath(const Size(160, 64)).computeMetrics().first;
      expect(metric.isClosed, isTrue);
      if (progress > 0) {
        expect(
            metric
                .extractPath(0, metric.length * progress)
                .computeMetrics()
                .first
                .length,
            closeTo(metric.length * progress, .1));
      }
    }
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'compact agenda and name-only courses fit large text in $brightness',
        (tester) async {
      tester.view.physicalSize = const Size(320, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime(2026, 9, 14, 8);
      final data = createDemoDashboard(now: now);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue, brightness: brightness)),
          home: Scaffold(
              body: MediaQuery(
                  data:
                      const MediaQueryData(textScaler: TextScaler.linear(1.8)),
                  child: Column(children: [
                    ActiveCourseCards(courses: data.attendance),
                    AcademicAgendaRows(
                        data: data, now: now, onOpen: (_, deadline) {})
                  ])))));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('68%'), findsOneWidget);
      expect(find.text('Today’s lectures'), findsOneWidget);
      expect(find.text('Upcoming deadlines'), findsOneWidget);
      expect(tester.getSize(find.byType(Card).at(0)),
          tester.getSize(find.byType(Card).at(1)));
      expect(tester.takeException(), isNull);
    });
  }
}
