import 'package:flutter/material.dart';

Future<bool?> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .56),
    builder: (context) => AlertDialog(
      icon: UnconstrainedBox(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
                destructive ? scheme.errorContainer : scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: destructive ? scheme.error : scheme.primary,
          ),
        ),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      )
                    : null,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: theme.colorScheme.surface,
    barrierColor: Colors.black.withValues(alpha: .52),
    builder: (context) => Theme(
      data: theme,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: child,
      ),
    ),
  );
}
