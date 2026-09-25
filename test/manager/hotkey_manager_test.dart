import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart' show HotKeyModifier;

void main() {
  group('KeyboardModifierExt', () {
    test('maps keyboard modifiers to hotkey modifiers', () {
      expect(KeyboardModifier.alt.toHotKeyModifier(), HotKeyModifier.alt);
      expect(
        KeyboardModifier.capsLock.toHotKeyModifier(),
        HotKeyModifier.capsLock,
      );
      expect(
        KeyboardModifier.control.toHotKeyModifier(),
        HotKeyModifier.control,
      );
      expect(KeyboardModifier.fn.toHotKeyModifier(), HotKeyModifier.fn);
      expect(KeyboardModifier.meta.toHotKeyModifier(), HotKeyModifier.meta);
      expect(KeyboardModifier.shift.toHotKeyModifier(), HotKeyModifier.shift);
    });

    test('covers every keyboard modifier', () {
      for (final modifier in KeyboardModifier.values) {
        expect(modifier.toHotKeyModifier(), isA<HotKeyModifier>());
      }
    });
  });

  testWidgets('control number shortcuts select visible navigation pages', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.profiles,
                label: PageLabel.profiles,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: HotKeyManager(
            child: Scaffold(body: Focus(autofocus: true, child: SizedBox())),
          ),
        ),
      ),
    );
    await tester.pump();

    final modifier = system.isMacOS
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();

    expect(container.read(currentPageLabelProvider), PageLabel.profiles);

    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();

    expect(container.read(currentPageLabelProvider), PageLabel.profiles);
  });
}
