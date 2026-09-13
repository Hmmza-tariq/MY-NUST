import 'academic_dashboard.dart';
import 'academic_results.dart';

/// Synthetic data in the same model used by the portal parser. Never persisted.
AcademicDashboardData createDemoDashboard({DateTime? now}) {
  final time = now ?? DateTime.now();
  final today = DateTime(time.year, time.month, time.day);
  const names = [
    'Programming Fundamentals',
    'Calculus',
    'Applied Physics',
    'English',
    'Digital Logic Design',
    'Pakistan Studies',
    'Programming Lab'
  ];
  const attendance = [94, 68, 77, 86, 72, 100, 90];
  const marks = [9, 3, 7, 10, 0, 8, 6];
  final courses = [
    for (var i = 0; i < names.length; i++)
      AcademicItem(
        title: names[i],
        detail: 'Demo course · Current semester',
        meta: {
          'demo': true,
          'percent': attendance[i],
          'atRisk': attendance[i] < 75,
          'code': 'DEMO-${101 + i}',
          'term': 'Current semester',
          'marksSyncedAt': time.toIso8601String(),
          'categories': [
            for (final category in [
              'Quiz',
              'Assignments',
              'Mid Term',
              'Final Term'
            ])
              {
                'name': category,
                'weight': category == 'Final Term'
                    ? 50
                    : category == 'Mid Term'
                        ? 30
                        : 10,
                'obtainedPercentage':
                    category == 'Final Term' ? null : marks[i] * 10,
                'assessments': [
                  for (var j = 1; j <= (category == 'Quiz' ? 3 : 1); j++)
                    {
                      'name': '$category $j',
                      'maxMarks': 10,
                      'obtainedMarks':
                          category == 'Final Term' || j == 3 ? null : marks[i],
                      'classAverage': category == 'Final Term' ? null : 7.2,
                      'percentage': category == 'Final Term' || j == 3
                          ? null
                          : marks[i] * 10,
                    }
                ],
              }
          ]
        },
      )
  ];
  return AcademicDashboardData(
    stats: const AcademicStats(studentName: 'Hamza', cgpa: 3.82),
    qalamSyncedAt: time,
    lmsSyncedAt: time,
    statsSyncedAt: time,
    resultsSyncedAt: time,
    attendance: courses,
    timetable: [
      for (var i = 0; i < 3; i++)
        AcademicItem(
            title: names[i],
            detail: '${9 + i * 2}:00 · Room ${201 + i}',
            date: today.add(Duration(hours: 9 + i * 2)),
            meta: {'demo': true})
    ],
    deadlines: [
      AcademicItem(
          title: 'Programming assignment',
          detail: 'Programming Fundamentals · Pending submission',
          date: today.add(const Duration(days: 1, hours: 23)),
          meta: {'demo': true}),
      AcademicItem(
          title: 'Calculus quiz',
          detail: 'Calculus · Upcoming quiz',
          date: today.add(const Duration(days: 3, hours: 10)),
          meta: {'demo': true})
    ],
    invoices: [
      const AcademicItem(
          title: 'Semester fee',
          detail: 'Paid · PKR 120,000',
          meta: {'demo': true, 'status': 'Paid', 'amount': 120000}),
      AcademicItem(
          title: 'Mess invoice',
          detail: 'Unpaid · PKR 8,500',
          date: today.add(const Duration(days: 5)),
          meta: {'demo': true, 'status': 'Unpaid', 'amount': 8500})
    ],
    results: [
      for (var term = 1; term <= 3; term++)
        AcademicTermResult(
            name: 'Fall ${2022 + term}',
            sgpa: 3.7 + term * .04,
            cgpa: 3.7 + term * .04,
            attemptedCredits: 18,
            earnedCredits: 18,
            cumulativeCredits: term * 18,
            regularSemesterCount: term,
            termType: 'regular',
            courses: [
              for (final name in names.take(6))
                AcademicCourseResult(
                    name: name, credits: 3, grade: 'A', gradePoint: 4)
            ])
    ],
  );
}
