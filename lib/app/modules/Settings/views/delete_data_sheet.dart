import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';

class DeleteDataSheet extends StatefulWidget {
  const DeleteDataSheet({super.key});
  @override
  State<DeleteDataSheet> createState() => _DeleteDataSheetState();
}

class _DeleteDataSheetState extends State<DeleteDataSheet> {
  final selected = SavedDataCategory.values.toSet();
  bool acknowledged = false;
  static const labels = {
    SavedDataCategory.portal: (
      'Portal connection',
      'Saved credentials, cookies and synced academic summaries'
    ),
    SavedDataCategory.gpa: (
      'GPA planner',
      'Every semester and course, including imported results and edits'
    ),
    SavedDataCategory.absolute: (
      'Absolute planner',
      'Assessments and lecture/lab weights'
    ),
    SavedDataCategory.downloads: (
      'App downloads',
      'Files downloaded through this app; other downloads are kept'
    ),
    SavedDataCategory.preferences: (
      'Preferences & news cache',
      'Theme, campus, biometric setting and cached news'
    ),
  };
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete saved data',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                  'Choose what to remove from this device. Official university records and accounts are never deleted.'),
              TextButton(
                  onPressed: () => setState(() {
                        selected.length == labels.length
                            ? selected.clear()
                            : selected.addAll(labels.keys);
                        acknowledged = false;
                      }),
                  child: Text(selected.length == labels.length
                      ? 'Deselect all'
                      : 'Select all')),
              for (final entry in labels.entries)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selected.contains(entry.key),
                  title: Text(entry.value.$1),
                  subtitle: Text(entry.value.$2),
                  onChanged: (value) => setState(() {
                    value == true
                        ? selected.add(entry.key)
                        : selected.remove(entry.key);
                    acknowledged = false;
                  }),
                ),
              const Divider(height: 24),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: acknowledged,
                  title: const Text('I understand this cannot be undone'),
                  onChanged: (value) =>
                      setState(() => acknowledged = value == true)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(
                    child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError),
                        onPressed: acknowledged && selected.isNotEmpty
                            ? () => Navigator.pop(context, selected.toSet())
                            : null,
                        child: const Text('Delete selected'))),
              ]),
            ]),
      );
}
