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

  Future<void> setAutoFill(bool autoFill) async {
    await _sharedPref.setBoolean('autoFill', autoFill);
  }

  bool getAutoFill() {
    return _sharedPref.getBoolean('autoFill') ?? false;
  }

  bool getAcademicAutoSync() =>
      _sharedPref.getBoolean('academicAutoSync') ?? false;
  String getPlannerSemester() =>
      _sharedPref.getString('plannerSelectedSemester') ?? 'Semester 1';
  void setPlannerSemester(String semester) {
    _sharedPref.setString('plannerSelectedSemester', semester);
  }

  Future<void> setAcademicAutoSync(bool enabled) async {
    await _sharedPref.setBoolean('academicAutoSync', enabled);
  }

  bool getAcademicSetupSeen() =>
      _sharedPref.getBoolean('academicSetupSeen') ?? false;
  Future<void> setAcademicSetupSeen() async {
    await _sharedPref.setBoolean('academicSetupSeen', true);
  }

  Future<void> setCredentials(
      String id, String lmsPassword, String qalamPassword) async {
    await _sharedPref.setString('id', id);
    await _sharedPref.setString('lmsPassword', lmsPassword);
    await _sharedPref.setString('qalamPassword', qalamPassword);
  }

  bool getConnectionBannerHidden() =>
      _sharedPref.getBoolean('connectionBannerHidden') ?? false;
  Future<void> setConnectionBannerHidden(bool value) async {
    await _sharedPref.setBoolean('connectionBannerHidden', value);
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
    await _sharedPref.setString('semesters', jsonEncode(data));
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

    await _sharedPref.setString(key, jsonEncode(data));
    final terms = getCourseTerms();
    if (!terms.contains(semester)) {
      terms.add(semester);
      await _sharedPref.setString('plannerCourseTerms', jsonEncode(terms));
    }
  }

  List<String> getCourseTerms() {
    final stored =
        (jsonDecode(_sharedPref.getString('plannerCourseTerms') ?? '[]')
                as List)
            .whereType<String>()
            .toList();
    // Discover old course-only planners without adding unused default terms.
    for (final name in [
      for (var i = 1; i <= 8; i++) 'Semester $i',
      for (var i = 1; i <= 4; i++) 'Summer $i'
    ]) {
      if (!stored.contains(name) && getCourses(name).isNotEmpty) {
        stored.add(name);
      }
    }
    return stored;
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
      _sharedPref.getDouble('absolutesWeight1') ?? 50.0,
      _sharedPref.getDouble('absolutesWeight2') ?? 50.0,
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

  Future<void> saveAcademicDashboard(Map<String, dynamic> value) async {
    await _sharedPref.setString('academicDashboard', jsonEncode(value));
  }

  Map<String, dynamic> getAcademicDashboard() {
    try {
      final value = jsonDecode(
        _sharedPref.getString('academicDashboard') ?? '{}',
      );
      return value is Map<String, dynamic> ? value : <String, dynamic>{};
    } catch (error) {
      debugPrint('Error reading academic dashboard: $error');
      return <String, dynamic>{};
    }
  }
}
