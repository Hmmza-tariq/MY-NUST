class Course {
  String name;
  int credit;
  double gpa;
  String semesterId;
  final String? source;
  Course({
    required this.name,
    required this.gpa,
    required this.credit,
    required this.semesterId,
    this.source,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'],
      gpa: (map['gpa'] as num).toDouble(),
      credit: (map['credit'] as num).toInt(),
      semesterId: map['semesterId'],
      source: map['source']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gpa': gpa,
      'credit': credit,
      'semesterId': semesterId,
      if (source != null) 'source': source,
    };
  }
}
