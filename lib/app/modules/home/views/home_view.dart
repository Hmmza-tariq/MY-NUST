import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/data/story.dart';
import 'package:nust/app/modules/widgets/app_glass_surface.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';
import 'package:nust/app/modules/widgets/app_page_shell.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.themeController.isDarkMode.value;
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            const Positioned.fill(child: _HomeBackdrop()),
            SafeArea(
              child: ScrollConfiguration(
                behavior:
                    const MaterialScrollBehavior().copyWith(overscroll: false),
                child: RefreshIndicator(
                  onRefresh: controller.fetchStoriesInBackground,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        toolbarHeight: 72,
                        titleSpacing: 16,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: .0),
                        surfaceTintColor: Colors.transparent,
                        title: _TopBar(controller: controller),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                        sliver: SliverList.list(
                          children: [
                            _Entrance(
                              order: 1,
                              child: _WelcomeHeader(controller: controller),
                            ),
                            const SizedBox(height: 24),
                            const _SectionTitle(
                              title: 'Student portals',
                              subtitle: 'Your academic services in one place',
                            ),
                            const SizedBox(height: 12),
                            _Entrance(
                              order: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _PortalCard(
                                      title: 'LMS',
                                      subtitle: 'Courses & assignments',
                                      icon: Icons.school_rounded,
                                      onTap: () => Get.toNamed(
                                        Routes.WEB,
                                        parameters: {'url': controller.lmsUrl},
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _PortalCard(
                                      title: 'Qalam',
                                      subtitle: 'Records & invoices',
                                      icon: Icons.account_balance_rounded,
                                      onTap: () => Get.toNamed(
                                        Routes.WEB,
                                        parameters: {
                                          'url': controller.qalamUrl
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              title: 'Academic tools',
                              subtitle: 'Plan with instant, local calculations',
                            ),
                            const SizedBox(height: 12),
                            _Entrance(
                              order: 3,
                              child: AppGlassSurface(
                                child: Column(
                                  children: [
                                    _HomeAction(
                                      icon: Icons.calculate_rounded,
                                      title: 'GPA planner',
                                      subtitle:
                                          'Project SGPA and its live CGPA impact',
                                      onTap: () =>
                                          Get.toNamed(Routes.GPA_CALCULATION),
                                    ),
                                    const Divider(height: 1),
                                    _HomeAction(
                                      icon: Icons.fact_check_rounded,
                                      title: 'Absolute score',
                                      subtitle:
                                          'Estimate your course performance',
                                      onTap: () => Get.toNamed(
                                        Routes.ABSOLUTES_CALCULATION,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _UpdatesHeader(controller: controller),
                            const SizedBox(height: 12),
                            _UpdatesList(controller: controller),
                            const SizedBox(height: 28),
                            _Entrance(
                              order: 5,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _UtilityButton(
                                      label: 'Settings',
                                      icon: Icons.tune_rounded,
                                      onTap: () => Get.toNamed(Routes.SETTINGS),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _UtilityButton(
                                      label: 'Help',
                                      icon: Icons.help_outline_rounded,
                                      onTap: () => Get.toNamed(Routes.HELP),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _UtilityButton(
                                      label: 'About',
                                      icon: Icons.info_outline_rounded,
                                      onTap: () => Get.toNamed(Routes.ABOUT),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) =>
      const AppBackground(child: SizedBox.expand());
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        borderRadius: 16,
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(AssetsManager.logo, width: 42, height: 42),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showCampusPicker(context, controller),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Flexible(
                        child: Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: Text(
                              '${controller.campusController.selectedCampus.value} Campus',
                              key: ValueKey(controller
                                  .campusController.selectedCampus.value),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Downloaded files',
              onPressed: () => Get.toNamed(Routes.DOWNLOADS),
              icon: const Icon(Icons.folder_rounded),
            ),
          ],
        ),
      );

  void _showCampusPicker(BuildContext context, HomeController controller) {
    final selectedCampus = controller.campusController.selectedCampus.value;
    final campuses = [...controller.campusController.campuses]
      ..remove(selectedCampus)
      ..insert(0, selectedCampus);
    var query = '';
    showAppSheet<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final scheme = Theme.of(context).colorScheme;
          final filtered = campuses
              .where((campus) =>
                  campus.toLowerCase().contains(query.trim().toLowerCase()))
              .toList();
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * .78,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your campus',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Updates and downloads will be tailored to this campus.',
                  style: TextStyle(color: appSecondaryText(context)),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Search campus',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => setSheetState(() => query = value),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No campus found',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.sizeOf(context).width >= 600 ? 4 : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.15,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final campus = filtered[index];
                            final selected = campus == selectedCampus;
                            return Material(
                              color: selected
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: selected
                                      ? scheme.primary
                                      : scheme.outlineVariant,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  controller.campusController.setCampus(campus);
                                  controller.fetchStories();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.check_circle_rounded
                                            : Icons.location_on_outlined,
                                        color: selected
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          campus,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY NUST',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.4,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything you need\nfor the semester.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -.5,
                      ),
                ),
              ],
            ),
          ),
          Obx(
            () => IconButton.filledTonal(
              tooltip: controller.isLoading.value
                  ? 'Refreshing updates'
                  : 'Refresh updates',
              onPressed:
                  controller.isLoading.value ? null : controller.fetchStories,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller.isLoading.value
                    ? const SizedBox.square(
                        key: ValueKey('loading'),
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        key: ValueKey('ready'),
                      ),
              ),
            ),
          ),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: appSecondaryText(context),
                ),
          ),
        ],
      );
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return AppGlassSurface(
      borderRadius: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const Icon(Icons.arrow_outward_rounded, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appSecondaryText(context),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: appSecondaryText(context),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      );
}

class _UpdatesHeader extends StatelessWidget {
  const _UpdatesHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => Obx(() => Row(
        children: [
          const Expanded(
            child: _SectionTitle(
              title: 'Latest updates',
              subtitle: 'From NUST and your campus',
            ),
          ),
          if (!controller.internetController.isOnline.value)
            const Chip(
              avatar: Icon(Icons.cloud_off_rounded, size: 16),
              label: Text('Offline'),
            ),
        ],
      ));
}

class _UpdatesList extends StatelessWidget {
  const _UpdatesList({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
        final stories = controller.campusController.topStories;
        if (controller.isLoading.value && stories.isEmpty) {
          return const SizedBox(height: 210, child: _StorySkeleton());
        }
        if (stories.isEmpty) {
          return AppGlassSurface(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.inbox_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.internetController.isOnline.value
                        ? 'No updates are available right now.'
                        : 'Connect to refresh. Saved tools remain available.',
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length.clamp(0, 8),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _StoryCard(story: stories[index]),
          ),
        );
      });
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.imageUrl ?? '';
    final link = story.link ?? '';
    return SizedBox(
      width: 292,
      child: AppGlassSurface(
        borderRadius: 12,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: link.isEmpty
                ? null
                : () => Get.toNamed(Routes.WEB, parameters: {'url': link}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 116,
                    width: double.infinity,
                    child: imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 200),
                            placeholder: (_, __) => const _ImagePlaceholder(),
                            errorWidget: (_, __, ___) =>
                                const _ImagePlaceholder(),
                          )
                        : const _ImagePlaceholder(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (story.category ?? 'Campus update').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .6,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          story.title ?? 'Open update',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Center(
          child: Icon(
            Icons.campaign_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
      );
}

class _StorySkeleton extends StatelessWidget {
  const _StorySkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppGlassSurface(
      borderRadius: 12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(semanticsLabel: 'Loading updates'),
            const SizedBox(height: 20),
            Container(
              height: 112,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 12,
              width: 100,
              color: scheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 10),
            Container(
              height: 16,
              width: 250,
              color: scheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        borderRadius: 12,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (order * 24)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 6 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
