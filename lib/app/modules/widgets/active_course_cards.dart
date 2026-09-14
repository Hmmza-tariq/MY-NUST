import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/academic_dashboard.dart';
import '../../services/academic_sync_service.dart';
import '../../routes/app_pages.dart';
import 'app_page_shell.dart';
import 'custom_snackbar.dart';

class ActiveCourseCards extends StatelessWidget {
  const ActiveCourseCards({super.key, required this.courses, this.onCourseTap});
  final List<AcademicItem> courses;
  final ValueChanged<AcademicItem>? onCourseTap;
  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Active courses', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, constraints) {
        final width = courses.length == 1
            ? constraints.maxWidth
            : courses.length == 2
                ? (constraints.maxWidth - 12) / 2
                : math.max(148.0, math.min(220.0, constraints.maxWidth * .44));
        return SizedBox(
            height: 72 + math.max(0.0, scale - 1) * 64,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                separatorBuilder: (_, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final percent = (course.meta?['percent'] as num?)?.toDouble();
                  return SizedBox(
                      width: width,
                      child: Semantics(
                          label: percent == null
                              ? 'Attendance unavailable'
                              : '${percent.toStringAsFixed(1)} percent attendance',
                          child: CustomPaint(
                              foregroundPainter: AttendanceBorderPainter(
                                  progress: (percent ?? 0).clamp(0, 100) / 100,
                                  color: percent != null && percent < 75
                                      ? scheme.error
                                      : scheme.primary,
                                  track: scheme.outlineVariant),
                              child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  color: scheme.surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                      onTap: () => onCourseTap != null
                                          ? onCourseTap!(course)
                                          : Get.to(() => CourseDetailsPage(
                                              course: course)),
                                      child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Positioned(
                                                top: 6,
                                                left: 10,
                                                child: ExcludeSemantics(
                                                    child: Text(
                                                        percent == null
                                                            ? '—'
                                                            : '${percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1)}%',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: percent !=
                                                                            null &&
                                                                        percent <
                                                                            75
                                                                    ? scheme
                                                                        .error
                                                                    : scheme
                                                                        .primary)))),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    12,
                                                    MediaQuery.textScalerOf(
                                                                context)
                                                            .scale(11) *
                                                        1,
                                                    12,
                                                    6),
                                                child: Center(
                                                    child: Text(
                                                        course.title,
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)))),
                                          ]))))));
                }));
      }),
    ]);
  }
}

/// A clockwise attendance trace, starting at the top-left straight edge.
/// The remaining perimeter is a neutral track; the fill never covers content.
class AttendanceBorderPainter extends CustomPainter {
  const AttendanceBorderPainter(
      {required this.progress, required this.color, required this.track});
  final double progress;
  final Color color, track;
  Path borderPath(Size size) {
    const inset = 1.5;
    const radius = 10.5;
    final rect = (Offset.zero & size).deflate(inset);
    return Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius),
          radius: const Radius.circular(radius))
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(Offset(rect.right - radius, rect.bottom),
          radius: const Radius.circular(radius))
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius),
          radius: const Radius.circular(radius))
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(Offset(rect.left + radius, rect.top),
          radius: const Radius.circular(radius))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = borderPath(size);
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawPath(path, pen);
    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        pen..color = color);
  }

  @override
  bool shouldRepaint(AttendanceBorderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track;
}

class AttendanceRing extends StatelessWidget {
  const AttendanceRing({super.key, this.percent, this.diameter = 76});
  final double? percent;
  final double diameter;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color =
        percent != null && percent! < 75 ? scheme.error : scheme.primary;
    return Semantics(
        label: percent == null
            ? 'Attendance unavailable'
            : '${percent!.toStringAsFixed(1)} percent attendance',
        child: ExcludeSemantics(
            child: SizedBox(
                width: diameter,
                height: diameter,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(
                      child: CircularProgressIndicator(
                          value: (percent ?? 0).clamp(0, 100) / 100,
                          strokeWidth: 4,
                          backgroundColor: scheme.surfaceContainerHighest,
                          color: color)),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: FittedBox(
                          child: Text(
                              percent == null
                                  ? '—'
                                  : '${percent!.toStringAsFixed(percent! % 1 == 0 ? 0 : 1)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700)))),
                ]))));
  }
}

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key, required this.course});
  final AcademicItem course;
  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  bool refreshing = false;
  AcademicSyncService? get sync => Get.isRegistered<AcademicSyncService>()
      ? Get.find<AcademicSyncService>()
      : null;
  @override
  void initState() {
    super.initState();
    if (widget.course.meta?['categories'] == null &&
        widget.course.url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
  }

  Future<void> _refresh() async {
    if (widget.course.meta?['demo'] == true) return;
    final service = sync;
    if (refreshing || service == null || widget.course.url == null) return;
    if (!service.canSyncQalam) {
      AppSnackbar.info(
          message: 'Connect Qalam in Settings to sync course marks.');
      return;
    }
    setState(() => refreshing = true);
    try {
      await service.syncCourseGrades(widget.course.url!);
      if (service.credentialsRejected.value) {
        AppSnackbar.error(message: service.statusText.value);
      }
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) => sync == null
      ? _content(widget.course)
      : Obx(() {
          final matches = sync!.data.value.attendance.where((e) =>
              e.url == widget.course.url && e.title == widget.course.title);
          return _content(matches.firstOrNull ?? widget.course);
        });

  Widget _content(AcademicItem course) {
    final scheme = Theme.of(context).colorScheme;
    final categories =
        (course.meta?['categories'] as List? ?? []).whereType<Map>();
    String value(dynamic number) =>
        number is num ? number.toStringAsFixed(number % 1 == 0 ? 0 : 2) : '—';
    final stamp =
        DateTime.tryParse(course.meta?['marksSyncedAt']?.toString() ?? '');
    final demo = course.meta?['demo'] == true;
    return AppPageShell(
        title: course.title,
        subtitle: course.detail,
        trailing: IconButton(
            tooltip: 'Sync course marks',
            onPressed: refreshing || demo ? null : _refresh,
            icon: const Icon(Icons.sync_rounded)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    AttendanceRing(
                        percent: (course.meta?['percent'] as num?)?.toDouble(),
                        diameter: 52),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Attendance',
                              style: Theme.of(context).textTheme.titleSmall),
                          if (course.meta?['instructor'] != null)
                            Text(course.meta!['instructor'].toString(),
                                style: Theme.of(context).textTheme.bodySmall),
                        ])),
                  ]))),
          const SizedBox(height: 16),
          Text('Assessment results',
              style: Theme.of(context).textTheme.titleLarge),
          Text(
              demo
                  ? 'Demo results · Sample data only'
                  : 'Scores published in your official gradebook',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          if (refreshing)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator()),
          if (categories.isEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(refreshing
                    ? 'Fetching your official gradebook…'
                    : stamp != null
                        ? 'No assessment results have been published yet.'
                        : 'Gradebook details aren’t available locally yet. Sync or open the official portal.')),
          for (final category in categories)
            Card.outlined(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                    title: Text(category['name']?.toString() ?? 'Assessment'),
                    subtitle:
                        Text('${value(category['weight'])}% of final grade'),
                    trailing: Text(
                        category['obtainedPercentage'] == null
                            ? 'Pending'
                            : '${value(category['obtainedPercentage'])}%',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: scheme.primary)),
                    children: [
                      for (final assessment
                          in (category['assessments'] as List? ?? [])
                              .whereType<Map>())
                        _AssessmentRow(assessment: assessment),
                    ])),
          const SizedBox(height: 8),
          Text(
              stamp == null
                  ? 'Source: Qalam · Marks not synced'
                  : '${demo ? 'Demo data' : 'Source: Qalam'} · Updated ${DateFormat('d MMM, h:mm a').format(stamp.toLocal())}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
              'Missing marks are shown as —. Published zero scores remain zero. Official records are authoritative.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
              onPressed: course.url == null || demo
                  ? null
                  : () =>
                      Get.toNamed(Routes.WEB, parameters: {'url': course.url!}),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in official portal')),
        ]));
  }
}

class _AssessmentRow extends StatelessWidget {
  const _AssessmentRow({required this.assessment});
  final Map assessment;
  String value(dynamic number) =>
      number is num ? number.toStringAsFixed(number % 1 == 0 ? 0 : 2) : '—';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pending = assessment['obtainedMarks'] == null;
    final percentage = assessment['percentage'] as num?;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Divider(height: 16),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(assessment['name']?.toString() ?? 'Assessment',
                    style: theme.textTheme.titleSmall),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: pending
                            ? scheme.secondaryContainer
                            : scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                        pending
                            ? 'Awaiting marks'
                            : 'Marks: ${value(assessment['obtainedMarks'])} / ${value(assessment['maxMarks'])}',
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: pending
                                ? scheme.onSecondaryContainer
                                : scheme.onPrimaryContainer))),
              ]),
          const SizedBox(height: 8),
          if (percentage != null) ...[
            LinearProgressIndicator(
                value: percentage.toDouble().clamp(0, 100) / 100,
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
                color: percentage < 50 ? scheme.error : scheme.primary,
                backgroundColor: scheme.surfaceContainerHighest),
            const SizedBox(height: 8),
          ],
          Text(
              'Class average: ${value(assessment['classAverage'])} · ${value(percentage)}%',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ]));
  }
}
