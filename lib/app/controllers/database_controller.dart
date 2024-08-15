import 'dart:convert';

import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/course.dart';
import '../data/semester.dart';

class DatabaseController extends GetxController {
  final String key = "1111111111111111";
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

  Future<void> saveCourses(List<Course> courses) async {
    Map<String, dynamic> data = {
      'courses': courses.map((course) => course.toMap()).toList(),
    };
    sharedPref.setString('courses', jsonEncode(data));
  }

  List<Course> getCourses() {
    List<Course> courses = [];
    try {
      Map<String, dynamic> data =
          jsonDecode(sharedPref.getString('courses') ?? '{}');
      if (data.isNotEmpty) {
        courses = data['courses']
            .map<Course>((course) => Course.fromMap(course))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting courses: $e');
    }
    return courses;
  }
}
