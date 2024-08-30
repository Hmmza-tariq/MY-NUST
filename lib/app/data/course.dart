class Course {
  String name;
  int credit;
  double gpa;
  String semesterId;
  Course({
    required this.name,
    required this.gpa,
    required this.credit,
    required this.semesterId,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'],
      gpa: map['gpa'],
      credit: map['credit'],
      semesterId: map['semesterId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gpa': gpa,
      'credit': credit,
      'semesterId': semesterId,
    };
  }
}
