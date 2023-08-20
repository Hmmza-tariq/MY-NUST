import 'package:flutter/material.dart';

import '../Core/semester.dart';

class GpaProvider with ChangeNotifier {
  List<Semester> semesters = [];

  List<Semester> addSemesterData(Semester a) {
    semesters.add(a);
    return semesters;
  }

  List<Semester> deleteSemesterData(Semester semester) {
    semesters.remove(semester);
    return semesters;
  }

  void updateSemesterData(Semester a, int index) {
    semesters[index] = a;
    notifyListeners();
  }

  List<Semester> getSemester() {
    return semesters;
  }

  void loadData(List<Semester> semesters) {
    this.semesters = semesters;
  }

  void updateSubjectData(Subject subject, int semesterIndex, int subjectIndex) {
    semesters[semesterIndex].subjects[subjectIndex] = subject;
    notifyListeners();
  }

  List<Subject> getSubjects(int index) {
    return semesters[index].subjects;
  }
}
