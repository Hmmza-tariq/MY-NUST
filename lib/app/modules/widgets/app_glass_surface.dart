import 'package:flutter/material.dart';

/// Compatibility wrapper for the app's premium layered surface system.
///
/// The old shader-based glass implementation was removed. Keeping this class
/// name lets feature modules migrate without duplicating surface styling.
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    required this.child,
    this.borderRadius = 20,
    this.padding = EdgeInsets.zero,
    this.emphasized = false,
    super.key,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      color: emphasized
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
