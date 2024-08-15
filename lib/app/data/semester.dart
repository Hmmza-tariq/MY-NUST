class Semester {
  String name;
  double gpa;
  int credit;

  Semester({
    required this.name,
    required this.gpa,
    required this.credit,
  });

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      name: map['name'],
      gpa: map['gpa'],
      credit: map['credit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gpa': gpa,
      'credit': credit,
    };
  }
}
