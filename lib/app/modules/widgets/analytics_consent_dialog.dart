import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/analytics_service.dart';
import 'app_dialog.dart';
import 'app_page_shell.dart';

enum _ConsentChoice { enable, details, decline }

Future<void> showAnalyticsConsent(BuildContext context,
    {AnalyticsService? service}) async {
  final analytics = service ?? AnalyticsService.instance;
  if (!analytics.needsConsent || !context.mounted) return;
  final choice = await showDialog<_ConsentChoice>(
    context: context,
    builder: (_) => const _AnalyticsLaunchPrompt(),
  );
  if (choice == _ConsentChoice.details && context.mounted) {
    await showAnalyticsDetails(context, service: analytics);
    if (analytics.needsConsent) await analytics.setEnabled(false);
  } else {
    // Back and barrier dismissal are not affirmative consent.
    await analytics.setEnabled(choice == _ConsentChoice.enable);
  }
}

class _AnalyticsLaunchPrompt extends StatelessWidget {
  const _AnalyticsLaunchPrompt();

  void _finish(BuildContext context, _ConsentChoice choice) =>
      Navigator.pop(context, choice);

  @override
  Widget build(BuildContext context) => AlertDialog(
        icon: Icon(Icons.insights_rounded,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Help improve My NUST?'),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text(
                  'Optional analytics shares feature activity, loading times, app/device information, '
                  'an app instance ID and approximate IP-based location with Google Firebase to improve the app. '
                  'Credentials, grades and feedback text are excluded. No advertising.'),
              const SizedBox(height: 12),
              Text(
                  'Off by default. Enable only if you choose. Manage this in About.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: appSecondaryText(context))),
              TextButton(
                  onPressed: () => _finish(context, _ConsentChoice.details),
                  child: const Text('View details')),
            ])),
        actions: [
          TextButton(
              onPressed: () => _finish(context, _ConsentChoice.decline),
              child: const Text('Not now')),
          FilledButton(
              onPressed: () => _finish(context, _ConsentChoice.enable),
              child: const Text('Enable analytics')),
        ],
      );
}

Future<void> showAnalyticsDetails(BuildContext context,
    {AnalyticsService? service}) async {
  await showAppSheet<void>(
      context: context,
      child:
          AnalyticsDetailsSheet(service: service ?? AnalyticsService.instance));
}

class AnalyticsDetailsSheet extends StatefulWidget {
  const AnalyticsDetailsSheet({super.key, required this.service});
  final AnalyticsService service;
  @override
  State<AnalyticsDetailsSheet> createState() => _AnalyticsDetailsSheetState();
}

class _AnalyticsDetailsSheetState extends State<AnalyticsDetailsSheet> {
  bool _saving = false;
  String? _error;
  Future<void> _save(bool enabled) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final saved = await widget.service.setEnabled(enabled);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = 'Could not save your choice. Analytics remains off.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .8),
        child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.insights_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Usage analytics',
                        style: Theme.of(context).textTheme.titleLarge)),
                IconButton(
                    tooltip: 'Close',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 12),
              const Text(
                  'Help us understand which features work well. Every app feature works with analytics off.'),
              const SizedBox(height: 20),
              Text('What is shared with Google Firebase',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              const Text(
                  'Feature taps, screen visits, public news and portal destination activity, counts, '
                  'loading/sync times, app/device information, an app instance identifier and approximate location inferred from IP addresses.'),
              const SizedBox(height: 20),
              Text('What stays out of analytics',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              const Text(
                  'Names, student IDs, passwords, cookies, portal HTML, grades, marks, attendance, invoices, '
                  'feedback text and private URLs. Advertising features stay disabled.'),
              const SizedBox(height: 16),
              const Text(
                  'You can change your choice in About at any time. Turning analytics off stops collection '
                  'and resets local analytics data and this device’s analytics ID. Previously processed server reports are not automatically deleted.'),
              TextButton.icon(
                  onPressed: () => launchUrl(
                      Uri.parse('https://mynust.web.app/privacy/'),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Privacy policy')),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                  valueListenable: widget.service.enabled,
                  builder: (context, enabled, _) => SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                          onPressed: _saving ? null : () => _save(!enabled),
                          icon: _saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Icon(enabled
                                  ? Icons.pause_rounded
                                  : Icons.insights_rounded),
                          label: Text(enabled
                              ? 'Turn analytics off'
                              : 'Enable analytics')))),
              const SizedBox(height: 8),
            ])),
      );
}

class AnalyticsPreferenceTile extends StatelessWidget {
  const AnalyticsPreferenceTile({super.key, this.service});
  final AnalyticsService? service;
  @override
  Widget build(BuildContext context) {
    final analytics = service ?? AnalyticsService.instance;
    return ValueListenableBuilder<bool>(
        valueListenable: analytics.enabled,
        builder: (context, enabled, _) => AppSectionCard(
                child: ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 24,
              horizontalTitleGap: 12,
              leading: Icon(Icons.insights_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Enable analytics'),
              subtitle:
                  Text(enabled ? 'On · Tap for details' : 'Off · Optional'),
              trailing: Switch.adaptive(
                  value: enabled,
                  onChanged: (value) async {
                    if (value) {
                      await showAnalyticsDetails(context, service: analytics);
                    } else {
                      await analytics.setEnabled(false);
                    }
                  }),
              onTap: () => showAnalyticsDetails(context, service: analytics),
            )));
  }
}
