import '../../data/academic_results.dart';
import '../../data/course.dart';
import '../../data/semester.dart';

/// Add-only import: existing entries and user edits always win. Re-running an
/// import cannot duplicate the same course within the same term.
class PlannerResultImporter {
  const PlannerResultImporter._();
  static List<Semester> mergeSemesters(
      List<Semester> existing, List<AcademicTermResult> results) {
    final merged = List<Semester>.of(existing);
    final names = existing.map((e) => _key(e.name)).toSet();
    for (final term in results) {
      final credits =
          term.earnedCredits > 0 ? term.earnedCredits : term.attemptedCredits;
      if (!names.add(_key(term.name)) ||
          credits <= 0 ||
          credits != credits.roundToDouble() ||
          term.sgpa < 0 ||
          term.sgpa > 4) {
        continue;
      }
      merged.add(Semester(
          name: term.name,
          gpa: term.sgpa,
          credit: credits.toInt(),
          source: 'qalam'));
    }
    return merged;
  }

  static List<Course> mergeCourses(
      List<Course> existing, AcademicTermResult term) {
    final merged = List<Course>.of(existing);
    final names = existing.map((e) => _key(e.name)).toSet();
    for (final course in term.courses) {
      if (!names.add(_key(course.name)) ||
          course.credits != course.credits.roundToDouble()) {
        continue;
      }
      merged.add(Course(
          name: course.name,
          gpa: course.gradePoint,
          credit: course.credits.toInt(),
          semesterId: term.name,
          source: 'qalam'));
    }
    return merged;
  }

  static String _key(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
