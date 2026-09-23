import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/devices/devices.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('$packageName/companion_client');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  var targets = <Map<String, Object?>>[
    {
      'deviceId': 'd1',
      'clientName': 'Living Room TV',
      'host': '192.168.1.5',
      'port': 443,
      'active': true,
      'lastSeenAtMs': 1700000000000,
    },
  ];

  setUp(() {
    system.isTVForTesting = true;
    FocusHighlightVisibility.visibleForTesting = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'targets':
          return targets;
        case 'readState':
          return {
            'ok': true,
            'data': {
              'running': true,
              'profileLabel': 'Home',
              'outboundMode': 'auto',
              'revision': 1,
            },
          };
        case 'forget':
          targets = [];
          return {'ok': true};
        default:
          return null;
      }
    });
  });
  tearDown(() {
    system.isTVForTesting = false;
    FocusHighlightVisibility.visibleForTesting = false;
    messenger.setMockMethodCallHandler(channel, null);
    targets = [
      {
        'deviceId': 'd1',
        'clientName': 'Living Room TV',
        'host': '192.168.1.5',
        'port': 443,
        'active': true,
        'lastSeenAtMs': 1700000000000,
      },
    ];
  });

  String? focusedText() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return null;
    final texts = find
        .descendant(of: find.byWidget(ctx.widget), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    return texts.isEmpty ? '<${ctx.widget.runtimeType}>' : texts.join('|');
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1000, 900);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DevicesView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<List<String?>> walk(WidgetTester tester, {int steps = 8}) async {
    final trail = <String?>[];
    for (var i = 0; i < steps; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      trail.add(focusedText());
    }
    return trail;
  }

  testWidgets('opens with a focused control, not nothing', (tester) async {
    await pump(tester);
    expect(focusedText(), isNotNull);
  });

  testWidgets('arrow down reaches the device row', (tester) async {
    await pump(tester);
    final trail = await walk(tester);
    expect(
      trail.any((t) => t != null && t.contains('Living Room TV')),
      isTrue,
      reason: 'device row must be reachable by D-pad, got $trail',
    );
  });

  testWidgets('the action menu opens focused on its first row', (tester) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    expect(focusedText(), isNotNull);
    expect(find.text('Rename'), findsOneWidget);
  });

  testWidgets('focus survives forgetting the focused device', (tester) async {
    await pump(tester);
    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forget this device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Living Room TV'), findsNothing);
    expect(focusedText(), isNotNull);
  });
}
