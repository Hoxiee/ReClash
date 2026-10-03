import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/desktop/hotkey_export.dart';
import 'package:reclash/common/desktop/hotkeys.dart';
import 'package:reclash/common/ui/keyboard.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('desktop action commands', () {
    test('every action has a unique stable desktop name', () {
      expect(HotAction.values.map((action) => action.desktopAction).toSet(), {
        'toggle',
        'toggle-window',
        'toggle-mode',
        'toggle-system-proxy',
        'toggle-tun',
        'mode-rule',
        'mode-global',
        'mode-direct',
        'test-delay',
        'update-profiles',
        'copy-env',
        'quit',
      });
      expect(
        HotAction.start.desktopCommand('com.reclash.dev'),
        'gapplication action com.reclash.dev toggle',
      );
    });

    test('application IDs cannot add shell syntax', () {
      for (final id in ['com.reclash;quit', 'com.reclash\nquit', r'$(quit)']) {
        expect(() => HotAction.start.desktopCommand(id), throwsArgumentError);
      }
    });
  });

  group('compositor exports', () {
    final binding = HotKeyAction(
      action: HotAction.start,
      key: PhysicalKeyboardKey.keyS.usbHidUsage,
      modifiers: const {KeyboardModifier.alt, KeyboardModifier.control},
    );
    final names = {PhysicalKeyboardKey.keyS.usbHidUsage: 'S'};

    HotkeyExport export(HotkeyExportFormat format) => exportHotkeys(
      format: format,
      applicationId: 'com.reclash',
      bindings: [binding],
      keyNames: names,
    );

    test('Sway uses non-repeating binds and native modifier names', () {
      expect(
        export(HotkeyExportFormat.sway).text,
        'bindsym --no-repeat Ctrl+Mod1+s exec '
        'gapplication action com.reclash toggle\n',
      );
    });

    test('Hyprland uses ordinary, non-repeating binds', () {
      expect(
        export(HotkeyExportFormat.hyprland).text,
        'bind = CTRL ALT, s, exec, gapplication action com.reclash toggle\n',
      );
    });

    test('niri passes argv directly without a shell', () {
      expect(
        export(HotkeyExportFormat.niri).text,
        'binds {\n'
        '    Ctrl+Alt+s repeat=false { spawn "gapplication" "action" '
        '"com.reclash" "toggle"; }\n'
        '}\n',
      );
    });

    test('unsupported keys and modifiers are reported, not guessed', () {
      final result = exportHotkeys(
        format: HotkeyExportFormat.sway,
        applicationId: 'com.reclash',
        bindings: [
          binding.copyWith(modifiers: {KeyboardModifier.fn}),
          binding.copyWith(action: HotAction.view, key: 0xdead),
          const HotKeyAction(action: HotAction.exit),
        ],
        keyNames: names,
      );
      expect(result.unsupported, [HotAction.start, HotAction.view]);
      expect(result.text.trim(), isEmpty);
    });

    test(
      'include paths preserve spaces and reject variable or line injection',
      () {
        expect(
          HotkeyExportFormat.niri.includeDirective('/home/a b/hotkeys'),
          'include "/home/a b/hotkeys/niri.kdl"',
        );
        for (final format in HotkeyExportFormat.values) {
          expect(format.includeDirective('/home/a\ninjected'), isNull);
          expect(format.includeDirective(r'/home/$other'), isNull);
        }
      },
    );

    test(
      'writes only owned files, atomically and without redundant updates',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'reclash-hotkeys-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final unrelated = File('${directory.path}/user.conf');
        await unrelated.writeAsString('preserve');
        final exports = {
          for (final format in HotkeyExportFormat.values)
            format: export(format),
        };
        await writeHotkeyExports(directory, exports);
        final file = File('${directory.path}/niri.kdl');
        final timestamp = DateTime(2020);
        await file.setLastModified(timestamp);
        await writeHotkeyExports(directory, exports);
        expect((await file.stat()).modified, timestamp);
        expect(await unrelated.readAsString(), 'preserve');
        expect(await File('${file.path}.tmp').exists(), false);
        await writeHotkeyExports(directory, {
          HotkeyExportFormat.niri: exportHotkeys(
            format: HotkeyExportFormat.niri,
            applicationId: 'com.reclash',
            bindings: const [],
            keyNames: const {},
          ),
        });
        expect(await file.readAsString(), 'binds {\n\n}\n');
      },
    );
  });

  group('Linux method channel', () {
    const channel = MethodChannel('com.reclash/hotkeys-test');
    const codec = StandardMethodCodec();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    late LinuxHotkeys bridge;
    late List<HotAction> invoked;
    late List<MethodCall> calls;

    Future<void> invoke(String action) async {
      await messenger.handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(MethodCall('invoke', action)),
        (_) {},
      );
    }

    setUp(() {
      invoked = [];
      calls = [];
      bridge = LinuxHotkeys(channel: channel, onAction: invoked.add);
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return switch (call.method) {
          'initialize' => {
            'applicationId': 'com.reclash.test',
            'systemSupported': false,
          },
          'keyNames' => ['s', null],
          _ => null,
        };
      });
    });

    tearDown(() async {
      await bridge.dispose();
      messenger.setMockMethodCallHandler(channel, null);
    });

    test(
      'exports all actions and honors the actual display capability',
      () async {
        final state = await bridge.initialize();
        expect(state.systemSupported, false);
        expect(state.applicationId, 'com.reclash.test');
        expect(calls.first.arguments, [
          for (final action in HotAction.values) action.desktopAction,
        ]);
        expect(await bridge.keyNames([115, 0]), ['s', null]);
        await bridge.setEnabled(false);
        expect(calls.last.method, 'setEnabled');
        expect(calls.last.arguments, false);
      },
    );

    testWidgets('disposal cancels an unanswered native probe without a timer', (
      tester,
    ) async {
      final reply = Completer<Object?>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        return call.method == 'initialize' ? reply.future : null;
      });
      final initialized = bridge.initialize();
      final rejected = expectLater(initialized, throwsStateError);
      await tester.pump();
      await tester.runAsync(() => bridge.dispose());
      await rejected;
      reply.complete({'applicationId': 'com.reclash', 'systemSupported': true});
      await tester.pump();
      expect(invoked, isEmpty);
    });

    test('dispatches only known actions and stops after disposal', () async {
      await bridge.initialize();
      await invoke('toggle');
      await invoke('mode-rule');
      await invoke('unknown');
      expect(invoked, [HotAction.start, HotAction.ruleMode]);
      await bridge.dispose();
      await invoke('toggle');
      expect(invoked, [HotAction.start, HotAction.ruleMode]);
    });

    test('rejects malformed native identity and key-name responses', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        return call.method == 'initialize'
            ? {'applicationId': 'invalid;id'}
            : ['s'];
      });
      await expectLater(bridge.initialize(), throwsFormatException);
      await expectLater(bridge.keyNames([1, 2]), throwsFormatException);
    });
  });

  testWidgets('local chords use physical keys and never repeat', (
    tester,
  ) async {
    var invoked = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CallbackShortcuts(
          bindings: {
            PhysicalHotkeyActivator(
              PhysicalKeyboardKey.keyA.usbHidUsage,
              const {KeyboardModifier.control},
            ): () =>
                invoked++,
          },
          child: const Focus(autofocus: true, child: SizedBox()),
        ),
      ),
    );
    await tester.pump();
    const cyrillicA = LogicalKeyboardKey(0x0444);
    await tester.sendKeyDownEvent(
      LogicalKeyboardKey.controlLeft,
      platform: 'macos',
    );
    await tester.sendKeyDownEvent(
      cyrillicA,
      platform: 'macos',
      physicalKey: PhysicalKeyboardKey.keyA,
    );
    await tester.sendKeyRepeatEvent(
      cyrillicA,
      platform: 'macos',
      physicalKey: PhysicalKeyboardKey.keyA,
    );
    await tester.sendKeyUpEvent(
      cyrillicA,
      platform: 'macos',
      physicalKey: PhysicalKeyboardKey.keyA,
    );
    await tester.sendKeyUpEvent(
      LogicalKeyboardKey.controlLeft,
      platform: 'macos',
    );
    expect(invoked, 1);
  });
}
