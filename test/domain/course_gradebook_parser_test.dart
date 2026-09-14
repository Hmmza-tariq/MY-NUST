import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/domain/portal/portal_snapshot_parser.dart';

void main() {
  test(
      'nested schedule events produce one timed lecture, not a day-only duplicate',
      () {
    final data = PortalSnapshotParser.merge(
        current: const AcademicDashboardData(attendance: [
          AcademicItem(
              title: 'Ethical Machines',
              detail: '',
              meta: {'instructor': 'Teacher'})
        ]),
        url: 'https://qalam.nust.edu.pk/student/class/schedule',
        markup:
            '''<div class="cd-schedule__events"><li class="cd-schedule__group">
      <div class="cd-schedule__top-info">Monday</div>
      <li class="cd-schedule__event"><a data-start="18:00" data-end="21:00"><em class="event-name">Teacher</em></a></li>
      </li></div>''');
    expect(data.timetable.length, 1);
    expect(data.timetable.single.title, 'Ethical Machines');
    expect(data.timetable.single.meta!['start'], '18:00');
  });
  test('recognized empty gradebook records a successful sync', () {
    const url = 'https://qalam.nust.edu.pk/student/course/gradebook/123';
    final data = PortalSnapshotParser.merge(
        current: const AcademicDashboardData(
            attendance: [AcademicItem(title: 'Math', detail: '', url: url)]),
        url: url,
        markup:
            '<table><tr><th>Assessment Type</th><th>Obtained Percentage</th></tr></table>');
    expect(data.attendance.single.meta!['categories'], isEmpty);
    expect(data.attendance.single.meta!['marksSyncedAt'], isNotNull);
  });
  test('dashboard courses inside a link retain their gradebook URL', () {
    final data = PortalSnapshotParser.merge(
        current: const AcademicDashboardData(),
        url: 'https://qalam.nust.edu.pk/',
        markup: '''
      <h1>Academics</h1><a href="/student/course/info/123"><div class="card"><h3>Calculus</h3>
      <p>MATH-101 Credits : 3.0 Grading in progress</p>
      <p>Attendance: 77.0% Summer 2026</p></div></a>
    ''');
    expect(data.attendance.single.url,
        'https://qalam.nust.edu.pk/student/course/gradebook/123');
  });
  test('dashboard course info links resolve to the official gradebook', () {
    final data = PortalSnapshotParser.merge(
        current: const AcademicDashboardData(),
        url: 'https://qalam.nust.edu.pk/',
        markup: '''
      <h1>Academics</h1><div class="card"><h3>Calculus</h3>
      <a href="/student/course/info/123">MATH-101 Credits : 3.0 Grading in progress</a>
      <p>Attendance: 77.0% Summer 2026</p></div>
    ''');
    expect(data.attendance.single.url,
        'https://qalam.nust.edu.pk/student/course/gradebook/123');
  });
  test('gradebook categories retain zero, missing marks and local persistence',
      () {
    const url = 'https://qalam.nust.edu.pk/student/course/gradebook/123';
    const initial = AcademicDashboardData(attendance: [
      AcademicItem(
          title: 'Calculus',
          detail: 'MATH-101',
          url: url,
          meta: {'percent': 77})
    ]);
    final merged =
        PortalSnapshotParser.merge(current: initial, url: url, markup: '''
      <table><tr><th>Assessment Type</th><th>Obtained Percentage</th></tr>
      <tr><td>Quiz <span>10.0%</span></td><td>10.00</td></tr>
      <tr><td colspan="2"><table>
        <tr><th>Assessment</th><th>Max Mark</th><th>Obtained Marks</th><th>Class Average</th><th>Percentage</th></tr>
        <tr><td>Quiz 1</td><td>10</td><td>0.00</td><td>7.73</td><td>0.00</td></tr>
        <tr><td>Quiz 2</td><td>10</td><td>—</td><td>8.41</td><td>—</td></tr>
      </table></td></tr>
      <tr><td>Assignments <span>20%</span></td><td>70</td></tr>
      <tr><td colspan="2"><table><tr><td>Assignment 1</td><td>10</td><td>7</td><td>8</td><td>70</td></tr></table></td></tr></table>
    ''');
    final restored = AcademicDashboardData.fromMap(merged.toMap());
    final categories = restored.attendance.single.meta!['categories'] as List;
    expect(categories.length, 2);
    expect(categories[0]['weight'], 10);
    expect(categories[0]['assessments'][0]['obtainedMarks'], 0);
    expect(categories[0]['assessments'][1]['obtainedMarks'], isNull);
    expect(categories[1]['assessments'][0]['obtainedMarks'], 7);
    final failed = PortalSnapshotParser.merge(
        current: restored, url: url, markup: '<h1>Sign in</h1>');
    expect(failed.attendance.single.meta!['categories'], categories);
  });
}
