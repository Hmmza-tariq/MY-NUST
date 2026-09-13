import 'package:flutter/material.dart';
import '../../data/academic_dashboard.dart';

class AcademicHomeSummary extends StatelessWidget {
  const AcademicHomeSummary(
      {required this.data,
      required this.syncing,
      required this.onOpen,
      super.key});
  final AcademicDashboardData data;
  final bool syncing;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final latest = data.results.isEmpty ? null : data.results.last;
    final synced = data.statsSyncedAt?.toLocal();
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Academic snapshot',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800))),
            IconButton.filledTonal(
              tooltip: 'Academic details',
              onPressed: onOpen,
              icon: const Icon(Icons.dashboard_customize_outlined),
            ),
          ]),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final width = (constraints.maxWidth - 8) / 2;
            return Wrap(spacing: 8, runSpacing: 8, children: [
              _Stat(
                  width: width,
                  label: 'Official CGPA',
                  value: data.stats.cgpa?.toStringAsFixed(2) ?? '—',
                  emphasized: true),
              if (latest != null)
                _Stat(
                    width: width,
                    label: '${latest.name} SGPA',
                    value: latest.sgpa.toStringAsFixed(2)),
            ]);
          }),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: Text(
                    synced == null
                        ? 'Source: Qalam · Not synced'
                        : 'Qalam · ${synced.day}/${synced.month} ${synced.hour.toString().padLeft(2, '0')}:${synced.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant))),
          ]),
        ]),
      ),
    );
  }
}

class AcademicConnectionBanner extends StatelessWidget {
  const AcademicConnectionBanner(
      {required this.hasCredentials,
      required this.syncing,
      required this.onPressed,
      this.onDismiss,
      this.message,
      this.needsCredentialUpdate = false,
      super.key});
  final bool hasCredentials;
  final bool syncing;
  final VoidCallback onPressed;
  final VoidCallback? onDismiss;
  final String? message;
  final bool needsCredentialUpdate;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.lock_outline_rounded,
                    color: scheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Sync your academic stats',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                          message ??
                              (syncing
                                  ? 'Syncing Qalam. Your stats will appear here shortly.'
                                  : hasCredentials
                                      ? 'Your Qalam details are saved. Sync to see your GPA and attendance here.'
                                      : 'Add Qalam credentials to see your GPA and attendance here. Details are stored on this device.'),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ])),
                if (onDismiss != null)
                  PopupMenuButton<String>(
                    tooltip: 'Banner options',
                    onSelected: (_) => onDismiss!(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'hide', child: Text('Don’t show again'))
                    ],
                  ),
              ]),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: syncing ? null : onPressed,
                      child: Text(syncing
                          ? 'Syncing…'
                          : needsCredentialUpdate
                              ? 'Edit credentials'
                              : hasCredentials
                                  ? 'Sync stats'
                                  : 'Add credentials'))),
            ])));
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.width,
      required this.label,
      required this.value,
      this.emphasized = false});
  final double width;
  final String label;
  final String value;
  final bool emphasized;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: emphasized ? scheme.primaryContainer : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color:
                    emphasized ? scheme.onPrimaryContainer : scheme.onSurface)),
        const SizedBox(height: 4),
        Text(label,
            maxLines: 2,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: emphasized
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant)),
      ]),
    );
  }
}
