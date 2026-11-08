import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/controllers/app_update_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('launch preload checks without a dialog and readiness reuses the result',
      () async {
    var calls = 0;
    final controller = AppUpdateController(
        supported: true,
        lookup: () async {
          calls++;
          return 41;
        });
    await controller.preload();
    expect(calls, 1);
    expect(controller.isUpdateAvailable.value, true);
    await controller.start();
    expect(calls, 1);
    expect(controller.checking.value, false);
  });
  test('readiness waits for an in-flight launch lookup', () async {
    final result = Completer<int?>();
    var calls = 0;
    final controller = AppUpdateController(
        supported: true,
        lookup: () {
          calls++;
          return result.future;
        });
    final launch = controller.preload();
    final ready = controller.start();
    expect(controller.checking.value, true);
    result.complete(null);
    await Future.wait([launch, ready]);
    expect(calls, 1);
    expect(controller.isUpdateAvailable.value, false);
    expect(controller.statusText.value, 'You’re up to date');
  });
  test(
      'failed launch lookup is non-blocking and throttled on foreground retries',
      () async {
    var calls = 0;
    final controller = AppUpdateController(
        supported: true,
        lookup: () async {
          calls++;
          throw StateError('unavailable');
        });
    await controller.preload();
    await controller.start();
    await controller.preload();
    expect(calls, 1);
    expect(controller.checking.value, false);
    expect(controller.statusText.value, 'Tap to check Google Play');
  });
  testWidgets(
      'available launch update prompts after readiness; Later respects cooldown',
      (tester) async {
    await tester
        .pumpWidget(GetMaterialApp(home: const Scaffold(body: Text('Home'))));
    final controller =
        AppUpdateController(supported: true, lookup: () async => 41);
    await controller.preload();
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);
    final startup = controller.start();
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    await startup;
    await controller.start();
    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });
}
