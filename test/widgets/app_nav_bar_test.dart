import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/nav/app_nav_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  final lens = find.descendant(
    of: find.byType(FloatingNavigationBar),
    matching: find.byType(PositionedDirectional),
  );

  Future<void> pumpBar(WidgetTester tester, {Widget? trailing}) async {
    container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              NavigationItem(
                glyph: AppGlyphs.dashboard,
                label: PageLabel.dashboard,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.profiles,
                label: PageLabel.profiles,
                builder: (_) => const SizedBox.shrink(),
              ),
              NavigationItem(
                glyph: AppGlyphs.tools,
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
        child: TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: AppNavBar(trailing: trailing),
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

  testWidgets('the lens travels instead of teleporting', (tester) async {
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
    final segmentWidth = tester
        .getSize(find.byKey(AppNavBar.highlightKey))
        .width;
    expect(middle, lessThan(settled));
    expect(
      settled,
      closeTo(start + 2 * segmentWidth, 1.0),
      reason: 'it must park under the third segment',
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
    final segmentWidth = tester
        .getSize(find.byKey(AppNavBar.highlightKey))
        .width;
    expect(settled, closeTo(start + segmentWidth, 1.0));
  });

  testWidgets('each destination is painted once', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);

    final labels = container
        .read(currentNavigationItemsStateProvider)
        .value
        .map((item) => item.label.label);
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('the lens settles without a ticker under reduced motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);
    final start = highlightX(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          homeBuilder: (child) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: child,
          ),
          child: const Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: AppNavBar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    goTo(PageLabel.tools);
    await tester.pump();

    final segmentWidth = tester
        .getSize(find.byKey(AppNavBar.highlightKey))
        .width;
    expect(
      highlightX(tester),
      closeTo(start + 2 * segmentWidth, 1.0),
      reason: 'the hop must land in a single frame',
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(highlightX(tester), closeTo(start + 2 * segmentWidth, 1.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the lens keeps up with a finger that never pauses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final extent = (bar.width - 8) / 3;
    var finger = Offset(bar.left + 4 + extent / 2, bar.center.dy);
    final gesture = await tester.startGesture(finger);
    await tester.pump(const Duration(milliseconds: 16));
    for (var i = 0; i < 30; i++) {
      finger += Offset(extent * 2 / 30, 0);
      await gesture.moveTo(finger);
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.getCenter(lens).dx, closeTo(finger.dx, extent * 0.3));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a press lifts the lens past the bar until it is let go', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);
    final bar = tester.getRect(find.byType(FloatingNavigationBar));
    final resting = tester.getRect(lens);
    expect(resting.height, bar.height - 8);

    final gesture = await tester.startGesture(resting.center);
    await tester.pumpAndSettle();
    final lifted = tester.getRect(lens);
    expect(lifted.top, lessThan(bar.top));
    expect(lifted.bottom, greaterThan(bar.bottom));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(lens), resting);
  });

  testWidgets('a long label shrinks to fit, then ellipsizes behind a tooltip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<List<Text>> pumpLabels(String label) async {
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 360,
                height: 64,
                child: FloatingNavigationBar(
                  selectedIndex: 0,
                  onSelected: (_) {},
                  destinations: [
                    for (final text in ['Home', 'Apps', 'Logs', label])
                      NavBarDestination(glyph: AppGlyphs.dashboard, label: text),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(FloatingNavigationBar),
              matching: find.byType(Text),
            ),
          )
          .toList();
    }

    final tooltips = find.descendant(
      of: find.byType(FloatingNavigationBar),
      matching: find.byType(Tooltip),
    );

    var labels = await pumpLabels('Dashboard');
    final shrunk = labels.first.style!.fontSize!;
    expect(shrunk, lessThan(10));
    expect(shrunk, greaterThan(9));
    expect(labels.map((text) => text.style!.fontSize).toSet(), {shrunk});
    expect(tooltips, findsNothing);

    labels = await pumpLabels('Configuration');
    expect(labels.first.style!.fontSize, closeTo(9, 0.001));
    expect(tester.widget<Tooltip>(tooltips).message, 'Configuration');
  });

  testWidgets('the trailing slot renders docked, the bar itself does not', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    bool? dockedInTrailing;
    await pumpBar(
      tester,
      trailing: Builder(
        builder: (context) {
          dockedInTrailing = AppNavBar.isDocked(context);
          return const Icon(Icons.rocket_launch);
        },
      ),
    );

    expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
    expect(dockedInTrailing, isTrue);

    final barContext = tester.element(find.byType(FloatingNavigationBar));
    expect(AppNavBar.isDocked(barContext), isFalse);
  });

  testWidgets('an absent trailing slot leaves nothing behind', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBar(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.rocket_launch), findsNothing);
  });
}
