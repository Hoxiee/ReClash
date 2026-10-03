import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:reclash/views/settings/hotkey_desktop.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<HotKeyAction> hotKeyActions = const [],
}) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  final subscription = container.listen(
    hotKeyActionsProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  container.read(hotKeyActionsProvider.notifier).value = hotKeyActions;
  return container;
}

Future<void> _pumpView(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: HotKeyView()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Wayland explains local scope and offers desktop commands', (
    tester,
  ) async {
    final container = _containerFor(tester);
    container
        .read(hotKeyPlatformProvider.notifier)
        .value = const HotkeyPlatformState(
      systemSupported: false,
      applicationId: 'com.reclash',
    );
    await _pumpView(tester, container);
    expect(find.text(currentAppLocalizations.hotkeyLocalDesc), findsOneWidget);
    expect(find.text(currentAppLocalizations.hotkeyDesc), findsNothing);
    await tester.scrollUntilVisible(
      find.text(currentAppLocalizations.hotkeyDesktopCommands),
      500,
    );
    expect(
      find.text(currentAppLocalizations.hotkeyDesktopCommands),
      findsOneWidget,
    );
  });

  testWidgets(
    'desktop commands use the running application ID and show all compositor formats',
    (tester) async {
      final container = _containerFor(tester);
      container
          .read(hotKeyPlatformProvider.notifier)
          .value = const HotkeyPlatformState(
        systemSupported: false,
        applicationId: 'com.reclash.dev',
        exportDirectory: '/tmp/reclash/hotkeys',
        exports: {
          HotkeyExportFormat.niri: HotkeyExport(
            text: '',
            unsupported: [HotAction.start],
          ),
        },
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: HotkeyDesktopView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('gapplication action com.reclash.dev toggle'),
        findsOneWidget,
      );
      expect(
        find.text('gapplication action com.reclash.dev quit'),
        findsOneWidget,
      );
      expect(find.text('Sway'), findsOneWidget);
      expect(find.text('Hyprland'), findsOneWidget);
      expect(find.text('niri'), findsOneWidget);
      expect(
        find.text(
          currentAppLocalizations.hotkeyExportSkipped(HotAction.start.label),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows the empty state for unbound actions', (tester) async {
    final container = _containerFor(tester);
    await _pumpView(tester, container);

    expect(find.text(currentAppLocalizations.hotkeyNotSet), findsWidgets);
    expect(tester.takeException(), null);
  });

  testWidgets('renders the recorded combination for a bound action', (
    tester,
  ) async {
    final container = _containerFor(
      tester,
      hotKeyActions: [
        HotKeyAction(
          action: HotAction.mode,
          key: PhysicalKeyboardKey.keyA.usbHidUsage,
          modifiers: const {KeyboardModifier.control},
        ),
      ],
    );
    await _pumpView(tester, container);

    expect(find.text('A'), findsWidgets);
    expect(tester.takeException(), null);
  });

  testWidgets('tapping a row opens the recorder dialog', (tester) async {
    final container = _containerFor(tester);
    await _pumpView(tester, container);

    await tester.tap(find.text(HotAction.view.label));
    await tester.pumpAndSettle();

    expect(find.byType(HotKeyRecorder), findsOne);
  });

  testWidgets('groups the bar actions in one capsule', (tester) async {
    final container = _containerFor(tester);
    await _pumpView(tester, container);

    final restoreGroup = find.ancestor(
      of: find.byGlyph(AppGlyphs.restore),
      matching: find.byType(TonalButtonGroup),
    );
    final clearGroup = find.ancestor(
      of: find.byGlyph(AppGlyphs.clearAll),
      matching: find.byType(TonalButtonGroup),
    );
    expect(restoreGroup, findsOneWidget);
    expect(clearGroup, findsOneWidget);
    expect(restoreGroup.evaluate().single, same(clearGroup.evaluate().single));
    expect(tester.takeException(), null);
  });

  testWidgets('the row remove button clears its binding', (tester) async {
    final container = _containerFor(
      tester,
      hotKeyActions: [
        HotKeyAction(
          action: HotAction.mode,
          key: PhysicalKeyboardKey.keyA.usbHidUsage,
          modifiers: const {KeyboardModifier.control},
        ),
      ],
    );
    await _pumpView(tester, container);

    await tester.tap(find.byTooltip(currentAppLocalizations.remove));
    await tester.pumpAndSettle();

    expect(container.read(hotKeyActionsProvider), isEmpty);
  });
}
