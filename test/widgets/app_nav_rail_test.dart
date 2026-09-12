import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  List<NavigationItem> items() => [
    NavigationItem(
      icon: const Icon(Icons.space_dashboard),
      label: PageLabel.dashboard,
      builder: (_) => const SizedBox.shrink(),
    ),
    NavigationItem(
      icon: const Icon(Icons.folder),
      label: PageLabel.profiles,
      builder: (_) => const SizedBox.shrink(),
    ),
    NavigationItem(
      icon: const Icon(Icons.view_timeline),
      label: PageLabel.requests,
      builder: (_) => const SizedBox.shrink(),
    ),
    NavigationItem(
      icon: const Icon(Icons.construction),
      label: PageLabel.tools,
      builder: (_) => const SizedBox.shrink(),
    ),
  ];

  Future<void> pumpRail(
    WidgetTester tester, {
    double viewWidth = 800,
    bool showLabel = false,
    double height = 500,
  }) async {
    tester.view.physicalSize = Size(viewWidth, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(value: items()),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = Size(viewWidth, 600);
    if (showLabel) {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(showLabel: true));
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(height: height, child: const AppNavRail()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double highlightY(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(AppNavRail.highlightKey)).dy;

  void goTo(PageLabel label) =>
      container.read(currentPageLabelProvider.notifier).toPage(label);

  testWidgets('the highlight travels between measured slot tops', (
    tester,
  ) async {
    await pumpRail(tester);
    final start = highlightY(tester);

    goTo(PageLabel.tools);
    await tester.pump();
    expect(highlightY(tester), closeTo(start, 0.5));

    await tester.pump(const Duration(milliseconds: 100));
    final middle = highlightY(tester);
    expect(middle, greaterThan(start));

    await tester.pumpAndSettle();
    expect(highlightY(tester), greaterThan(middle));
  });

  testWidgets('semantic groups divide and pin tools to the bottom', (
    tester,
  ) async {
    await pumpRail(tester);

    final dashboardY = tester
        .getCenter(find.byIcon(Icons.space_dashboard).first)
        .dy;
    final profilesY = tester.getCenter(find.byIcon(Icons.folder).first).dy;
    final requestsY = tester
        .getCenter(find.byIcon(Icons.view_timeline).first)
        .dy;
    final toolsY = tester.getCenter(find.byIcon(Icons.construction).first).dy;

    expect(profilesY - dashboardY, greaterThan(NavRailMetrics.iconSlotHeight));
    expect(requestsY - profilesY, greaterThan(NavRailMetrics.iconSlotHeight));
    final expectedToolsY =
        500 -
        64 -
        NavRailMetrics.padding.bottom -
        NavRailMetrics.iconSlotHeight / 2;
    expect(toolsY, closeTo(expectedToolsY, 1));
    expect(toolsY - requestsY, greaterThan(200));
  });

  testWidgets('labels stack first and extend only on wide windows', (
    tester,
  ) async {
    await pumpRail(tester, showLabel: true);

    expect(tester.getSize(find.byType(AppNavRail)).width, 72);
    expect(find.text(PageLabel.dashboard.label), findsNWidgets(2));

    container.read(viewSizeProvider.notifier).value = const Size(1200, 600);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AppNavRail)).width, 200);
    expect(find.text(PageLabel.dashboard.label), findsNWidgets(2));
  });

  testWidgets('a short viewport falls back to scrolling', (tester) async {
    await pumpRail(tester, height: 180);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard focus has a ring independent from selection', (
    tester,
  ) async {
    await pumpRail(tester);

    bool focusInRail() {
      final context = FocusManager.instance.primaryFocus?.context;
      return context?.findAncestorWidgetOfExactType<AppNavRail>() != null;
    }

    for (var i = 0; i < 10 && !focusInRail(); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(focusInRail(), isTrue);
    expect(find.byKey(AppNavRail.focusRingKey), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(find.byKey(AppNavRail.focusRingKey), findsOneWidget);
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
  });
}
