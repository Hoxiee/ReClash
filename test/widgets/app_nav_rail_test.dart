import 'package:reclash/common/common.dart';
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
      icon: const Icon(Icons.bug_report),
      label: PageLabel.logs,
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
    Locale? locale,
    VoidCallback? onAbout,
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
              child: SizedBox(
                height: height,
                child: AppNavRail(onAbout: onAbout),
              ),
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

  testWidgets('tools follow logs with a group divider', (tester) async {
    await pumpRail(tester);

    final dashboardY = tester
        .getCenter(find.byIcon(Icons.space_dashboard).first)
        .dy;
    final profilesY = tester.getCenter(find.byIcon(Icons.folder).first).dy;
    final requestsY = tester
        .getCenter(find.byIcon(Icons.view_timeline).first)
        .dy;
    final toolsY = tester.getCenter(find.byIcon(Icons.construction).first).dy;

    expect(
      profilesY - dashboardY,
      greaterThan(NavRailMetrics.stackedSlotHeight),
    );
    expect(
      requestsY - profilesY,
      greaterThan(NavRailMetrics.stackedSlotHeight),
    );
    final logsY = tester.getCenter(find.byIcon(Icons.bug_report).first).dy;
    expect(logsY - requestsY, NavRailMetrics.stackedSlotHeight);
    expect(
      toolsY - logsY,
      NavRailMetrics.stackedSlotHeight + NavRailMetrics.dividerExtent,
    );
    final divider = find.byWidgetPredicate(
      (widget) =>
          widget is Positioned && widget.height == NavRailMetrics.hairline,
    );
    expect(divider, findsNWidgets(3));
    final dividerY = tester.getCenter(divider.last).dy;
    expect(dividerY, greaterThan(logsY));
    expect(dividerY, lessThan(toolsY));
  });

  testWidgets('about sits at the bottom separate from tools', (tester) async {
    var aboutCalls = 0;
    await pumpRail(tester, onAbout: () => aboutCalls++);

    final tools = find.byIcon(Icons.construction).first;
    final about = find.byIcon(Icons.info_outline);
    final toolsButton = find.ancestor(
      of: tools,
      matching: find.byType(InkWell),
    );
    final aboutButton = find.ancestor(
      of: about,
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(aboutButton), tester.getSize(toolsButton));
    expect(tester.getCenter(about).dx, tester.getCenter(tools).dx);
    expect(
      tester.getCenter(about).dy - tester.getCenter(tools).dy,
      greaterThan(NavRailMetrics.stackedSlotHeight),
    );
    expect(
      tester.widget<InkWell>(aboutButton).customBorder,
      tester.widget<InkWell>(toolsButton).customBorder,
    );

    final railBottom = tester.getRect(find.byType(AppNavRail)).bottom;
    expect(
      railBottom - tester.getCenter(about).dy,
      lessThan(NavRailMetrics.stackedSlotHeight),
    );

    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(aboutCalls, 1);
    expect(container.read(currentPageLabelProvider), PageLabel.dashboard);
  });

  testWidgets('about stays fixed while the rail scrolls', (tester) async {
    var aboutCalls = 0;
    await pumpRail(tester, height: 180, onAbout: () => aboutCalls++);

    final aboutCenter = tester.getCenter(find.byIcon(Icons.info_outline));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.byIcon(Icons.info_outline)), aboutCenter);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(aboutCalls, 1);

    final toolsButton = tester.widget<InkWell>(
      find.ancestor(
        of: find.byIcon(Icons.construction).first,
        matching: find.byType(InkWell),
      ),
    );
    toolsButton.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(aboutCalls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('labels stack under the icons without widening the rail', (
    tester,
  ) async {
    await pumpRail(tester, showLabel: true);

    expect(tester.getSize(find.byType(AppNavRail)).width, NavRailMetrics.width);
    expect(find.text(PageLabel.dashboard.label), findsNWidgets(2));

    container.read(viewSizeProvider.notifier).value = const Size(1400, 600);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(AppNavRail)).width, NavRailMetrics.width);
    expect(find.text(PageLabel.dashboard.label), findsNWidgets(2));
  });

  for (final locale in AppLocalizations.delegate.supportedLocales) {
    testWidgets('the selected label stays inside the pill in $locale', (
      tester,
    ) async {
      await pumpRail(tester, showLabel: true, locale: locale);

      for (final item in items()) {
        goTo(item.label);
        await tester.pumpAndSettle();
        final highlight = find.byKey(AppNavRail.highlightKey);
        final pill = tester.getRect(highlight);
        final decoration = tester.widget<DecoratedBox>(highlight).decoration;
        final contour = decoration.getClipPath(pill, TextDirection.ltr);
        final label = tester.getRect(find.text(item.label.label).first);
        for (final point in [
          label.topLeft,
          label.topRight,
          label.bottomLeft,
          label.bottomRight,
        ]) {
          expect(
            contour.contains(point),
            isTrue,
            reason: '${item.label} in $locale crosses the rounded contour',
          );
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short windows preserve labels and scroll to tools', (
    tester,
  ) async {
    await pumpRail(tester, showLabel: true, height: 340);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text(PageLabel.dashboard.label), findsNWidgets(2));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.construction).first);
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
