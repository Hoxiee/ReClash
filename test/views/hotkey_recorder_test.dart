import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<HotKeyAction> hotKeyActions = const [],
}) {
  const size = Size(1000, 900);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  // hotKeyActionsProvider is autoDispose: without a live listener the seeded
  // value is discarded before the assertions read it back.
  final subscription = container.listen(
    hotKeyActionsProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  container.read(hotKeyActionsProvider.notifier).value = hotKeyActions;
  return container;
}

Future<void> _pumpRecorder(
  WidgetTester tester,
  ProviderContainer container,
  HotKeyAction action,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                dialogs.showCommonDialog(
                  child: HotKeyRecorder(
                    hotKeyAction: action,
                    labels: ShortcutLabels.host(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _pressChord(WidgetTester tester) async {
  await simulateKeyDownEvent(
    LogicalKeyboardKey.controlLeft,
    physicalKey: PhysicalKeyboardKey.controlLeft,
  );
  await simulateKeyDownEvent(
    LogicalKeyboardKey.keyA,
    physicalKey: PhysicalKeyboardKey.keyA,
  );
  await tester.pumpAndSettle();
  await simulateKeyUpEvent(
    LogicalKeyboardKey.keyA,
    physicalKey: PhysicalKeyboardKey.keyA,
  );
  await simulateKeyUpEvent(
    LogicalKeyboardKey.controlLeft,
    physicalKey: PhysicalKeyboardKey.controlLeft,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('prompts for input until a key is captured', (tester) async {
    final container = _containerFor(tester);
    await _pumpRecorder(
      tester,
      container,
      const HotKeyAction(action: HotAction.mode),
    );

    expect(find.text(currentAppLocalizations.pressKeyboard), findsOne);

    await _pressChord(tester);

    expect(find.text(currentAppLocalizations.pressKeyboard), findsNothing);
    expect(find.text('A'), findsWidgets);
  });

  testWidgets('save stores a modifier plus key combination', (tester) async {
    final container = _containerFor(tester);
    await _pumpRecorder(
      tester,
      container,
      const HotKeyAction(action: HotAction.mode),
    );

    await _pressChord(tester);
    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();

    final stored = container.read(hotKeyActionsProvider);
    expect(stored, hasLength(1));
    expect(stored.single.action, HotAction.mode);
    expect(stored.single.key, PhysicalKeyboardKey.keyA.usbHidUsage);
    expect(stored.single.modifiers, {KeyboardModifier.control});
  });

  testWidgets('a bare key cannot be saved and asks for a modifier', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpRecorder(
      tester,
      container,
      const HotKeyAction(action: HotAction.mode),
    );

    await simulateKeyDownEvent(
      LogicalKeyboardKey.keyA,
      physicalKey: PhysicalKeyboardKey.keyA,
    );
    await tester.pumpAndSettle();
    await simulateKeyUpEvent(
      LogicalKeyboardKey.keyA,
      physicalKey: PhysicalKeyboardKey.keyA,
    );
    await tester.pumpAndSettle();

    final save = tester.widget<TextButton>(
      find.widgetWithText(TextButton, currentAppLocalizations.save),
    );
    expect(save.onPressed, isNull);

    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();
    expect(container.read(hotKeyActionsProvider), isEmpty);
  });

  testWidgets('a conflicting combination reports the action it moves from', (
    tester,
  ) async {
    final taken = HotKeyAction(
      action: HotAction.start,
      key: PhysicalKeyboardKey.keyA.usbHidUsage,
      modifiers: const {KeyboardModifier.control},
    );
    final container = _containerFor(tester, hotKeyActions: [taken]);
    await _pumpRecorder(
      tester,
      container,
      const HotKeyAction(action: HotAction.mode),
    );

    await _pressChord(tester);

    expect(
      find.text(
        currentAppLocalizations.hotkeyConflictWith(HotAction.start.label),
      ),
      findsOne,
    );

    await tester.tap(find.text(currentAppLocalizations.save));
    await tester.pumpAndSettle();

    final stored = container.read(hotKeyActionsProvider);
    expect(stored, hasLength(1));
    expect(stored.single.action, HotAction.mode);
    expect(stored.single.key, PhysicalKeyboardKey.keyA.usbHidUsage);
  });

  testWidgets('remove clears the key and modifiers for the action', (
    tester,
  ) async {
    final existing = HotKeyAction(
      action: HotAction.mode,
      key: PhysicalKeyboardKey.keyB.usbHidUsage,
      modifiers: const {KeyboardModifier.control},
    );
    final container = _containerFor(tester, hotKeyActions: [existing]);
    await _pumpRecorder(tester, container, existing);

    await tester.tap(find.text(currentAppLocalizations.remove));
    await tester.pumpAndSettle();

    expect(container.read(hotKeyActionsProvider), isEmpty);
  });
}
