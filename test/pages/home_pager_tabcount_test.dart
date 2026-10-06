import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/home/home.dart';

import '../helpers/test_app.dart';

class _FlagNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final _proxies = NotifierProvider<_FlagNotifier, bool>(_FlagNotifier.new);
final _variant = NotifierProvider<_FlagNotifier, bool>(_FlagNotifier.new);

final _builds = <PageLabel, int>{};

class _CountedContent extends StatefulWidget {
  const _CountedContent(this.label, {super.key});

  final PageLabel label;

  @override
  State<_CountedContent> createState() => _CountedContentState();
}

class _CountedContentState extends State<_CountedContent> {
  @override
  void initState() {
    super.initState();
    _builds.update(widget.label, (n) => n + 1, ifAbsent: () => 1);
  }

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('content:${widget.label.name}'));
}

NavigationItem _item(
  PageLabel label, {
  List<NavigationItemMode> modes = const [
    NavigationItemMode.mobile,
    NavigationItemMode.desktop,
  ],
}) => NavigationItem(
  glyph: AppGlyphs.tools,
  label: label,
  modes: modes,
  builder: (_) => _CountedContent(label, key: GlobalObjectKey(label)),
);

final _navOverride = navigationItemsStateProvider.overrideWith((ref) {
  final hasProxies = ref.watch(_proxies);
  return NavigationItemsState(
    value: [
      _item(PageLabel.dashboard),
      if (hasProxies) _item(PageLabel.proxies),
      _item(PageLabel.requests, modes: const [NavigationItemMode.desktop]),
      _item(PageLabel.profiles),
      _item(PageLabel.tools),
    ],
  );
});

const _desktop = [NavigationItemMode.desktop];

final _desktopOverride = navigationItemsStateProvider.overrideWith((ref) {
  final hasProxies = ref.watch(_proxies);
  // Mirrors the real desktop strip, with tools last so a late proxies tab
  // pushes it one slot down the controller.
  return NavigationItemsState(
    value: [
      _item(PageLabel.dashboard),
      if (hasProxies) _item(PageLabel.proxies),
      _item(PageLabel.profiles),
      _item(PageLabel.requests, modes: _desktop),
      _item(PageLabel.connections, modes: _desktop),
      _item(PageLabel.dns, modes: _desktop),
      _item(PageLabel.tools),
    ],
  );
});

final _reorderOverride = navigationItemsStateProvider.overrideWith((ref) {
  final swapped = ref.watch(_variant);
  // Both variants keep the SAME length but move tools to a different index: a
  // tab leaves before tools while another joins after it.
  return NavigationItemsState(
    value: swapped
        ? [
            _item(PageLabel.dashboard),
            _item(PageLabel.profiles),
            _item(PageLabel.tools),
            _item(PageLabel.logs),
          ]
        : [
            _item(PageLabel.dashboard),
            _item(PageLabel.proxies),
            _item(PageLabel.profiles),
            _item(PageLabel.tools),
          ],
  );
});

double _pageOffsetOf(WidgetTester tester, PageLabel label) {
  final content = tester.getTopLeft(find.byKey(GlobalObjectKey(label)));
  final viewport = tester.getTopLeft(find.byType(PageView));
  return content.dx - viewport.dx;
}

Future<void> _pumpShell(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(includeNavigatorKey: false, child: HomePage()),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(_builds.clear);

  testWidgets('tools element survives a tab-set change mid tab-switch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        _desktopOverride,
        navSurfaceProvider.overrideWithValue(NavSurface.rail),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await _pumpShell(tester, container);

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(_builds[PageLabel.tools], 1);

    container.read(currentPageLabelProvider.notifier).toPage(
      PageLabel.dashboard,
    );
    await tester.pumpAndSettle();

    // dashboard -> tools is a non-adjacent jump, so the slide permutation is
    // live; growing the set now must not tear the kept-alive page down.
    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    container.read(_proxies.notifier).set(true);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      _builds[PageLabel.tools],
      1,
      reason: 'the active tools page must relocate, not rebuild from scratch',
    );
    expect(_pageOffsetOf(tester, PageLabel.tools), 0);
    expect(find.text('content:tools'), findsOneWidget);
  });

  testWidgets('tools keeps content when a tab appears before it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [_navOverride]);
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);

    await _pumpShell(tester, container);

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(_pageOffsetOf(tester, PageLabel.tools), 0);

    container.read(_proxies.notifier).set(true);
    await tester.pump();
    await tester.pump();
    expect(
      _pageOffsetOf(tester, PageLabel.tools),
      0,
      reason: 'tools must stay on-screen after proxies appears',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tools keeps content when proxies appears on a fixed desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        _desktopOverride,
        navSurfaceProvider.overrideWithValue(NavSurface.rail),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await _pumpShell(tester, container);

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    container.read(_proxies.notifier).set(true);
    await tester.pumpAndSettle();
    expect(
      _pageOffsetOf(tester, PageLabel.tools),
      0,
      reason: 'tools must stay on-screen after a late proxies tab on desktop',
    );
    expect(find.text('content:tools'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tools keeps content across landscape->portrait->landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [_navOverride]);
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);

    await _pumpShell(tester, container);

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(_pageOffsetOf(tester, PageLabel.tools), 0);

    tester.view.physicalSize = const Size(400, 800);
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);
    await tester.pump();
    await tester.pump();
    expect(
      _pageOffsetOf(tester, PageLabel.tools),
      0,
      reason: 'tools must stay on-screen in portrait',
    );

    tester.view.physicalSize = const Size(1200, 800);
    container.read(viewSizeProvider.notifier).value = const Size(1200, 800);
    await tester.pump();
    await tester.pump();
    expect(
      _pageOffsetOf(tester, PageLabel.tools),
      0,
      reason: 'tools must reappear after returning to landscape',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tools keeps content when the set reorders at equal length', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(overrides: [_reorderOverride]);
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);

    await _pumpShell(tester, container);

    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();
    expect(_pageOffsetOf(tester, PageLabel.tools), 0);

    container.read(_variant.notifier).set(true);
    await tester.pump();
    await tester.pump();
    expect(
      _pageOffsetOf(tester, PageLabel.tools),
      0,
      reason: 'tools must stay on-screen after an equal-length reorder',
    );
    expect(tester.takeException(), isNull);
  });
}
