import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import '../helpers/glyph_finders.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
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
    bool showLabel = false,
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
          locale: locale,
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

  Rect highlightRect(WidgetTester tester) =>
      tester.getRect(find.byKey(AppNavRail.highlightKey));

  void goTo(PageLabel label) =>
      container.read(currentPageLabelProvider.notifier).toPage(label);

  testWidgets('the selection bar stretches toward the new slot', (
    tester,
  ) async {
    await pumpRail(tester);
    final start = highlightRect(tester);

    // Tools is pinned and carries no indicator, so the stretch is measured
    // against a scrollable slot instead.
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
      greaterThan(NavRailMetrics.stackedSlotHeight),
    );
    expect(
      requestsY - profilesY,
      greaterThan(NavRailMetrics.stackedSlotHeight),
    );
    // Requests and logs share a group, so no divider stretches the gap.
    expect(logsY - requestsY, NavRailMetrics.stackedSlotHeight);

    // Tools is pinned outside the scroll body, so only the two intra-list
    // group boundaries render as Positioned hairlines.
    final divider = find.byWidgetPredicate(
      (widget) =>
          widget is Positioned && widget.height == NavRailMetrics.hairline,
    );
    expect(divider, findsNWidgets(2));
  });

  testWidgets('tools sits pinned at the rail bottom', (tester) async {
    await pumpRail(tester);

    final logsY = tester.getCenter(find.byGlyph(AppGlyphs.logs).first).dy;
    final tools = find.byGlyph(AppGlyphs.tools).first;
    final toolsY = tester.getCenter(tools).dy;
    expect(toolsY, greaterThan(logsY));

    final railBottom = tester.getRect(find.byType(AppNavRail)).bottom;
    expect(railBottom - toolsY, lessThan(NavRailMetrics.stackedSlotHeight));

    // Selecting the pinned slot removes the sliding indicator entirely.
    goTo(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(find.byKey(AppNavRail.highlightKey), findsNothing);

    goTo(PageLabel.dashboard);
    await tester.pumpAndSettle();
    await tester.tap(tools);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
  });

  testWidgets('tools stays pinned while the rail scrolls', (tester) async {
    await pumpRail(tester, height: 180);

    final toolsCenter = tester.getCenter(find.byGlyph(AppGlyphs.tools).first);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byGlyph(AppGlyphs.tools).first), toolsCenter);

    await tester.tap(find.byGlyph(AppGlyphs.tools).first);
    await tester.pumpAndSettle();
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.takeException(), isNull);
  });

  testWidgets('labels stack under the icons without widening the rail', (
    tester,
  ) async {
    await pumpRail(tester, showLabel: true);

    expect(tester.getSize(find.byType(AppNavRail)).width, NavRailMetrics.width);
    expect(find.text(PageLabel.dashboard.label), findsOneWidget);

    container.read(viewSizeProvider.notifier).value = const Size(1400, 600);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AppNavRail)).width, NavRailMetrics.width);
    expect(find.text(PageLabel.dashboard.label), findsOneWidget);
  });

  for (final locale in AppLocalizations.delegate.supportedLocales) {
    testWidgets('the selected label stays inside its slot in $locale', (
      tester,
    ) async {
      await pumpRail(tester, showLabel: true, locale: locale);

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

  testWidgets('short windows preserve labels and keep tools reachable', (
    tester,
  ) async {
    await pumpRail(tester, showLabel: true, height: 340);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text(PageLabel.dashboard.label), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    // Tools is pinned, so it is tappable without scrolling the list.
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
