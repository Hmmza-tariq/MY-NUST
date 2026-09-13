import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust/app/modules/widgets/portal_connection_tile.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('compact connection row at 320 with large text $brightness',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var managed = false, restored = false;
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(useMaterial3: true, brightness: brightness),
          home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(320, 800), textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                  body: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PortalConnectionTile(
                          enabled: false,
                          syncing: false,
                          hasCredentials: false,
                          needsAttention: false,
                          bannerHidden: true,
                          onChanged: (_) {},
                          onManage: () => managed = true,
                          onPrivacy: () {},
                          onShowBanner: () => restored = true))))));
      await tester.tap(find.text('Portal connection'));
      expect(managed, isTrue);
      expect(find.text('Show Home banner'), findsNothing);
      await tester.tap(find.byTooltip('Connection options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Home banner'));
      await tester.pumpAndSettle();
      expect(restored, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
