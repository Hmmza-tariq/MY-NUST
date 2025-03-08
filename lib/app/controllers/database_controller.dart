import 'dart:convert';

import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../data/course.dart';
import '../data/semester.dart';

class DatabaseController extends GetxController {
  final String key = dotenv.env['DATABASE_KEY'] ?? 'key';
  late EncryptedSharedPreferences _sharedPref;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> initialize() async {
    try {
      await EncryptedSharedPreferences.initialize(key);
      _sharedPref = EncryptedSharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error initializing shared preferences: $e');
    }
  }

  Future<bool> clear() async {
    return _sharedPref.clear();
  }

  void setBiometric(bool auth) {
    _sharedPref.setBoolean('biometric', auth);
  }

  bool getBiometric() {
    return _sharedPref.getBoolean('biometric') ?? false;
  }

  void setDarkMode(bool darkMode) {
    _sharedPref.setBoolean('darkMode', darkMode);
  }

  bool getDarkMode() {
    return _sharedPref.getBoolean('darkMode') ?? true;
  }

  void setCampus(String campus) {
    _sharedPref.setString('campus', campus);
  }

  String getCampus() {
    return _sharedPref.getString('campus') ?? 'CEME';
  }

  void setAutoFill(bool autoFill) {
    _sharedPref.setBoolean('autoFill', autoFill);
  }

  bool getAutoFill() {
    return _sharedPref.getBoolean('autoFill') ?? false;
  }

  void setCredentials(String id, String lmsPassword, String qalamPassword) {
    _sharedPref.setString('id', id);
    _sharedPref.setString('lmsPassword', lmsPassword);
    _sharedPref.setString('qalamPassword', qalamPassword);
  }

  Map<String, String> getCredentials() {
    return {
      'id': _sharedPref.getString('id') ?? '',
      'lmsPassword': _sharedPref.getString('lmsPassword') ?? '',
      'qalamPassword': _sharedPref.getString('qalamPassword') ?? '',
    };
  }

  Future<void> saveSemesters(List<Semester> semesters) async {
    Map<String, dynamic> data = {
      'semesters': semesters.map((semester) => semester.toMap()).toList(),
    };
    _sharedPref.setString('semesters', jsonEncode(data));
  }

  List<Semester> getSemesters() {
    List<Semester> semesters = [];
    try {
      Map<String, dynamic> data =
          jsonDecode(_sharedPref.getString('semesters') ?? '{}');
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

    _sharedPref.setString(key, jsonEncode(data));
  }

  List<Course> getCourses(String semester) {
    List<Course> courses = [];
    String key = "courses-${semester.replaceAll(" ", "-").toLowerCase()}";
    try {
      Map<String, dynamic> data =
          jsonDecode(_sharedPref.getString(key) ?? '{}');

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
    _sharedPref.setString('absolutesAssessments', jsonEncode(list));
  }

  List<dynamic> getAbsolutesAssessments() {
    List<dynamic> data = [];
    try {
      data = jsonDecode(_sharedPref.getString('absolutesAssessments') ?? '[]');
    } catch (e) {
      debugPrint('Error getting Absolutes assessments: $e');
    }
    return data;
  }

  void saveAbsolutesWeights(double value, double value2) {
    _sharedPref.setDouble('absolutesWeight1', value);
    _sharedPref.setDouble('absolutesWeight2', value2);
  }

  List<double> getAbsolutesWeights() {
    return [
      _sharedPref.getDouble('absolutesWeight1') ?? 0.0,
      _sharedPref.getDouble('absolutesWeight2') ?? 0.0,
    ];
  }

  Future<dynamic> getDataFromFirebase(String path) async {
    try {
      DatabaseEvent event = await _firebaseDatabase.ref().child(path).once();
      return event.snapshot.value;
    } catch (e) {
      debugPrint('error in get data: $e');
      return null;
    }
  }

  Future<void> setData(String key, String value) async {
    await _sharedPref.setString(key, value);
  }

  Future<String> getData(String key) async {
    return _sharedPref.getString(key) ?? '';
  }
}
