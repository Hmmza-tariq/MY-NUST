import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_button.dart';
import '../../../resources/color_manager.dart';
import '../controllers/gpa_calculation_controller.dart';

class GpaCalculationView extends GetView<GpaCalculationController> {
  const GpaCalculationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => Scaffold(
        backgroundColor:
            controller.themeController.theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: ColorManager.gradientColor,
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                height: Get.height,
                width: Get.width,
                child: Column(children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ColorManager.primary,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const Spacer(),
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.help_outline_rounded,
                      //     color: ColorManager.primary,
                      //   ),
                      //   onPressed: () {
                      //     Get.toNamed(Routes.HELP);
                      //   },
                      // ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    width: Get.width * 0.7,
                    decoration: BoxDecoration(
                      color: controller.themeController.theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          title: "CGPA",
                          color: controller.isCGPA.value
                              ? ColorManager.primary
                              : controller
                                  .themeController.theme.cardTheme.color!,
                          textColor: !controller.isCGPA.value &&
                                  !controller.themeController.isDarkMode.value
                              ? ColorManager.black
                              : ColorManager.white,
                          widthFactor: 0.3,
                          onPressed: () {
                            controller.isCGPA.value = true;
                          },
                        ),
                        CustomButton(
                          title: "SGPA",
                          color: controller.isCGPA.value
                              ? controller
                                  .themeController.theme.cardTheme.color!
                              : ColorManager.primary,
                          textColor: controller.isCGPA.value &&
                                  !controller.themeController.isDarkMode.value
                              ? ColorManager.black
                              : ColorManager.white,
                          widthFactor: 0.3,
                          onPressed: () {
                            controller.isCGPA.value = false;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  controller.isCGPA.value
                      ? SizedBox(
                          height: Get.height * 0.8,
                          child: (controller.semesters.isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add Semesters to Calculate CGPA",
                                        style: TextStyle(
                                          color: controller
                                              .themeController
                                              .theme
                                              .appBarTheme
                                              .titleTextStyle
                                              ?.color,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      CustomButton(
                                        title: "Add Semester",
                                        color: ColorManager.primary,
                                        textColor: ColorManager.white,
                                        widthFactor: 0.4,
                                        isBold: false,
                                        onPressed: () {
                                          controller.addSemester();
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.semesters.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: controller.themeController
                                                .theme.cardTheme.color,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Obx(
                                            () => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    DropdownButton<String>(
                                                      value: controller
                                                          .semesters[index]
                                                          .value
                                                          .name,
                                                      style: TextStyle(
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle
                                                            ?.color,
                                                      ),
                                                      underline:
                                                          const SizedBox(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      dropdownColor: controller
                                                          .themeController
                                                          .theme
                                                          .cardTheme
                                                          .color,
                                                      items: controller
                                                          .semesterNames
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.name =
                                                                value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_rounded,
                                                        color:
                                                            ColorManager.error,
                                                      ),
                                                      onPressed: () {
                                                        controller.semesters
                                                            .removeAt(index);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text.rich(
                                                  TextSpan(
                                                    text: "Credit: ",
                                                    style: TextStyle(
                                                      color: controller
                                                          .themeController
                                                          .theme
                                                          .appBarTheme
                                                          .titleTextStyle!
                                                          .color,
                                                      fontSize: 16,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: controller
                                                            .semesters[index]
                                                            .value
                                                            .credit
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .semesters[
                                                                    index]
                                                                .value
                                                                .credit >
                                                            0) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit--;
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.75,
                                                      child: Slider(
                                                        value: controller
                                                            .semesters[index]
                                                            .value
                                                            .credit
                                                            .toDouble(),
                                                        min: 0,
                                                        max: 21,
                                                        divisions: 21,
                                                        label: controller
                                                            .semesters[index]
                                                            .value
                                                            .credit
                                                            .toString(),
                                                        onChanged: (value) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit =
                                                                value.toInt();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .semesters[
                                                                    index]
                                                                .value
                                                                .credit <
                                                            21) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit++;
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text.rich(
                                                  TextSpan(
                                                    text: "GPA: ",
                                                    style: TextStyle(
                                                      color: controller
                                                          .themeController
                                                          .theme
                                                          .appBarTheme
                                                          .titleTextStyle!
                                                          .color,
                                                      fontSize: 16,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: controller
                                                            .semesters[index]
                                                            .value
                                                            .gpa
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .semesters[
                                                                    index]
                                                                .value
                                                                .gpa >
                                                            0) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.gpa -=
                                                                0.01;
                                                            semester?.gpa = double
                                                                .parse(semester
                                                                    .gpa
                                                                    .toStringAsFixed(
                                                                        2));
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.75,
                                                      child: Slider(
                                                        value: controller
                                                            .semesters[index]
                                                            .value
                                                            .gpa,
                                                        min: 0,
                                                        max: 4,
                                                        divisions: 400,
                                                        label: controller
                                                            .semesters[index]
                                                            .value
                                                            .gpa
                                                            .toString(),
                                                        onChanged: (value) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.gpa =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .semesters[
                                                                    index]
                                                                .value
                                                                .gpa <
                                                            4) {
                                                          controller
                                                              .semesters[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.gpa +=
                                                                0.01;
                                                            semester?.gpa = double
                                                                .parse(semester
                                                                    .gpa
                                                                    .toStringAsFixed(
                                                                        2));
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (index ==
                                            controller.semesters.length - 1)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 32,
                                            ),
                                            child: Row(
                                              children: [
                                                CustomButton(
                                                  title: "Add Semester",
                                                  color: ColorManager.primary,
                                                  textColor: ColorManager.white,
                                                  widthFactor: 0.4,
                                                  isBold: false,
                                                  onPressed: () {
                                                    controller.addSemester();
                                                  },
                                                ),
                                                const Spacer(),
                                                CustomButton(
                                                    title: "Calculate",
                                                    color: ColorManager.primary,
                                                    textColor:
                                                        ColorManager.white,
                                                    widthFactor: 0.4,
                                                    isBold: false,
                                                    onPressed: controller
                                                        .calculateCGPA),
                                              ],
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                        )
                      : SizedBox(
                          height: Get.height * 0.8,
                          child: (controller.courses.isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add Course to Calculate SGPA",
                                        style: TextStyle(
                                          color: controller
                                              .themeController
                                              .theme
                                              .appBarTheme
                                              .titleTextStyle
                                              ?.color,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      CustomButton(
                                        title: "Add Course",
                                        color: ColorManager.primary,
                                        textColor: ColorManager.white,
                                        widthFactor: 0.4,
                                        isBold: false,
                                        onPressed: () {
                                          controller.addSemester();
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: controller.courses.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: controller.themeController
                                                .theme.cardTheme.color,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Obx(
                                            () => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    DropdownButton<String>(
                                                      value: controller
                                                          .courses[index]
                                                          .value
                                                          .name,
                                                      style: TextStyle(
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle
                                                            ?.color,
                                                      ),
                                                      underline:
                                                          const SizedBox(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      dropdownColor: controller
                                                          .themeController
                                                          .theme
                                                          .cardTheme
                                                          .color,
                                                      items: controller
                                                          .semesterNames
                                                          .map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          controller
                                                              .courses[index]
                                                              .update((course) {
                                                            course?.name =
                                                                value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_rounded,
                                                        color:
                                                            ColorManager.error,
                                                      ),
                                                      onPressed: () {
                                                        controller.courses
                                                            .removeAt(index);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text.rich(
                                                  TextSpan(
                                                    text: "Credit: ",
                                                    style: TextStyle(
                                                      color: controller
                                                          .themeController
                                                          .theme
                                                          .appBarTheme
                                                          .titleTextStyle!
                                                          .color,
                                                      fontSize: 16,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: controller
                                                            .courses[index]
                                                            .value
                                                            .credit
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .courses[index]
                                                                .value
                                                                .credit >
                                                            0) {
                                                          controller
                                                              .courses[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit--;
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.75,
                                                      child: Slider(
                                                        value: controller
                                                            .courses[index]
                                                            .value
                                                            .credit
                                                            .toDouble(),
                                                        min: 0,
                                                        max: 21,
                                                        divisions: 21,
                                                        label: controller
                                                            .courses[index]
                                                            .value
                                                            .credit
                                                            .toString(),
                                                        onChanged: (value) {
                                                          controller
                                                              .courses[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit =
                                                                value.toInt();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .courses[index]
                                                                .value
                                                                .credit <
                                                            21) {
                                                          controller
                                                              .courses[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.credit++;
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text.rich(
                                                  TextSpan(
                                                    text: "GPA: ",
                                                    style: TextStyle(
                                                      color: controller
                                                          .themeController
                                                          .theme
                                                          .appBarTheme
                                                          .titleTextStyle!
                                                          .color,
                                                      fontSize: 16,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: controller
                                                            .courses[index]
                                                            .value
                                                            .gpa
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: ColorManager
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .courses[index]
                                                                .value
                                                                .gpa >
                                                            0) {
                                                          controller
                                                              .courses[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.gpa -=
                                                                0.01;
                                                            semester?.gpa = double
                                                                .parse(semester
                                                                    .gpa
                                                                    .toStringAsFixed(
                                                                        2));
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: Get.width * 0.75,
                                                      child: Slider(
                                                        value: controller
                                                            .courses[index]
                                                            .value
                                                            .gpa,
                                                        min: 0,
                                                        max: 4,
                                                        divisions: 400,
                                                        label: controller
                                                            .courses[index]
                                                            .value
                                                            .gpa
                                                            .toString(),
                                                        onChanged: (value) {
                                                          controller
                                                              .courses[index]
                                                              .update(
                                                                  (semester) {
                                                            semester?.gpa =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (controller
                                                                .courses[index]
                                                                .value
                                                                .gpa <
                                                            4) {
                                                          controller
                                                              .courses[index]
                                                              .update((course) {
                                                            course?.gpa += 0.01;
                                                            course?.gpa = double
                                                                .parse(course
                                                                    .gpa
                                                                    .toStringAsFixed(
                                                                        2));
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: controller
                                                            .themeController
                                                            .theme
                                                            .appBarTheme
                                                            .titleTextStyle!
                                                            .color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (index ==
                                            controller.semesters.length - 1)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 32,
                                            ),
                                            child: Row(
                                              children: [
                                                CustomButton(
                                                  title: "Add Course",
                                                  color: ColorManager.primary,
                                                  textColor: ColorManager.white,
                                                  widthFactor: 0.4,
                                                  isBold: false,
                                                  onPressed: () {
                                                    controller.addCourse();
                                                  },
                                                ),
                                                const Spacer(),
                                                CustomButton(
                                                    title: "Calculate",
                                                    color: ColorManager.primary,
                                                    textColor:
                                                        ColorManager.white,
                                                    widthFactor: 0.4,
                                                    isBold: false,
                                                    onPressed: controller
                                                        .calculateCGPA),
                                              ],
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
