import 'package:html/dom.dart';

/// Reads only gradebook tables, not course lists or historical results.
class CourseGradebookParser {
  static List<Map<String, dynamic>>? parse(Document document) {
    String clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final tables = document.querySelectorAll('table');
    if (!tables.any((t) =>
        clean(t.text).contains('Assessment Type') &&
        clean(t.text).contains('Obtained Percentage'))) {
      return null;
    }
    final categories = <Map<String, dynamic>>[];
    Map<String, dynamic>? category;
    double? number(String text) =>
        double.tryParse(clean(text).replaceAll('%', ''));
    for (final row in document.querySelectorAll('tr')) {
      final cells = row.children
          .where((e) => ['td', 'th'].contains(e.localName))
          .toList();
      if (cells.isEmpty || cells.any((c) => c.querySelector('table') != null)) {
        continue;
      }
      final texts = cells.map((c) => clean(c.text)).toList();
      if (texts.any(
          (t) => t.contains('Assessment Type') || t.contains('Max Mark'))) {
        continue;
      }
      if (cells.length == 2 && number(texts[1]) != null) {
        final weight = RegExp(r'(\d+(?:\.\d+)?)\s*%').firstMatch(texts[0]);
        final name =
            clean(texts[0].replaceAll(RegExp(r'\d+(?:\.\d+)?\s*%'), ''));
        if (name.isEmpty || number(name) != null) continue;
        category = {
          'name': name,
          'weight': double.tryParse(weight?.group(1) ?? ''),
          'obtainedPercentage': number(texts[1]),
          'assessments': <Map<String, dynamic>>[],
        };
        categories.add(category);
      } else if (category != null &&
          cells.length >= 5 &&
          number(texts[1]) != null) {
        (category['assessments'] as List).add({
          'name': texts[0],
          'maxMarks': number(texts[1]),
          'obtainedMarks': number(texts[2]),
          'classAverage': number(texts[3]),
          'percentage': number(texts[4]),
        });
      }
    }
    // A recognized, empty gradebook is a successful fetch, not a failure.
    return categories;
  }
}
