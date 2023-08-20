import 'package:flutter/material.dart';
import '../Core/assessments.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentProvider extends ChangeNotifier {
  List<Assessment> _assessments = [];
  double _lectureWeightage = 67;
  double _labWeightage = 33;
  List<Assessment> get assessments => _assessments;
  double get lectureWeightage => _lectureWeightage;
  double get labWeightage => _labWeightage;

  void setAssessments(List<Assessment> assessments) {
    _assessments = assessments;
    notifyListeners();
  }

  void updateWeightages(double lectureWeightage, double labWeightage) {
    _lectureWeightage = lectureWeightage;
    _labWeightage = labWeightage;
    _saveWeightages();
    notifyListeners();
  }

  double calculateTotalAbsolutesForSection(String section) {
    double totalObtainedMarks = 0;
    double totalMarks = 0;
    double totalWeightage = 0;

    for (var assessment in _assessments) {
      if (assessment.section == section) {
        totalObtainedMarks += assessment.obtainedMarks;
        totalWeightage += assessment.weightage;
        totalMarks += assessment.totalMarks;
      }
    }

    return (totalObtainedMarks / totalMarks) * totalWeightage;
  }

  Future<void> _saveWeightages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lectureWeightage', _lectureWeightage);
    prefs.setDouble('labWeightage', _labWeightage);
  }

  Future<void> loadWeightages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _lectureWeightage = prefs.getDouble('lectureWeightage') ?? 67;
    _labWeightage = prefs.getDouble('labWeightage') ?? 33;
  }
}
