import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/modules/widgets/active_course_cards.dart';
import 'package:get/get.dart';
import 'package:nust/app/data/demo_academic_dashboard.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final width in [320.0, 800.0]) {
      testWidgets('formatted results fit $width in $brightness with large text',
          (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Get.testMode = true;
        addTearDown(Get.reset);
        final course = createDemoDashboard().attendance.first;
        await tester.pumpWidget(GetMaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: brightness)),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.8)),
                child: child!),
            home: CourseDetailsPage(course: course)));
        await tester.ensureVisible(find.text('Quiz'));
        await tester.tap(find.text('Quiz'));
        await tester.pumpAndSettle();
        expect(find.text('Awaiting marks'), findsOneWidget);
        expect(find.text('10% of final grade'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('course details expand categories and distinguish missing marks',
      (tester) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    const course = AcademicItem(title: 'Calculus', detail: 'MATH-101', meta: {
      'percent': 77,
      'categories': [
        {
          'name': 'Quiz',
          'weight': 10,
          'obtainedPercentage': 0,
          'assessments': [
            {
              'name': 'Quiz 1',
              'maxMarks': 10,
              'obtainedMarks': 0,
              'classAverage': 7.73,
              'percentage': null
            }
          ]
        }
      ]
    });
    await tester.pumpWidget(
        const GetMaterialApp(home: CourseDetailsPage(course: course)));
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Marks: 0 / 10'), findsOneWidget);
    expect(find.text('Class average: 7.73 · —%'), findsOneWidget);
    expect(find.text('Open in official portal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final count in [1, 2, 7]) {
    for (final brightness in Brightness.values) {
      testWidgets('$count courses fit at 320 with large text in $brightness',
          (tester) async {
        tester.view.physicalSize = const Size(320, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        AcademicItem? selected;
        await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: brightness)),
            home: Scaffold(
                body: MediaQuery(
                    data: const MediaQueryData(
                        size: Size(320, 850),
                        textScaler: TextScaler.linear(1.8)),
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ActiveCourseCards(courses: [
                          for (var i = 0; i < count; i++)
                            AcademicItem(
                                title: 'Course $i with a long title',
                                detail: 'MATH-101',
                                meta: {'percent': 77})
                        ], onCourseTap: (course) => selected = course))))));
        await tester.pumpAndSettle();
        if (count == 1) {
          expect(tester.getSize(find.byType(Card).first).width, 288);
        }
        if (count == 7) {
          await tester.drag(find.byType(ListView), const Offset(-1800, 0));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Course 6 with a long title'));
          expect(selected?.title, 'Course 6 with a long title');
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
