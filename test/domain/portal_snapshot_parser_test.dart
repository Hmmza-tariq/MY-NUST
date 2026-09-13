import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/domain/portal/portal_snapshot_parser.dart';

void main() {
  test('student name comes from Academics profile and survives local cache',
      () {
    final result = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(),
      url: 'https://qalam.nust.edu.pk/',
      markup:
          '<section id="page_content"><h2>Academics</h2><div>Sample Student</div> <div>0000123456</div><p>CGPA: 3.39</p></section>',
    );
    expect(result.stats.studentName, 'Sample Student');
    final cached = AcademicDashboardData.fromMap(result.toMap());
    expect(cached.stats.greeting, 'Hey, Sample!');
    final next = PortalSnapshotParser.merge(
        current: cached,
        url: 'https://qalam.nust.edu.pk/',
        markup: '<p>CGPA: 3.40</p>');
    expect(next.stats.studentName, 'Sample Student');
    expect(AcademicDashboardData.fromMap({}).stats.greeting, isNull);
  });
  test('extracts LMS deadline rows without duplicates', () {
    final result = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(),
      url: 'https://lms.nust.edu.pk/my/',
      markup: '''
        <ul><li class="activity"><a href="https://lms.nust.edu.pk/mod/assign/view.php?id=1">Lab report</a><span>Assignment due Friday</span></li></ul>
      ''',
      capturedAt: DateTime(2026, 9, 11),
    );

    expect(result.deadlines, hasLength(1));
    expect(result.deadlines.single.title, 'Lab report');
    expect(result.lmsSyncedAt, DateTime(2026, 9, 11));
  });

  test('parses one aggregate attendance item per dashboard course card', () {
    final result = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(),
      url: 'https://qalam.nust.edu.pk/',
      markup: '''
        <section>
          <h2>Classes, Grades and Attendance</h2>
          <div class="panel">
            <div class="panel-heading">Calculus &amp; Analytical Geometry</div>
            <div class="panel-body">
              <a>Irfan Youngs</a>
              <p>MATH-101 Credits : 3.0 Grading in progress</p>
              <p>Attendance: 77.0% Summer 2026</p>
            </div>
          </div>
        </section>
      ''',
      capturedAt: DateTime(2026, 9, 11),
    );

    expect(result.attendance, hasLength(1));
    expect(result.attendance.single.title, 'Calculus & Analytical Geometry');
    expect(result.attendance.single.meta?['percent'], 77);
    expect(result.attendance.single.meta?['code'], 'MATH-101');
    expect(result.attendance.single.meta?['term'], 'Summer 2026');
    expect(result.attendance.single.meta?['atRisk'], isFalse);
  });

  test('does not turn attendance sessions into separate course rows', () {
    const existing = AcademicItem(
      title: 'Calculus & Analytical Geometry',
      detail: 'MATH-101 • Summer 2026',
    );
    final result = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(attendance: [existing]),
      url: 'https://qalam.nust.edu.pk/student/attendance',
      markup: '''
        <table><thead><tr><th>No</th><th>Student</th><th>Section</th><th>Date</th></tr></thead>
        <tbody>
          <tr><td>1</td><td>Student</td><td>F26-S1</td><td>2026-09-08 09:00 P</td></tr>
          <tr><td>2</td><td>Student</td><td>F26-S2</td><td>2026-09-15 09:00 P</td></tr>
        </tbody></table>
      ''',
    );

    expect(result.attendance, hasLength(1));
    expect(result.attendance.single.title, existing.title);
  });

  test('ignores enrolment schedule tables and clears an empty class schedule',
      () {
    const existing = AcademicItem(title: 'Wrong row', detail: 'Course Drop');
    final enrolment = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(timetable: [existing]),
      url: 'https://qalam.nust.edu.pk/student/enrollment/schedule',
      markup: '''
        <table><thead><tr><th>Event</th><th>Start</th></tr></thead>
        <tbody><tr><td>Course Drop</td><td>2026-07-06</td></tr></tbody></table>
      ''',
    );
    expect(enrolment.timetable.single.title, 'Wrong row');

    final schedule = PortalSnapshotParser.merge(
      current: enrolment,
      url: 'https://qalam.nust.edu.pk/student/class/schedule',
      markup: '<div class="cd-schedule__events"></div>',
    );
    expect(schedule.timetable, isEmpty);
  });

  test('maps invoice headers and preserves paid status as metadata', () {
    final result = PortalSnapshotParser.merge(
      current: const AcademicDashboardData(),
      url: 'https://qalam.nust.edu.pk/student/invoices',
      markup: '''
        <table>
          <thead><tr>
            <th>Invoice Date</th><th>Due Date</th><th>Term</th><th>Semester</th>
            <th>Challan Type</th><th>Challan ID</th><th>Scholarship %</th>
            <th>Payable Amount</th><th>Status</th><th>Print/Save</th>
            <th>Action</th><th>Paid Date</th>
          </tr></thead>
          <tbody><tr>
            <td>2025-01-02</td><td>2025-01-22</td><td>Spring 2025</td><td>-</td>
            <td>Full Payment</td><td>0485826</td><td>0.0</td><td>0</td>
            <td>Paid</td><td></td><td></td><td>2025-01-21</td>
          </tr></tbody>
        </table>
      ''',
    );

    expect(result.invoices, hasLength(1));
    expect(result.invoices.single.title, 'Spring 2025 • Full Payment');
    expect(result.invoices.single.meta?['challanId'], '0485826');
    expect(result.invoices.single.meta?['isPaid'], isTrue);
    expect(result.invoices.single.date, DateTime(2025, 1, 22));
  });
}
