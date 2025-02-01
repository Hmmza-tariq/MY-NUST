import 'dart:io';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/assessment.dart';

class AbsolutesCalculationController extends GetxController {
  ThemeController themeController = Get.find();
  DatabaseController databaseController = Get.find();
  ScrollController scrollController = ScrollController();

  RxString selectedType = "both".obs;

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
    assessments.add(Assessment());
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
  }

  void calculateAbsolutes() {
    Get.focusScope!.unfocus();
    double totalScore = 0.0;
    double labScore = 0.0;
    double lectureScore = 0.0;

    if (selectedType.value == "both") {
      if (labWeight.value + lectureWeight.value != 100) {
        Get.snackbar("Error", "Total Lecture + Lab weightage must be 100.",
            backgroundColor: Colors.red, colorText: Colors.white);
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
    Color color = absolutes.value <= 30
        ? ColorManager.error
        : absolutes.value <= 60
            ? ColorManager.orange
            : absolutes.value <= 80
                ? ColorManager.green
                : ColorManager.primary;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeController.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        width: Get.width,
        height: (selectedType.value == "both"
            ? Get.height * 0.3
            : Get.height * 0.24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: themeController.isDarkMode.value
                        ? ColorManager.lightGrey1
                        : ColorManager.black,
                  ),
                  onPressed: Get.back,
                ),
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeController.isDarkMode.value
                        ? ColorManager.lightGrey1
                        : ColorManager.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: themeController.isDarkMode.value
                        ? ColorManager.lightGrey1
                        : ColorManager.black,
                  ),
                  onPressed: () async {
                    await captureScreenShot(selectedType.value == "both"
                        ? " "
                        : " ${selectedType.value.capitalizeFirst} ");
                  },
                ),
              ],
            ),
            Screenshot(
              controller: screenshotController,
              child: Container(
                color: themeController.theme.scaffoldBackgroundColor,
                width: Get.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Absolutes Score${selectedType.value == "both" ? "" : " in ${selectedType.value.capitalizeFirst}"}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkMode.value
                                ? ColorManager.lightGrey1
                                : ColorManager.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: absolutes.value.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 24,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: " out of 100",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeController.isDarkMode.value
                                      ? ColorManager.lightGrey1
                                      : ColorManager.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedType.value == "both")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  text: "Absolutes Score in Lab: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeController.isDarkMode.value
                                        ? ColorManager.lightGrey1
                                        : ColorManager.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: labScore.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  text: "Absolutes Score in Lecture: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeController.isDarkMode.value
                                        ? ColorManager.lightGrey1
                                        : ColorManager.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: lectureScore.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      top: 24,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: ColorManager.gradientColor),
                        alignment: Alignment.center,
                        child: Text("My NUST",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: !themeController.isDarkMode.value
                                  ? ColorManager.black
                                  : ColorManager.white,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: themeController.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
    );
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
      Get.snackbar("Error", "Total assessment weightage cannot exceed 100.",
          backgroundColor: Colors.red, colorText: Colors.white);
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
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
            "Hey! Check this out. I have calculated my${type}Absolute score using My Nust App. It's amazing! You should try it too.",
      );
    });
    return true;
  }
}
