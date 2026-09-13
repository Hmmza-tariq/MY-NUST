import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/data/academic_results.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';
import 'package:nust/app/domain/calculators/planner_result_importer.dart';
import 'package:nust/app/domain/calculators/gpa_projection.dart';
import 'package:nust/app/domain/portal/portal_snapshot_parser.dart';

const fixture = '''
<table class="table_tree"><thead><tr>
<th>Term</th><th>Grade Points</th><th>Cumulative GP</th><th>Attempted CH</th><th>Earned CH</th><th>Cumulative CH</th><th>Current SGPA</th><th>Current CGPA</th><th>Previous SGPA</th><th>Previous CGPA</th><th>Term Type</th><th>Regular Semester Count</th>
</tr></thead><tbody>
<tr class="table-parent-row"><td>Fall 2021</td><td>27.5</td><td>27.5</td><td>18.0</td><td>15.0</td><td>15.0</td><td>1.83</td><td>1.83</td><td>0</td><td>0</td><td>regular</td><td>1</td></tr>
<tr class="table-child-row"><th>Course</th><th>Credit Hours</th><th>Grade Pts</th><th>Final Grade</th></tr>
<tr class="table-child-row"><td>English</td><td>2.0</td><td>5.0</td><td>C+</td></tr>
<tr class="table-child-row"><td>Calculus</td><td>3.0</td><td>4.5</td><td>D+</td></tr>
<tr class="table-child-row"><td>Physics</td><td>3.0</td><td>0.0</td><td>F</td></tr>
<tr class="table-parent-row"><td>Spring 2022</td><td>14</td><td>41.5</td><td>17</td><td>9</td><td>24</td><td>1.56</td><td>1.73</td><td>0</td><td>0</td><td>regular</td><td>2</td></tr>
<tr class="table-child-row"><th>Course</th><th>Credit Hours</th><th>Grade Pts</th><th>Final Grade</th></tr>
<tr class="table-child-row"><td>Calculus</td><td>3</td><td>9</td><td>B</td></tr>
<tr class="table-child-row"><td>Ungraded</td><td>3</td><td></td><td>I</td></tr>
</tbody></table>
''';

AcademicDashboardData parse() => PortalSnapshotParser.merge(
    current: const AcademicDashboardData(),
    url: 'https://qalam.nust.edu.pk/student/results/',
    markup: fixture,
    capturedAt: DateTime(2026, 9, 12));

void main() {
  test(
      'editing imported term replaces its contribution instead of double-counting it',
      () {
    final unchanged = GpaProjection.replacingTerm(terms: [
      (name: 'Fall 2025', gradePoints: 3.0, credits: 18.0),
      (name: 'Spring 2026', gradePoints: 4.0, credits: 18.0)
    ], selectedTerm: 'Spring 2026', plannedSgpa: 4, plannedCredits: 18);
    expect(unchanged, 3.5);
    expect(
        GpaProjection.replacingTerm(terms: [
          (name: 'Fall 2025', gradePoints: 3.0, credits: 18.0),
          (name: 'Spring 2026', gradePoints: 4.0, credits: 18.0)
        ], selectedTerm: 'Spring 2026', plannedSgpa: 2, plannedCredits: 18),
        2.5);
  });
  test('reads actual Qalam direct term/course rows and normalizes total points',
      () {
    final result = parse();
    expect(result.results, hasLength(2));
    expect(result.results.first.courses, hasLength(3));
    expect(result.results.first.courses.first.gradePoint, 2.5);
    expect(result.results.first.courses[1].gradePoint, 1.5);
    expect(result.results.first.courses.last.gradePoint, 0);
    expect(result.results.last.courses, hasLength(1));
    expect(result.results.last.courses.single.gradePoint, 3);
    expect(result.results.first.sgpa, 1.83);
    expect(result.results.first.earnedCredits, 15);
    expect(result.results.first.regularSemesterCount, 1);
    expect(result.results.first.termType, 'regular');
    expect(result.resultsSyncedAt, DateTime(2026, 9, 12));
  });

  test('results and stats round-trip locally and survive unrelated LMS sync',
      () {
    final results = parse();
    final dashboard = PortalSnapshotParser.merge(
        current: results,
        url: 'https://qalam.nust.edu.pk/',
        markup:
            '<div id="page_content">Academics CGPA: 1.96 Earned Cr : 136.0 Inprogress Cr : 3.0 Total Cr : 0.0</div>',
        capturedAt: DateTime(2026, 9, 12));
    final local = AcademicDashboardData.fromMap(dashboard.toMap());
    expect(local.stats.cgpa, 1.96);
    expect(local.stats.earnedCredits, 136);
    expect(local.stats.inProgressCredits, 3);
    expect(local.results.first.courses.first.gradePoint, 2.5);
    expect(local.results.first.regularSemesterCount, 1);
    expect(local.results.first.termType, 'regular');
    final lms = PortalSnapshotParser.merge(
        current: local,
        url: 'https://lms.nust.edu.pk/my/',
        markup: '<main>No deadlines</main>');
    expect(lms.stats.cgpa, 1.96);
    expect(lms.results, hasLength(2));
    expect(lms.statsSyncedAt, DateTime(2026, 9, 12));
  });

  test('error markup cannot erase cached results, stats, timetable or invoices',
      () {
    final result = parse();
    final failed = PortalSnapshotParser.merge(
        current: result,
        url: 'https://qalam.nust.edu.pk/student/results/',
        markup: '<main>Service unavailable</main>');
    expect(failed.results, hasLength(2));
    expect(failed.resultsSyncedAt, result.resultsSyncedAt);
    const item = AcademicItem(title: 'Cached', detail: 'Cached');
    final failedSchedule = PortalSnapshotParser.merge(
        current:
            const AcademicDashboardData(timetable: [item], invoices: [item]),
        url: 'https://qalam.nust.edu.pk/student/class/schedule',
        markup: 'Service unavailable');
    expect(failedSchedule.timetable, hasLength(1));
    final failedInvoice = PortalSnapshotParser.merge(
        current: failedSchedule,
        url: 'https://qalam.nust.edu.pk/student/invoices',
        markup: 'Service unavailable');
    expect(failedInvoice.invoices, hasLength(1));
  });

  test(
      'term import is add-only, preserves edits and uses official earned basis',
      () {
    final terms = parse().results;
    final manual = Semester(name: 'Fall 2021', gpa: 3.39, credit: 18);
    final merged = PlannerResultImporter.mergeSemesters([manual], terms);
    expect(merged, hasLength(2));
    expect(merged.first, same(manual));
    expect(merged.first.gpa, 3.39);
    expect(merged.last.credit, 9);
    expect(merged.last.gpa, 1.56);
    expect(merged.last.source, 'qalam');
    expect(PlannerResultImporter.mergeSemesters(merged, terms), hasLength(2));
  });

  test('course import is idempotent within term and preserves matching edits',
      () {
    final term = parse().results.first;
    final manual =
        Course(name: ' english ', credit: 2, gpa: 4, semesterId: term.name);
    final merged = PlannerResultImporter.mergeCourses([manual], term);
    expect(merged, hasLength(3));
    expect(merged.first.gpa, 4);
    expect(merged[1].gpa, 1.5);
    expect(merged.last.gpa, 0);
    expect(PlannerResultImporter.mergeCourses(merged, term), hasLength(3));
    expect(
        PlannerResultImporter.mergeCourses([], parse().results.last)
            .single
            .name,
        'Calculus');
  });

  test('does not silently round fractional credits unsupported by planner', () {
    const term = AcademicTermResult(
        name: 'Fall 2026',
        sgpa: 3,
        cgpa: 3,
        attemptedCredits: 1.5,
        earnedCredits: 1.5,
        cumulativeCredits: 1.5,
        courses: [
          AcademicCourseResult(
              name: 'Lab', credits: 1.5, grade: 'B', gradePoint: 3)
        ]);
    expect(PlannerResultImporter.mergeSemesters([], [term]), isEmpty);
    expect(PlannerResultImporter.mergeCourses([], term), isEmpty);
  });
}
