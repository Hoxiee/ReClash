import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';

class _CommonAction extends CommonAction {
  int toggles = 0;

  @override
  void toggleRunning() => toggles++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const native = MethodChannel('com.reclash/hotkeys');
  const legacy = MethodChannel('dev.leanflutter.plugins/hotkey_manager');
  const legacyEvents = MethodChannel(
    'dev.leanflutter.plugins/hotkey_manager_event',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late List<MethodCall> registrations;
  var systemSupported = false;
  var missingBridge = false;

  setUp(() {
    calls = [];
    registrations = [];
    systemSupported = false;
    missingBridge = false;
    messenger.setMockMethodCallHandler(native, (call) async {
      calls.add(call);
      if (missingBridge) throw MissingPluginException();
      return switch (call.method) {
        'initialize' => {
          'applicationId': 'com.reclash.test',
          'systemSupported': systemSupported,
        },
        'keyNames' => ['s'],
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(legacy, (call) async {
      registrations.add(call);
      return true;
    });
    messenger.setMockMethodCallHandler(legacyEvents, (_) async => null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(native, null);
    messenger.setMockMethodCallHandler(legacy, null);
    messenger.setMockMethodCallHandler(legacyEvents, null);
  });

  Future<(_CommonAction, ProviderContainer)> mount(WidgetTester tester) async {
    final action = _CommonAction();
    final container = ProviderContainer(
      overrides: [commonActionProvider.overrideWith(() => action)],
    );
    addTearDown(container.dispose);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
    globalState.container = container;
    container.listen(hotKeyActionsProvider, (_, _) {});
    container.read(hotKeyActionsProvider.notifier).value = [
      HotKeyAction(
        action: HotAction.start,
        key: PhysicalKeyboardKey.keyS.usbHidUsage,
        modifiers: const {KeyboardModifier.control, KeyboardModifier.alt},
      ),
    ];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: HotKeyManager(
            exportDirectory: () async =>
                throw const FileSystemException('Test export disabled'),
            child: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (action, container);
  }

  Future<void> chord(WidgetTester tester) async {
    await tester.sendKeyDownEvent(
      LogicalKeyboardKey.controlLeft,
      platform: 'macos',
    );
    await tester.sendKeyDownEvent(
      LogicalKeyboardKey.altLeft,
      platform: 'macos',
    );
    await tester.sendKeyDownEvent(
      const LogicalKeyboardKey(0x044b),
      platform: 'macos',
      physicalKey: PhysicalKeyboardKey.keyS,
    );
    await tester.sendKeyUpEvent(
      const LogicalKeyboardKey(0x044b),
      platform: 'macos',
      physicalKey: PhysicalKeyboardKey.keyS,
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft, platform: 'macos');
    await tester.sendKeyUpEvent(
      LogicalKeyboardKey.controlLeft,
      platform: 'macos',
    );
    await tester.pump();
  }

  Future<void> desktopToggle() {
    return messenger.handlePlatformMessage(
      native.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('invoke', 'toggle'),
      ),
      (_) {},
    );
  }

  testWidgets(
    'Wayland uses physical local keys and the shared desktop dispatcher',
    (tester) async {
      final (action, container) = await mount(tester);
      expect(container.read(hotKeyPlatformProvider).systemSupported, false);
      expect(registrations.where((call) => call.method == 'register'), isEmpty);
      await chord(tester);
      expect(action.toggles, 1);
      await desktopToggle();
      expect(action.toggles, 2);

      container.read(hotKeyRecordingProvider.notifier).value = true;
      await tester.pumpAndSettle();
      await chord(tester);
      await desktopToggle();
      expect(action.toggles, 2);
      expect(
        calls.where((call) => call.method == 'setEnabled').last.arguments,
        false,
      );

      container.read(hotKeyRecordingProvider.notifier).value = false;
      await tester.pumpAndSettle();
      await chord(tester);
      expect(action.toggles, 3);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(calls.last.method, 'dispose');
    },
    skip: !Platform.isLinux,
  );

  testWidgets('X11 keeps native registration without a second local binding', (
    tester,
  ) async {
    systemSupported = true;
    final (action, container) = await mount(tester);
    expect(container.read(hotKeyPlatformProvider).systemSupported, true);
    expect(
      registrations.where((call) => call.method == 'register'),
      hasLength(1),
    );
    await chord(tester);
    expect(action.toggles, 0);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }, skip: !Platform.isLinux);

  testWidgets(
    'a missing native bridge degrades to local keys without false global success',
    (tester) async {
      missingBridge = true;
      final (action, container) = await mount(tester);
      final platform = container.read(hotKeyPlatformProvider);
      expect(platform.systemSupported, false);
      expect(platform.applicationId, isNull);
      await chord(tester);
      expect(action.toggles, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
    skip: !Platform.isLinux,
  );
}
