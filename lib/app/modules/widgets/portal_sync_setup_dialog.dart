import 'package:flutter/material.dart';

Future<bool?> showPortalSyncSetup(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.sync_lock_rounded),
        title: const Text('Your academic day, ready when you are'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Benefit(
                icon: Icons.insights_rounded,
                title: 'GPA at a glance',
                detail:
                    'See official CGPA and the latest semester GPA on Home.'),
            const _Benefit(
                icon: Icons.today_rounded,
                title: 'Stay on top of your day',
                detail:
                    'Sync timetable, attendance, deadlines and outstanding challans.'),
            const _Benefit(
                icon: Icons.history_edu_rounded,
                title: 'Skip manual GPA entry',
                detail:
                    'Import previous terms and their graded courses into your planner.'),
            const SizedBox(height: 16),
            Text('You are in control',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'This independent app signs in directly to the official portals using details you choose to save. Credentials and summaries use encrypted local app storage; sync does not upload them to our servers. Official portals receive your sign-in and read requests, and may keep session cookies.\n\n'
              'Enable automatic sync to refresh on app launch and when returning after a minute. Cached summaries work offline and show their source and sync time. You can disable sync or remove the connection and local summaries in Settings. Saving credentials is optional; the planners and official web view still work without it. University results remain authoritative.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable automatic sync')),
        ],
      ),
    );

class _Benefit extends StatelessWidget {
  const _Benefit(
      {required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(detail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ])),
        ]),
      );
}
