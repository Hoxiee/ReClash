import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/devices/tv_control.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('$packageName/companion_receiver');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    system.isTVForTesting = true;
    FocusHighlightVisibility.visibleForTesting = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'isRunning':
          return true;
        case 'trustedClients':
          return [
            {
              'clientId': 'c1',
              'clientName': 'My Phone',
              'createdAtMs': 1700000000000,
              'lastSeenAtMs': 1700000000000,
            },
          ];
        case 'openPairingWindow':
          return {
            'deviceId': 'tv1',
            'host': '192.168.1.9',
            'port': 443,
            'spkiPin': 'pin',
            'pairingSecret': 'secret',
            'expiresInMs': 120000,
          };
        case 'pendingPairing':
          return null;
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
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1000, 1200);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: TvControlView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<bool> reach(WidgetTester tester, bool Function(String?) done) async {
    for (var i = 0; i < 14; i++) {
      if (done(focusedText())) return true;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    return done(focusedText());
  }

  testWidgets('opens with a focused control', (tester) async {
    await pump(tester);
    expect(focusedText(), isNotNull);
  });

  testWidgets('arrow down reaches the trusted phone and reset row', (
    tester,
  ) async {
    await pump(tester);
    expect(
      await reach(tester, (t) => t != null && t.contains('Revoke this phone')),
      isTrue,
      reason: 'trusted phone revoke not reachable',
    );
    expect(
      await reach(
        tester,
        (t) => t != null && t.contains('Reset pairing identity'),
      ),
      isTrue,
      reason: 'reset identity not reachable',
    );
  });

  testWidgets('add-phone window opens focused on a dismiss action', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is GlyphIcon && w.glyph == AppGlyphs.qrCode,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(focusedText(), 'Cancel');
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('revoke asks first and rests focus on Cancel', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Revoke this phone'));
    await tester.pumpAndSettle();
    expect(focusedText(), 'Cancel');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
