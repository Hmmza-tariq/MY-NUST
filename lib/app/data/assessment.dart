class Assessment {
  String name;
  double weight;
  double totalMarks;
  double obtainedMarks;
  String type;

  Assessment({
    this.name = "",
    this.weight = 1,
    this.totalMarks = 100,
    this.obtainedMarks = 0,
    this.type = "lecture",
  });
}
