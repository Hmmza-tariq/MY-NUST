import 'package:html/dom.dart';
import '../../data/academic_results.dart';

/// Reads only the results table containing the official term SGPA/CGPA columns.
/// Nested course grade-points are total points, not the per-credit grade value.
class QalamResultsParser {
  const QalamResultsParser._();

  static List<AcademicTermResult>? parse(Document document) {
    for (final table in document.querySelectorAll('table')) {
      final rows = table
          .querySelectorAll('tr')
          .where((row) => _tableOf(row) == table)
          .toList();
      final headerIndex = rows.indexWhere((row) {
        final text = _clean(row.text).toLowerCase();
        return text.contains('current sgpa') && text.contains('current cgpa');
      });
      if (headerIndex < 0) continue;
      final headers = _cells(rows[headerIndex])
          .map((e) => _clean(e.text).toLowerCase())
          .toList();
      final terms = <AcademicTermResult>[];
      String? name;
      Map<String, String> fields = {};
      var courses = <AcademicCourseResult>[];
      var courseHeaders = <String>[];
      double number(String key) => double.tryParse(fields[key] ?? '') ?? 0;
      void finish() {
        if (name == null) return;
        final sgpa = double.tryParse(fields['current sgpa'] ?? '');
        final cgpa = double.tryParse(fields['current cgpa'] ?? '');
        if (sgpa == null ||
            cgpa == null ||
            !sgpa.isFinite ||
            !cgpa.isFinite ||
            sgpa < 0 ||
            sgpa > 4 ||
            cgpa < 0 ||
            cgpa > 4) {
          return;
        }
        terms.add(AcademicTermResult(
          name: name,
          sgpa: sgpa,
          cgpa: cgpa,
          attemptedCredits: number('attempted ch'),
          earnedCredits: number('earned ch'),
          cumulativeCredits: number('cumulative ch'),
          regularSemesterCount:
              int.tryParse(fields['regular semester count'] ?? ''),
          termType: fields['term type'],
          courses: List.of(courses),
        ));
      }

      for (final row in rows.skip(headerIndex + 1)) {
        final cells = _cells(row);
        final values = cells.map((e) => _clean(e.text)).toList();
        if (values.length >= headers.length &&
            values.isNotEmpty &&
            RegExp(r'^(Spring|Summer|Fall|Autumn|Winter)\s+\d{4}',
                    caseSensitive: false)
                .hasMatch(values.first)) {
          finish();
          name = values.first;
          fields = {
            for (var i = 0; i < headers.length; i++) headers[i]: values[i]
          };
          courses = [];
          courseHeaders = [];
        }
        if (name != null) {
          final normalized = values.map((e) => e.toLowerCase()).toList();
          if (normalized.contains('course') &&
              normalized.contains('final grade')) {
            courseHeaders = normalized;
          } else if (courseHeaders.isNotEmpty &&
              values.length == courseHeaders.length) {
            final course = _course({
              for (var i = 0; i < courseHeaders.length; i++)
                courseHeaders[i]: values[i]
            });
            if (course != null) courses.add(course);
          }
          for (final nested in row.querySelectorAll('table')) {
            courses.addAll(_courses(nested));
          }
        }
      }
      finish();
      final seen = <String>{};
      return terms.where((e) => seen.add(e.name.toLowerCase())).toList();
    }
    return null; // Unrecognised/error/login markup must not erase cached results.
  }

  static List<AcademicCourseResult> _courses(Element table) {
    final rows = table
        .querySelectorAll('tr')
        .where((row) => _tableOf(row) == table)
        .toList();
    if (rows.isEmpty) return [];
    final headers =
        _cells(rows.first).map((e) => _clean(e.text).toLowerCase()).toList();
    if (!headers.contains('course') || !headers.contains('final grade')) {
      return [];
    }
    final result = <AcademicCourseResult>[];
    for (final row in rows.skip(1)) {
      final values = _cells(row).map((e) => _clean(e.text)).toList();
      if (values.length < headers.length) continue;
      final fields = {
        for (var i = 0; i < headers.length; i++) headers[i]: values[i]
      };
      final course = _course(fields);
      if (course != null) result.add(course);
    }
    return result;
  }

  static AcademicCourseResult? _course(Map<String, String> fields) {
    final credits = double.tryParse(fields['credit hours'] ?? '') ?? 0;
    final grade = (fields['final grade'] ?? '').toUpperCase();
    final name = fields['course'] ?? '';
    const grades = {
      'A': 4.0,
      'A-': 3.67,
      'B+': 3.5,
      'B': 3.0,
      'B-': 2.67,
      'C+': 2.5,
      'C': 2.0,
      'C-': 1.67,
      'D+': 1.5,
      'D': 1.0,
      'F': 0.0
    };
    if (name.isEmpty || credits <= 0 || !grades.containsKey(grade)) return null;
    final totalPoints = double.tryParse(fields['grade pts'] ?? '');
    final point = totalPoints == null ? grades[grade]! : totalPoints / credits;
    if (point < 0 || point > 4) return null;
    return AcademicCourseResult(
        name: name, credits: credits, grade: grade, gradePoint: point);
  }

  static List<Element> _cells(Element row) => row.children
      .where((e) => e.localName == 'th' || e.localName == 'td')
      .toList();
  static Element? _tableOf(Element element) {
    Element? parent = element.parent;
    while (parent != null) {
      if (parent.localName == 'table') return parent;
      parent = parent.parent;
    }
    return null;
  }

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
}
