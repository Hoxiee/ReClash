import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/dashboard.dart';
import 'package:reclash/views/dashboard/widget_registry.dart';
import 'package:reclash/widgets/layout/grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('dashboard uses 12 columns from 480 logical pixels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(511, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        newDashboardEnabledProvider.overrideWithValue(false),
        byeDpiSupportedProvider.overrideWithValue(true),
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    final grid = find.byType(Grid);
    expect(tester.getSize(grid).width, 479);
    expect(tester.widget<Grid>(grid).crossAxisCount, 8);

    tester.view.physicalSize = const Size(512, 1000);
    await tester.pump();

    expect(tester.getSize(grid).width, 480);
    expect(tester.widget<Grid>(grid).crossAxisCount, 12);
    expect(tester.takeException(), null);
  });

  testWidgets('dashboard limits a wide grid to 16 centered columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        newDashboardEnabledProvider.overrideWithValue(false),
        byeDpiSupportedProvider.overrideWithValue(true),
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    final grid = find.byType(Grid);
    expect(tester.widget<Grid>(grid).crossAxisCount, 16);
    expect(tester.getSize(grid).width, 1120);
    expect(tester.getTopLeft(grid).dx, 240);
    expect(tester.takeException(), null);
  });

  testWidgets('edit mode offers every removed ReClash widget', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        newDashboardEnabledProvider.overrideWithValue(false),
        byeDpiSupportedProvider.overrideWithValue(true),
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Memory info'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Service'), findsOneWidget);
    expect(find.text('Change server'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('the connection mode swaps which widgets the grid offers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        newDashboardEnabledProvider.overrideWithValue(false),
        byeDpiSupportedProvider.overrideWithValue(true),
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(appSettingProvider.notifier).value = const AppSettingProps(region: AppRegion.russia);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Change server'), findsOneWidget);
    expect(find.text('Smart routing'), findsOneWidget);
    expect(find.text('Strategy'), findsNothing);

    container
        .read(desyncSettingProvider.notifier)
        .update((state) => state.copyWith(featureEnabled: true, enabled: true, onlyDpi: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Strategy'), findsOneWidget);
    expect(find.text('Strategy test'), findsOneWidget);
    expect(find.text('Engine'), findsOneWidget);
    expect(find.text('Change server'), findsNothing);
    expect(find.text('Smart routing'), findsNothing);
    expect(tester.takeException(), null);
  });

  test('ReClash cards keep compact spans except subscription and announce', () {
    expect(DashboardWidget.memoryInfo.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.serviceInfo.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.changeServerButton.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.smartRouting.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.desyncTest.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.desyncEngine.widget.crossAxisCellCount, 4);
    expect(DashboardWidget.metaInfo.widget.crossAxisCellCount, 8);
    expect(DashboardWidget.announce.widget.crossAxisCellCount, 8);
    expect(DashboardWidget.desyncStrategy.widget.crossAxisCellCount, 8);
  });

  test('only the mode a widget belongs to may show it', () {
    expect(
      DashboardWidget.changeServerButton.visibleIn(DashboardMode.vpn),
      isTrue,
    );
    expect(
      DashboardWidget.changeServerButton.visibleIn(DashboardMode.byedpi),
      isFalse,
    );
    expect(
      DashboardWidget.desyncStrategy.visibleIn(DashboardMode.vpn),
      isFalse,
    );
    expect(
      DashboardWidget.desyncStrategy.visibleIn(DashboardMode.byedpi),
      isTrue,
    );
  });
}
