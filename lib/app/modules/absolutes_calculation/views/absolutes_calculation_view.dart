import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/confetti.dart';
import 'package:nust/app/resources/color_manager.dart';
import '../../widgets/custom_button.dart';
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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildChooseTypeButtons(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller.scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _buildWeightSection(),
                                const SizedBox(height: 16),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.assessments.length,
                                  itemBuilder: (context, index) {
                                    return _buildAssessmentCard(index);
                                  },
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
              Obx(() {
                if ((controller.assessments.length > 2 &&
                    controller.scrollController.hasClients)) {
                  return Positioned(
                    bottom: 80,
                    right: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        controller.scrollController.animateTo(
                          controller.scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: IconButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: ColorManager.primary.withOpacity(0.4),
                      ),
                      icon: Icon(
                        Icons.arrow_downward_rounded,
                        color: ColorManager.white.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildChooseTypeButtons() {
    return Container(
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
      return Row(
        children: [
          InputWidget(
            doubleValue: controller.lectureWeight,
            title: "Lecture Weight (%)",
            onChanged: () {
              controller.saveWeights();
            },
          ),
          const SizedBox(width: 16),
          InputWidget(
            doubleValue: controller.labWeight,
            title: "Lab Weight (%)",
            onChanged: () {
              controller.saveWeights();
            },
          ),
        ],
      );
    } else {
      return SizedBox(
        width: Get.width,
        child: InputWidget(
          doubleValue: 100.0.obs,
          title: controller.selectedType.value == "lab"
              ? "Lab Weight (%)"
              : "Lecture Weight (%)",
          isEditable: false,
        ),
      );
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              InputWidget(
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
