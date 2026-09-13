import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../data/academic_dashboard.dart';
import '../../data/academic_results.dart';
import 'qalam_results_parser.dart';
import 'course_gradebook_parser.dart';

class PortalSnapshotParser {
  const PortalSnapshotParser._();

  static AcademicDashboardData merge({
    required AcademicDashboardData current,
    required String url,
    required String markup,
    DateTime? capturedAt,
  }) {
    final uri = Uri.tryParse(url);
    final host = uri?.host.toLowerCase() ?? '';
    final path = uri?.path.toLowerCase() ?? '';
    final document = html_parser.parse(markup);
    final now = capturedAt ?? DateTime.now();

    if (host == 'lms.nust.edu.pk') {
      final deadlines = <AcademicItem>[];
      for (final element in document.querySelectorAll(
        'li, .activity, .event, .timeline-event-list-item, tr',
      )) {
        final text = _clean(element.text);
        if (text.length < 8 || !_deadlinePattern.hasMatch(text)) continue;
        final anchor = element.querySelector('a[href]');
        deadlines.add(AcademicItem(
          title: _clean(anchor?.text ?? '').isEmpty
              ? _firstLine(text)
              : _clean(anchor!.text),
          detail: text,
          url: anchor?.attributes['href'],
        ));
        if (deadlines.length == 20) break;
      }
      return AcademicDashboardData(
        timetable: current.timetable,
        deadlines: _unique(deadlines),
        attendance: current.attendance,
        invoices: current.invoices,
        qalamSyncedAt: current.qalamSyncedAt,
        lmsSyncedAt: now,
        stats: current.stats,
        results: current.results,
        resultsSyncedAt: current.resultsSyncedAt,
        statsSyncedAt: current.statsSyncedAt,
      );
    }

    if (host != 'qalam.nust.edu.pk') return current;

    var timetable = current.timetable;
    var attendance = current.attendance;
    var invoices = current.invoices;
    var stats = current.stats;
    var results = current.results;
    var resultsSyncedAt = current.resultsSyncedAt;
    var statsSyncedAt = current.statsSyncedAt;

    // Only the official class schedule route is a timetable. Qalam also has
    // enrolment "schedule" tables whose rows are academic-calendar windows.
    if (path == '/student/class/schedule' &&
        (document.querySelector('.cd-schedule__events') != null ||
            document.querySelector('.cd-schedule__event') != null ||
            RegExp(r'no (class|record)', caseSensitive: false)
                .hasMatch(document.body?.text ?? ''))) {
      timetable = _parseTimetable(document);
    }

    // The dashboard contains one aggregate card per course. The attendance
    // page can contain one row per lecture, which must not become course rows.
    if (path == '/' || path.contains('dashboard')) {
      if (document.body?.text.contains('Academics') == true ||
          _attendancePattern.hasMatch(document.body?.text ?? '')) {
        attendance = _parseDashboardAttendance(document).map((item) {
          final previous = current.attendance.where((old) =>
              old.title == item.title &&
              old.meta?['term'] == item.meta?['term']);
          return AcademicItem(
              title: item.title,
              detail: item.detail,
              url: item.url,
              meta: {
                ...?previous.firstOrNull?.meta,
                ...?item.meta,
                'attendanceSyncedAt': now.toIso8601String()
              });
        }).toList();
      }
      stats = _parseStats(document, current.stats);
      if (!identical(stats, current.stats)) statsSyncedAt = now;
    }
    if (path == '/student/results/' || path == '/student/results') {
      final parsed = QalamResultsParser.parse(document);
      if (parsed != null) {
        results = parsed;
        resultsSyncedAt = now;
      }
    }

    if (path == '/student/invoices' || path == '/student/messinvoices') {
      final category = path.contains('mess') ? 'mess' : 'tuition';
      final parsed = _parseInvoices(document, category: category);
      if (parsed != null) {
        invoices = [
          ...current.invoices.where(
            (item) => item.meta?['category'] != category,
          ),
          ...parsed,
        ];
      }
    }

    if (RegExp(r'^/student/course/gradebook/\d+/?$').hasMatch(path)) {
      final categories = CourseGradebookParser.parse(document);
      if (categories != null) {
        attendance = attendance.map((item) {
          if (Uri.tryParse(item.url ?? '')
                  ?.path
                  .replaceAll(RegExp(r'/$'), '') !=
              path.replaceAll(RegExp(r'/$'), '')) {
            return item;
          }
          return AcademicItem(
              title: item.title,
              detail: item.detail,
              url: item.url,
              meta: {
                ...?item.meta,
                'categories': categories,
                'marksSyncedAt': now.toIso8601String()
              });
        }).toList();
      }
    }

    return AcademicDashboardData(
      timetable: _unique(timetable),
      deadlines: current.deadlines,
      attendance: _unique(attendance),
      invoices: _unique(invoices),
      qalamSyncedAt: now,
      lmsSyncedAt: current.lmsSyncedAt,
      stats: stats,
      results: results,
      resultsSyncedAt: resultsSyncedAt,
      statsSyncedAt: statsSyncedAt,
    );
  }

  static AcademicStats _parseStats(Document document, AcademicStats previous) {
    final text = _profileText(document);
    double? read(String pattern) => double.tryParse(
        RegExp(pattern, caseSensitive: false).firstMatch(text)?.group(1) ?? '');
    final cgpa = read(r'\bCGPA\s*:\s*(\d+(?:\.\d+)?)');
    if (cgpa == null || cgpa > 4) return previous;
    return AcademicStats(
      cgpa: cgpa,
      studentName: _studentName(document) ?? previous.studentName,
      earnedCredits: read(r'Earned\s+Cr\s*:\s*(\d+(?:\.\d+)?)'),
      inProgressCredits: read(r'In\s*progress\s+Cr\s*:\s*(\d+(?:\.\d+)?)'),
      totalCredits: read(r'Total\s+Cr\s*:\s*(\d+(?:\.\d+)?)'),
    );
  }

  static String? _studentName(Document document) {
    final explicit = document
        .querySelector('[data-student-name], #student_name, .student-name');
    final tagged = _clean(
        explicit?.attributes['data-student-name'] ?? explicit?.text ?? '');
    if (tagged.isNotEmpty) return tagged;
    final text = _profileText(document);
    // Only the Academics profile preceding the student's numeric ID is used;
    // never infer a student name from faculty links or attendance session rows.
    final match =
        RegExp(r'Academics\s*([^\d]{2,100}?)\s*\d{6,}\b', caseSensitive: false)
            .firstMatch(text);
    final name = _clean(match?.group(1) ?? '');
    return name.isEmpty ? null : name;
  }

  static List<AcademicItem> _parseTimetable(Document document) {
    final result = <AcademicItem>[];
    final candidates = document.querySelectorAll(
      '.cd-schedule__event, [data-start][data-end]',
    );
    for (final element in candidates) {
      final title = _clean(element.querySelector('.event-name')?.text ??
          element.querySelector('em')?.text ??
          element.text);
      if (title.isEmpty) continue;
      final start = element.attributes['data-start'] ?? '';
      final end = element.attributes['data-end'] ?? '';
      final day = _clean(_closestScheduleGroup(element)
              ?.querySelector('.cd-schedule__top-info')
              ?.text ??
          '');
      final time = [start, end].where((value) => value.isNotEmpty).join(' – ');
      final detail = [day, time].where((value) => value.isNotEmpty).join(' • ');
      result.add(AcademicItem(
        title: title,
        detail: detail,
        url: element.querySelector('a[href]')?.attributes['href'] ??
            (element.localName == 'a' ? element.attributes['href'] : null),
        meta: {
          if (day.isNotEmpty) 'day': day,
          if (start.isNotEmpty) 'start': start,
          if (end.isNotEmpty) 'end': end,
        },
      ));
    }
    return _unique(result);
  }

  static String _profileText(Document document) {
    final parts = <String>[];
    void visit(Node node) {
      if (node is Element &&
          (node.localName == 'script' || node.localName == 'style')) {
        return;
      }
      if (node is Text) parts.add(node.text);
      for (final child in node.nodes) {
        visit(child);
      }
    }

    final root = document.querySelector('#page_content') ?? document.body;
    if (root != null) {
      visit(root);
    }
    return _clean(parts.join(' '));
  }

  static List<AcademicItem> _parseDashboardAttendance(Document document) {
    final matching = document.querySelectorAll('.panel, .card, div').where((e) {
      final text = _clean(e.text);
      return text.length < 900 &&
          _attendancePattern.hasMatch(text) &&
          _creditsPattern.hasMatch(text);
    }).toList()
      ..sort((a, b) => a.text.length.compareTo(b.text.length));

    final result = <AcademicItem>[];
    final courseCodes = <String>{};
    for (final element in matching) {
      final text = _clean(element.text);
      final percentMatch = _attendancePattern.firstMatch(text);
      final percent = double.tryParse(percentMatch?.group(1) ?? '');
      if (percent == null || percent > 100) continue;

      final code = _courseCodePattern.firstMatch(text)?.group(0) ?? '';
      final heading = _clean(element
              .querySelector(
                '.panel-heading, .card-header, .course-title, h2, h3, h4, h5',
              )
              ?.text ??
          '');
      if (heading.isEmpty ||
          heading.toLowerCase().contains('classes, grades')) {
        continue;
      }
      final identity = code.isEmpty ? heading.toLowerCase() : code;
      if (!courseCodes.add(identity)) continue;

      final credits = _creditsPattern.firstMatch(text)?.group(1) ?? '';
      final term = _termPattern.firstMatch(text)?.group(0) ?? '';
      final instructor = _clean(element.querySelector('a')?.text ?? '');
      final detail =
          [code, term].where((value) => value.isNotEmpty).join(' • ');
      result.add(AcademicItem(
        title: heading,
        detail: detail,
        url: _gradebookUrl(element),
        meta: {
          'percent': percent,
          'atRisk': percent < 75,
          if (code.isNotEmpty) 'code': code,
          if (term.isNotEmpty) 'term': term,
          if (credits.isNotEmpty) 'credits': credits,
          if (instructor.isNotEmpty && instructor != heading)
            'instructor': instructor,
        },
      ));
    }
    return result;
  }

  static String? _gradebookUrl(Element element) {
    Element? enclosingLink;
    for (Element? parent = element; parent != null; parent = parent.parent) {
      if (parent.localName == 'a' && parent.attributes.containsKey('href')) {
        enclosingLink = parent;
        break;
      }
    }
    for (final link in [
      if (enclosingLink != null) enclosingLink,
      ...element.querySelectorAll('a[href]')
    ]) {
      final uri = Uri.parse('https://qalam.nust.edu.pk/')
          .resolve(link.attributes['href']!);
      final match =
          RegExp(r'^/student/course/(?:info|gradebook|attendance)/(\d+)/?$')
              .firstMatch(uri.path);
      if (uri.host == 'qalam.nust.edu.pk' && match != null) {
        return 'https://qalam.nust.edu.pk/student/course/gradebook/${match.group(1)}';
      }
    }
    return null;
  }

  static List<AcademicItem>? _parseInvoices(
    Document document, {
    required String category,
  }) {
    final result = <AcademicItem>[];
    var recognized = false;
    for (final table in document.querySelectorAll('table')) {
      final headers = table
          .querySelectorAll('thead th, thead td')
          .map((cell) => _clean(cell.text).toLowerCase())
          .toList();
      if (!headers.any((value) =>
          value.contains('challan') || value.contains('invoice date'))) {
        continue;
      }
      recognized = true;
      for (final row in table.querySelectorAll('tbody tr')) {
        final values = row
            .querySelectorAll('th,td')
            .map((cell) => _clean(cell.text))
            .toList();
        if (values.isEmpty || values.every((value) => value.isEmpty)) continue;
        final fields = <String, String>{};
        for (var index = 0;
            index < values.length && index < headers.length;
            index++) {
          fields[headers[index]] = values[index];
        }
        String read(String key) => fields.entries
            .where((entry) => entry.key.contains(key))
            .map((entry) => entry.value)
            .firstWhere((value) => value.isNotEmpty, orElse: () => '');

        final status = read('status');
        final dueDate = read('due date');
        final invoiceDate = read('invoice date');
        final term = read('term');
        final type = read('challan type');
        final amount = read('payable amount');
        final challanId = read('challan id');
        final paidDate = read('paid date');
        final isPaid = _isPaidStatus(status);
        final title = [term, type]
            .where((value) => value.isNotEmpty && value != '-')
            .join(' • ');
        result.add(AcademicItem(
          title: title.isEmpty
              ? (category == 'mess' ? 'Mess challan' : 'Fee challan')
              : title,
          detail: [status, dueDate]
              .where((value) => value.isNotEmpty && value != '-')
              .join(' • '),
          date: _parseDate(dueDate),
          url: row.querySelector('a[href]')?.attributes['href'],
          meta: {
            'category': category,
            'status': status,
            'isPaid': isPaid,
            if (amount.isNotEmpty) 'amount': amount,
            if (dueDate.isNotEmpty) 'dueDate': dueDate,
            if (invoiceDate.isNotEmpty) 'invoiceDate': invoiceDate,
            if (challanId.isNotEmpty) 'challanId': challanId,
            if (paidDate.isNotEmpty) 'paidDate': paidDate,
            if (term.isNotEmpty) 'term': term,
            if (type.isNotEmpty) 'type': type,
          },
        ));
      }
    }
    return recognized ? _unique(result) : null;
  }

  static DateTime? _parseDate(String value) {
    final match = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(value);
    if (match == null) return null;
    return DateTime.tryParse(
      '${match.group(1)}-${match.group(2)!.padLeft(2, '0')}-${match.group(3)!.padLeft(2, '0')}',
    );
  }

  static bool _isPaidStatus(String value) {
    final status = value.trim().toLowerCase();
    if (status.contains('unpaid') || status.contains('not paid')) return false;
    return status == 'paid' ||
        status.contains('fully paid') ||
        status.contains('completed');
  }

  static Element? _closestScheduleGroup(Element element) {
    Element? current = element;
    while (current != null) {
      if (current.classes.contains('cd-schedule__group')) return current;
      current = current.parent;
    }
    return null;
  }

  static final _attendancePattern = RegExp(
    r'Attendance\s*:?\s*(\d{1,3}(?:\.\d+)?)\s*%',
    caseSensitive: false,
  );
  static final _creditsPattern = RegExp(
    r'Credits?\s*:?\s*(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  static final _courseCodePattern = RegExp(r'\b[A-Z]{2,8}-\d{2,4}\b');
  static final _termPattern = RegExp(
    r'\b(?:Spring|Summer|Fall|Autumn|Winter)\s+\d{4}\b',
    caseSensitive: false,
  );
  static final _deadlinePattern = RegExp(
    r'\b(due|deadline|closes?|submit|submission)\b',
    caseSensitive: false,
  );

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').trim();
  static String _firstLine(String value) =>
      value.length <= 64 ? value : '${value.substring(0, 61)}…';
  static List<AcademicItem> _unique(List<AcademicItem> values) {
    final seen = <String>{};
    return values
        .where((item) => seen.add('${item.title}|${item.detail}'))
        .toList();
  }
}
