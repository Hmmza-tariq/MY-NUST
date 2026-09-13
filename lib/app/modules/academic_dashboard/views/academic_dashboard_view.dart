import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/academic_dashboard.dart';
import '../../widgets/app_page_shell.dart';
import '../controllers/academic_dashboard_controller.dart';

class AcademicDashboardView extends GetView<AcademicDashboardController> {
  const AcademicDashboardView({super.key});

  @override
  Widget build(BuildContext context) => AppPageShell(
        title: 'Academic details',
        trailing: Obx(() => TextButton.icon(
              onPressed: controller.syncService.isSyncing.value
                  ? null
                  : controller.syncService.canAutoSync
                      ? controller.sync
                      : controller.openSettings,
              icon: controller.syncService.isSyncing.value
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(controller.syncService.isSyncing.value
                  ? 'Syncing…'
                  : 'Synced ${_relativeTime(controller.data.value.qalamSyncedAt)}'),
            )),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'academic-portals',
          onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => SafeArea(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: const Text('Open official Qalam'),
                        onTap: () {
                          Navigator.pop(context);
                          controller.openQalam();
                        }),
                    ListTile(
                        leading: const Icon(Icons.menu_book_outlined),
                        title: const Text('Open official LMS'),
                        onTap: () {
                          Navigator.pop(context);
                          controller.openLms();
                        }),
                  ]))),
          icon: const Icon(Icons.open_in_browser_rounded),
          label: const Text('Official portals'),
        ),
        subtitle: 'A clean summary from your connected academic portals.',
        child: Obx(() {
          final data = controller.data.value;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.syncService.qalamAttempted.value &&
                      !controller.syncService.qalamAuthenticated.value &&
                      !controller.syncService.isSyncing.value)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(controller.syncService.statusText.value,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  _TimetableCard(
                    items: data.timetable,
                    syncedAt: data.qalamSyncedAt,
                    onOpen: controller.openQalam,
                  ),
                  const SizedBox(height: 12),
                  _DeadlinesCard(
                    items: data.deadlines,
                    syncedAt: data.lmsSyncedAt,
                    onOpen: controller.openLms,
                  ),
                  const SizedBox(height: 12),
                  _AttendanceCard(
                    items: data.attendance,
                    syncedAt: data.qalamSyncedAt,
                    onOpen: controller.openQalam,
                  ),
                  const SizedBox(height: 12),
                  _InvoicesCard(
                    items: data.invoices,
                    syncedAt: data.qalamSyncedAt,
                    onOpen: controller.openQalam,
                  ),
                  const SizedBox(height: 88),
                ],
              ),
            ),
          );
        }),
      );
}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({
    required this.items,
    required this.syncedAt,
    required this.onOpen,
  });
  final List<AcademicItem> items;
  final DateTime? syncedAt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Today’s timetable',
        icon: Icons.calendar_today_rounded,
        source: 'Qalam',
        syncedAt: syncedAt,
        onOpen: onOpen,
        child: items.isEmpty
            ? const _EmptyState(
                icon: Icons.event_available_rounded,
                title: 'No classes today',
                message: 'Qalam has no classes scheduled for today.',
              )
            : Column(
                children: items
                    .take(5)
                    .map((item) => _SimpleItem(
                          title: item.title,
                          supporting: item.detail,
                          icon: Icons.schedule_rounded,
                        ))
                    .toList(),
              ),
      );
}

class _DeadlinesCard extends StatelessWidget {
  const _DeadlinesCard({
    required this.items,
    required this.syncedAt,
    required this.onOpen,
  });
  final List<AcademicItem> items;
  final DateTime? syncedAt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Upcoming deadlines',
        icon: Icons.task_alt_rounded,
        source: 'LMS',
        syncedAt: syncedAt,
        onOpen: onOpen,
        child: items.isEmpty
            ? const _EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Nothing due soon',
                message: 'No assignment or quiz deadlines were found.',
              )
            : Column(
                children: items
                    .take(4)
                    .map((item) => _SimpleItem(
                          title: item.title,
                          supporting: item.detail,
                          icon: Icons.assignment_outlined,
                        ))
                    .toList(),
              ),
      );
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.items,
    required this.syncedAt,
    required this.onOpen,
  });
  final List<AcademicItem> items;
  final DateTime? syncedAt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Attendance',
        icon: Icons.fact_check_outlined,
        source: 'Qalam',
        syncedAt: syncedAt,
        onOpen: onOpen,
        child: items.isEmpty
            ? const _EmptyState(
                icon: Icons.query_stats_rounded,
                title: 'No course attendance found',
                message: 'Course totals will appear after the next Qalam sync.',
              )
            : Column(
                children: items
                    .take(6)
                    .map((item) => _AttendanceCourse(item: item))
                    .toList(),
              ),
      );
}

class _InvoicesCard extends StatelessWidget {
  const _InvoicesCard({
    required this.items,
    required this.syncedAt,
    required this.onOpen,
  });
  final List<AcademicItem> items;
  final DateTime? syncedAt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final unpaid = items.where((item) => item.meta?['isPaid'] != true).toList();
    final paid = items.length - unpaid.length;
    return _SectionCard(
      title: 'Invoices & challans',
      icon: Icons.receipt_long_outlined,
      source: 'Qalam',
      syncedAt: syncedAt,
      onOpen: onOpen,
      child: unpaid.isEmpty
          ? _EmptyState(
              icon: Icons.price_check_rounded,
              title: items.isEmpty ? 'No challans found' : 'No payments due',
              message: paid == 0
                  ? 'Outstanding fee or mess challans will appear here.'
                  : '$paid paid challan${paid == 1 ? '' : 's'} synced. Paid items stay out of your Today list.',
            )
          : Column(
              children: unpaid
                  .take(4)
                  .map((item) => _InvoiceItem(item: item))
                  .toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.source,
    required this.syncedAt,
    required this.onOpen,
    required this.child,
  });
  final String title;
  final IconData icon;
  final String source;
  final DateTime? syncedAt;
  final VoidCallback onOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _IconTile(
                  icon: icon,
                  background: scheme.secondaryContainer,
                  foreground: scheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.2,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: child,
            ),
            const SizedBox(height: 10),
            Divider(color: scheme.outlineVariant),
            _SourceFooter(
              source: source,
              syncedAt: syncedAt,
              onOpen: onOpen,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCourse extends StatelessWidget {
  const _AttendanceCourse({required this.item});
  final AcademicItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = (item.meta?['percent'] as num?)?.toDouble();
    final percent = value?.clamp(0, 100).toDouble() ?? 0;
    final atRisk = percent < 75;
    final code = item.meta?['code']?.toString() ?? '';
    final term = item.meta?['term']?.toString() ?? '';
    final credits = item.meta?['credits']?.toString() ?? '';
    final difference = (percent - 75).abs();
    final status = atRisk
        ? '${difference.toStringAsFixed(_fractionDigits(difference))}% below minimum'
        : '${difference.toStringAsFixed(_fractionDigits(difference))}% above minimum';
    final color = atRisk ? scheme.error : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percent.toStringAsFixed(_fractionDigits(percent))}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          if (code.isNotEmpty || term.isNotEmpty || credits.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [code, term, if (credits.isNotEmpty) '$credits credits']
                  .where((value) => value.isNotEmpty)
                  .join(' • '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              color: color,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                atRisk ? Icons.warning_amber_rounded : Icons.check_rounded,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                'Minimum 75%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceItem extends StatelessWidget {
  const _InvoiceItem({required this.item});
  final AcademicItem item;

  @override
  Widget build(BuildContext context) {
    final meta = item.meta ?? const <String, dynamic>{};
    final amount = _formatAmount(meta['amount']?.toString() ?? '');
    final due = _formatPortalDate(meta['dueDate']?.toString() ?? '');
    final status = meta['status']?.toString() ?? 'Due';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  due.isEmpty ? status : 'Due $due • $status',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (amount.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              amount,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimpleItem extends StatelessWidget {
  const _SimpleItem({
    required this.title,
    required this.supporting,
    required this.icon,
  });
  final String title;
  final String supporting;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                if (supporting.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supporting,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({
    required this.source,
    required this.syncedAt,
    required this.onOpen,
  });
  final String source;
  final DateTime? syncedAt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.cloud_done_outlined,
            size: 17, color: scheme.onSurfaceVariant),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '$source · ${_shortTimestamp(syncedAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.foreground,
  });
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: foreground, size: 22),
      );
}

int _fractionDigits(double value) => value == value.roundToDouble() ? 0 : 1;

String _shortTimestamp(DateTime? value) {
  if (value == null) return 'Not synced';
  final local = value.toLocal();
  final now = DateTime.now();
  final date = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final prefix =
      date == today ? 'Today' : '${_months[local.month - 1]} ${local.day}';
  return '$prefix, ${_clock(local)}';
}

String _relativeTime(DateTime? value) {
  if (value == null) return 'not yet';
  final difference = DateTime.now().difference(value.toLocal());
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hr ago';
  return _shortTimestamp(value);
}

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
}

String _formatPortalDate(String value) {
  final match = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(value);
  if (match == null) return value;
  final month = int.tryParse(match.group(2) ?? '');
  if (month == null || month < 1 || month > 12) return value;
  return '${_months[month - 1]} ${int.parse(match.group(3)!)}, ${match.group(1)}';
}

String _formatAmount(String value) {
  if (value.isEmpty || value == '-') return '';
  final numeric = double.tryParse(value.replaceAll(',', ''));
  if (numeric == null) return value;
  final whole = numeric.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return 'PKR $buffer';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
