class Semester {
  String name;
  List<Subject> subjects;
  double gpa;

  Semester(this.name, this.subjects, {this.gpa = 0.0});
}

class Subject {
  String name;
  int creditHours;
  String expectedGrade;

  Subject(this.name, this.creditHours, this.expectedGrade);
}
