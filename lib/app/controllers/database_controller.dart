import 'dart:convert';

import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../data/course.dart';
import '../data/semester.dart';

class DatabaseController extends GetxController {
  final String key = dotenv.env['DATABASE_KEY'] ?? 'key';
  late EncryptedSharedPreferences sharedPref;

  Future<void> initialize() async {
    try {
      await EncryptedSharedPreferences.initialize(key);
      sharedPref = EncryptedSharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing shared preferences: $e');
    }
  }

  Future<bool> clear() async {
    return sharedPref.clear();
  }

  void setBiometric(bool auth) {
    sharedPref.setBoolean('biometric', auth);
  }

  bool getBiometric() {
    return sharedPref.getBoolean('biometric') ?? false;
  }

  void setDarkMode(bool darkMode) {
    sharedPref.setBoolean('darkMode', darkMode);
  }

  bool getDarkMode() {
    return sharedPref.getBoolean('darkMode') ?? true;
  }

  void setCampus(String campus) {
    sharedPref.setString('campus', campus);
  }

  String getCampus() {
    return sharedPref.getString('campus') ?? 'CEME';
  }

  void setAutoFill(bool autoFill) {
    sharedPref.setBoolean('autoFill', autoFill);
  }

  bool getAutoFill() {
    return sharedPref.getBoolean('autoFill') ?? false;
  }

  void setCredentials(String id, String lmsPassword, String qalamPassword) {
    sharedPref.setString('id', id);
    sharedPref.setString('lmsPassword', lmsPassword);
    sharedPref.setString('qalamPassword', qalamPassword);
  }

  Map<String, String> getCredentials() {
    return {
      'id': sharedPref.getString('id') ?? '',
      'lmsPassword': sharedPref.getString('lmsPassword') ?? '',
      'qalamPassword': sharedPref.getString('qalamPassword') ?? '',
    };
  }

  Future<void> saveSemesters(List<Semester> semesters) async {
    Map<String, dynamic> data = {
      'semesters': semesters.map((semester) => semester.toMap()).toList(),
    };
    sharedPref.setString('semesters', jsonEncode(data));
  }

  List<Semester> getSemesters() {
    List<Semester> semesters = [];
    try {
      Map<String, dynamic> data =
          jsonDecode(sharedPref.getString('semesters') ?? '{}');
      if (data.isNotEmpty) {
        semesters = data['semesters']
            .map<Semester>((semester) => Semester.fromMap(semester))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting semesters: $e');
    }
    return semesters;
  }

  Future<void> saveCourses(List<Course> courses, String semester) async {
    String key = "courses-${semester.replaceAll(" ", "-").toLowerCase()}";
    Map<String, dynamic> data = {
      key: courses.map((course) => course.toMap()).toList(),
    };

    sharedPref.setString(key, jsonEncode(data));
  }

  List<Course> getCourses(String semester) {
    List<Course> courses = [];
    String key = "courses-${semester.replaceAll(" ", "-").toLowerCase()}";
    try {
      Map<String, dynamic> data = jsonDecode(sharedPref.getString(key) ?? '{}');

      if (data.isNotEmpty) {
        courses =
            data[key].map<Course>((course) => Course.fromMap(course)).toList();
      }
    } catch (e) {
      debugPrint('Error getting courses: $e');
    }
    return courses;
  }

  void saveAbsolutesAssessments(List<Map<String, Object>> list) {
    sharedPref.setString('absolutesAssessments', jsonEncode(list));
  }

  List<dynamic> getAbsolutesAssessments() {
    List<dynamic> data = [];
    try {
      data = jsonDecode(sharedPref.getString('absolutesAssessments') ?? '[]');
    } catch (e) {
      debugPrint('Error getting Absolutes assessments: $e');
    }
    return data;
  }

  void saveAbsolutesWeights(double value, double value2) {
    sharedPref.setDouble('absolutesWeight1', value);
    sharedPref.setDouble('absolutesWeight2', value2);
  }

  List<double> getAbsolutesWeights() {
    return [
      sharedPref.getDouble('absolutesWeight1') ?? 0.0,
      sharedPref.getDouble('absolutesWeight2') ?? 0.0,
    ];
  }
}
