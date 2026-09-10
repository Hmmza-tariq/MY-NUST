import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import 'app_glass_surface.dart';

Color appSecondaryText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.scrollable = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () {
                  if (Get.previousRoute.isEmpty) {
                    Get.offAllNamed(Routes.HOME);
                  } else {
                    Get.back();
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appSecondaryText(context),
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: scrollable
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Positioned(
            top: -92,
            right: -72,
            child: _BackgroundShape(
              size: 240,
              color: scheme.tertiaryContainer.withValues(alpha: .52),
              radius: 76,
              rotation: .28,
            ),
          ),
          Positioned(
            top: 360,
            left: -96,
            child: _BackgroundShape(
              size: 190,
              color: scheme.secondaryContainer.withValues(alpha: .56),
              radius: 58,
              rotation: -.22,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _BackgroundShape extends StatelessWidget {
  const _BackgroundShape({
    required this.size,
    required this.color,
    required this.radius,
    required this.rotation,
  });

  final double size;
  final Color color;
  final double radius;
  final double rotation;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: rotation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        borderRadius: 12,
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      );
}
