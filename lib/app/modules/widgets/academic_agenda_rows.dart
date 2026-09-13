import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/academic_dashboard.dart';

class AcademicAgendaRows extends StatelessWidget {
  const AcademicAgendaRows(
      {super.key, required this.data, required this.onOpen, this.now});
  final AcademicDashboardData data;
  final void Function(AcademicItem item, bool deadline) onOpen;
  final DateTime? now;

  static bool isToday(AcademicItem item, DateTime today) {
    final date = item.date?.toLocal();
    if (date != null) return DateUtils.isSameDay(date, today);
    final day = item.meta?['day']?.toString().trim().toLowerCase();
    return day != null &&
        (day == DateFormat('EEEE').format(today).toLowerCase() ||
            day == DateFormat('EEE').format(today).toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final time = now ?? DateTime.now();
    final lectures = data.timetable
        .where((item) => isToday(item, time))
        .toList()
      ..sort((a, b) => (a.meta?['start']?.toString() ??
              a.date?.toIso8601String() ??
              '')
          .compareTo(
              b.meta?['start']?.toString() ?? b.date?.toIso8601String() ?? ''));
    final deadlines = data.deadlines
        .where((item) => item.date != null && item.date!.isAfter(time))
        .toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (lectures.isNotEmpty)
        _row(context, 'Today’s lectures', lectures, false),
      if (deadlines.isNotEmpty)
        _row(context, 'Upcoming deadlines', deadlines.take(5).toList(), true),
    ]);
  }

  Widget _row(BuildContext context, String title, List<AcademicItem> items,
      bool deadline) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                  height: 70 + math.max(0.0, scale - 1) * 64,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final timing = deadline
                            ? DateFormat('d MMM · h:mm a')
                                .format(item.date!.toLocal())
                            : item.meta?['start']?.toString() ??
                                (item.date != null
                                    ? DateFormat('h:mm a')
                                        .format(item.date!.toLocal())
                                    : item.detail);
                        final stamp =
                            deadline ? data.lmsSyncedAt : data.qalamSyncedAt;
                        return SizedBox(
                            width: items.length == 1
                                ? constraints.maxWidth
                                : math.max(
                                    160.0,
                                    math.min(
                                        240.0, constraints.maxWidth * .55)),
                            child: Tooltip(
                                message:
                                    '${item.meta?['demo'] == true ? 'Demo data' : deadline ? 'LMS' : 'Qalam'}${stamp == null ? '' : ' · Updated ${DateFormat('d MMM, h:mm a').format(stamp.toLocal())}'}',
                                child: Card.outlined(
                                    margin: EdgeInsets.zero,
                                    color: deadline
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surfaceContainerLow,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: deadline
                                                ? theme.colorScheme.tertiary
                                                    .withValues(alpha: .45)
                                                : theme.colorScheme
                                                    .outlineVariant)),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                        onTap: () => onOpen(item, deadline),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.title,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: theme.textTheme
                                                          .titleSmall),
                                                  const SizedBox(height: 4),
                                                  Row(children: [
                                                    Icon(
                                                        deadline
                                                            ? Icons
                                                                .event_outlined
                                                            : Icons
                                                                .schedule_rounded,
                                                        size: 14,
                                                        color: deadline
                                                            ? theme.colorScheme
                                                                .tertiary
                                                            : theme.colorScheme
                                                                .primary),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                        child: Text(timing,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: theme
                                                                .textTheme
                                                                .labelMedium
                                                                ?.copyWith(
                                                                    color: deadline
                                                                        ? theme
                                                                            .colorScheme
                                                                            .tertiary
                                                                        : theme
                                                                            .colorScheme
                                                                            .primary)))
                                                  ]),
                                                ]))))));
                      }))),
        ]));
  }
}
