import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class GpaCalculationController extends GetxController {
  ThemeController themeController = Get.find();
  DatabaseController databaseController = Get.find();
  ConfettiController confettiController = ConfettiController();
  ScrollController scrollController = ScrollController();
  GlobalKey previewContainer = GlobalKey();

  var isCGPA = true.obs;
  var semesters = <Rx<Semester>>[].obs;
  var courses = <Rx<Course>>[].obs;
  var selectedSemester = "Semester 1".obs;
  var semesterNames = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
    "Summer 1",
    "Summer 2",
    "Summer 3",
    "Summer 4",
  ];
  List<String> grades = ["F", "D", "D+", "C", "C+", "B", "B+", "A"];

  @override
  void onInit() {
    super.onInit();
    loadSemesters();
    loadCourses(selectedSemester.value);
  }

  @override
  void onClose() {
    confettiController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void addSemester() {
    semesters.add(Semester(
      name: semesterNames[semesters.length.clamp(0, semesterNames.length - 1)],
      credit: 1,
      gpa: 4,
    ).obs);
    saveSemesters();
  }

  void addCourse(String semesterId) {
    courses.add(Course(
            name: "Course ${courses.length + 1}",
            credit: 1,
            gpa: 4,
            semesterId: semesterId)
        .obs);
    saveCourses();
  }

  void calculateCGPA() {
    double totalCredit = 0;
    double totalGPA = 0;
    for (var semester in semesters) {
      totalCredit += semester.value.credit;
      totalGPA += semester.value.gpa * semester.value.credit;
    }
    double cgpa = totalGPA / totalCredit;
    showResult(true, cgpa);
  }

  void calculateSGPA() {
    double totalCredit = 0;
    double totalGPA = 0;
    for (var course in courses) {
      totalCredit += course.value.credit;
      totalGPA += course.value.gpa * course.value.credit;
    }
    double sgpa = totalGPA / totalCredit;
    showResult(false, sgpa);
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
    var loadedCourses = databaseController.getCourses(semester);
    courses = loadedCourses.map((c) => c.obs).toList().obs;
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

  void showResult(bool isCGPA, double result) async {
    confettiController.play();

    final List<Color> colors = [
      ColorManager.cyan,
      ColorManager.orange,
      ColorManager.green,
      ColorManager.pink,
      ColorManager.warning,
      ColorManager.primary,
      ColorManager.secondary,
    ];

    List<PieChartSectionData> sections = [];
    List<Widget> details = [];

    if (isCGPA) {
      for (int i = 0; i < semesters.length; i++) {
        var semester = semesters[i];
        double achievedGPA = semester.value.gpa * semester.value.credit;
        double totalCredits =
            semester.value.credit * 4.0; // Maximum GPA of 4.0 per credit
        double emptySpace = totalCredits - achievedGPA;

        // Achieved GPA section
        sections.add(PieChartSectionData(
          color: colors[i % colors.length],
          value: achievedGPA,
          title:
              "${semester.value.name}\n${semester.value.gpa.toStringAsFixed(2)}",
          radius: Get.width * 0.14,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeController.isDarkMode.value
                ? ColorManager.lightGrey1
                : ColorManager.black,
          ),
          titlePositionPercentageOffset: 0.5,
        ));

        // Empty space section
        if (emptySpace > 0) {
          sections.add(PieChartSectionData(
            color: ColorManager.primary.withOpacity(.2),
            value: emptySpace,
            title: '', // No title for empty space
            radius: Get.width * 0.14,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeController.isDarkMode.value
                  ? ColorManager.lightGrey1
                  : ColorManager.black,
            ),
            titlePositionPercentageOffset: 0.5,
          ));
        }
      }
    } else {
      for (int i = 0; i < courses.length; i++) {
        var course = courses[i];
        double achievedGPA = course.value.gpa * course.value.credit;
        double totalCredits = course.value.credit * 4.0;
        double emptySpace = totalCredits - achievedGPA;

        // Achieved GPA section
        sections.add(PieChartSectionData(
          color: colors[i % colors.length],
          value: achievedGPA,
          title: "${course.value.name}\n${getGrade(course.value.gpa)}",
          radius: Get.width * 0.14,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeController.isDarkMode.value
                ? ColorManager.lightGrey1
                : ColorManager.black,
          ),
          titlePositionPercentageOffset: .5,
        ));

        // Empty space section
        if (emptySpace > 0) {
          sections.add(PieChartSectionData(
            color: ColorManager.primary.withOpacity(.2),
            value: emptySpace,
            title: '',
            radius: Get.width * 0.14,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeController.isDarkMode.value
                  ? ColorManager.lightGrey1
                  : ColorManager.black,
            ),
            titlePositionPercentageOffset: .5,
          ));
        }
      }
    }

    await Get.bottomSheet(
      backgroundColor: themeController.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.68,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
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
                        await captureScreenShot(isCGPA ? "CGPA" : "SGPA");
                      },
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RepaintBoundary(
                    key: previewContainer,
                    child: Container(
                      color: themeController.theme.scaffoldBackgroundColor,
                      height: Get.height * 0.36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(PieChartData(
                            sections: sections,
                            centerSpaceRadius: 80,
                            sectionsSpace: 2,
                            borderData: FlBorderData(show: false),
                          )),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isCGPA ? "Your CGPA" : "Your SGPA",
                                style: themeController
                                    .theme.appBarTheme.titleTextStyle,
                              ),
                              Text(
                                result.toStringAsFixed(2),
                                style: themeController
                                    .theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.primary,
                                  fontSize: 40,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: Get.height * 0.018,
                            right: 16,
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
                          if (!isCGPA)
                            Positioned(
                              top: Get.height * 0.018,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: ColorManager.gradientColor),
                                alignment: Alignment.center,
                                child: Text(selectedSemester.value,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: !themeController.isDarkMode.value
                                          ? ColorManager.black
                                          : ColorManager.white,
                                    )),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      color: themeController.isDarkMode.value
                          ? ColorManager.lightGrey1
                          : ColorManager.black,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: Get.height * 0.24,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: details,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    confettiController.stop();
  }

  Future<bool> captureScreenShot(String type) async {
    await ShareFilesAndScreenshotWidgets().shareScreenshot(
        previewContainer, 1000, "Logo", "result.png", "image/png",
        text:
            "Hey! Check this out. I calculated my expected $type using 'My NUST' app.");
    return true;
  }
}
