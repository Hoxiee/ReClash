import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/app_nav_bar.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpBar(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
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
                icon: const Icon(Icons.construction),
                label: PageLabel.tools,
                builder: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AppNavBar(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double highlightX(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(AppNavBar.highlightKey)).dx;

  void goTo(PageLabel label) =>
      container.read(currentPageLabelProvider.notifier).toPage(label);

  testWidgets('the highlight travels instead of teleporting', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);

    final start = highlightX(tester);

    goTo(PageLabel.tools);
    await tester.pump();
    expect(
      highlightX(tester),
      closeTo(start, 0.5),
      reason: 'the first frame of a hop must still be at the old segment',
    );

    await tester.pump(const Duration(milliseconds: 100));
    final middle = highlightX(tester);
    expect(middle, greaterThan(start));

    await tester.pumpAndSettle();
    final settled = highlightX(tester);
    final segmentWidth =
        tester.getSize(find.byKey(AppNavBar.highlightKey)).width;
    expect(middle, lessThan(settled));
    expect(
      settled,
      closeTo(start + 2 * segmentWidth, 1.0),
      reason: 'it must park exactly under the third segment',
    );
  });

  testWidgets('an interrupted hop continues from where it is', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);
    final start = highlightX(tester);

    goTo(PageLabel.tools);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final interruptedAt = highlightX(tester);

    goTo(PageLabel.profiles);
    await tester.pump();
    expect(
      highlightX(tester),
      closeTo(interruptedAt, 0.5),
      reason: 'a redirected hop must not snap back to its origin',
    );

    await tester.pumpAndSettle();
    final settled = highlightX(tester);
    final segmentWidth =
        tester.getSize(find.byKey(AppNavBar.highlightKey)).width;
    expect(settled, closeTo(start + segmentWidth, 1.0));
  });

  testWidgets('each destination is painted twice', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);

    final labels = container
        .read(currentNavigationItemsStateProvider)
        .value
        .map((item) => item.label.label);
    for (final label in labels) {
      expect(find.text(label), findsNWidgets(2));
    }
  });
}
