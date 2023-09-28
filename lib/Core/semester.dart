class Semester {
  String name;
  List<Subject> subjects;
  double gpa;
  int credits;

  Semester(this.name, this.subjects, {this.gpa = 0.0, this.credits = 0});
}

class Subject {
  String name;
  int creditHours;
  String expectedGrade;

  Subject(this.name, this.creditHours, this.expectedGrade);
}

class Sem {
  String name = "1";
  double sgpa = 0;
  int credits = 0;
  Sem(this.name, this.sgpa, this.credits);
}
