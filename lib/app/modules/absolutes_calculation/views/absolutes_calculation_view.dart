import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/assessment.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_glass_surface.dart';
import '../../widgets/app_page_shell.dart';
import '../controllers/absolutes_calculation_controller.dart';

class AbsolutesCalculationView extends GetView<AbsolutesCalculationController> {
  const AbsolutesCalculationView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final visible = controller.assessments.asMap().entries.where((entry) {
          return controller.selectedType.value == 'both' ||
              entry.value.type == controller.selectedType.value;
        }).toList();

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 76,
                    titleSpacing: 16,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: .96),
                    surfaceTintColor: Colors.transparent,
                    title: _Header(
                      onBack: () => Get.previousRoute.isEmpty
                          ? Get.offAllNamed(Routes.HOME)
                          : Get.back(),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _GettingStartedCard(),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: 'lecture',
                                  label: Text('Lecture'),
                                  icon: Icon(Icons.menu_book_outlined),
                                ),
                                ButtonSegment(
                                  value: 'lab',
                                  label: Text('Lab'),
                                  icon: Icon(Icons.science_outlined),
                                ),
                                ButtonSegment(
                                  value: 'both',
                                  label: Text('Both'),
                                  icon: Icon(Icons.dashboard_outlined),
                                ),
                              ],
                              selected: {controller.selectedType.value},
                              onSelectionChanged: (value) =>
                                  controller.selectedType.value = value.first,
                            ),
                          ),
                          if (controller.selectedType.value == 'both') ...[
                            const SizedBox(height: 12),
                            AppGlassSurface(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Course split',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use this only when lecture and lab have separate weightage in your course outline.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: appSecondaryText(context),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _NumberField(
                                          key: const ValueKey('lecture-weight'),
                                          label: 'Lecture %',
                                          value: controller.lectureWeight.value,
                                          onChanged: (value) {
                                            controller.lectureWeight.value =
                                                value;
                                            controller.saveWeights();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _NumberField(
                                          key: const ValueKey('lab-weight'),
                                          label: 'Lab %',
                                          value: controller.labWeight.value,
                                          onChanged: (value) {
                                            controller.labWeight.value = value;
                                            controller.saveWeights();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        controller.labWeight.value +
                                                    controller
                                                        .lectureWeight.value ==
                                                100
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.info_outline_rounded,
                                        size: 18,
                                        color: controller.labWeight.value +
                                                    controller
                                                        .lectureWeight.value ==
                                                100
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Total: ${(controller.labWeight.value + controller.lectureWeight.value).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: appSecondaryText(context),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Expanded(
                            child: visible.isEmpty
                                ? _EmptyAbsolute(
                                    onAdd: () => _showAddAssessmentSheet(
                                        context, controller),
                                    onExample: controller.loadExample,
                                  )
                                : ListView.separated(
                                    physics: const ClampingScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: visible.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, position) {
                                      final entry = visible[position];
                                      return _AssessmentCard(
                                        controller: controller,
                                        assessment: entry.value,
                                      );
                                    },
                                  ),
                          ),
                          if (visible.isNotEmpty)
                            _ActionBar(
                              onAdd: () =>
                                  _showAddAssessmentSheet(context, controller),
                              onCalculate: controller.calculateAbsolutes,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
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
                  'Absolute score',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Weighted marks, simplified',
                  style: TextStyle(color: appSecondaryText(context)),
                ),
              ],
            ),
          ),
        ],
      );
}

class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard();

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        emphasized: true,
        borderRadius: 12,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Choose Lecture or Lab, add marks from your course outline, then view your weighted result.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      );
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.controller,
    required this.assessment,
  });
  final AbsolutesCalculationController controller;
  final Assessment assessment;

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ObjectKey(assessment),
                    initialValue: assessment.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Assessment name',
                      prefixIcon: Icon(Icons.assignment_outlined),
                    ),
                    onChanged: (value) {
                      assessment.name = value;
                      controller.saveAssessments();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete assessment',
                  onPressed: () async {
                    final confirmed = await showAppConfirmationDialog(
                      context: context,
                      title: 'Delete this assessment?',
                      message:
                          'This item will no longer count toward the absolute score.',
                      confirmLabel: 'Delete',
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                    );
                    if (confirmed == true) {
                      controller.assessments.remove(assessment);
                      controller.saveAssessments();
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumberField(
              label: 'Weight in final grade (%)',
              value: assessment.weight,
              icon: Icons.percent_rounded,
              onChanged: (value) {
                assessment.weight = value;
                controller.saveAssessments();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Total marks',
                    value: assessment.totalMarks,
                    onChanged: (value) {
                      assessment.totalMarks = value;
                      controller.saveAssessments();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Your marks',
                    value: assessment.obtainedMarks,
                    onChanged: (value) {
                      assessment.obtainedMarks = value;
                      controller.saveAssessments();
                    },
                  ),
                ),
              ],
            ),
            if (controller.selectedType.value == 'both') ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: assessment.type,
                decoration: const InputDecoration(
                  labelText: 'Assessment type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                borderRadius: BorderRadius.circular(16),
                items: const [
                  DropdownMenuItem(
                    value: 'lecture',
                    child: Text('Lecture'),
                  ),
                  DropdownMenuItem(value: 'lab', child: Text('Lab')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  assessment.type = value;
                  controller.saveAssessments();
                },
              ),
            ],
          ],
        ),
      );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    super.key,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: value.toStringAsFixed(
          value == value.roundToDouble() ? 0 : 1,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
        ),
        onChanged: (raw) {
          final parsed = double.tryParse(raw);
          if (parsed != null) onChanged(parsed);
        },
      );
}

class _EmptyAbsolute extends StatelessWidget {
  const _EmptyAbsolute({required this.onAdd, required this.onExample});
  final VoidCallback onAdd;
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
                  Icons.fact_check_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add your first assessment',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Add the assessment weight from your course outline, its total marks, and the marks you earned.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: appSecondaryText(context), height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add assessment'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onExample,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Use example: Quiz 1 · 8/10 · 10%'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onAdd, required this.onCalculate});
  final VoidCallback onAdd;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add assessment'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onCalculate,
                child: const Text('View result'),
              ),
            ),
          ],
        ),
      );
}

Future<void> _showAddAssessmentSheet(
  BuildContext context,
  AbsolutesCalculationController controller,
) async {
  final nameController = TextEditingController();
  final weightController = TextEditingController(text: '10');
  final totalController = TextEditingController(text: '10');
  final obtainedController = TextEditingController(text: '8');
  var type = controller.selectedType.value == 'both'
      ? 'lecture'
      : controller.selectedType.value;

  await showAppSheet<void>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add assessment',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Use the values from your course outline or fill the example.',
              style: TextStyle(color: appSecondaryText(context)),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Assessment name',
                prefixIcon: Icon(Icons.assignment_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight in final grade (%)',
                prefixIcon: Icon(Icons.percent_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: totalController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Total marks'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: obtainedController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Your marks'),
                  ),
                ),
              ],
            ),
            if (controller.selectedType.value == 'both') ...[
              const SizedBox(height: 12),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'lecture', label: Text('Lecture')),
                  ButtonSegment(value: 'lab', label: Text('Lab')),
                ],
                selected: {type},
                onSelectionChanged: (value) =>
                    setSheetState(() => type = value.first),
              ),
            ],
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () {
                nameController.text = 'Quiz 1';
                weightController.text = '10';
                totalController.text = '10';
                obtainedController.text = '8';
              },
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Fill example: Quiz 1 · 8/10 · 10%'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final weight = double.tryParse(weightController.text);
                  final total = double.tryParse(totalController.text);
                  final obtained = double.tryParse(obtainedController.text);
                  if (weight == null || total == null || obtained == null) {
                    return;
                  }
                  controller.addAssessmentEntry(
                    name: nameController.text.trim().isEmpty
                        ? 'Assessment ${controller.assessments.length + 1}'
                        : nameController.text.trim(),
                    weight: weight,
                    totalMarks: total,
                    obtainedMarks: obtained,
                    type: type,
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add assessment'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  nameController.dispose();
  weightController.dispose();
  totalController.dispose();
  obtainedController.dispose();
}
