import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/confetti.dart';
import 'package:nust/app/resources/color_manager.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_scrollbar.dart';
import '../../widgets/input_widget.dart';
import '../controllers/absolutes_calculation_controller.dart';

class AbsolutesCalculationView extends GetView<AbsolutesCalculationController> {
  const AbsolutesCalculationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: controller.themeController.theme.scaffoldBackgroundColor,
      body: Container(
          decoration: BoxDecoration(
            gradient: ColorManager.gradientColor,
          ),
          height: Get.height,
          child: SafeArea(
            child: Obx(
              () => Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        _buildHeader(),
                        _buildChooseTypeButtons(),
                        _buildWeightSection(),
                        if (controller.assessments.isEmpty)
                          SizedBox(
                            height: Get.height * 0.5,
                            width: Get.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Add an assessment to get\nstarted",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: controller.themeController.theme
                                        .appBarTheme.titleTextStyle?.color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  title: "Add Assessment",
                                  color: ColorManager.primary,
                                  textColor: ColorManager.white,
                                  widthFactor: 0.4,
                                  isBold: false,
                                  onPressed: controller.addAssessment,
                                ),
                              ],
                            ),
                          )
                        else
                          Expanded(
                            child: CustomScrollbar(
                              controller: controller.scrollController,
                              child: ListView.builder(
                                itemCount: controller.assessments.length,
                                controller: controller.scrollController,
                                itemBuilder: (context, index) {
                                  return _buildAssessmentCard(index);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (controller.assessments.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomButtons(),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: controller.confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      minBlastForce: 10,
                      maxBlastForce: 20,
                      numberOfParticles: 20,
                      colors: const [
                        ColorManager.primary,
                        ColorManager.secondary,
                      ],
                      createParticlePath: drawHexagons,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ColorManager.primary,
            ),
            onPressed: () => Get.back(),
          ),
          const Text(
            "Absolutes Calculation",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorManager.primary,
            ),
          ),
          const IconButton(icon: SizedBox(), onPressed: null),
        ],
      ),
    );
  }

  Widget _buildChooseTypeButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(8.0),
      width: Get.width,
      decoration: BoxDecoration(
        color: controller.themeController.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            title: "BOTH",
            color: controller.selectedType.value == 'both'
                ? ColorManager.primary
                : controller.themeController.theme.cardTheme.color!,
            textColor: controller.selectedType.value != 'both' &&
                    !controller.themeController.isDarkMode.value
                ? ColorManager.black
                : ColorManager.white,
            widthFactor: 0.28,
            horizontalPadding: 0,
            fontSize: 12,
            verticalPadding: 0,
            onPressed: () {
              controller.selectedType.value = 'both';
            },
          ),
          CustomButton(
            title: "LECTURE",
            color: controller.selectedType.value == 'lecture'
                ? ColorManager.primary
                : controller.themeController.theme.cardTheme.color!,
            textColor: controller.selectedType.value != 'lecture' &&
                    !controller.themeController.isDarkMode.value
                ? ColorManager.black
                : ColorManager.white,
            widthFactor: 0.28,
            horizontalPadding: 0,
            fontSize: 12,
            verticalPadding: 0,
            onPressed: () {
              controller.selectedType.value = 'lecture';
            },
          ),
          CustomButton(
            title: "LAB",
            color: controller.selectedType.value == 'lab'
                ? ColorManager.primary
                : controller.themeController.theme.cardTheme.color!,
            textColor: controller.selectedType.value != 'lab' &&
                    !controller.themeController.isDarkMode.value
                ? ColorManager.black
                : ColorManager.white,
            widthFactor: 0.28,
            horizontalPadding: 0,
            fontSize: 12,
            verticalPadding: 0,
            onPressed: () {
              controller.selectedType.value = 'lab';
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection() {
    if (controller.selectedType.value == "both") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            InputWidget(
              widthFactor: .44,
              doubleValue: controller.lectureWeight,
              title: "Lecture Weight (%)",
              onChanged: () {
                controller.saveWeights();
              },
            ),
            const SizedBox(width: 16),
            InputWidget(
              widthFactor: .44,
              doubleValue: controller.labWeight,
              title: "Lab Weight (%)",
              onChanged: () {
                controller.saveWeights();
              },
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAssessmentCard(int index) {
    final assessment = controller.assessments[index];
    if (controller.selectedType.value != "both" &&
        assessment.type != controller.selectedType.value) {
      return const SizedBox();
    }
    RxString name = assessment.name.obs;
    RxDouble weight = assessment.weight.obs;
    RxDouble totalMarks = assessment.totalMarks.obs;
    RxDouble obtainedMarks = assessment.obtainedMarks.obs;

    return Container(
      decoration: BoxDecoration(
        color: controller.themeController.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12.0),
      margin: EdgeInsets.only(
          right: 16,
          left: 16,
          top: 8,
          bottom: index == controller.assessments.length - 1 ? 60 : 8),
      child: Column(
        children: [
          Row(
            children: [
              InputWidget(
                  widthFactor: .7,
                  stringValue: name,
                  title: "Assessment Name",
                  isBorder: false,
                  onChanged: () {
                    assessment.name = name.value;
                    controller.saveAssessments();
                  }),
              IconButton(
                icon: const Icon(Icons.delete, color: ColorManager.error),
                onPressed: () {
                  controller.removeAssessment(index);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InputWidget(
                widthFactor: .2,
                doubleValue: weight,
                title: "Weight",
                onChanged: () {
                  assessment.weight = weight.value;
                  controller.saveAssessments();
                },
                isBorder: false,
              ),
              const SizedBox(width: 8),
              InputWidget(
                widthFactor: .3,
                doubleValue: totalMarks,
                title: "Total Marks",
                onChanged: () {
                  assessment.totalMarks = totalMarks.value;
                  controller.saveAssessments();
                },
                isBorder: false,
              ),
              const SizedBox(width: 8),
              InputWidget(
                widthFactor: .3,
                doubleValue: obtainedMarks,
                title: "Obtained Marks",
                onChanged: () {
                  assessment.obtainedMarks = obtainedMarks.value;
                  controller.saveAssessments();
                },
                isBorder: false,
              ),
            ],
          ),
          if (controller.selectedType.value == "both")
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: DropdownButtonFormField<String>(
                value: assessment.type,
                borderRadius: BorderRadius.circular(12),
                style: TextStyle(
                  color: !controller.themeController.isDarkMode.value
                      ? ColorManager.black
                      : ColorManager.white,
                ),
                dropdownColor: controller.themeController.theme.cardTheme.color,
                decoration: InputDecoration(
                  labelText: "Assessment Type",
                  border: null,
                  enabledBorder: null,
                  focusedBorder: null,
                  labelStyle: TextStyle(
                    color: !controller.themeController.isDarkMode.value
                        ? ColorManager.primary
                        : ColorManager.lightGrey3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "lab", child: Text("Lab")),
                  DropdownMenuItem(value: "lecture", child: Text("Lecture")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    assessment.type = val;
                    controller.saveAssessments();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: ColorManager.gradientColor,
        boxShadow: [
          BoxShadow(
            color: controller.themeController.isDarkMode.value
                ? ColorManager.transparent
                : ColorManager.shadow,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomButton(
            title: "Add Assessment",
            color: ColorManager.primary,
            textColor: ColorManager.white,
            widthFactor: 0.4,
            isBold: false,
            onPressed: controller.addAssessment,
          ),
          CustomButton(
            title: "Calculate",
            color: ColorManager.primary,
            textColor: ColorManager.white,
            widthFactor: 0.4,
            isBold: false,
            onPressed: controller.calculateAbsolutes,
          ),
        ],
      ),
    );
  }
}
