import 'dart:async';

import 'package:reclash/common/desktop/hotkeys.dart';
import 'package:reclash/common/setup_check.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/setup.dart';
import 'package:reclash/models/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

class _HotkeySetupSession extends SetupSession {
  _HotkeySetupSession({required this.initiallyActive});

  final bool initiallyActive;

  @override
  SetupSessionState build() => SetupSessionState(
    active: initiallyActive,
    step: SetupStep.profile,
    draft: const SetupDraft(coverage: SetupCoverage.tun),
  );

  void setActive(bool active) => state = state.copyWith(active: active);
}

class _CommonAction extends CommonAction {
  int toggles = 0;

  @override
  Future<void> toggleRunning() async => toggles++;
}

class _SystemAction extends SystemAction {
  int reveals = 0;
  int exits = 0;

  @override
  Future<void> updateVisible() async => reveals++;

  @override
  Future<void> handleExit([bool needSave = true]) async => exits++;
}

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

  group('HotKeyActionExt', () {
    test('builds a spec keyed by the action index and the HID usage', () {
      final spec = HotKeyAction(
        action: HotAction.tun,
        key: PhysicalKeyboardKey.keyT.usbHidUsage,
        modifiers: {KeyboardModifier.control, KeyboardModifier.shift},
      ).toHotKeySpec();

      expect(spec?.id, HotAction.tun.index);
      expect(spec?.key, PhysicalKeyboardKey.keyT.usbHidUsage);
      expect(
        spec?.modifiers,
        unorderedEquals([HotKeyModifier.control, HotKeyModifier.shift]),
      );
    });

    test('skips an action without a key or without modifiers', () {
      expect(
        const HotKeyAction(
          action: HotAction.start,
          modifiers: {KeyboardModifier.control},
        ).toHotKeySpec(),
        isNull,
      );
      expect(
        HotKeyAction(
          action: HotAction.start,
          key: PhysicalKeyboardKey.keyS.usbHidUsage,
        ).toHotKeySpec(),
        isNull,
      );
    });
  });

  group('HotKeyManager', () {
    final action = HotKeyAction(
      action: HotAction.view,
      key: PhysicalKeyboardKey.keyV.usbHidUsage,
      modifiers: const {KeyboardModifier.control},
    );

    Future<(ProviderContainer, List<List<HotKeySpec>>)> pump(
      WidgetTester tester, {
      bool safeMode = false,
      bool systemSupported = true,
      HotKeyAction? configuredAction,
      List<HotKeyAction>? configuredActions,
      Stream<int>? events,
      Future<List<HotKeyFailure>> Function()? respond,
      bool setupActive = false,
    }) async {
      final registrations = <List<HotKeySpec>>[];
      final container = ProviderContainer(
        overrides: [
          safeModeProvider.overrideWithValue(safeMode),
          hotKeyActionsProvider.overrideWithValue(
            configuredActions ?? [configuredAction ?? action],
          ),
          commonActionProvider.overrideWith(_CommonAction.new),
          systemActionProvider.overrideWith(_SystemAction.new),
          setupSessionProvider.overrideWith(
            () => _HotkeySetupSession(initiallyActive: setupActive),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HotKeyManager(
            platformState: HotkeyPlatformState(
              systemSupported: systemSupported,
            ),
            registerHotKeys: ({required specs}) async {
              registrations.add(specs);
              return respond?.call() ?? const [];
            },
            hotKeyEventSource: () => events ?? const Stream<int>.empty(),
            child: const Focus(autofocus: true, child: SizedBox.shrink()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (container, registrations);
    }

    testWidgets('registers the configured shortcuts with the OS', (
      tester,
    ) async {
      final (container, registrations) = await pump(tester);

      expect(registrations, hasLength(1));
      expect(registrations.single.single.id, HotAction.view.index);
      expect(container.read(hotKeyFailuresProvider), isEmpty);
    });

    testWidgets('setup registers only view and exit shortcuts', (tester) async {
      final (container, registrations) = await pump(
        tester,
        setupActive: true,
        configuredActions: [
          action,
          HotKeyAction(
            action: HotAction.exit,
            key: PhysicalKeyboardKey.keyQ.usbHidUsage,
            modifiers: const {KeyboardModifier.control},
          ),
          HotKeyAction(
            action: HotAction.start,
            key: PhysicalKeyboardKey.keyS.usbHidUsage,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );

      expect(registrations.single.map((spec) => spec.id), [
        HotAction.view.index,
        HotAction.exit.index,
      ]);
      expect(
        (container.read(setupSessionProvider.notifier) as _HotkeySetupSession)
            .state
            .active,
        isTrue,
      );
    });

    testWidgets('registers network shortcuts after setup completes', (
      tester,
    ) async {
      final (container, registrations) = await pump(
        tester,
        setupActive: true,
        configuredAction: HotKeyAction(
          action: HotAction.start,
          key: PhysicalKeyboardKey.keyS.usbHidUsage,
          modifiers: const {KeyboardModifier.control},
        ),
      );
      expect(registrations.last, isEmpty);

      (container.read(setupSessionProvider.notifier) as _HotkeySetupSession)
          .setActive(false);
      await tester.pumpAndSettle();

      expect(registrations.last.single.id, HotAction.start.index);
    });

    testWidgets(
      'setup blocks stale native start events but allows view and exit',
      (tester) async {
        final events = StreamController<int>(sync: true);
        addTearDown(events.close);
        final (container, _) = await pump(
          tester,
          setupActive: true,
          events: events.stream,
        );
        events.add(HotAction.start.index);
        events.add(HotAction.view.index);
        events.add(HotAction.exit.index);
        await tester.pump();
        final common =
            container.read(commonActionProvider.notifier) as _CommonAction;
        final system =
            container.read(systemActionProvider.notifier) as _SystemAction;
        expect(common.toggles, 0);
        expect(system.reveals, 1);
        expect(system.exits, 1);

        (container.read(setupSessionProvider.notifier) as _HotkeySetupSession)
            .setActive(false);
        await tester.pumpAndSettle();
        events.add(HotAction.start.index);
        await tester.pump();
        expect(common.toggles, 1);
      },
    );

    testWidgets('setup blocks local start until the wizard completes', (
      tester,
    ) async {
      final (container, _) = await pump(
        tester,
        setupActive: true,
        systemSupported: false,
        configuredAction: HotKeyAction(
          action: HotAction.start,
          key: PhysicalKeyboardKey.keyS.usbHidUsage,
          modifiers: const {KeyboardModifier.control, KeyboardModifier.alt},
        ),
      );
      Future<void> startShortcut() async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
      }

      final common =
          container.read(commonActionProvider.notifier) as _CommonAction;
      await startShortcut();
      expect(common.toggles, 0);
      (container.read(setupSessionProvider.notifier) as _HotkeySetupSession)
          .setActive(false);
      await tester.pumpAndSettle();
      await startShortcut();
      expect(common.toggles, 1);
    });

    testWidgets('a safe mode build registers nothing', (tester) async {
      final (_, registrations) = await pump(tester, safeMode: true);

      expect(registrations, isEmpty);
    });

    testWidgets(
      'runs configured shortcuts locally when global hooks are absent',
      (tester) async {
        final (container, registrations) = await pump(
          tester,
          systemSupported: false,
          configuredAction: HotKeyAction(
            action: HotAction.start,
            key: PhysicalKeyboardKey.keyS.usbHidUsage,
            modifiers: const {KeyboardModifier.control, KeyboardModifier.alt},
          ),
        );

        expect(registrations, isEmpty);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        expect(
          (container.read(commonActionProvider.notifier) as _CommonAction)
              .toggles,
          1,
        );
      },
    );

    testWidgets('publishes the shortcuts the OS refused', (tester) async {
      final (container, _) = await pump(
        tester,
        respond: () async => [
          HotKeyFailure(id: HotAction.view.index, reason: 'taken'),
        ],
      );

      expect(container.read(hotKeyFailuresProvider), {HotAction.view: 'taken'});
    });

    testWidgets('marks every shortcut failed when registration throws', (
      tester,
    ) async {
      final (container, _) = await pump(
        tester,
        respond: () => Future.error(StateError('no backend')),
      );

      expect(container.read(hotKeyFailuresProvider).keys, [HotAction.view]);
    });

    testWidgets('releases every shortcut while one is being recorded', (
      tester,
    ) async {
      final (container, registrations) = await pump(
        tester,
        respond: () async => [
          HotKeyFailure(id: HotAction.view.index, reason: 'taken'),
        ],
      );

      container.read(hotKeyRecordingProvider.notifier).value = true;
      await tester.pumpAndSettle();

      expect(registrations.last, isEmpty);
      expect(container.read(hotKeyFailuresProvider), {
        HotAction.view: 'taken',
      }, reason: 'an empty registration says nothing about the bindings');

      container.read(hotKeyRecordingProvider.notifier).value = false;
      await tester.pumpAndSettle();

      expect(registrations, hasLength(3));
      expect(registrations.last.single.id, HotAction.view.index);
    });
  });
}
