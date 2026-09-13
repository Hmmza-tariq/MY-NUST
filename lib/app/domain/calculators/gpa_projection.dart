class GpaProjection {
  const GpaProjection._();

  static double weightedAverage(
    Iterable<({double gradePoints, double credits})> entries,
  ) {
    var points = 0.0;
    var credits = 0.0;
    for (final entry in entries) {
      if (!entry.gradePoints.isFinite ||
          !entry.credits.isFinite ||
          entry.credits <= 0) {
        continue;
      }
      points += entry.gradePoints.clamp(0, 4) * entry.credits;
      credits += entry.credits;
    }
    return credits == 0 ? 0 : points / credits;
  }

  static double projectedCgpa({
    required double currentCgpa,
    required double completedCredits,
    required double plannedSgpa,
    required double plannedCredits,
  }) {
    if (completedCredits < 0 || plannedCredits < 0) return 0;
    final totalCredits = completedCredits + plannedCredits;
    if (totalCredits == 0) return 0;
    final result = ((currentCgpa.clamp(0, 4) * completedCredits) +
            (plannedSgpa.clamp(0, 4) * plannedCredits)) /
        totalCredits;
    return result.clamp(0, 4);
  }

  static double replacingTerm({
    required Iterable<({String name, double gradePoints, double credits})>
        terms,
    required String selectedTerm,
    required double plannedSgpa,
    required double plannedCredits,
  }) {
    final remaining = terms
        .where((e) =>
            e.name.trim().toLowerCase() != selectedTerm.trim().toLowerCase())
        .toList();
    return projectedCgpa(
      currentCgpa: weightedAverage(remaining
          .map((e) => (gradePoints: e.gradePoints, credits: e.credits))),
      completedCredits: remaining.fold<double>(0, (n, e) => n + e.credits),
      plannedSgpa: plannedSgpa,
      plannedCredits: plannedCredits,
    );
  }
}
