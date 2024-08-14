import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';

class GpaCalculationController extends GetxController {
  ThemeController themeController = Get.find();
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
  var grades = [
    "A",
    "B+",
    "B"
        "C+",
    "C"
        "+",
    "B"
        "B+",
    "B"
  ];

  void addSemester() {
    semesters.add(Semester(
      name: semesterNames[semesters.length.clamp(0, semesterNames.length - 1)],
      credit: 0,
      gpa: 0,
    ).obs);
  }

  void addCourse() {
    courses.add(Course(
      name: "Course ${courses.length + 1}",
      credit: 0,
      gpa: 0,
    ).obs);
  }

  void calculateCGPA() {
    double totalCredit = 0;
    double totalGPA = 0;
    for (var semester in semesters) {
      totalCredit += semester.value.credit;
      totalGPA += semester.value.gpa * semester.value.credit;
    }
    double cgpa = totalGPA / totalCredit;
    print('CGPA: $cgpa');
    // Get.snackbar(
    //   "CGPA",
    //   cgpa.toStringAsFixed(2),
    //   snackPosition: SnackPosition.TOP,
    //   backgroundColor: ColorManager.primary,
    //   colorText: ColorManager.white,
    // );
  }
}
