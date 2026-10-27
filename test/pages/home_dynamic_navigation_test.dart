import 'dart:async';

import 'package:reclash/common/app_ports.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/manager/hotkey_manager.dart';
import 'package:reclash/common/desktop/hotkeys.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/views/navigation.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

final _itemsProvider = NotifierProvider<_Items, List<NavigationItem>>(
  _Items.new,
);

class _Items extends Notifier<List<NavigationItem>> {
  @override
  List<NavigationItem> build() => const [];

  void set(List<NavigationItem> value) => state = value;
}

class _Harness {
  _Harness(this.tester, this.container, this.items);

  final WidgetTester tester;
  final ProviderContainer container;
  final _Items items;

  Future<void> settle() => tester.pumpAndSettle();

  Future<void> show(PageLabel label) async {
    await tester.tap(find.byGlyph(_glyphFor(label)));
    await settle();
    expect(container.read(currentPageLabelProvider), label);
  }
}

Glyph _glyphFor(PageLabel label) => switch (label) {
  PageLabel.dashboard => AppGlyphs.dashboard,
  PageLabel.proxies => AppGlyphs.proxies,
  PageLabel.profiles => AppGlyphs.profiles,
  PageLabel.tools => AppGlyphs.tools,
  _ => AppGlyphs.dashboard,
};

NavigationItem _item(PageLabel label, {bool keep = true, List<int>? inits}) =>
    NavigationItem(
      glyph: _glyphFor(label),
      label: label,
      keep: keep,
      builder: (_) => _Page(label: label, inits: inits),
    );

Future<_Harness> _mount(
  WidgetTester tester, {
  required List<NavigationItem> items,
  PageLabel selected = PageLabel.dashboard,
  bool reducedMotion = false,
  bool withShortcutManager = false,
  Size size = const Size(500, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reducedMotion);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final container = ProviderContainer(
    overrides: [
      navigationItemsStateProvider.overrideWith(
        (ref) => NavigationItemsState(value: ref.watch(_itemsProvider)),
      ),
      currentPageLabelProvider.overrideWith(() => _SelectedPage(selected)),
      toolsSessionProvider.overrideWith(_ToolsSession.new),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = size;
  final itemNotifier = container.read(_itemsProvider.notifier)..set(items);

  final Widget home = withShortcutManager
      ? HotKeyManager(
          platformState: const HotkeyPlatformState(systemSupported: false),
          registerHotKeys: ({required specs}) async => const [],
          hotKeyEventSource: () => const Stream<int>.empty(),
          child: const HomePage(),
        )
      : const HomePage();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(includeNavigatorKey: false, child: home),
    ),
  );
  await tester.pump();
  return _Harness(tester, container, itemNotifier);
}

class _ToolsSession extends ToolsSession {
  @override
  ToolsState build() => const ToolsState();
}

class _SelectedPage extends CurrentPageLabel {
  _SelectedPage(this.initial);
  final PageLabel initial;

  @override
  PageLabel build() => initial;
}

class _Page extends StatefulWidget {
  const _Page({required this.label, this.inits});
  final PageLabel label;
  final List<int>? inits;

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  var count = 0;

  @override
  void initState() {
    super.initState();
    widget.inits?.add(widget.label.index);
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('page:${widget.label.name}'),
        Text('count:$count'),
        Text('active:${PageActivityScope.isActiveOf(context)}'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: const Text('increment'),
        ),
      ],
    ),
  );
}

void main() {
  setUp(() {
    navigationPort = navigation;
    addTearDown(() => navigationPort = null);
  });

  final dashboard = _item(PageLabel.dashboard);
  final tools = _item(PageLabel.tools);
  final profiles = _item(PageLabel.profiles);
  final proxies = _item(PageLabel.proxies);

  testWidgets('sidebar shortcuts select the existing Tools routes', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, tools],
      size: const Size(1200, 800),
    );
    harness.container
        .read(appSettingProvider.notifier)
        .update(
          (state) =>
              state.copyWith(sidebarExpanded: true, sidebarNarrow: false),
        );
    await harness.settle();

    for (final (glyph, page) in [
      (AppGlyphs.info, ToolPage.about),
      (AppGlyphs.paintbrush, ToolPage.theme),
    ]) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationSidebar),
          matching: find.byGlyph(AppGlyphs.dashboard),
        ),
      );
      await harness.settle();
      await tester.tap(find.byGlyph(glyph));
      await harness.settle();
      expect(harness.container.read(currentPageLabelProvider), PageLabel.tools);
      expect(harness.container.read(toolsSessionProvider).path, [
        ToolRoute(page),
      ]);
      expect(find.byType(NavigationSidebar), findsOneWidget);
      expect(find.text('page:tools'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(HomePage))).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    }
  });

  for (final floating in [true, false]) {
    testWidgets('wide bar matches sidebar destinations and groups '
        'with floating=$floating', (tester) async {
      final requests = NavigationItem(
        glyph: AppGlyphs.requests,
        label: PageLabel.requests,
        modes: [NavigationItemMode.desktop],
        builder: (_) => const Text('requests content'),
      );
      final harness = await _mount(
        tester,
        items: [dashboard, profiles, requests, tools],
        size: const Size(1200, 800),
      );
      await harness.settle();
      final sidebarItems = harness.container
          .read(currentNavigationItemsStateProvider)
          .value;
      harness.container
          .read(appSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              navigationLayout: NavigationLayout.bar,
              floatingNavigationBar: floating,
            ),
          );
      await harness.settle();
      expect(
        harness.container.read(currentNavigationItemsStateProvider).value,
        sidebarItems,
      );
      if (floating) {
        final destinations = tester
            .widget<NavigationDock>(find.byType(NavigationDock))
            .destinations;
        expect(
          destinations.map((item) => item.id),
          sidebarItems.map((item) => item.label),
        );
        expect(destinations.map((item) => item.group), [0, 1, 2, 3]);
      } else {
        final destinations = tester
            .widget<AnimatedNavigationBar>(find.byType(AnimatedNavigationBar))
            .destinations;
        expect(
          destinations.map((item) => item.id),
          sidebarItems.map((item) => item.label),
        );
        expect(destinations.map((item) => item.group), [0, 1, 2, 3]);
      }
      await tester.tap(find.byGlyph(AppGlyphs.requests));
      await harness.settle();
      expect(
        harness.container.read(shownPageLabelProvider),
        PageLabel.requests,
      );
      expect(find.text('requests content'), findsOneWidget);
      tester.view.physicalSize = const Size(500, 800);
      harness.container.read(viewSizeProvider.notifier).value = const Size(
        500,
        800,
      );
      await harness.settle();
      expect(
        harness.container
            .read(currentNavigationItemsStateProvider)
            .value
            .map((item) => item.label),
        [PageLabel.dashboard, PageLabel.profiles, PageLabel.tools],
      );
      expect(find.byGlyph(AppGlyphs.requests), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('inserting and removing before selected keeps tools selected', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, tools],
      selected: PageLabel.tools,
    );

    await tester.tap(find.text('increment'));
    await tester.pump();
    final activeElement = tester.element(find.text('page:tools'));
    harness.items.set([dashboard, profiles, tools]);
    await tester.pump();
    expect(tester.element(find.text('page:tools')), same(activeElement));
    expect(find.text('count:1').hitTestable(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.element(find.text('page:tools')), same(activeElement));
    await tester.pumpAndSettle();
    expect(harness.container.read(currentPageLabelProvider), PageLabel.tools);
    expect(find.text('page:tools'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);

    harness.items.set([profiles, tools]);
    await tester.pumpAndSettle();
    expect(harness.container.read(currentPageLabelProvider), PageLabel.tools);
    expect(find.text('page:tools'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
  });

  testWidgets('a late tab cannot evict the page during a far switch', (
    tester,
  ) async {
    final inits = <int>[];
    final keptTools = _item(PageLabel.tools, inits: inits);
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, keptTools],
    );
    harness.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.slide));
    await tester.pump();
    await harness.show(PageLabel.tools);
    await tester.tap(find.text('increment'));
    await tester.pump();
    final toolsElement = tester.element(find.text('page:tools'));
    await harness.show(PageLabel.dashboard);
    harness.container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.tools);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    harness.items.set([dashboard, proxies, profiles, keptTools]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.element(find.text('page:tools')), same(toolsElement));
    expect(inits, [PageLabel.tools.index]);
    await tester.pumpAndSettle();
    expect(find.text('count:1').hitTestable(), findsOneWidget);
    expect(find.text('page:tools').hitTestable(), findsOneWidget);
    expect(harness.container.read(currentPageLabelProvider), PageLabel.tools);
    expect(tester.takeException(), isNull);
  });

  testWidgets('equal length reorder keeps selected page by label', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, proxies, profiles, tools],
      selected: PageLabel.profiles,
    );

    harness.items.set([tools, profiles, dashboard, proxies]);
    await tester.pumpAndSettle();
    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.profiles,
    );
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
  });

  testWidgets('list changes midfade preserve the selected page', (
    tester,
  ) async {
    final toolsInits = <int>[];
    final trackedTools = _item(PageLabel.tools, inits: toolsInits);
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, trackedTools],
      selected: PageLabel.dashboard,
    );

    harness.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.fade));
    await tester.pump();
    await harness.show(PageLabel.tools);
    expect(toolsInits, [PageLabel.tools.index]);
    await harness.show(PageLabel.dashboard);
    expect(toolsInits, [PageLabel.tools.index]);
    await tester.tap(find.byGlyph(AppGlyphs.profiles));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    harness.items.set([profiles, trackedTools]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
    expect(toolsInits, [PageLabel.tools.index]);
    await tester.pumpAndSettle();

    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.profiles,
    );
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
  });

  testWidgets('list changes midslide do not replace the active page', (
    tester,
  ) async {
    final toolsInits = <int>[];
    final trackedTools = _item(PageLabel.tools, inits: toolsInits);
    final harness = await _mount(
      tester,
      items: [dashboard, proxies, profiles, trackedTools],
      selected: PageLabel.dashboard,
    );

    harness.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.slide));
    await tester.pump();
    await harness.show(PageLabel.tools);
    await harness.show(PageLabel.dashboard);
    expect(toolsInits, [PageLabel.tools.index]);
    await tester.tap(find.byGlyph(AppGlyphs.profiles));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    harness.items.set([profiles, trackedTools]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
    expect(toolsInits, [PageLabel.tools.index]);
    await tester.pumpAndSettle();

    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.profiles,
    );
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
  });

  testWidgets('A to B to A does not duplicate the outgoing page', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, tools],
      selected: PageLabel.dashboard,
    );

    await tester.tap(find.byGlyph(AppGlyphs.profiles));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byGlyph(AppGlyphs.dashboard));
    await tester.pump();
    expect(find.text('page:dashboard'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('page:dashboard'), findsOneWidget);
    expect(find.text('page:profiles'), findsNothing);
    expect(find.text('active:true'), findsOneWidget);
    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.dashboard,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty to populated mounts requested page without rewriting it', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: const [],
      selected: PageLabel.tools,
    );

    expect(tester.takeException(), isNull);
    harness.items.set([dashboard, profiles, tools]);
    await tester.pumpAndSettle();

    expect(harness.container.read(currentPageLabelProvider), PageLabel.tools);
    expect(find.text('page:tools'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
  });

  testWidgets('reduced motion immediately displays selected page', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, tools],
      reducedMotion: true,
    );

    await tester.tap(find.byGlyph(AppGlyphs.profiles));
    await tester.pump();
    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.profiles,
    );
    expect(find.text('page:profiles'), findsOneWidget);
    expect(find.text('active:true'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabling reduced motion settles the current page transition', (
    tester,
  ) async {
    final harness = await _mount(tester, items: [dashboard, profiles, tools]);
    harness.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.fade));
    await tester.pump();
    harness.container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.profiles);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('page:dashboard'), findsOneWidget);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    expect(find.text('page:dashboard'), findsNothing);
    expect(find.text('page:profiles'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ctrl+number selects the visible page by navigation order', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, profiles, tools],
      withShortcutManager: true,
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(
      harness.container.read(currentPageLabelProvider),
      PageLabel.profiles,
    );
    expect(find.text('page:profiles'), findsOneWidget);
  });

  testWidgets('visited pages mount lazily once and retain state offstage', (
    tester,
  ) async {
    final inits = <int>[];
    final harness = await _mount(
      tester,
      items: [
        _item(PageLabel.dashboard, inits: inits),
        _item(PageLabel.profiles, inits: inits),
        _item(PageLabel.tools, inits: inits),
      ],
    );
    expect(inits, [PageLabel.dashboard.index]);

    await tester.tap(find.text('increment'));
    await tester.pump();
    await harness.show(PageLabel.profiles);
    expect(inits, [PageLabel.dashboard.index, PageLabel.profiles.index]);
    expect(find.text('page:dashboard'), findsNothing);
    expect(find.text('count:1', skipOffstage: false), findsOneWidget);
    await harness.show(PageLabel.dashboard);
    expect(inits, [PageLabel.dashboard.index, PageLabel.profiles.index]);
    expect(find.text('count:1'), findsOneWidget);
  });

  testWidgets('the sidebar slides the pages vertically, touching', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, proxies, profiles],
      size: const Size(1200, 800),
    );
    harness.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(tabAnimation: TabAnimation.slide));
    await tester.pump();
    final rest = tester.getCenter(find.text('page:dashboard'));
    harness.container
        .read(currentPageLabelProvider.notifier)
        .toPage(PageLabel.profiles);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    final outgoing = tester.getCenter(find.text('page:dashboard'));
    final incoming = tester.getCenter(find.text('page:profiles'));
    expect(outgoing.dx, rest.dx);
    expect(incoming.dx, rest.dx);
    expect(outgoing.dy, lessThan(rest.dy));
    expect(incoming.dy, greaterThan(rest.dy));
    expect(incoming.dy - outgoing.dy, moreOrLessEquals(800, epsilon: 0.01));
    await tester.pumpAndSettle();
    expect(find.text('page:dashboard'), findsNothing);
    expect(tester.getCenter(find.text('page:profiles')), rest);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a switch interrupted for a third page keeps the pages touching',
    (tester) async {
      final harness = await _mount(
        tester,
        items: [dashboard, proxies, profiles, tools],
      );
      harness.container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(tabAnimation: TabAnimation.slide));
      await tester.pump();
      final rest = tester.getCenter(find.text('page:dashboard'));
      final notifier = harness.container.read(
        currentPageLabelProvider.notifier,
      );
      notifier.toPage(PageLabel.proxies);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      notifier.toPage(PageLabel.tools);
      await tester.pump();
      for (var frame = 0; frame < 6; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final first = tester.getCenter(find.text('page:dashboard')).dx;
        final second = tester.getCenter(find.text('page:proxies')).dx;
        final third = tester.getCenter(find.text('page:tools')).dx;
        expect(second - first, moreOrLessEquals(500, epsilon: 0.01));
        expect(third - second, moreOrLessEquals(500, epsilon: 0.01));
      }
      await tester.pumpAndSettle();
      expect(find.text('page:dashboard'), findsNothing);
      expect(find.text('page:proxies'), findsNothing);
      expect(tester.getCenter(find.text('page:tools')), rest);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the bar layout keeps the bottom bar at desktop width', (
    tester,
  ) async {
    final harness = await _mount(
      tester,
      items: [dashboard, proxies, profiles],
      size: const Size(1200, 800),
    );
    expect(find.byType(NavigationDock), findsNothing);
    harness.container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(navigationLayout: NavigationLayout.bar),
        );
    await tester.pumpAndSettle();
    expect(harness.container.read(isMobileViewProvider), isTrue);
    expect(find.byType(NavigationDock), findsOneWidget);
    await harness.show(PageLabel.profiles);
    expect(find.text('page:profiles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
