import 'package:flutter/material.dart';

class GpaImpactSummary extends StatelessWidget {
  const GpaImpactSummary(
      {required this.sgpa,
      required this.termLabel,
      this.currentCgpa,
      this.projectedCgpa,
      super.key});
  final double sgpa;
  final String termLabel;
  final double? currentCgpa;
  final double? projectedCgpa;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final change = currentCgpa == null || projectedCgpa == null
        ? null
        : projectedCgpa! - currentCgpa!;
    return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ColoredBox(
              key: const ValueKey('semester-sgpa-panel'),
              color: scheme.tertiaryContainer,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Semester SGPA',
                              style: theme.textTheme.titleSmall?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(termLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onTertiaryContainer)),
                        ])),
                    const SizedBox(width: 12),
                    Text(sgpa.toStringAsFixed(2),
                        style: theme.textTheme.headlineMedium?.copyWith(
                            color: scheme.onTertiaryContainer,
                            fontWeight: FontWeight.w800)),
                  ]))),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text('CGPA projection',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: scheme.onSurfaceVariant))),
                      if (change != null)
                        Text(
                            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: scheme.primary)),
                    ]),
                    const SizedBox(height: 10),
                    if (change == null)
                      Text(
                          'Add a completed semester to see your CGPA projection.',
                          style: theme.textTheme.bodySmall)
                    else
                      Row(children: [
                        Expanded(
                            child: _GpaValue(
                                label: 'Current CGPA', value: currentCgpa!)),
                        Icon(Icons.arrow_forward_rounded,
                            size: 18, color: scheme.onSurfaceVariant),
                        Expanded(
                            child: _GpaValue(
                                label: 'Projected CGPA',
                                value: projectedCgpa!)),
                      ]),
                  ])),
        ]));
  }
}

class _GpaValue extends StatelessWidget {
  const _GpaValue({required this.label, required this.value});
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value.toStringAsFixed(2),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]);
}
