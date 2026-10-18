import 'dart:async';

import 'package:reclash/common/app_ports.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
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
}) async {
  tester.view.physicalSize = const Size(500, 800);
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
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(500, 800);
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
}
