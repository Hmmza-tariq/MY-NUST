import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_snackbar.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('all feedback uses one themed snackbar in $brightness',
        (tester) async {
      Get.testMode = true;
      addTearDown(Get.reset);
      final scheme =
          ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness);
      await tester.pumpWidget(GetMaterialApp(
          theme: ThemeData(colorScheme: scheme),
          home: const Scaffold(body: Text('Home'))));
      await tester.pumpAndSettle();
      for (final show in [
        AppSnackbar.success,
        AppSnackbar.error,
        AppSnackbar.info,
        AppSnackbar.warning
      ]) {
        show(message: 'Consistent feedback');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final bar = tester.widget<GetSnackBar>(find.byType(GetSnackBar));
        expect(bar.backgroundColor, scheme.inverseSurface);
        expect(bar.snackPosition, SnackPosition.BOTTOM);
        expect(bar.title, isNull);
        expect(find.text('Consistent feedback'), findsOneWidget);
        AppSnackbar.dismiss();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
