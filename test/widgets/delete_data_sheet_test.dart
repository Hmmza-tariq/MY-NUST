import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/modules/Settings/views/delete_data_sheet.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('deletion requires explicit acknowledgement in $brightness',
        (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue, brightness: brightness)),
          home: const Scaffold(
              body: Padding(
                  padding: EdgeInsets.all(20), child: DeleteDataSheet()))));
      FilledButton button() =>
          tester.widget(find.widgetWithText(FilledButton, 'Delete selected'));
      expect(button().onPressed, isNull);
      expect(find.text('GPA planner'), findsOneWidget);
      expect(find.text('App downloads'), findsOneWidget);
      await tester
          .ensureVisible(find.text('I understand this cannot be undone'));
      await tester.tap(find.text('I understand this cannot be undone'));
      await tester.pump();
      expect(button().onPressed, isNotNull);
      await tester.ensureVisible(find.text('Deselect all'));
      await tester.tap(find.text('Deselect all'));
      await tester.pump();
      expect(button().onPressed, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}
