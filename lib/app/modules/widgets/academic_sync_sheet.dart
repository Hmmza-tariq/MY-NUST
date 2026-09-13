import 'package:flutter/material.dart';

class AcademicSyncSheet extends StatelessWidget {
  const AcademicSyncSheet(
      {required this.termCount,
      required this.courseCount,
      required this.busy,
      required this.onImport,
      required this.onSync,
      required this.onOpenPortal,
      this.syncedAt,
      super.key});
  final int termCount;
  final int courseCount;
  final bool busy;
  final DateTime? syncedAt;
  final VoidCallback onImport;
  final VoidCallback onSync;
  final VoidCallback onOpenPortal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stamp = syncedAt?.toLocal();
    Widget action(
            {required IconData icon,
            required String title,
            required String subtitle,
            required VoidCallback onTap,
            bool primary = false}) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
                color: primary
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                    enabled: !busy,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Icon(icon,
                        color: primary
                            ? scheme.onPrimaryContainer
                            : scheme.primary),
                    title: Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: primary
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: primary
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: onTap)));
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sync & import',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
              termCount == 0
                  ? 'Bring your academic history into the planner.'
                  : '$termCount terms · $courseCount graded courses available offline',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12)
          ],
          action(
              icon: Icons.playlist_add_rounded,
              title:
                  termCount == 0 ? 'Connect & import' : 'Import saved results',
              subtitle: 'Add terms and courses. Your existing edits stay safe.',
              onTap: onImport,
              primary: true),
          action(
              icon: Icons.sync_rounded,
              title: 'Refresh from Qalam',
              subtitle: 'Fetch the latest GPA and academic records.',
              onTap: onSync),
          action(
              icon: Icons.open_in_browser_rounded,
              title: 'Open official results',
              subtitle: 'View the original records in Qalam.',
              onTap: onOpenPortal),
          const SizedBox(height: 8),
          Text(
              stamp == null
                  ? 'Qalam Results · Not synced yet'
                  : 'Qalam Results · ${stamp.day}/${stamp.month}/${stamp.year} ${stamp.hour.toString().padLeft(2, '0')}:${stamp.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ]);
  }
}
