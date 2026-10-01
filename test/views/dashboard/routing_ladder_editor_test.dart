import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/routing/routing_ladder_editor.dart';

import '../../helpers/test_app.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  SmartRoutingProps props = const SmartRoutingProps(enabled: true),
}) async {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(smartRoutingSettingProvider.notifier).value = props;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        includeNavigatorKey: true,
        child: CustomScrollView(slivers: [RoutingLadderEditorSliver()]),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('an untouched config lays out the shipped default order', (
    tester,
  ) async {
    final container = await _pump(tester);

    expect(container.read(smartRoutingSettingProvider).ladder, isEmpty);
    expect(find.byType(Switch), findsNWidgets(routingDefaultRungTokens.length));
  });

  testWidgets('toggling a rung materializes the full ladder with it off', (
    tester,
  ) async {
    final container = await _pump(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final ladder = container.read(smartRoutingSettingProvider).ladder;
    expect(ladder.length, routingDefaultRungTokens.length);
    expect(ladder.first.enabled, isFalse);
    expect(ladder.first.id, routingDefaultRungTokens.first);
  });
}
