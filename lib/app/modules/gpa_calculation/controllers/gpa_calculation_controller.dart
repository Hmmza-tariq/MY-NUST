import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';
import 'package:nust/app/controllers/review_prompt_controller.dart';
import 'package:nust/app/domain/calculators/gpa_projection.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../domain/calculators/planner_result_importer.dart';
import '../../../services/academic_sync_service.dart';
import '../../../routes/app_pages.dart';

class GpaCalculationController extends GetxController {
  DatabaseController databaseController = Get.find();
  ConfettiController confettiController = ConfettiController();
  ScrollController scrollController = ScrollController();
  ScreenshotController screenshotController = ScreenshotController();
  var isCGPA = true.obs;
  var semesters = <Rx<Semester>>[].obs;
  var courses = <Rx<Course>>[].obs;
  var selectedSemester = "Semester 1".obs;
  List<String> get semesterNames => {
        ...databaseController.getCourseTerms(),
        ...semesters.map((e) => e.value.name),
        ...Get.find<AcademicSyncService>()
            .data
            .value
            .results
            .map((e) => e.name),
        selectedSemester.value,
      }.toList();

  String get nextSemesterName {
    var number = 1;
    while (semesterNames.contains('Semester $number') ||
        academicSync.data.value.results
            .any((term) => term.regularSemesterCount == number)) {
      number++;
    }
    return 'Semester $number';
  }

  String semesterLabel(String name) {
    final terms = academicSync.data.value.results;
    final index = terms.indexWhere((term) => term.name == name);
    if (index < 0) return name;
    final term = terms[index];
    final date = name.toLowerCase().replaceAll(' ', '-');
    if (term.regularSemesterCount != null && term.regularSemesterCount! > 0) {
      return 'Semester ${term.regularSemesterCount} ($date)';
    }
    if (term.termType == 'defer') return 'Deferred term ($date)';
    if (name.toLowerCase().startsWith('summer')) return 'Summer term ($date)';
    // Old snapshots did not include the university semester counter.
    final number = terms
        .take(index + 1)
        .where((e) =>
            !e.name.toLowerCase().startsWith('summer') && e.termType != 'defer')
        .length;
    return 'Semester $number ($date)';
  }

  final importing = false.obs;
  final AcademicSyncService academicSync = Get.find();

  Future<void> importQalamResults() async {
    if (importing.value) return;
    if (academicSync.data.value.results.isEmpty) {
      if (!academicSync.canAutoSync) {
        Get.toNamed(Routes.SETTINGS);
        AppSnackbar.info(
            message:
                'Save your Qalam credentials to sync results, or open Results in the official portal.');
        return;
      }
      await academicSync.syncSavedPortals();
    }
    final snapshot = academicSync.data.value;
    if (snapshot.results.isEmpty) {
      AppSnackbar.error(
          message:
              'No previous results found. Open Qalam Results and sync again.');
      return;
    }
    final unsupported = snapshot.results
        .expand((e) => e.courses)
        .where((e) => e.credits != e.credits.roundToDouble())
        .length;
    final confirmed = await showAppConfirmationDialog(
      context: Get.context!,
      title: 'Import Qalam history?',
      message:
          '${snapshot.results.length} terms and ${snapshot.results.fold<int>(0, (n, e) => n + e.courses.length)} graded courses are ready.\n\n'
          'Terms and courses are saved locally. Existing matching entries and your edits are kept; importing again will not duplicate them.\n\n'
          '${unsupported == 0 ? '' : '$unsupported courses have fractional credits unsupported by this planner and will be skipped.\n\n'}'
          'Term SGPA uses Qalam’s earned-credit basis. Planner estimates can differ from official CGPA because of repeats and university rules. The official result remains authoritative.',
      confirmLabel: 'Import',
      icon: Icons.download_rounded,
    );
    if (confirmed != true) return;
    importing.value = true;
    try {
      final old = databaseController.getSemesters();
      final merged =
          PlannerResultImporter.mergeSemesters(old, snapshot.results);
      await databaseController.saveSemesters(merged);
      var courseCount = 0;
      for (final term in snapshot.results) {
        final existing = databaseController.getCourses(term.name);
        final courses = PlannerResultImporter.mergeCourses(existing, term);
        courseCount += courses.length - existing.length;
        await databaseController.saveCourses(courses, term.name);
      }
      await databaseController.setData(
          'qalamPlannerImportedAt', DateTime.now().toIso8601String());
      loadSemesters();
      selectedSemester.value = snapshot.results.last.name;
      loadCourses(selectedSemester.value);
      AppSnackbar.success(
          message:
              '${merged.length - old.length} terms and $courseCount courses added. Existing entries kept.');
    } finally {
      importing.value = false;
    }
  }

  List<String> grades = ["F", "D", "D+", "C", "C+", "B", "B+", "A"];

  @override
  void onInit() {
    super.onInit();
    loadSemesters();
    selectedSemester.value = databaseController.getPlannerSemester();
    if (databaseController.getCourses(selectedSemester.value).isEmpty &&
        !semesters.any((e) => e.value.name == selectedSemester.value) &&
        academicSync.data.value.results.isNotEmpty) {
      selectedSemester.value = academicSync.data.value.results.last.name;
    }
    loadCourses(selectedSemester.value);
  }

  @override
  void onClose() {
    confettiController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void addSemester() {
    addSemesterEntry(
      name: nextSemesterName,
      credit: 1,
      gpa: 4,
    );
  }

  void addSemesterEntry({
    required String name,
    required int credit,
    required double gpa,
  }) {
    semesters.add(Semester(name: name, credit: credit, gpa: gpa).obs);
    saveSemesters();
  }

  void addCourse(String semesterId) {
    addCourseEntry(
      name: "Course ${courses.length + 1}",
      credit: 1,
      gpa: 4,
      semesterId: semesterId,
    );
  }

  void addCourseEntry({
    required String name,
    required int credit,
    required double gpa,
    required String semesterId,
  }) {
    courses.add(Course(
      name: name,
      credit: credit,
      gpa: gpa,
      semesterId: semesterId,
    ).obs);
    saveCourses();
  }

  void loadCgpaExample() {
    if (semesters.isNotEmpty) return;
    semesters.add(Semester(name: 'Semester 1', credit: 18, gpa: 3.25).obs);
    saveSemesters();
  }

  void loadSgpaExample() {
    if (courses.isNotEmpty) return;
    courses.add(Course(
      name: 'Calculus',
      credit: 3,
      gpa: 3.5,
      semesterId: selectedSemester.value,
    ).obs);
    saveCourses();
  }

  void calculateCGPA() {
    if (semesters.isEmpty || completedCredits == 0) {
      AppSnackbar.error(message: 'Add at least one semester first');
      return;
    }
    showResult(true, currentCgpa, 0);
  }

  void calculateSGPA() {
    if (courses.isEmpty || plannedCredits == 0) {
      AppSnackbar.error(message: 'Add at least one course first');
      return;
    }
    showResult(false, plannedSgpa, plannedCredits.toInt());
  }

  double get completedCredits => semesters.fold<double>(
        0,
        (total, semester) => total + semester.value.credit,
      );

  double get plannedCredits => courses.fold<double>(
        0,
        (total, course) => total + course.value.credit,
      );

  double get currentCgpa => GpaProjection.weightedAverage(
        semesters.map(
          (semester) => (
            gradePoints: semester.value.gpa,
            credits: semester.value.credit.toDouble(),
          ),
        ),
      );

  double get plannedSgpa => GpaProjection.weightedAverage(
        courses.map(
          (course) => (
            gradePoints: course.value.gpa,
            credits: course.value.credit.toDouble(),
          ),
        ),
      );

  double get projectedCgpa => GpaProjection.replacingTerm(
        terms: semesters.map((e) => (
              name: e.value.name,
              gradePoints: e.value.gpa,
              credits: e.value.credit.toDouble()
            )),
        selectedTerm: selectedSemester.value,
        plannedSgpa: plannedSgpa,
        plannedCredits: plannedCredits,
      );

  double get projectedChange => projectedCgpa - currentCgpa;

  void addSGPAToCGPA(String semesterName, double sgpa, int totalCredit) {
    // Check if semester already exists in CGPA
    int existingIndex =
        semesters.indexWhere((s) => s.value.name == semesterName);

    if (existingIndex != -1) {
      // Update existing semester
      semesters[existingIndex].update((semester) {
        semester?.gpa = double.parse(sgpa.toStringAsFixed(2));
        semester?.credit = totalCredit;
      });
    } else {
      // Add new semester
      semesters.add(Semester(
        name: semesterName,
        credit: totalCredit,
        gpa: double.parse(sgpa.toStringAsFixed(2)),
      ).obs);
    }

    saveSemesters();

    AppSnackbar.success(
      message: 'SGPA added to CGPA calculator',
    );
  }

  void saveSemesters() {
    databaseController.saveSemesters(semesters.map((s) => s.value).toList());
  }

  void loadSemesters() {
    var loadedSemesters = databaseController.getSemesters();
    semesters.assignAll(loadedSemesters.map((s) => s.obs));
  }

  void saveCourses() {
    databaseController.saveCourses(
        courses.map((c) => c.value).toList(), selectedSemester.value);
  }

  void loadCourses(String semester) {
    selectedSemester.value = semester;
    databaseController.setPlannerSemester(semester);
    var loadedCourses = databaseController.getCourses(semester);
    courses.assignAll(loadedCourses.map((c) => c.obs));
  }

  String getGrade(double gpa) {
    if (gpa >= 4.0) return 'A';
    if (gpa >= 3.5) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.5) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.5) return 'D+';
    if (gpa >= 1.0) return 'D';
    if (gpa >= 0.0) return 'F';
    return 'I';
  }

  double getGradePoint(String grade) {
    switch (grade) {
      case 'A':
        return 4.0;
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'D+':
        return 1.5;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  void showResult(bool isCGPA, double result, int totalCredit) async {
    confettiController.play();
    final entries = isCGPA
        ? semesters
            .map((item) => _GpaResultEntry(
                  label: item.value.name,
                  detail: '${item.value.credit} credits',
                  value: item.value.gpa,
                ))
            .toList()
        : courses
            .map((item) => _GpaResultEntry(
                  label: item.value.name,
                  detail:
                      '${item.value.credit} credits · ${getGrade(item.value.gpa)}',
                  value: item.value.gpa,
                ))
            .toList();

    final context = Get.context;
    if (context != null) {
      await showAppSheet<void>(
        context: context,
        child: _GpaResultSheet(
          screenshotController: screenshotController,
          title: isCGPA ? 'Your CGPA' : 'Your SGPA',
          subtitle: isCGPA ? 'Academic history' : selectedSemester.value,
          result: result,
          entries: entries,
          onShare: () => captureScreenShot(isCGPA ? 'CGPA' : 'SGPA'),
          onAddToCgpa: !isCGPA && totalCredit > 0
              ? () {
                  addSGPAToCGPA(selectedSemester.value, result, totalCredit);
                  Get.back();
                }
              : null,
        ),
      );
    }
    confettiController.stop();
    await Get.find<ReviewPromptController>().recordSuccessfulOutcome();
  }

  Future<bool> captureScreenShot(String type) async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/image.png').create();
      await imagePath.writeAsBytes(image!);
      await SharePlus.instance.share(ShareParams(
          files: [XFile(imagePath.path)],
          text:
              "Hey! Check this out. I calculated my expected $type using 'My NUST' app."));
    });
    return true;
  }
}

class _GpaResultEntry {
  const _GpaResultEntry({
    required this.label,
    required this.detail,
    required this.value,
  });

  final String label;
  final String detail;
  final double value;
}

class _GpaResultSheet extends StatelessWidget {
  const _GpaResultSheet({
    required this.screenshotController,
    required this.title,
    required this.subtitle,
    required this.result,
    required this.entries,
    required this.onShare,
    this.onAddToCgpa,
  });

  final ScreenshotController screenshotController;
  final String title;
  final String subtitle;
  final double result;
  final List<_GpaResultEntry> entries;
  final Future<bool> Function() onShare;
  final VoidCallback? onAddToCgpa;

  String get _message => result >= 3.5
      ? 'Excellent standing'
      : result >= 3
          ? 'Strong progress'
          : result >= 2
              ? 'Keep building momentum'
              : 'A clear path to improve';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .86),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calculation complete',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    Text('A clear breakdown of your result',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Share result',
                onPressed: onShare,
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Screenshot(
                controller: screenshotController,
                child: Material(
                  color: scheme.surface,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Text(subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                    )),
                            const SizedBox(height: 4),
                            Text(result.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w900,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                )),
                            Text(title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    )),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: (result / 4).clamp(0, 1),
                                minHeight: 10,
                                backgroundColor:
                                    scheme.surface.withValues(alpha: .55),
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_message,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w800,
                                    )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Breakdown',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                )),
                      ),
                      const SizedBox(height: 8),
                      ...entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GpaResultBar(entry: entry),
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Created with My NUST',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onAddToCgpa != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddToCgpa,
                icon: const Icon(Icons.add_chart_rounded),
                label: const Text('Add this SGPA to CGPA'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GpaResultBar extends StatelessWidget {
  const _GpaResultBar({required this.entry});
  final _GpaResultEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  Text(entry.detail,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          )),
                ],
              ),
            ),
            Text(entry.value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (entry.value / 4).clamp(0, 1),
            minHeight: 7,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
