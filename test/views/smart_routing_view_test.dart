import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required SmartRoutingProps props,
}) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 800));
  container.read(smartRoutingSettingProvider.notifier).value = props;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        includeNavigatorKey: true,
        child: SmartRoutingView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('a disabled engine shows nothing to tune', (tester) async {
    await _pump(tester, props: const SmartRoutingProps());

    expect(find.text('Smart routing'), findsWidgets);
    expect(find.text('Region'), findsNothing);
    expect(find.text('Behaviour'), findsNothing);
  });

  testWidgets('the intro card is omitted', (tester) async {
    await _pump(tester, props: const SmartRoutingProps());

    expect(find.textContaining('Start from a region preset'), findsNothing);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.textContaining('Start from a region preset'), findsNothing);
  });

  testWidgets('the mid layer is settings, never weights', (tester) async {
    await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
      ),
    );

    expect(find.text('Region'), findsOne);
    expect(find.text('Require UDP support'), findsOne);
    expect(find.text('Settle time'), findsOne);
    await tester.scrollUntilVisible(
      find.text('Servers per check'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Servers per check'), findsOne);
  });

  for (final title in ['Open-internet checks', 'Local checks']) {
    testWidgets('$title uses the standard list editor', (tester) async {
      await _pump(
        tester,
        props: const SmartRoutingProps(
          enabled: true,
          preset: SmartRoutingPreset.russia,
          openMarkers: [
            RcxMarker(url: 'https://example.com/open', statuses: [204]),
          ],
          domesticMarkers: [
            RcxMarker(url: 'https://example.com/local', statuses: [200]),
          ],
        ),
      );

      await tester.scrollUntilVisible(
        find.text(title),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
    });
  }

  testWidgets('an adjusted preset says so and can be reset', (tester) async {
    final container = await _pump(
      tester,
      props: const SmartRoutingProps(
        enabled: true,
        preset: SmartRoutingPreset.russia,
        dwellSeconds: 600,
      ),
    );

    expect(find.text('Russia · adjusted'), findsOne);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final props = container.read(smartRoutingSettingProvider);
    expect(props.matchesPreset, isTrue);
    expect(props.enabled, isTrue);
    expect(find.text('Russia'), findsAtLeast(1));
  });

  testWidgets(
    'turning it on from off adopts a preset instead of an empty one',
    (tester) async {
      final container = await _pump(tester, props: const SmartRoutingProps());

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final props = container.read(smartRoutingSettingProvider);
      expect(props.enabled, isTrue);
      expect(props.rcxParams.enabled, isTrue);
    },
  );
}
