import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/settings/hotkey.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
