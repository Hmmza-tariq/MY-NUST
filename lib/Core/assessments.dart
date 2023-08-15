class Assessment {
  String name;
  double weightage;
  double obtainedMarks;
  double totalMarks;
  String section;

  Assessment(this.name, this.weightage, this.obtainedMarks, this.totalMarks,
      {required this.section});

  String getSection() {
    return section;
  }
}
