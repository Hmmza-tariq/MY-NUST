import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_glass_surface.dart';
import '../../widgets/app_page_shell.dart';
import '../controllers/gpa_calculation_controller.dart';

class GpaCalculationView extends GetView<GpaCalculationController> {
  const GpaCalculationView({super.key});

  @override
  Widget build(BuildContext context) => Obx(
        () => Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 76,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: .96),
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 16,
                    title: _Header(
                      onBack: () => Get.previousRoute.isEmpty
                          ? Get.offAllNamed(Routes.HOME)
                          : Get.back(),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedPlannerHeader(
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.timeline_rounded),
                            label: Text('CGPA'),
                          ),
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.school_outlined),
                            label: Text('SGPA'),
                          ),
                        ],
                        selected: {controller.isCGPA.value},
                        onSelectionChanged: (value) =>
                            controller.isCGPA.value = value.first,
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: controller.isCGPA.value
                            ? _CgpaPane(
                                key: const ValueKey('cgpa'),
                                controller: controller,
                              )
                            : _SgpaPane(
                                key: const ValueKey('sgpa'),
                                controller: controller,
                              ),
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

class _PinnedPlannerHeader extends SliverPersistentHeaderDelegate {
  const _PinnedPlannerHeader({required this.child});
  final Widget child;

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .96),
        elevation: overlapsContent ? 1 : 0,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );

  @override
  bool shouldRebuild(covariant _PinnedPlannerHeader oldDelegate) =>
      oldDelegate.child != child;
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton.outlined(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPA planner',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Plan, adjust, and compare instantly',
                  style: TextStyle(color: appSecondaryText(context)),
                ),
              ],
            ),
          ),
        ],
      );
}

class _CgpaPane extends StatelessWidget {
  const _CgpaPane({required this.controller, super.key});
  final GpaCalculationController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
        if (controller.semesters.isEmpty) {
          return _EmptyPlanner(
            icon: Icons.auto_graph_rounded,
            title: 'Start your CGPA history',
            message:
                'Add completed semesters. You can edit every example value before calculating.',
            primaryLabel: 'Add semester',
            onPrimary: () => _showAddSemesterSheet(context, controller),
            exampleLabel: 'Use example: 18 credits · 3.25 GPA',
            onExample: controller.loadCgpaExample,
          );
        }
        return Column(
          children: [
            _SummaryCard(
              title: 'Current CGPA',
              value: controller.currentCgpa.toStringAsFixed(2),
              detail:
                  '${controller.completedCredits.toInt()} completed credits',
              icon: Icons.insights_rounded,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: controller.semesters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _SemesterCard(
                  controller: controller,
                  index: index,
                ),
              ),
            ),
            _ActionBar(
              addLabel: 'Add semester',
              calculateLabel: 'Calculate CGPA',
              onAdd: () => _showAddSemesterSheet(context, controller),
              onCalculate: controller.calculateCGPA,
            ),
          ],
        );
      });
}

class _SgpaPane extends StatelessWidget {
  const _SgpaPane({required this.controller, super.key});
  final GpaCalculationController controller;

  @override
  Widget build(BuildContext context) => Obx(() => Column(
        children: [
          _SemesterSelector(
            label: 'Planning semester',
            value: controller.selectedSemester.value,
            values: controller.semesterNames,
            onChanged: (value) {
              controller.selectedSemester.value = value;
              controller.loadCourses(value);
            },
          ),
          if (controller.courses.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ProjectionCard(controller: controller),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: controller.courses.isEmpty
                ? _EmptyPlanner(
                    icon: Icons.menu_book_outlined,
                    title: 'Plan this semester',
                    message:
                        'Add courses, select credit hours and choose an expected grade.',
                    primaryLabel: 'Add course',
                    onPrimary: () => _showAddCourseSheet(context, controller),
                    exampleLabel: 'Use example: Calculus · 3 credits · B+',
                    onExample: controller.loadSgpaExample,
                  )
                : ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: controller.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _CourseCard(
                      controller: controller,
                      index: index,
                    ),
                  ),
          ),
          if (controller.courses.isNotEmpty)
            _ActionBar(
              addLabel: 'Add course',
              calculateLabel: 'Calculate SGPA',
              onAdd: () => _showAddCourseSheet(context, controller),
              onCalculate: controller.calculateSGPA,
            ),
        ],
      ));
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({required this.controller, required this.index});
  final GpaCalculationController controller;
  final int index;

  @override
  Widget build(BuildContext context) => Obx(() {
        final semester = controller.semesters[index].value;
        return AppGlassSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SemesterSelector(
                      label: 'Completed semester',
                      value: semester.name,
                      values: controller.semesterNames,
                      onChanged: (value) {
                        controller.semesters[index]
                            .update((item) => item?.name = value);
                        controller.saveSemesters();
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete semester',
                    onPressed: () async {
                      final confirmed = await showAppConfirmationDialog(
                        context: context,
                        title: 'Delete this semester?',
                        message:
                            'This removes the semester from the CGPA calculation.',
                        confirmLabel: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                      );
                      if (confirmed == true) {
                        controller.semesters.removeWhere(
                          (item) => identical(item.value, semester),
                        );
                        controller.saveSemesters();
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _CompactStepper(
                      label: 'Credits',
                      value: semester.credit.toString(),
                      onMinus: semester.credit <= 1
                          ? null
                          : () {
                              controller.semesters[index]
                                  .update((item) => item?.credit--);
                              controller.saveSemesters();
                            },
                      onPlus: semester.credit >= 30
                          ? null
                          : () {
                              controller.semesters[index]
                                  .update((item) => item?.credit++);
                              controller.saveSemesters();
                            },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GpaNumberField(
                      value: semester.gpa,
                      onChanged: (value) {
                        controller.semesters[index]
                            .update((item) => item?.gpa = value);
                        controller.saveSemesters();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.controller, required this.index});
  final GpaCalculationController controller;
  final int index;

  @override
  Widget build(BuildContext context) => Obx(() {
        final course = controller.courses[index].value;
        return AppGlassSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: ObjectKey(course),
                      initialValue: course.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Course name',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                      ),
                      onChanged: (value) {
                        controller.courses[index].value.name = value;
                        controller.saveCourses();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Delete course',
                    onPressed: () async {
                      final confirmed = await showAppConfirmationDialog(
                        context: context,
                        title: 'Delete this course?',
                        message:
                            'This course will no longer count toward the SGPA.',
                        confirmLabel: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                      );
                      if (confirmed == true) {
                        controller.courses.removeWhere(
                          (item) => identical(item.value, course),
                        );
                        controller.saveCourses();
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _CompactStepper(
                    label: 'Credits',
                    value: course.credit.toString(),
                    onMinus: course.credit <= 1
                        ? null
                        : () {
                            controller.courses[index]
                                .update((item) => item?.credit--);
                            controller.saveCourses();
                          },
                    onPlus: course.credit >= 6
                        ? null
                        : () {
                            controller.courses[index]
                                .update((item) => item?.credit++);
                            controller.saveCourses();
                          },
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _CompactGradeStepper(
                    grade: controller.getGrade(course.gpa),
                    onChanged: (grade) {
                      controller.courses[index].update(
                        (item) => item?.gpa = controller.getGradePoint(grade),
                      );
                      controller.saveCourses();
                    },
                  )),
                ],
              ),
            ],
          ),
        );
      });
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({required this.controller});
  final GpaCalculationController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
        final hasHistory =
            controller.semesters.isNotEmpty && controller.completedCredits > 0;
        final change = controller.projectedChange;
        return AppGlassSurface(
          emphasized: true,
          padding: const EdgeInsets.all(16),
          child: hasHistory
              ? Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Live CGPA impact',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        _ValuePill(
                          value: (change >= 0 ? '+' : '') +
                              change.toStringAsFixed(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Metric(
                          label: 'Current',
                          value: controller.currentCgpa.toStringAsFixed(2),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                        _Metric(
                          label: 'Projected',
                          value: controller.projectedCgpa.toStringAsFixed(2),
                        ),
                        _Metric(
                          label: 'SGPA',
                          value: controller.plannedSgpa.toStringAsFixed(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (controller.plannedSgpa / 4).clamp(0, 1),
                        minHeight: 8,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.plannedSgpa >= 3.5
                              ? 'Strong target'
                              : controller.plannedSgpa >= 3
                                  ? 'On track'
                                  : 'Room to grow',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          '${(controller.plannedSgpa / 4 * 100).round()}% of 4.0',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: appSecondaryText(context),
                                  ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add a completed CGPA semester to see the projected change.',
                      ),
                    ),
                  ],
                ),
        );
      });
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });
  final String title;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        emphasized: true,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    detail,
                    style: TextStyle(color: appSecondaryText(context)),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
}

class _EmptyPlanner extends StatelessWidget {
  const _EmptyPlanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.exampleLabel,
    required this.onExample,
  });
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String exampleLabel;
  final VoidCallback onExample;

  @override
  Widget build(BuildContext context) => Center(
        child: AppGlassSurface(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: appSecondaryText(context), height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPrimary,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(primaryLabel),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onExample,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(exampleLabel, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.addLabel,
    required this.calculateLabel,
    required this.onAdd,
    required this.onCalculate,
  });
  final String addLabel;
  final String calculateLabel;
  final VoidCallback onAdd;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(addLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onCalculate,
                child: Text(calculateLabel),
              ),
            ),
          ],
        ),
      );
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton.outlined(
            tooltip: 'Decrease $label',
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 46,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton.outlined(
            tooltip: 'Increase $label',
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      );
}

class _CompactStepper extends StatelessWidget {
  const _CompactStepper({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Decrease $label',
              onPressed: onMinus,
              icon: const Icon(Icons.remove_rounded, size: 20),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: appSecondaryText(context),
                          )),
                  Text(value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      )),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Increase $label',
              onPressed: onPlus,
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
      );
}

class _SemesterSelector extends StatelessWidget {
  const _SemesterSelector({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      menuChildren: values
          .map(
            (item) => MenuItemButton(
              leadingIcon: Icon(
                item == value
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 19,
              ),
              onPressed: () => onChanged(item),
              child: Text(item),
            ),
          )
          .toList(),
      builder: (context, menuController, child) => Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => menuController.isOpen
              ? menuController.close()
              : menuController.open(),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.unfold_more_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactGradeStepper extends StatelessWidget {
  const _CompactGradeStepper({required this.grade, required this.onChanged});
  final String grade;
  final ValueChanged<String> onChanged;
  static const grades = ['F', 'D', 'D+', 'C', 'C+', 'B', 'B+', 'A'];

  @override
  Widget build(BuildContext context) {
    final index = grades.indexOf(grade).clamp(0, grades.length - 1);
    return _CompactStepper(
      label: 'Grade',
      value: grade,
      onMinus: index == 0 ? null : () => onChanged(grades[index - 1]),
      onPlus: index == grades.length - 1
          ? null
          : () => onChanged(grades[index + 1]),
    );
  }
}

class _GpaNumberField extends StatefulWidget {
  const _GpaNumberField({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_GpaNumberField> createState() => _GpaNumberFieldState();
}

class _GpaNumberFieldState extends State<_GpaNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _GpaNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  void _handleFocusChange() {
    setState(() {});
    if (_focusNode.hasFocus) return;
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || parsed < 0 || parsed > 4) {
      _controller.text = widget.value.toStringAsFixed(2);
    } else {
      _controller.text = parsed.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 64,
      padding: const EdgeInsets.fromLTRB(14, 6, 12, 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus ? scheme.primary : scheme.outlineVariant,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semester GPA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _focusNode.hasFocus
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(
                  height: 28,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty ||
                            RegExp(
                              r'^(?:[0-3](?:\.[0-9]{0,2})?|4(?:\.0{0,2})?)$',
                            ).hasMatch(newValue.text)) {
                          return newValue;
                        }
                        return oldValue;
                      }),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (text) {
                      final value = double.tryParse(text);
                      if (value != null && value >= 0 && value <= 4) {
                        widget.onChanged(value);
                      }
                    },
                    onSubmitted: (_) => _focusNode.unfocus(),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '/ 4',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _GradeStepper extends StatelessWidget {
  const _GradeStepper({
    required this.grade,
    required this.gradePoint,
    required this.onChanged,
  });

  final String grade;
  final double gradePoint;
  final ValueChanged<String> onChanged;

  static const grades = ['F', 'D', 'D+', 'C', 'C+', 'B', 'B+', 'A'];

  @override
  Widget build(BuildContext context) {
    final index = grades.indexOf(grade).clamp(0, grades.length - 1);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expected grade',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: appSecondaryText(context),
                      ),
                ),
                Text(
                  '$grade  ·  ${gradePoint.toStringAsFixed(1)} points',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: 'Lower grade',
            onPressed: index == 0 ? null : () => onChanged(grades[index - 1]),
            icon: const Icon(Icons.remove_rounded),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            tooltip: 'Higher grade',
            onPressed: index == grades.length - 1
                ? null
                : () => onChanged(grades[index + 1]),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddSemesterSheet(
  BuildContext context,
  GpaCalculationController controller,
) async {
  var name = controller.semesterNames[controller.semesters.length
      .clamp(0, controller.semesterNames.length - 1)];
  var credits = 18;
  var gpa = 3.0;

  await showAppSheet<void>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add completed semester',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter one semester now. You can fine-tune it later.',
              style: TextStyle(color: appSecondaryText(context)),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: name,
              decoration: const InputDecoration(
                labelText: 'Semester',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              items: controller.semesterNames
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setSheetState(() => name = value);
              },
            ),
            const SizedBox(height: 14),
            _StepperRow(
              label: 'Credit hours',
              value: '$credits',
              onMinus:
                  credits <= 1 ? null : () => setSheetState(() => credits--),
              onPlus:
                  credits >= 30 ? null : () => setSheetState(() => credits++),
            ),
            const SizedBox(height: 12),
            _GpaNumberField(
              value: gpa,
              onChanged: (value) => setSheetState(() => gpa = value),
            ),
            TextButton.icon(
              onPressed: () => setSheetState(() {
                credits = 18;
                gpa = 3.25;
              }),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Fill example: 18 credits · 3.25 GPA'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  controller.addSemesterEntry(
                    name: name,
                    credit: credits,
                    gpa: gpa,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add semester'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showAddCourseSheet(
  BuildContext context,
  GpaCalculationController controller,
) async {
  final nameController = TextEditingController();
  var credits = 3;
  var grade = 'B+';

  await showAppSheet<void>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add planned course',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Set a target grade and see its CGPA impact immediately.',
              style: TextStyle(color: appSecondaryText(context)),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Course name',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
            ),
            const SizedBox(height: 14),
            _StepperRow(
              label: 'Credit hours',
              value: '$credits',
              onMinus:
                  credits <= 1 ? null : () => setSheetState(() => credits--),
              onPlus:
                  credits >= 6 ? null : () => setSheetState(() => credits++),
            ),
            const SizedBox(height: 14),
            _GradeStepper(
              grade: grade,
              gradePoint: controller.getGradePoint(grade),
              onChanged: (value) => setSheetState(() => grade = value),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => setSheetState(() {
                nameController.text = 'Calculus';
                credits = 3;
                grade = 'B+';
              }),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Fill example: Calculus · 3 credits · B+'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final name = nameController.text.trim();
                  controller.addCourseEntry(
                    name: name.isEmpty
                        ? 'Course ${controller.courses.length + 1}'
                        : name,
                    credit: credits,
                    gpa: controller.getGradePoint(grade),
                    semesterId: controller.selectedSemester.value,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add course'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  nameController.dispose();
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: appSecondaryText(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}
