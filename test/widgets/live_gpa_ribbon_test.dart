import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/services/academic_sync_service.dart';
import 'package:nust/app/modules/gpa_calculation/controllers/gpa_calculation_controller.dart';
import 'package:nust/app/modules/gpa_calculation/views/gpa_calculation_view.dart';

class _TestAuthentication extends AuthenticationController {
  // Keep this test independent of platform biometric initialization.
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  testWidgets('empty planners show sync progress and disable duplicate actions',
      (tester) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'DATABASE_KEY=0123456789abcdef');
    final database = Get.put(DatabaseController());
    await database.initialize();
    Get.put<AuthenticationController>(_TestAuthentication());
    final sync = Get.put(AcademicSyncService());
    final planner = Get.put(GpaCalculationController());
    await tester.pumpWidget(const GetMaterialApp(home: GpaCalculationView()));
    sync.isSyncing.value = true;
    sync.statusText.value = 'Syncing Qalam results…';
    await tester.pump();
    for (final cgpa in [true, false]) {
      planner.isCGPA.value = cgpa;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Syncing with Qalam…'), findsOneWidget);
      expect(find.text('Syncing Qalam results…'), findsOneWidget);
      final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Syncing with Qalam…'));
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
    }
    sync.isSyncing.value = false;
    await tester.pumpAndSettle();
    expect(find.text('Sync with Qalam'), findsOneWidget);
  });
  testWidgets(
      'live ribbon appears only after the main card leaves and updates while editing',
      (tester) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'DATABASE_KEY=0123456789abcdef');
    final database = Get.put(DatabaseController());
    await database.initialize();
    Get.put<AuthenticationController>(_TestAuthentication());
    Get.put(AcademicSyncService());
    await database
        .saveSemesters([Semester(name: 'Term', credit: 18, gpa: 3.5)]);
    await database.saveCourses([
      for (var i = 0; i < 12; i++)
        Course(name: 'Course $i', credit: 3, gpa: 3, semesterId: 'Term')
    ], 'Term');
    database.setPlannerSemester('Term');
    final controller = Get.put(GpaCalculationController());
    controller.isCGPA.value = false;
    await tester.pumpWidget(const GetMaterialApp(home: GpaCalculationView()));
    await tester.pumpAndSettle();
    expect(find.text('SGPA 3.00'), findsNothing);
    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('SGPA 3.00'), findsOneWidget);
    controller.courses.first.update((course) => course!.gpa = 4);
    await tester.pumpAndSettle();
    expect(find.text('SGPA 3.08'), findsOneWidget);
    await tester.tap(find.text('SGPA 3.08'));
    await tester.pumpAndSettle();
    expect(find.text('Semester SGPA').hitTestable(), findsOneWidget);
    expect(find.text('SGPA 3.08'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
