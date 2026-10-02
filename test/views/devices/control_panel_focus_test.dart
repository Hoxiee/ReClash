import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/devices/control_panel.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('$packageName/companion_client');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final commands = <String>[];
  var commandStatus = 'succeeded';

  setUp(() {
    system.isTVForTesting = true;
    FocusHighlightVisibility.visibleForTesting = true;
    commands.clear();
    commandStatus = 'succeeded';
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'readState':
          return {
            'ok': true,
            'data': {
              'running': true,
              'profileLabel': 'Home',
              'groupName': 'Group',
              'nodeName': 'US Alpha',
              'outboundMode': 'auto',
              'revision': 1,
            },
          };
        case 'readGroups':
          return {
            'ok': true,
            'data': {
              'items': [
                {
                  'name': 'Group',
                  'type': 'Selector',
                  'selected': 'US Alpha',
                  'options': [
                    {'name': 'US Alpha', 'type': 'ss', 'delayMs': 120},
                    {'name': 'JP Beta', 'type': 'ss'},
                  ],
                },
              ],
            },
          };
        case 'readProfiles':
          return {
            'ok': true,
            'data': {
              'items': [
                {'id': 1, 'label': 'Home', 'active': true},
                {'id': 2, 'label': 'Work', 'active': false},
              ],
            },
          };
        case 'command':
          final args = (call.arguments as Map).cast<String, Object?>();
          commands.add(args['kind'] as String);
          return {
            'ok': true,
            'data': {'status': commandStatus, 'effectState': 'applied'},
          };
        default:
          return null;
      }
    });
  });
  tearDown(() {
    system.isTVForTesting = false;
    FocusHighlightVisibility.visibleForTesting = false;
    messenger.setMockMethodCallHandler(channel, null);
  });

  String? focusedText() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return null;
    Element? node = ctx as Element;
    for (var depth = 0; depth < 6 && node != null; depth++) {
      final texts = find
          .descendant(
            of: find.byWidget(node.widget),
            matching: find.byType(Text),
          )
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .whereType<String>()
          .toList();
      if (texts.isNotEmpty) return texts.join('|');
      Element? parent;
      node.visitAncestorElements((e) {
        parent = e;
        return false;
      });
      node = parent;
    }
    return '<none>';
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1000, 1400);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: CompanionControlPanel(deviceId: 'd1', title: 'Living Room'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<bool> focusUntil(
    WidgetTester tester,
    LogicalKeyboardKey key,
    bool Function(String?) done,
  ) async {
    for (var i = 0; i < 14; i++) {
      if (done(focusedText())) return true;
      await tester.sendKeyEvent(key);
      await tester.pump();
    }
    return done(focusedText());
  }

  testWidgets('opens with a focused control', (tester) async {
    await pump(tester);
    expect(focusedText(), isNotNull);
  });

  const modes = {'Auto', 'Rule', 'Global', 'Direct'};

  testWidgets('arrow keys reach a mode chip and the node row', (tester) async {
    await pump(tester);
    final reachedMode = await focusUntil(
      tester,
      LogicalKeyboardKey.arrowDown,
      (t) => modes.contains(t),
    );
    expect(reachedMode, isTrue, reason: 'mode chip not reachable downward');
    final reachedNode = await focusUntil(
      tester,
      LogicalKeyboardKey.arrowDown,
      (t) => t != null && t.contains('US Alpha'),
    );
    expect(reachedNode, isTrue, reason: 'node row not reachable downward');
  });

  testWidgets('arrow keys walk every mode chip', (tester) async {
    await pump(tester);
    await focusUntil(tester, LogicalKeyboardKey.arrowDown, modes.contains);
    final seen = <String?>{focusedText()};
    const walk = [
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
    ];
    for (final key in walk) {
      await tester.sendKeyEvent(key);
      await tester.pump();
      seen.add(focusedText());
    }
    expect(seen, containsAll(modes));
  });

  testWidgets('select on a mode chip sends the command', (tester) async {
    await pump(tester);
    await focusUntil(tester, LogicalKeyboardKey.arrowDown, modes.contains);
    // The snapshot is on Auto, so step to any other chip and activate it.
    await focusUntil(
      tester,
      LogicalKeyboardKey.arrowRight,
      (t) => t != null && modes.contains(t) && t != 'Auto',
    );
    final chip = focusedText();
    expect(chip != null && modes.contains(chip) && chip != 'Auto', isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(commands, contains('settings.setOutboundMode'));
  });

  testWidgets('activating the whole hero card toggles protection', (
    tester,
  ) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    // A pending toggle keeps the hero medallion spinning until a poll confirms it, so pump a bounded
    // window instead of settling, then assert the command went out.
    for (var i = 0; i < 6 && commands.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(commands, contains('connection.setRunning'));
  });

  testWidgets('an unknown toggle outcome rolls the switch back', (
    tester,
  ) async {
    commandStatus = 'outcomeUnknown';
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(commands, contains('connection.setRunning'));
    // The snapshot stays on; an unconfirmed toggle must not leave the switch stuck on its
    // optimistic off value (I13).
    final toggle = tester.widget<Switch>(find.byType(Switch));
    expect(toggle.value, isTrue);
  });

  testWidgets('tapping an inactive profile sends profiles.select', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(commands, contains('profiles.select'));
  });

  testWidgets('node picker opens focused on the current node', (tester) async {
    await pump(tester);
    await tester.tap(find.text('US Alpha').first);
    await tester.pumpAndSettle();
    final focused = focusedText();
    expect(
      focused != null && focused.contains('US Alpha'),
      isTrue,
      reason: 'picker should land focus on the selected node, got $focused',
    );
  });
}
