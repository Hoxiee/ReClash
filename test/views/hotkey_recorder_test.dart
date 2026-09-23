import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpRecorder(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [viewSizeProvider.overrideWithValue(const Size(1000, 900))],
        child: Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                dialogs.showCommonDialog(
                  child: const HotKeyRecorder(
                    hotKeyAction: HotKeyAction(action: HotAction.start),
                  ),
                );
              },
              child: const Text('record'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('record'));
    await tester.pumpAndSettle();
  }

  testWidgets('a bare navigation key is not recorded', (tester) async {
    await pumpRecorder(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.byType(KeyboardKeyBox), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(KeyboardKeyBox), findsNothing);
  });

  testWidgets('a chord with a modifier is recorded', (tester) async {
    await pumpRecorder(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(find.byType(KeyboardKeyBox), findsWidgets);
  });

  testWidgets('tab reaches the dialog actions', (tester) async {
    await pumpRecorder(tester);

    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    final focused = FocusManager.instance.primaryFocus?.context;
    expect(focused?.findAncestorWidgetOfExactType<TextButton>(), isNotNull);
  });
}
