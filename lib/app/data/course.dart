class Course {
  String name;
  int credit;
  double gpa;

  Course({
    required this.name,
    required this.gpa,
    required this.credit,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
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
