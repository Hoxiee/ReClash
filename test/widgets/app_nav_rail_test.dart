import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    // The key-driven visibility handler does not survive the test framework's
    // between-test teardown, so drive the seam directly: a keyboard highlight
    // is what makes the ring eligible to show.
    FocusHighlightVisibility.visibleForTesting = true;
  });

  List<NavigationItem> items() => [
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
      glyph: AppGlyphs.requests,
      label: PageLabel.requests,
      builder: (_) => const SizedBox.shrink(),
    ),
    NavigationItem(
      glyph: AppGlyphs.logs,
      label: PageLabel.logs,
      builder: (_) => const SizedBox.shrink(),
    ),
    NavigationItem(
      glyph: AppGlyphs.tools,
      label: PageLabel.tools,
      builder: (_) => const SizedBox.shrink(),
    ),
  ];

  Future<void> pumpRail(
    WidgetTester tester, {
    double viewWidth = 800,
    bool expanded = false,
    double height = 500,
    Locale? locale,
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          locale: locale,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: height,
                child: AppNavRail(expanded: expanded),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect highlightRect(WidgetTester tester) =>
      tester.getRect(find.byKey(AppNavRail.highlightKey));

  void goTo(PageLabel label) =>
      container.read(currentPageLabelProvider.notifier).toPage(label);

  testWidgets('the selection bar stretches toward the new slot', (
    tester,
  ) async {
    await pumpRail(tester);
    final start = highlightRect(tester);

    goTo(PageLabel.logs);
    await tester.pump();
    expect(highlightRect(tester).top, closeTo(start.top, 0.5));

    await tester.pump(const Duration(milliseconds: 120));
    final mid = highlightRect(tester);
    // The leading edge runs ahead first, so the bar is taller mid-flight.
    expect(mid.height, greaterThan(start.height));
    expect(mid.bottom, greaterThan(start.bottom));

    await tester.pumpAndSettle();
    final end = highlightRect(tester);
    expect(end.top, greaterThan(start.top));
    expect(end.height, closeTo(start.height, 0.5));
  });

  testWidgets('group dividers separate the scrollable sections', (
    tester,
  ) async {
    await pumpRail(tester);

    final dashboardY = tester
        .getCenter(find.byGlyph(AppGlyphs.dashboard).first)
        .dy;
    final profilesY = tester
        .getCenter(find.byGlyph(AppGlyphs.profiles).first)
        .dy;
    final requestsY = tester
        .getCenter(find.byGlyph(AppGlyphs.requests).first)
        .dy;
    final logsY = tester.getCenter(find.byGlyph(AppGlyphs.logs).first).dy;

    expect(
      profilesY - dashboardY,
      greaterThan(NavRailMetrics.compactSlotHeight),
    );
    expect(
      requestsY - profilesY,
      greaterThan(NavRailMetrics.compactSlotHeight),
    );
    // Requests and logs share a group, so no divider stretches the gap.
    expect(logsY - requestsY, NavRailMetrics.compactSlotHeight);

    // Three group boundaries render as Positioned hairlines: dashboard|profiles,
    // profiles|requests, and logs|tools.
    final divider = find.byWidgetPredicate(
      (widget) =>
          widget is Positioned && widget.height == NavRailMetrics.hairline,
    );
    expect(divider, findsNWidgets(3));
  });

  testWidgets('tools sits in the scrolling list with an indicator', (
    tester,
  ) async {
    await pumpRail(tester);

    final logsY = tester.getCenter(find.byGlyph(AppGlyphs.logs).first).dy;
    final tools = find.byGlyph(AppGlyphs.tools).first;
    expect(tester.getCenter(tools).dy, greaterThan(logsY));

    // Tools is an ordinary destination now, so selecting it keeps the bar.
    goTo(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(find.byKey(AppNavRail.highlightKey), findsOneWidget);

    goTo(PageLabel.dashboard);
    await tester.pumpAndSettle();
    await tester.tap(tools);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
  });

  testWidgets('tools scrolls with the list and stays reachable', (
    tester,
  ) async {
    await pumpRail(tester, height: 180);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.dragUntilVisible(
      find.byGlyph(AppGlyphs.tools).first,
      find.byType(SingleChildScrollView),
      const Offset(0, -60),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byGlyph(AppGlyphs.tools).first);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the foot toggle flips the rail width', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
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
    container.read(viewSizeProvider.notifier).value = const Size(800, 600);

    var expanded = false;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 500,
                child: StatefulBuilder(
                  builder: (context, setState) => AppNavRail(
                    expanded: expanded,
                    onToggle: () => setState(() => expanded = !expanded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.compactWidth,
    );

    await tester.tap(find.byKey(AppNavRail.toggleKey));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.expandedWidth,
    );
  });

  testWidgets('the width never overshoots its expanded target', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
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
    container.read(viewSizeProvider.notifier).value = const Size(800, 600);

    var expanded = false;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 500,
                child: StatefulBuilder(
                  builder: (context, setState) => AppNavRail(
                    expanded: expanded,
                    onToggle: () => setState(() => expanded = !expanded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The morph spring overshoots >1; if it ever drove the width the rail would
    // flare past its target. Sampling mid-flight guards the bounce-free easing.
    await tester.tap(find.byKey(AppNavRail.toggleKey));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      final width = tester.getSize(find.byType(AppNavRail)).width;
      expect(width, lessThanOrEqualTo(NavRailMetrics.expandedWidth + 0.01));
      expect(width, greaterThanOrEqualTo(NavRailMetrics.compactWidth - 0.01));
    }
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion snaps the rail to its target width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
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
    container.read(viewSizeProvider.notifier).value = const Size(800, 600);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(height: 500, child: AppNavRail(expanded: true)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.expandedWidth,
    );
  });

  testWidgets('expanding widens the rail and reveals labels', (tester) async {
    await pumpRail(tester, expanded: true);
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.expandedWidth,
    );
    expect(find.text(PageLabel.dashboard.label), findsOneWidget);
  });

  for (final locale in AppLocalizations.delegate.supportedLocales) {
    testWidgets('the selected label stays inside its slot in $locale', (
      tester,
    ) async {
      await pumpRail(tester, expanded: true, locale: locale);

      for (final item in items()) {
        goTo(item.label);
        await tester.pumpAndSettle();
        final labelFinder = find.text(item.label.label);
        final slot = tester.getRect(
          find.ancestor(of: labelFinder, matching: find.byType(InkWell)),
        );
        final label = tester.getRect(labelFinder);
        final reason = '${item.label} in $locale overflows its slot';
        expect(
          label.left,
          greaterThanOrEqualTo(slot.left - 0.5),
          reason: reason,
        );
        expect(
          label.right,
          lessThanOrEqualTo(slot.right + 0.5),
          reason: reason,
        );
        expect(label.top, greaterThanOrEqualTo(slot.top - 0.5), reason: reason);
        expect(
          label.bottom,
          lessThanOrEqualTo(slot.bottom + 0.5),
          reason: reason,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short windows keep the labels and tools reachable', (
    tester,
  ) async {
    await pumpRail(tester, expanded: true, height: 260);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text(PageLabel.dashboard.label), findsOneWidget);
    await tester.dragUntilVisible(
      find.byGlyph(AppGlyphs.tools).first,
      find.byType(SingleChildScrollView),
      const Offset(0, -60),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byGlyph(AppGlyphs.tools).first);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.takeException(), isNull);
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

  testWidgets('rail arrows stop at the edges instead of wrapping', (
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

    String focusedLabel() {
      final context = FocusManager.instance.primaryFocus?.context;
      final slot = context?.findAncestorWidgetOfExactType<InkWell>();
      return tester
          .widget<Text>(
            find.descendant(
              of: find.byWidget(slot!),
              matching: find.byType(Text),
            ),
          )
          .data!;
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    final top = focusedLabel();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(focusedLabel(), top);
    expect(focusInRail(), isTrue);

    for (var i = 0; i < 10; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    final bottom = focusedLabel();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusedLabel(), bottom);
    expect(focusInRail(), isTrue);
  });

  testWidgets('rail left arrow keeps focus inside the rail', (tester) async {
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

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(focusInRail(), isTrue);
  });
}
