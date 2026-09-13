class Semester {
  String name;
  double gpa;
  int credit;
  final String? source;

  Semester({
    required this.name,
    required this.gpa,
    required this.credit,
    this.source,
  });

  factory Semester.fromMap(Map<String, dynamic> map) {
    return Semester(
      name: map['name'],
      gpa: (map['gpa'] as num).toDouble(),
      credit: (map['credit'] as num).toInt(),
      source: map['source']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gpa': gpa,
      'credit': credit,
      if (source != null) 'source': source,
    };
  }
}
