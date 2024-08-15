import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';
import 'package:nust/app/controllers/theme_controller.dart';

import '../../../resources/color_manager.dart';

class GpaCalculationController extends GetxController {
  ThemeController themeController = Get.find();
  DatabaseController databaseController = Get.find();
  var isCGPA = true.obs;
  var semesters = <Rx<Semester>>[].obs;
  var courses = <Rx<Course>>[].obs;
  var semesterNames = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
    "Summer"
  ];
  var grades = ["A", "B+", "B", "C+", "C", "D+", "D", "F"];

  @override
  void onInit() {
    super.onInit();
    loadSemesters();
    loadCourses();
  }

  void addSemester() {
    semesters.add(Semester(
      name: semesterNames[semesters.length.clamp(0, semesterNames.length - 1)],
      credit: 0,
      gpa: 0,
    ).obs);
    saveSemesters();
  }

  void addCourse() {
    courses.add(Course(
      name: "Course ${courses.length + 1}",
      credit: 0,
      gpa: 0,
    ).obs);
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
    Get.snackbar(
      "CGPA",
      cgpa.toStringAsFixed(2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorManager.primary,
      colorText: ColorManager.white,
    );
  }

  void calculateSGPA() {
    double totalCredit = 0;
    double totalGPA = 0;
    for (var course in courses) {
      totalCredit += course.value.credit;
      totalGPA += course.value.gpa * course.value.credit;
    }
    double sgpa = totalGPA / totalCredit;
    Get.snackbar(
      "SGPA",
      sgpa.toStringAsFixed(2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: ColorManager.primary,
      colorText: ColorManager.white,
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
    databaseController.saveCourses(courses.map((c) => c.value).toList());
  }

  void loadCourses() {
    var loadedCourses = databaseController.getCourses();
    courses.assignAll(loadedCourses.map((c) => c.obs));
  }
}
