import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/data/demo_academic_dashboard.dart';

void main() {
  test('demo matches persisted model and includes mixed academic states', () {
    final now = DateTime(2026, 9, 14, 8);
    final data =
        AcademicDashboardData.fromMap(createDemoDashboard(now: now).toMap());
    expect(data.attendance.length, 7);
    expect(data.attendance.where((c) => c.meta?['atRisk'] == true).length, 2);
    expect(data.attendance.every((c) => c.url == null), isTrue);
    expect(data.timetable.length, 3);
    expect(data.timetable.every((c) => c.date?.day == now.day), isTrue);
    expect(data.deadlines.length, 2);
    expect(data.results.length, 3);
    final categories = data.attendance[4].meta!['categories'] as List;
    expect(categories.first['assessments'][0]['obtainedMarks'], 0);
    expect(categories.last['assessments'][0]['obtainedMarks'], isNull);
  });
}
