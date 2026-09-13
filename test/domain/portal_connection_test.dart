import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/modules/Authentication/controllers/authentication_controller.dart';
import 'package:nust/app/modules/Settings/views/settings_view.dart';
import 'package:nust/app/modules/widgets/academic_home_summary.dart';
import 'package:nust/app/services/academic_sync_service.dart';

class MemoryDatabase extends GetxController implements DatabaseController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  bool autofill = false, automatic = false, hidden = false;
  String savedId = '';
  @override
  Future<void> setCredentials(
      String id, String lmsPassword, String qalamPassword) async {
    await Future<void>.delayed(Duration.zero);
    savedId = id;
  }

  @override
  Map<String, dynamic> getAcademicDashboard() => {};
  @override
  bool getAcademicAutoSync() => automatic;
  @override
  bool getConnectionBannerHidden() => hidden;
  @override
  Future<void> setAutoFill(bool value) async {
    autofill = value;
  }

  @override
  Future<void> setAcademicAutoSync(bool value) async {
    automatic = value;
  }

  @override
  Future<void> setConnectionBannerHidden(bool value) async {
    hidden = value;
  }
}

class MemoryAuthentication extends AuthenticationController {
  @override
  // Avoid invoking platform biometrics in a pure connection unit test.
  // ignore: must_call_super
  void onInit() {}
}

class CountingSync extends AcademicSyncService {
  int attempts = 0;
  @override
  Future<void> syncSavedPortals(
      {bool resultsOnly = false, String? courseUrl}) async {
    attempts++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => dotenv.loadFromString(envString: 'ENCRYPTION_KEY=fixture'));
  tearDown(Get.reset);
  test('demo sync needs no credentials and restores cache without writes', () async {
    Get.put<DatabaseController>(MemoryDatabase());
    Get.put<AuthenticationController>(MemoryAuthentication());
    final sync = Get.put(AcademicSyncService());
    await sync.setDemoMode(true);
    expect(sync.data.value.attendance.length, 7);
    await sync.syncOnOpen();
    await sync.syncSavedPortals();
    expect(sync.isSyncing.value, isFalse);
    expect(sync.credentialsRejected.value, isFalse);
    await sync.setDemoMode(false);
    expect(sync.data.value.attendance, isEmpty);
  });
  test('connection switch persists both gates and startup sync runs', () async {
    final db = Get.put<DatabaseController>(MemoryDatabase()) as MemoryDatabase;
    final auth = Get.put<AuthenticationController>(MemoryAuthentication());
    auth.id.value = 'fixture.student';
    auth.qalamPassword.value = 'fixture-only';
    final sync = Get.put<AcademicSyncService>(CountingSync()) as CountingSync;
    await sync.saveConnection('fixture.student', '', 'fixture-only');
    expect(db.savedId, 'fixture.student');
    expect(db.automatic && db.autofill, isTrue);
    expect(auth.isAutofillEnabled.value, isTrue);
    await sync.syncOnOpen();
    expect(sync.attempts, 1);
    await sync.setAutomaticSync(false);
    expect(db.automatic || db.autofill, isFalse);
    expect(auth.isAutofillEnabled.value, isFalse);
    await sync.syncOnOpen();
    expect(sync.attempts, 1);
  });
  test('banner dismissal persists into a new service instance', () async {
    final db = Get.put<DatabaseController>(MemoryDatabase()) as MemoryDatabase;
    Get.put<AuthenticationController>(MemoryAuthentication());
    final sync = Get.put<AcademicSyncService>(CountingSync());
    await sync.hideConnectionBanner();
    expect(db.hidden, isTrue);
    await Get.delete<AcademicSyncService>(force: true);
    expect(
        Get.put<AcademicSyncService>(CountingSync())
            .connectionBannerHidden
            .value,
        isTrue);
  });
  test('only an explicit login rejection is marked invalid', () {
    expect(
        AcademicSyncService.loginWasRejected(
            '<div class="alert">Wrong login/password</div>'),
        isTrue);
    expect(
        AcademicSyncService.loginWasRejected(
            '<p>Invalid login, please try again</p>'),
        isTrue);
    expect(
        AcademicSyncService.loginWasRejected(
            '<form><input id="password"></form>'),
        isFalse);
    expect(AcademicSyncService.loginWasRejected('<p>Connection timed out</p>'),
        isFalse);
    expect(
        AcademicSyncService.loginWasRejected(
            '<script>var error = "Invalid password";</script><p>Login</p>'),
        isFalse);
  });
  test('credentials require an ID and at least one portal password', () {
    expect(validatePortalCredentials(' ', 'fixture', ''), isNotNull);
    expect(validatePortalCredentials('student', '', ''), isNotNull);
    expect(validatePortalCredentials('student', '', 'fixture'), isNull);
    expect(validatePortalCredentials('student', 'fixture', ''), isNull);
  });
  testWidgets('banner menu offers persistent dismissal without a loader',
      (tester) async {
    var dismissed = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AcademicConnectionBanner(
                hasCredentials: true,
                syncing: false,
                onPressed: () {},
                onDismiss: () => dismissed = true))));
    await tester.tap(find.byTooltip('Banner options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Don’t show again'));
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
