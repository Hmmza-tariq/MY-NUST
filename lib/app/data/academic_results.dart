class AcademicStats {
  const AcademicStats(
      {this.studentName,
      this.cgpa,
      this.earnedCredits,
      this.inProgressCredits,
      this.totalCredits});
  final double? cgpa;
  final String? studentName;
  String? get greeting {
    final name = studentName?.trim();
    if (name == null || name.isEmpty) return null;
    return 'Hey, ${name.split(RegExp(r'\s+')).first}!';
  }

  final double? earnedCredits;
  final double? inProgressCredits;
  final double? totalCredits;

  factory AcademicStats.fromMap(Map<String, dynamic> map) => AcademicStats(
        cgpa: (map['cgpa'] as num?)?.toDouble(),
        studentName: map['studentName']?.toString(),
        earnedCredits: (map['earnedCredits'] as num?)?.toDouble(),
        inProgressCredits: (map['inProgressCredits'] as num?)?.toDouble(),
        totalCredits: (map['totalCredits'] as num?)?.toDouble(),
      );
  Map<String, dynamic> toMap() => {
        if (cgpa != null) 'cgpa': cgpa,
        if (studentName != null) 'studentName': studentName,
        if (earnedCredits != null) 'earnedCredits': earnedCredits,
        if (inProgressCredits != null) 'inProgressCredits': inProgressCredits,
        if (totalCredits != null) 'totalCredits': totalCredits,
      };
}

class AcademicCourseResult {
  const AcademicCourseResult(
      {required this.name,
      required this.credits,
      required this.grade,
      required this.gradePoint});
  final String name;
  final double credits;
  final String grade;
  final double gradePoint;
  factory AcademicCourseResult.fromMap(Map<String, dynamic> map) =>
      AcademicCourseResult(
        name: map['name'].toString(),
        credits: (map['credits'] as num).toDouble(),
        grade: map['grade'].toString(),
        gradePoint: (map['gradePoint'] as num).toDouble(),
      );
  Map<String, dynamic> toMap() => {
        'name': name,
        'credits': credits,
        'grade': grade,
        'gradePoint': gradePoint
      };
}

class AcademicTermResult {
  const AcademicTermResult(
      {required this.name,
      required this.sgpa,
      required this.cgpa,
      required this.attemptedCredits,
      required this.earnedCredits,
      required this.cumulativeCredits,
      this.regularSemesterCount,
      this.termType,
      this.courses = const []});
  final String name;
  final double sgpa;
  final double cgpa;
  final double attemptedCredits;
  final double earnedCredits;
  final double cumulativeCredits;
  final int? regularSemesterCount;
  final String? termType;
  final List<AcademicCourseResult> courses;
  factory AcademicTermResult.fromMap(Map<String, dynamic> map) =>
      AcademicTermResult(
        name: map['name'].toString(),
        sgpa: (map['sgpa'] as num).toDouble(),
        cgpa: (map['cgpa'] as num).toDouble(),
        attemptedCredits: (map['attemptedCredits'] as num).toDouble(),
        earnedCredits: (map['earnedCredits'] as num).toDouble(),
        cumulativeCredits: (map['cumulativeCredits'] as num).toDouble(),
        regularSemesterCount: (map['regularSemesterCount'] as num?)?.toInt(),
        termType: map['termType'] as String?,
        courses: (map['courses'] as List? ?? [])
            .whereType<Map>()
            .map((e) =>
                AcademicCourseResult.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
  Map<String, dynamic> toMap() => {
        'name': name,
        'sgpa': sgpa,
        'cgpa': cgpa,
        'attemptedCredits': attemptedCredits,
        'earnedCredits': earnedCredits,
        'cumulativeCredits': cumulativeCredits,
        if (regularSemesterCount != null)
          'regularSemesterCount': regularSemesterCount,
        if (termType != null) 'termType': termType,
        'courses': courses.map((e) => e.toMap()).toList(),
      };
}
