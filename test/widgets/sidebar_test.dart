import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/sidebar.dart';
import 'package:reclash/ui/surface.dart';
import 'package:reclash/ui/tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

final _paneFinder = find
    .byWidgetPredicate((widget) => widget is Material && widget.elevation > 0)
    .first;

const _destinations = [
  SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Dashboard'),
  SidebarDestination(glyph: AppGlyphs.proxies, label: 'Proxies'),
  SidebarDestination(glyph: AppGlyphs.profiles, label: 'Profiles'),
];

Finder _glyph(Glyph glyph) => find.byWidgetPredicate(
  (widget) => widget is GlyphIcon && widget.glyph == glyph,
);

double _fillOf(WidgetTester tester, Glyph glyph) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(of: _glyph(glyph), matching: find.byType(CustomPaint)),
  );
  return (paint.painter! as GlyphPainter).fill;
}

Widget _sidebar({
  List<SidebarDestination> destinations = _destinations,
  int selectedIndex = 0,
  bool expanded = true,
  bool narrow = false,
  List<SidebarAction> actions = const [],
  ValueChanged<int>? onSelected,
  VoidCallback? onToggle,
  Size windowControls = Size.zero,
  EdgeInsets safePadding = EdgeInsets.zero,
  bool disableAnimations = false,
}) {
  return TestApp(
    child: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Row(
          children: [
            SizedBox(
              height: 400,
              child: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(padding: safePadding),
                  child: NavigationSidebar(
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    expanded: expanded,
                    narrow: narrow,
                    actions: actions,
                    onSelected: onSelected ?? (_) {},
                    onToggle: onToggle,
                    windowControls: windowControls,
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox.expand(key: ValueKey('content'))),
          ],
        ),
      ),
    ),
  );
}

Finder get _sidebarFinder => find.byType(NavigationSidebar);

Finder _indicator(WidgetTester tester) {
  final primary = Theme.of(tester.element(_sidebarFinder)).colorScheme.primary;
  return find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is ShapeDecoration &&
        (widget.decoration as ShapeDecoration).color == primary,
  );
}

Finder _labels(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate(
    (widget) => widget is Opacity && widget.alwaysIncludeSemantics,
  ),
);

Iterable<double> _labelOpacities(WidgetTester tester, String label) {
  return tester.widgetList<Opacity>(_labels(label)).map((o) => o.opacity);
}

Finder _shown(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is Opacity &&
        widget.alwaysIncludeSemantics &&
        widget.opacity == 1,
  ),
  matching: find.text(label),
);

Finder _rowTooltip(String message) => find.byWidgetPredicate(
  (widget) => widget is AppTooltip && widget.message == message,
);

Finder _tip(String message) => find.byWidgetPredicate(
  (widget) => widget is AppTooltip && widget.message == message,
);

Iterable<double> _membershipOpacities(WidgetTester tester, String label) =>
    tester
        .widgetList<Opacity>(
          find.ancestor(of: find.text(label), matching: find.byType(Opacity)),
        )
        .where((opacity) => !opacity.alwaysIncludeSemantics)
        .map((opacity) => opacity.opacity);

List<SidebarAction> _actions(ValueChanged<String> onPressed) => [
  SidebarAction(
    glyph: AppGlyphs.info,
    tooltip: 'About',
    onPressed: () => onPressed('about'),
  ),
  SidebarAction(
    glyph: AppGlyphs.paintbrush,
    tooltip: 'Theme',
    onPressed: () => onPressed('theme'),
  ),
];

void main() {
  testWidgets('wide footer actions are icon-only beside the toggle', (
    tester,
  ) async {
    final pressed = <String>[];
    var toggled = 0;
    await tester.pumpWidget(
      _sidebar(
        actions: _actions(pressed.add),
        onToggle: () => toggled++,
        windowControls: const Size(88, 28),
      ),
    );
    expect(find.text('About'), findsNothing);
    expect(find.text('Theme'), findsNothing);
    final toggle = tester.getCenter(_tip('Collapse'));
    final about = tester.getCenter(_tip('About'));
    final theme = tester.getCenter(_tip('Theme'));
    expect(about.dy, toggle.dy);
    expect(theme.dy, toggle.dy);
    expect(about.dx, greaterThan(toggle.dx));
    expect(theme.dx, greaterThan(about.dx));
    await tester.tap(_tip('About'));
    await tester.tap(_tip('Theme'));
    expect(pressed, ['about', 'theme']);
    expect(toggled, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('footer actions stay reachable while destinations scroll', (
    tester,
  ) async {
    final pressed = <String>[];
    await tester.pumpWidget(
      _sidebar(
        destinations: [
          for (var i = 0; i < 20; i++)
            SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Row $i'),
        ],
        actions: _actions(pressed.add),
        onToggle: () {},
      ),
    );
    await tester.drag(find.byType(Scrollable), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(_tip('Theme'));
    expect(pressed, ['theme']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact and narrow sidebars hide footer actions', (
    tester,
  ) async {
    final actions = _actions((_) {});
    await tester.pumpWidget(
      _sidebar(expanded: false, actions: actions, onToggle: () {}),
    );
    expect(_tip('About'), findsNothing);
    expect(_tip('Theme'), findsNothing);
    await tester.pumpWidget(_sidebar(actions: actions, onToggle: () {}));
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(_tip('About').hitTestable(), findsOneWidget);
    expect(_tip('Theme').hitTestable(), findsOneWidget);
    await tester.pumpWidget(
      _sidebar(expanded: false, actions: actions, onToggle: () {}),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(_tip('About').hitTestable(), findsNothing);
    expect(_tip('Theme').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(_tip('About'), findsNothing);
    await tester.pumpWidget(
      _sidebar(narrow: true, actions: actions, onToggle: () {}),
    );
    await tester.pumpAndSettle();
    expect(_tip('About'), findsNothing);
    expect(_tip('Theme'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final disableAnimations in [false, true]) {
    testWidgets('footer actions close the overlay '
        'with reduced motion=$disableAnimations', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(
        _sidebar(
          expanded: false,
          actions: _actions(pressed.add),
          disableAnimations: disableAnimations,
        ),
      );
      await tester.tap(_tip('Expand'));
      await tester.pumpAndSettle();
      await tester.tap(_tip('About'));
      await tester.pumpAndSettle();
      expect(pressed, ['about']);
      expect(_tip('About'), findsNothing);
      expect(_tip('Expand'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'persistent group boundary survives adjacent removals and insertions',
    (tester) async {
      const a = SidebarDestination(
        glyph: AppGlyphs.dashboard,
        label: 'A',
        id: 'a',
      );
      const b = SidebarDestination(
        glyph: AppGlyphs.proxies,
        label: 'B',
        id: 'b',
        group: 1,
      );
      const c = SidebarDestination(
        glyph: AppGlyphs.profiles,
        label: 'C',
        id: 'c',
        group: 1,
      );
      final divider = find.byWidgetPredicate(NavigationSidebar.isGroupDivider);
      await tester.pumpWidget(_sidebar(destinations: [a, b, c]));
      final height = tester
          .getSize(
            find.ancestor(of: divider, matching: find.byType(ClipRect)).first,
          )
          .height;
      await tester.pumpWidget(_sidebar(destinations: [a, c]));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(divider, findsOneWidget);
        expect(
          tester
              .getSize(
                find
                    .ancestor(of: divider, matching: find.byType(ClipRect))
                    .first,
              )
              .height,
          closeTo(height, 0.01),
        );
      }
      await tester.pumpWidget(_sidebar(destinations: [a, b, c]));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(divider, findsOneWidget);
        expect(
          tester
              .getSize(
                find
                    .ancestor(of: divider, matching: find.byType(ClipRect))
                    .first,
              )
              .height,
          closeTo(height, 0.01),
        );
      }
      await tester.pumpAndSettle();
    },
  );

  testWidgets('leaving destinations cannot retain keyboard focus', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar());
    final node = Focus.of(tester.element(find.text('Proxies')));
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
    await tester.pumpWidget(
      _sidebar(destinations: [_destinations[0], _destinations[2]]),
    );
    await tester.pump();
    expect(node.hasFocus, isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'narrow opening stacks labels and keeps destinations interactive',
    (tester) async {
      int? selected;
      await tester.pumpWidget(
        _sidebar(narrow: true, expanded: false, onToggle: () {}),
      );
      await tester.pumpWidget(
        _sidebar(
          narrow: true,
          onToggle: () {},
          onSelected: (index) => selected = index,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(_sidebarFinder).width, lessThan(100));
      expect(
        tester.getTopLeft(find.text('Proxies')).dy,
        greaterThan(tester.getBottomLeft(_glyph(AppGlyphs.proxies)).dy),
      );
      await tester.tap(find.text('Proxies'));
      expect(selected, 1);
      await tester.pumpWidget(
        _sidebar(narrow: true, expanded: false, onToggle: () {}),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(_sidebarFinder).width, 48);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('foot separator notices overflow smaller than the toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sidebar(
        destinations: [
          for (var i = 0; i < 8; i++)
            SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Row $i'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(NavigationSidebar.footSeparatorKey)).height,
      greaterThan(0),
    );
  });

  testWidgets('reduced motion opens and closes the overlay immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sidebar(expanded: false, narrow: true, disableAnimations: true),
    );
    await tester.tap(_tip('Expand'));
    await tester.pump();
    expect(_labelOpacities(tester, 'Proxies'), unorderedEquals([0, 1]));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Proxies'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing the hovered destination fades the hover ghost', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.text('Proxies')));
    await mouse.moveTo(tester.getCenter(find.text('Proxies')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _sidebar(destinations: [_destinations[0], _destinations[2]]),
    );
    await tester.pumpAndSettle();
    final ghost = find.descendant(
      of: find.byKey(NavigationSidebar.hoverGhostKey),
      matching: find.byType(DecoratedBox),
    );
    expect(ghost, findsNothing);
  });

  testWidgets('destination slots animate insertion and removal', (
    tester,
  ) async {
    const start = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(glyph: AppGlyphs.profiles, label: 'C', id: 'c'),
    ];
    await tester.pumpWidget(_sidebar(destinations: start));
    expect(_membershipOpacities(tester, 'A'), contains(1));

    final inserted = [
      start[0],
      const SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
      start[1],
    ];
    await tester.pumpWidget(_sidebar(destinations: inserted));
    expect(_membershipOpacities(tester, 'B'), contains(0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_membershipOpacities(tester, 'B').single, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(_membershipOpacities(tester, 'B'), contains(1));

    await tester.pumpWidget(_sidebar(destinations: start));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_membershipOpacities(tester, 'B').single, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsNothing);
  });

  testWidgets('a returning destination revives its slot with fresh data', (
    tester,
  ) async {
    const before = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(glyph: AppGlyphs.proxies, label: 'Old', id: 'b'),
    ];
    final after = [
      before[0],
      const SidebarDestination(glyph: AppGlyphs.proxies, label: 'New', id: 'b'),
    ];
    await tester.pumpWidget(_sidebar(destinations: before));
    await tester.pumpWidget(_sidebar(destinations: [before[0]]));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(_sidebar(destinations: after));
    await tester.pumpAndSettle();

    expect(find.text('Old'), findsNothing);
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('duplicate glyphs keep distinct legacy slots', (tester) async {
    const destinations = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'First'),
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Second'),
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Third'),
    ];
    int? selected;
    await tester.pumpWidget(
      _sidebar(
        destinations: destinations,
        onSelected: (index) => selected = index,
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    await tester.tap(find.text('Third'));
    expect(selected, 2);
  });

  testWidgets('group changes animate their separator', (tester) async {
    const first = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
    ];
    await tester.pumpWidget(_sidebar(destinations: first));
    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsNothing,
    );

    const separated = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(
        glyph: AppGlyphs.proxies,
        label: 'B',
        group: 1,
        id: 'b',
      ),
    ];
    await tester.pumpWidget(_sidebar(destinations: separated));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(_sidebar(destinations: first));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsNothing,
    );
  });

  testWidgets('group dividers track animated slot changes, including empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
          SidebarDestination(
            glyph: AppGlyphs.proxies,
            label: 'B',
            group: 1,
            id: 'b',
          ),
        ],
      ),
    );
    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsOneWidget,
    );

    await tester.pumpWidget(_sidebar(destinations: const []));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a leaving destination cannot be tapped', (tester) async {
    const destinations = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
    ];
    int? selected;
    await tester.pumpWidget(
      _sidebar(
        destinations: destinations,
        onSelected: (index) => selected = index,
      ),
    );
    await tester.pumpWidget(
      _sidebar(
        destinations: [destinations[0]],
        onSelected: (index) => selected = index,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('B').hitTestable(), findsNothing);
    expect(
      tester.widgetList<Opacity>(
        find.ancestor(of: find.text('B'), matching: find.byType(Opacity)),
      ),
      isNotEmpty,
    );
    expect(selected, isNull);
  });

  testWidgets('tap resolves the current identity index during reorder', (
    tester,
  ) async {
    const before = [
      SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
      SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
      SidebarDestination(glyph: AppGlyphs.profiles, label: 'C', id: 'c'),
    ];
    final after = [before[2], before[0], before[1]];
    int? selected;
    await tester.pumpWidget(
      _sidebar(destinations: before, onSelected: (index) => selected = index),
    );
    await tester.pumpWidget(
      _sidebar(destinations: after, onSelected: (index) => selected = index),
    );
    await tester.tap(find.text('B'));
    expect(selected, 2);
  });

  testWidgets('reduced motion settles slots immediately mid-flight', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
        ],
      ),
    );
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
          SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          SidebarDestination(glyph: AppGlyphs.dashboard, label: 'A', id: 'a'),
          SidebarDestination(glyph: AppGlyphs.proxies, label: 'B', id: 'b'),
        ],
        disableAnimations: true,
      ),
    );
    expect(_membershipOpacities(tester, 'B'), contains(1));
  });

  testWidgets('group dividers separate destination groups', (tester) async {
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          SidebarDestination(
            glyph: AppGlyphs.dashboard,
            label: 'Dashboard',
            group: 0,
          ),
          SidebarDestination(
            glyph: AppGlyphs.proxies,
            label: 'Proxies',
            group: 1,
          ),
          SidebarDestination(
            glyph: AppGlyphs.profiles,
            label: 'Profiles',
            group: 1,
          ),
        ],
      ),
    );

    expect(
      find.byWidgetPredicate(NavigationSidebar.isGroupDivider),
      findsOneWidget,
    );
  });

  testWidgets('the hover magnet follows the cursor to the nearest row', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar());
    await tester.pumpAndSettle();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Profiles')));
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(find.byKey(NavigationSidebar.hoverGhostKey)).dy,
      moreOrLessEquals(tester.getCenter(find.text('Profiles')).dy, epsilon: 1),
    );
  });

  testWidgets('the magnet pre-fills the icon it approaches', (tester) async {
    await tester.pumpWidget(_sidebar());
    await tester.pumpAndSettle();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Proxies')));
    await tester.pumpAndSettle();

    expect(_fillOf(tester, AppGlyphs.proxies), moreOrLessEquals(0.7));
    expect(_fillOf(tester, AppGlyphs.dashboard), 1);
  });

  testWidgets('pressing a row dips its content', (tester) async {
    await tester.pumpWidget(_sidebar());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Proxies')),
    );
    await tester.pumpAndSettle();

    final scales = find
        .ancestor(
          of: find.text('Proxies').hitTestable(),
          matching: find.byType(Transform),
        )
        .evaluate()
        .map((element) => (element.widget as Transform).transform.entry(0, 0));
    expect(scales, isNotEmpty);
    expect(scales, contains(moreOrLessEquals(0.94, epsilon: 0.01)));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the toggle sits below the destinations', (tester) async {
    await tester.pumpWidget(_sidebar());

    expect(
      tester.getTopLeft(_tip('Collapse')).dy,
      greaterThan(tester.getBottomRight(find.text('Profiles')).dy),
    );
  });

  testWidgets('the foot separator stays collapsed when the list fits', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar());
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(NavigationSidebar.footSeparatorKey)).height,
      0,
    );
  });

  testWidgets('the foot separator appears when the list scrolls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sidebar(
        destinations: [
          for (var i = 0; i < 12; i++)
            SidebarDestination(glyph: AppGlyphs.dashboard, label: 'Row $i'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(NavigationSidebar.footSeparatorKey)).height,
      greaterThan(0),
    );
  });

  testWidgets('destination pills keep a square compact footprint', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar(expanded: false));

    final selected = find.byWidgetPredicate(
      (widget) =>
          widget is Material &&
          widget.color ==
              Theme.of(
                tester.element(_sidebarFinder),
              ).colorScheme.onSurface.withValues(alpha: 0.08),
    );
    expect(tester.getSize(selected), const Size(36, 36));

    await tester.pumpWidget(_sidebar());
    await tester.pumpAndSettle();
    expect(tester.getSize(selected), const Size(208, 36));
  });

  testWidgets('the selected row carries a centered indicator', (tester) async {
    await tester.pumpWidget(_sidebar(selectedIndex: 1));

    final indicator = tester.getRect(_indicator(tester));
    expect(indicator.width, 3);
    expect(indicator.height, 16);
    expect(
      indicator.center.dy,
      moreOrLessEquals(tester.getCenter(_glyph(AppGlyphs.proxies)).dy),
    );
    expect(tester.getSize(_sidebarFinder).width, 220);
    expect(_labelOpacities(tester, 'Proxies'), [1]);
    expect(
      tester.getSemantics(find.text('Proxies')),
      isSemantics(isSelected: true, isButton: true),
    );
  });

  testWidgets('the indicator stretches toward the new row and settles on it', (
    tester,
  ) async {
    await tester.pumpWidget(_sidebar());
    final start = tester.getRect(_indicator(tester));

    await tester.pumpWidget(_sidebar(selectedIndex: 2));
    await tester.pump(const Duration(milliseconds: 160));
    final middle = tester.getRect(_indicator(tester));
    expect(middle.top, greaterThanOrEqualTo(start.top));
    expect(middle.height, greaterThan(16));

    await tester.pumpAndSettle();
    final end = tester.getRect(_indicator(tester));
    expect(end.height, 16);
    expect(
      end.center.dy,
      moreOrLessEquals(tester.getCenter(_glyph(AppGlyphs.profiles)).dy),
    );
  });

  testWidgets('only the selected row fills its icon', (tester) async {
    await tester.pumpWidget(_sidebar());
    expect(_fillOf(tester, AppGlyphs.dashboard), 1);
    expect(_fillOf(tester, AppGlyphs.profiles), 0);

    await tester.pumpWidget(_sidebar(selectedIndex: 2));
    await tester.pumpAndSettle();
    expect(_fillOf(tester, AppGlyphs.dashboard), 0);
    expect(_fillOf(tester, AppGlyphs.profiles), 1);
  });

  testWidgets('the toggle widens the sidebar in place when it can', (
    tester,
  ) async {
    var toggled = 0;
    int? selected;
    await tester.pumpWidget(
      _sidebar(
        expanded: false,
        onToggle: () => toggled++,
        onSelected: (index) => selected = index,
      ),
    );

    expect(tester.getSize(_sidebarFinder).width, 48);
    expect(_labelOpacities(tester, 'Proxies'), [0]);
    expect(_rowTooltip('Proxies'), findsOneWidget);
    await tester.tap(_glyph(AppGlyphs.profiles));
    expect(selected, 2);

    await tester.tap(_tip('Expand'));
    await tester.pump();
    expect(toggled, 1);
    expect(find.text('Proxies'), findsOneWidget);

    await tester.pumpWidget(_sidebar(onToggle: () {}));
    await tester.pump(const Duration(milliseconds: 120));
    final width = tester.getSize(_sidebarFinder).width;
    expect(width, allOf(greaterThan(48), lessThan(220)));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.getSize(_sidebarFinder).width, 220);
    expect(_rowTooltip('Proxies'), findsNothing);
    expect(_tip('Collapse'), findsOneWidget);
  });

  testWidgets('an expanded row whose label is cut off keeps its tooltip', (
    tester,
  ) async {
    const long = 'Подключения и активные соединения';
    await tester.pumpWidget(
      _sidebar(
        destinations: const [
          ..._destinations,
          SidebarDestination(glyph: AppGlyphs.connections, label: long),
        ],
        onToggle: () {},
      ),
    );

    expect(_rowTooltip(long), findsOneWidget);
    expect(_rowTooltip('Proxies'), findsNothing);
  });

  testWidgets('the toggle glyph follows the pane as it widens', (tester) async {
    List<Rect> glyph(String tooltip) => [
      for (final shape
          in tester
              .widget<GlyphIcon>(
                find.descendant(
                  of: _tip(tooltip),
                  matching: find.byType(GlyphIcon),
                ),
              )
              .glyph
              .shapes)
        shape.path.getBounds(),
    ];

    await tester.pumpWidget(_sidebar(expanded: false, onToggle: () {}));
    final collapsed = glyph('Expand');

    await tester.pumpWidget(_sidebar(onToggle: () {}));
    await tester.pump(const Duration(milliseconds: 120));
    final midway = glyph('Collapse');
    expect(midway, isNot(collapsed));

    await tester.pumpAndSettle();
    expect(glyph('Collapse'), isNot(midway));
  });

  testWidgets('window controls keep their corner clear', (tester) async {
    await tester.pumpWidget(
      _sidebar(
        expanded: false,
        onToggle: () {},
        windowControls: const Size(78, 32),
      ),
    );

    final sidebar = tester.getRect(_sidebarFinder);
    expect(sidebar.width, 78);
    final toggle = _tip('Expand');
    expect(
      tester.getTopLeft(toggle).dy,
      greaterThanOrEqualTo(sidebar.top + 32),
    );
    expect(tester.getCenter(toggle).dx, sidebar.center.dx);
    expect(tester.getCenter(_glyph(AppGlyphs.profiles)).dx, sidebar.center.dx);
    final selectedItem = tester.getRect(
      find
          .ancestor(
            of: _glyph(AppGlyphs.dashboard),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(selectedItem.size, const Size(54, 36));
    expect(selectedItem.center.dx, sidebar.center.dx);

    final folder = tester.getCenter(_glyph(AppGlyphs.profiles));
    await tester.pumpWidget(
      _sidebar(onToggle: () {}, windowControls: const Size(78, 32)),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(_sidebarFinder).width, 220);
    expect(tester.getCenter(_glyph(AppGlyphs.profiles)), folder);
  });

  group('without room to widen', () {
    Future<void> openOverlay(WidgetTester tester) async {
      await tester.tap(_tip('Expand'));
      await tester.pumpAndSettle();
      expect(find.text('Proxies'), findsNWidgets(2));
    }

    testWidgets('the toggle opens the pane over the content', (tester) async {
      await tester.pumpWidget(_sidebar(expanded: false));
      final contentWidth = tester
          .getSize(find.byKey(const ValueKey('content')))
          .width;

      await openOverlay(tester);

      expect(tester.getSize(_sidebarFinder).width, 48);
      expect(
        tester.getSize(find.byKey(const ValueKey('content'))).width,
        contentWidth,
      );
      expect(_labelOpacities(tester, 'Proxies'), unorderedEquals([0, 1]));
      expect(
        tester.getBottomLeft(_tip('Collapse')),
        tester.getBottomLeft(_tip('Expand')),
      );
      final colorScheme = Theme.of(tester.element(_sidebarFinder)).colorScheme;
      final pane = tester.widget<Material>(_paneFinder);
      expect(pane.color, colorScheme.chromeSurface);
      expect(
        (pane.shape! as BorderDirectional).end,
        Divider.createBorderSide(tester.element(_sidebarFinder)),
      );

      await tester.tap(_tip('Collapse'));
      await tester.pumpAndSettle();
      expect(find.text('Proxies'), findsOneWidget);
    });

    testWidgets('the pane covers the safe area around the sidebar', (
      tester,
    ) async {
      const safePadding = EdgeInsets.only(left: 40, top: 24, bottom: 16);
      await tester.pumpWidget(
        _sidebar(expanded: false, safePadding: safePadding),
      );
      final sidebar = tester.getRect(_sidebarFinder);
      expect(sidebar.width, 48 + safePadding.left);
      final toggle = tester.getTopLeft(_tip('Expand'));
      expect(toggle.dx, greaterThanOrEqualTo(sidebar.left + safePadding.left));
      expect(toggle.dy, greaterThanOrEqualTo(sidebar.top + safePadding.top));

      await openOverlay(tester);

      final pane = tester.getRect(_paneFinder);
      expect(pane.topLeft, sidebar.topLeft);
      expect(pane.height, sidebar.height);
      expect(pane.width, 220 + safePadding.left);
      expect(
        tester.getBottomLeft(_tip('Collapse')),
        tester.getBottomLeft(_tip('Expand')),
      );
    });

    testWidgets('choosing a row selects it and closes the pane', (
      tester,
    ) async {
      int? selected;
      await tester.pumpWidget(
        _sidebar(expanded: false, onSelected: (index) => selected = index),
      );
      await openOverlay(tester);

      await tester.tap(_shown('Profiles'));
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(find.text('Profiles'), findsOneWidget);
    });

    testWidgets('a tap outside or escape dismisses the pane', (tester) async {
      await tester.pumpWidget(_sidebar(expanded: false));

      await openOverlay(tester);
      await tester.tapAt(const Offset(600, 300));
      await tester.pumpAndSettle();
      expect(find.text('Proxies'), findsOneWidget);

      await openOverlay(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Proxies'), findsOneWidget);
    });

    testWidgets('a tooltip inside the pane lays out over it', (tester) async {
      await tester.pumpWidget(_sidebar(expanded: false));
      await openOverlay(tester);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: tester.getCenter(_tip('Collapse')));
      await gesture.moveTo(tester.getCenter(_tip('Collapse')));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Collapse'), findsOneWidget);
    });

    testWidgets('widening the window closes the pane', (tester) async {
      await tester.pumpWidget(_sidebar(expanded: false));
      await openOverlay(tester);

      await tester.pumpWidget(_sidebar(expanded: false, onToggle: () {}));
      await tester.pump();
      expect(find.text('Proxies'), findsOneWidget);
    });
  });
}
