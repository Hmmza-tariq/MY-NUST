import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/domain/calculators/gpa_projection.dart';

void main() {
  group('GpaProjection', () {
    test('calculates a credit-weighted average', () {
      final result = GpaProjection.weightedAverage(const [
        (gradePoints: 4.0, credits: 3.0),
        (gradePoints: 3.0, credits: 1.0),
      ]);
      expect(result, 3.75);
    });

    test('ignores invalid credits and clamps grade points', () {
      final result = GpaProjection.weightedAverage(const [
        (gradePoints: 5.0, credits: 3.0),
        (gradePoints: 2.0, credits: 0.0),
      ]);
      expect(result, 4.0);
    });

    test('projects CGPA from current and planned credit hours', () {
      final result = GpaProjection.projectedCgpa(
        currentCgpa: 3.2,
        completedCredits: 60,
        plannedSgpa: 3.8,
        plannedCredits: 15,
      );
      expect(result, closeTo(3.32, 0.0001));
    });

    test('returns zero for no credit history', () {
      expect(
        GpaProjection.projectedCgpa(
          currentCgpa: 3.2,
          completedCredits: 0,
          plannedSgpa: 3.8,
          plannedCredits: 0,
        ),
        0,
      );
    });
  });
}
