import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/course.dart';
import 'package:nust/app/data/semester.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('GPA reset removes all course keys, including orphaned legacy courses',
      () async {
    SharedPreferences.setMockInitialValues({
      'cached_top_stories': 'ordinary news cache',
      'plugin_plain_flag': true,
    });
    dotenv.loadFromString(envString: 'DATABASE_KEY=0123456789abcdef');
    final database = DatabaseController();
    await database.initialize();
    await database.setCredentials('sample', 'sample-lms', 'sample-qalam');
    await database
        .saveSemesters([Semester(name: 'Fall 2021', credit: 18, gpa: 3.8)]);
    await database.saveCourses(
        [Course(name: 'Calculus', credit: 3, gpa: 4, semesterId: 'Fall 2021')],
        'Fall 2021');
    await database.setData('courses-orphan', '{"courses-orphan":[]}');
    database.saveAbsolutesAssessments([
      {'name': 'Quiz', 'weight': 10}
    ]);
    await database.clearGpaPlanner();
    expect(database.getSemesters(), isEmpty);
    expect(database.getCourses('Fall 2021'), isEmpty);
    expect(await database.getData('courses-orphan'), isEmpty);
    expect(database.getCourseTerms(), isEmpty);
    expect(database.getCredentials()['id'], 'sample');
    expect(database.getAbsolutesAssessments(), isNotEmpty);
    final plain = await SharedPreferences.getInstance();
    expect(plain.getString('cached_top_stories'), 'ordinary news cache');
    expect(plain.getBool('plugin_plain_flag'), isTrue);
    await database.clearAbsolutePlanner();
    expect(database.getAbsolutesAssessments(), isEmpty);
    expect(await database.clear(), isTrue);
    expect(plain.getKeys(), isEmpty);
    expect(database.getCredentials()['id'], isEmpty);
    // Re-open storage to check persistence, not only an in-memory planner copy.
    await database.initialize();
    expect(database.getSemesters(), isEmpty);
    expect(database.getCourseTerms(), isEmpty);
  });
}
