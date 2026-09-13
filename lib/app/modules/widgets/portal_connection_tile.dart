import 'package:flutter/material.dart';

class PortalConnectionTile extends StatelessWidget {
  const PortalConnectionTile(
      {super.key,
      required this.enabled,
      required this.syncing,
      required this.hasCredentials,
      required this.needsAttention,
      required this.bannerHidden,
      required this.onChanged,
      required this.onManage,
      required this.onPrivacy,
      required this.onShowBanner});
  final bool enabled, syncing, hasCredentials, needsAttention, bannerHidden;
  final ValueChanged<bool> onChanged;
  final VoidCallback onManage, onPrivacy, onShowBanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = needsAttention
        ? 'Check saved login'
        : syncing
            ? 'Syncing…'
            : !hasCredentials
                ? 'Not connected'
                : enabled
                    ? 'Connected'
                    : 'Paused';
    return Row(children: [
      Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.sync_lock_rounded,
              color: scheme.onSecondaryContainer)),
      const SizedBox(width: 12),
      Expanded(
          child: InkWell(
              onTap: onManage,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Portal connection',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(state,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: needsAttention
                                    ? scheme.error
                                    : scheme.onSurfaceVariant)),
                      ])))),
      Switch(value: enabled, onChanged: onChanged),
      PopupMenuButton<String>(
          tooltip: 'Connection options',
          onSelected: (value) {
            switch (value) {
              case 'manage':
                onManage();
                break;
              case 'privacy':
                onPrivacy();
                break;
              case 'banner':
                onShowBanner();
                break;
            }
          },
          itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'manage', child: Text('Manage credentials')),
                const PopupMenuItem(
                    value: 'privacy', child: Text('Benefits & privacy')),
                if (bannerHidden)
                  const PopupMenuItem(
                      value: 'banner', child: Text('Show Home banner')),
              ]),
    ]);
  }
}
