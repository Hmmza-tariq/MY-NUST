import 'academic_results.dart';

class AcademicItem {
  const AcademicItem({
    required this.title,
    required this.detail,
    this.date,
    this.url,
    this.meta,
  });

  final String title;
  final String detail;
  final DateTime? date;
  final String? url;
  final Map<String, dynamic>? meta;

  factory AcademicItem.fromMap(Map<String, dynamic> map) => AcademicItem(
        title: map['title']?.toString() ?? '',
        detail: map['detail']?.toString() ?? '',
        date: DateTime.tryParse(map['date']?.toString() ?? ''),
        url: map['url']?.toString(),
        meta: map['meta'] is Map
            ? Map<String, dynamic>.from(map['meta'] as Map)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'detail': detail,
        if (date != null) 'date': date!.toIso8601String(),
        if (url != null) 'url': url,
        if (meta != null) 'meta': meta,
      };
}

class AcademicDashboardData {
  const AcademicDashboardData({
    this.timetable = const [],
    this.deadlines = const [],
    this.attendance = const [],
    this.invoices = const [],
    this.qalamSyncedAt,
    this.lmsSyncedAt,
    this.stats = const AcademicStats(),
    this.results = const [],
    this.resultsSyncedAt,
    this.statsSyncedAt,
  });

  final List<AcademicItem> timetable;
  final List<AcademicItem> deadlines;
  final List<AcademicItem> attendance;
  final List<AcademicItem> invoices;
  final DateTime? qalamSyncedAt;
  final DateTime? lmsSyncedAt;
  final AcademicStats stats;
  final List<AcademicTermResult> results;
  final DateTime? resultsSyncedAt;
  final DateTime? statsSyncedAt;

  factory AcademicDashboardData.fromMap(Map<String, dynamic> map) {
    List<AcademicItem> read(String key) => (map[key] as List? ?? const [])
        .whereType<Map>()
        .map((item) => AcademicItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return AcademicDashboardData(
      timetable: read('timetable'),
      deadlines: read('deadlines'),
      attendance: read('attendance'),
      invoices: read('invoices'),
      qalamSyncedAt: DateTime.tryParse(map['qalamSyncedAt']?.toString() ?? ''),
      lmsSyncedAt: DateTime.tryParse(map['lmsSyncedAt']?.toString() ?? ''),
      stats: AcademicStats.fromMap(
          Map<String, dynamic>.from(map['stats'] as Map? ?? {})),
      results: (map['results'] as List? ?? [])
          .whereType<Map>()
          .map((e) => AcademicTermResult.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      resultsSyncedAt:
          DateTime.tryParse(map['resultsSyncedAt']?.toString() ?? ''),
      statsSyncedAt: DateTime.tryParse(map['statsSyncedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
        'timetable': timetable.map((item) => item.toMap()).toList(),
        'deadlines': deadlines.map((item) => item.toMap()).toList(),
        'attendance': attendance.map((item) => item.toMap()).toList(),
        'invoices': invoices.map((item) => item.toMap()).toList(),
        if (qalamSyncedAt != null)
          'qalamSyncedAt': qalamSyncedAt!.toIso8601String(),
        if (lmsSyncedAt != null) 'lmsSyncedAt': lmsSyncedAt!.toIso8601String(),
        'stats': stats.toMap(),
        'results': results.map((e) => e.toMap()).toList(),
        if (resultsSyncedAt != null)
          'resultsSyncedAt': resultsSyncedAt!.toIso8601String(),
        if (statsSyncedAt != null)
          'statsSyncedAt': statsSyncedAt!.toIso8601String(),
      };
}
