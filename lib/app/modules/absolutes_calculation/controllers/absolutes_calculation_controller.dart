import 'dart:io';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/controllers/review_prompt_controller.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/assessment.dart';

class AbsolutesCalculationController extends GetxController {
  DatabaseController databaseController = Get.find();
  ScrollController scrollController = ScrollController();

  RxString selectedType = "lecture".obs;

  RxDouble labWeight = 50.0.obs;
  RxDouble lectureWeight = 50.0.obs;

  RxList<Assessment> assessments = <Assessment>[].obs;

  RxDouble absolutes = 0.0.obs;

  ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 3));
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void onInit() {
    super.onInit();
    loadWeight();
    loadAssessments();
  }

  @override
  void onClose() {
    confettiController.dispose();
    scrollController.dispose();

    super.onClose();
  }

  void addAssessment() {
    // Set the type based on currently selected type
    String assessmentType =
        selectedType.value == "both" ? "lecture" : selectedType.value;
    assessments.add(Assessment(type: assessmentType));
    saveAssessments();
  }

  void addAssessmentEntry({
    required String name,
    required double weight,
    required double totalMarks,
    required double obtainedMarks,
    required String type,
  }) {
    assessments.add(Assessment(
      name: name,
      weight: weight,
      totalMarks: totalMarks,
      obtainedMarks: obtainedMarks,
      type: type,
    ));
    saveAssessments();
  }

  void loadExample() {
    selectedType.value = 'lecture';
    if (assessments.any((assessment) => assessment.type == 'lecture')) return;
    assessments.add(Assessment(
      name: 'Quiz 1',
      weight: 10,
      totalMarks: 10,
      obtainedMarks: 8,
      type: 'lecture',
    ));
    saveAssessments();
  }

  void removeAssessment(int index) {
    if (index >= 0 && index < assessments.length) {
      assessments.removeAt(index);
      saveAssessments();
    }
  }

  void saveWeights() {
    databaseController.saveAbsolutesWeights(
      labWeight.value,
      lectureWeight.value,
    );
  }

  void loadWeight() {
    List<double> weights = databaseController.getAbsolutesWeights();
    labWeight.value = weights[0];
    lectureWeight.value = weights[1];
    if (labWeight.value + lectureWeight.value == 0) {
      labWeight.value = 50;
      lectureWeight.value = 50;
      saveWeights();
    }
  }

  Future<void> calculateAbsolutes() async {
    Get.focusScope!.unfocus();
    double totalScore = 0.0;
    double labScore = 0.0;
    double lectureScore = 0.0;

    if (selectedType.value == "both") {
      if (labWeight.value + lectureWeight.value != 100) {
        AppSnackbar.error(
            message: "Total Lecture + Lab weightage must be 100.");
        return;
      }
      var labAssessments = assessments.where((a) => a.type == "lab").toList();
      var lectureAssessments =
          assessments.where((a) => a.type == "lecture").toList();

      labScore = _calculateAssessmentScore(labAssessments);
      lectureScore = _calculateAssessmentScore(lectureAssessments);

      totalScore = (labScore * (labWeight.value / 100)) +
          (lectureScore * (lectureWeight.value / 100));
    } else {
      var tempAssessments =
          assessments.where((a) => a.type == selectedType.value).toList();
      totalScore = _calculateAssessmentScore(tempAssessments);
    }
    if (totalScore == -1) {
      return;
    }
    absolutes.value = totalScore;
    confettiController.play();
    final context = Get.context;
    if (context == null) return;
    await showAppSheet<void>(
      context: context,
      child: _AbsoluteResultSheet(
        screenshotController: screenshotController,
        score: totalScore,
        type: selectedType.value,
        labScore: labScore,
        lectureScore: lectureScore,
        onShare: () => captureScreenShot(selectedType.value == "both"
            ? " "
            : " ${selectedType.value.capitalizeFirst} "),
      ),
    );
    await Get.find<ReviewPromptController>().recordSuccessfulOutcome();
  }

  double _calculateAssessmentScore(List<Assessment> list) {
    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (var a in list) {
      if (a.totalMarks > 0) {
        double normalizedScore = (a.obtainedMarks / a.totalMarks);
        double weightedScore = normalizedScore * a.weight;
        totalWeightedScore += weightedScore;
        totalWeight += a.weight;
      }
    }

    if (totalWeight > 100) {
      AppSnackbar.error(
          message: "Total assessment weightage cannot exceed 100.");
      return -1;
    }

    if (totalWeight < 100) {
      totalWeight = 100;
    }

    return (totalWeightedScore / totalWeight) * 100;
  }

  void saveAssessments() {
    databaseController.saveAbsolutesAssessments(
      assessments
          .map((a) => {
                "name": a.name,
                "weight": a.weight,
                "totalMarks": a.totalMarks,
                "obtainedMarks": a.obtainedMarks,
                "type": a.type,
              })
          .toList(),
    );
  }

  void loadAssessments() {
    List data = databaseController.getAbsolutesAssessments();
    assessments.clear();
    for (var aData in data) {
      assessments.add(Assessment(
        name: aData["name"] ?? "",
        weight: (aData["weight"] ?? 1).toDouble(),
        totalMarks: (aData["totalMarks"] ?? 100).toDouble(),
        obtainedMarks: (aData["obtainedMarks"] ?? 0).toDouble(),
        type: aData["type"] ?? "lecture",
      ));
    }
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
            "Hey! Check this out. I have calculated my${type}Absolute score using My Nust App. It's amazing! You should try it too.",
      ));
    });
    return true;
  }
}

class _AbsoluteResultSheet extends StatelessWidget {
  const _AbsoluteResultSheet({
    required this.screenshotController,
    required this.score,
    required this.type,
    required this.labScore,
    required this.lectureScore,
    required this.onShare,
  });

  final ScreenshotController screenshotController;
  final double score;
  final String type;
  final double labScore;
  final double lectureScore;
  final Future<bool> Function() onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scoreColor = score <= 30
        ? scheme.error
        : score <= 60
            ? scheme.tertiary
            : scheme.primary;
    final title =
        type == 'both' ? 'Absolute score' : '${type.capitalizeFirst} score';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.insights_rounded, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  Text(
                    'Based on the assessments entered',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: 'Share result',
              onPressed: onShare,
              icon: const Icon(Icons.ios_share_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Screenshot(
          controller: screenshotController,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                Text(
                  score.toStringAsFixed(2),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'out of 100',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (score / 100).clamp(0, 1),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  score >= 80
                      ? 'Achievement: Excellent momentum'
                      : score >= 60
                          ? 'Achievement: Solid progress'
                          : 'Next goal: Reach 60 points',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (type == 'both') ...[
                  const SizedBox(height: 18),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreDetail(
                          label: 'Lecture',
                          value: lectureScore,
                        ),
                      ),
                      Expanded(
                        child: _ScoreDetail(label: 'Lab', value: labScore),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'MY NUST',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

class _ScoreDetail extends StatelessWidget {
  const _ScoreDetail({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value.toStringAsFixed(2),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
}
