import 'package:flutter/material.dart';
import 'app_page_shell.dart';

class AppUpdateTile extends StatelessWidget {
  const AppUpdateTile(
      {super.key,
      required this.checking,
      required this.available,
      required this.status,
      required this.onCheck});
  final bool checking, available;
  final String status;
  final VoidCallback? onCheck;
  @override
  Widget build(BuildContext context) => AppSectionCard(
          child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.system_update_alt_rounded,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('App updates'),
        subtitle: Text(checking
            ? 'Checking Google Play…'
            : available
                ? 'New version available'
                : status),
        trailing: checking
            ? const SizedBox.square(
                dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right_rounded),
        onTap: checking ? null : onCheck,
      ));
}
