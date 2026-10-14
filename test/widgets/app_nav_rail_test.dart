import 'package:flutter/gestures.dart';
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
    bool wide = false,
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
                child: AppNavRail(expanded: expanded, wide: wide),
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

  testWidgets('the wide rail is a labelled list at a fixed width', (
    tester,
  ) async {
    await pumpRail(tester, expanded: true, wide: true);

    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.wideWidth,
    );
    final dashboardRow = tester.getRect(find.text(PageLabel.dashboard.label));
    final dashboardIcon = tester.getRect(
      find.byGlyph(AppGlyphs.dashboard).first,
    );
    expect(dashboardRow.left, greaterThan(dashboardIcon.right));
    expect(dashboardRow.center.dy, closeTo(dashboardIcon.center.dy, 1));
    // Slot tooltips stay off while the labels read; the foot toggle keeps
    // its own expand/collapse hint and is excluded here.
    Element? toggleTooltip;
    tester
        .element(find.byKey(AppNavRail.toggleKey))
        .visitAncestorElements((element) {
          if (element.widget is AppTooltip) {
            toggleTooltip = element;
            return false;
          }
          return true;
        });
    expect(
      find
          .byType(AppTooltip)
          .evaluate()
          .where((element) => element != toggleTooltip)
          .every((element) => (element.widget as AppTooltip).message == null),
      isTrue,
    );
  });

  testWidgets('right-clicking the rail toggles the wide mode', (tester) async {
    tester.view.physicalSize = const Size(1200, 600);
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
    container.read(viewSizeProvider.notifier).value = const Size(1200, 600);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(navSurface: NavSurface.rail));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: AppSidebarContainer(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.compactWidth,
    );

    final rail = tester.getCenter(find.byType(AppNavRail));
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.down(rail);
    await gesture.up();
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AppSidebarContainer)),
    );
    await tester.tap(find.text(l10n.sidebarOpenWide));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).railWide, isTrue);
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.compactWidth,
    );

    await tester.tap(find.byKey(AppNavRail.toggleKey));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.wideWidth,
    );

    await tester.tap(find.byKey(AppNavRail.toggleKey));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AppNavRail)).width,
      NavRailMetrics.compactWidth,
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

  testWidgets('wide folding never moves the icons and fades labels late', (
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

    var expanded = true;
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
                    wide: true,
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

    double labelOpacity(String text) {
      final el = tester.element(find.text(text));
      double? opacity;
      el.visitAncestorElements((ancestor) {
        if (opacity == null && ancestor.widget is Opacity) {
          opacity = (ancestor.widget as Opacity).opacity;
        }
        return opacity == null;
      });
      return opacity ?? -1;
    }

    final slotDx = tester.getTopLeft(find.byType(GlyphIcon).first).dx;
    final toggleDx = tester.getTopLeft(find.byType(GlyphIcon).last).dx;

    await tester.tap(find.byKey(AppNavRail.toggleKey));
    var midOpacity = -1.0;
    var lateOpacity = -1.0;
    for (var i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      final width = tester.getSize(find.byType(AppNavRail)).width;
      expect(width, greaterThanOrEqualTo(NavRailMetrics.compactWidth - 0.01));
      expect(width, lessThanOrEqualTo(NavRailMetrics.wideWidth + 0.01));
      expect(
        tester.getTopLeft(find.byType(GlyphIcon).first).dx,
        closeTo(slotDx, 0.01),
      );
      expect(
        tester.getTopLeft(find.byType(GlyphIcon).last).dx,
        closeTo(toggleDx, 0.01),
      );
      // The foot toggle is a fixed square, never a stretched bar.
      expect(
        tester.getSize(find.byKey(AppNavRail.toggleKey)),
        const Size(
          NavRailMetrics.compactWidth - NavRailMetrics.pillInsetX * 2,
          NavRailMetrics.compactSlotHeight - NavRailMetrics.pillInsetY * 2,
        ),
      );
      if (width < 200 && width > 150) {
        midOpacity = labelOpacity(PageLabel.dashboard.label);
      }
      if (width < 90 && width > 50) {
        lateOpacity = labelOpacity(PageLabel.dashboard.label);
      }
    }
    // The shrinking edge curtains the labels away; they dissolve at the end.
    expect(midOpacity, greaterThan(0.5));
    expect(lateOpacity, lessThan(0.5));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byType(GlyphIcon).first).dx,
      closeTo(slotDx, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the foot separator only shows while the rail scrolls', (
    tester,
  ) async {
    await pumpRail(tester);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(AppNavRail.footSeparatorKey)).height,
      0,
    );
  });

  testWidgets('a mouse drag scrolls a short rail', (tester) async {
    await pumpRail(tester, expanded: true, height: 180);
    await tester.pumpAndSettle();

    final pixels = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .pixels;
    expect(pixels, 0);

    await tester.dragFrom(
      tester.getCenter(find.byType(SingleChildScrollView)),
      const Offset(0, -120),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the foot separator shows while the rail scrolls', (
    tester,
  ) async {
    await pumpRail(tester, height: 180);
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      tester.getSize(find.byKey(AppNavRail.footSeparatorKey)).height,
      NavRailMetrics.groupGap + NavRailMetrics.hairline,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the foot toggle hints expand and collapse', (tester) async {    tester.view.physicalSize = const Size(800, 600);
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

    AppLocalizations l10n() =>
        AppLocalizations.of(tester.element(find.byType(AppNavRail)));
    AppTooltip toggleTooltip() => tester.widget(
      find.ancestor(
        of: find.byKey(AppNavRail.toggleKey),
        matching: find.byType(AppTooltip),
      ),
    );

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
    expect(toggleTooltip().message, l10n().showMore);

    await tester.tap(find.byKey(AppNavRail.toggleKey));
    await tester.pumpAndSettle();
    expect(toggleTooltip().message, l10n().showLess);
  });

  testWidgets('the last slot stays reachable above the foot toggle', (
    tester,
  ) async {
    // Seven expanded slots need 473px of list against a 500px rail: the list
    // fits the body but not the scroll viewport above the foot, so the rail
    // must scroll. Judging by the whole height strands Tools under the foot
    // with no way to reach it.
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final seven = [
      (AppGlyphs.dashboard, PageLabel.dashboard),
      (AppGlyphs.proxies, PageLabel.proxies),
      (AppGlyphs.profiles, PageLabel.profiles),
      (AppGlyphs.requests, PageLabel.requests),
      (AppGlyphs.connections, PageLabel.connections),
      (AppGlyphs.dns, PageLabel.dns),
      (AppGlyphs.tools, PageLabel.tools),
    ];
    container = ProviderContainer(
      overrides: [
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              for (final (glyph, label) in seven)
                NavigationItem(
                  glyph: glyph,
                  label: label,
                  builder: (_) => const SizedBox.shrink(),
                ),
            ],
          ),
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
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 500,
                child: AppNavRail(expanded: true),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scrollable verdict: the separator is up and the tail is reachable.
    expect(
      tester.getSize(find.byKey(AppNavRail.footSeparatorKey)).height,
      NavRailMetrics.groupGap + NavRailMetrics.hairline,
    );
    await tester.dragUntilVisible(
      find.byGlyph(AppGlyphs.tools).first,
      find.byType(SingleChildScrollView),
      const Offset(0, -60),
    );
    await tester.pumpAndSettle();
    expect(find.byGlyph(AppGlyphs.tools), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
