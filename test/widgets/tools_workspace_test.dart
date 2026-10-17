import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'dart:async';

import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/tools/catalog.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/input.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/tools.dart';
import 'package:reclash/views/tools/global_search.dart';
import 'package:reclash/views/tools/search.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await preferences.rebind();
  });

  Future<ProviderContainer> pumpTools(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    bool home = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        if (home)
          navigationItemsStateProvider.overrideWithValue(
            NavigationItemsState(
              value: [
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: PageLabel.dashboard,
                  builder: (_) => const CommonScaffold(
                    key: GlobalObjectKey(PageLabel.dashboard),
                    title: 'Origin',
                    body: Text('origin content'),
                  ),
                ),
                NavigationItem(
                  glyph: AppGlyphs.tools,
                  label: PageLabel.tools,
                  builder: (_) =>
                      const ToolsView(key: GlobalObjectKey(PageLabel.tools)),
                ),
              ],
            ),
          ),
        profilesProvider.overrideWith(TestProfiles.new),
        scriptsProvider.overrideWith(TestScripts.new),
        globalRulesProvider.overrideWith(TestGlobalRules.new),
        iconSetsProvider.overrideWith(TestIconSets.new),
        clashProvidersProvider.overrideWith(TestClashProviders.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    if (home) {
      container
          .read(profilesProvider.notifier)
          .put(const Profile(id: 1, autoUpdateDuration: Duration.zero));
      container.read(viewSizeProvider.notifier).value = size;
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: home ? const HomePage() : const ToolsView()),
      ),
    );
    await tester.pump();
    return container;
  }

  for (final floating in [true, false]) {
    testWidgets('global shortcut hands off to Tools with floating=$floating', (
      tester,
    ) async {
      final container = await pumpTools(
        tester,
        size: const Size(390, 844),
        home: true,
      );
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(floatingNavigationBar: floating));
      await tester.pumpAndSettle();
      expect(container.read(shownPageLabelProvider), PageLabel.dashboard);
      expect(find.byTooltip('Search'), findsNothing);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'log level');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log level').first);
      await tester.pumpAndSettle();
      expect(container.read(shownPageLabelProvider), PageLabel.tools);
      expect(
        container.read(toolsSessionProvider).path.last.settingId,
        'general.logLevel',
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SettingTarget && w.spec.id == 'general.logLevel',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('opening a setting spec applies its value', (tester) async {
    final container = await pumpTools(tester);
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general, settingId: 'general.allowLan'));
    await tester.pumpAndSettle();

    final target = find.byWidgetPredicate(
      (widget) =>
          widget is SettingTarget && widget.spec.id == 'general.allowLan',
    );
    expect(target, findsOneWidget);
    final initial = container.read(patchClashConfigProvider).allowLan;
    await tester.tap(
      find.descendant(of: target, matching: find.byType(Switch)),
    );
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).allowLan, !initial);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide layout shows an empty detail placeholder', (tester) async {
    await pumpTools(tester, size: const Size(1800, 1000));
    expect(find.byType(NullStatus), findsOneWidget);
    expect(
      find.text('Choose a section or search for a setting'),
      findsOneWidget,
    );
    final divider = find.byKey(const ValueKey('tools-pane-divider'));
    expect(tester.getSize(divider).width, 1);
    expect(tester.getCenter(divider).dx, 360.5);
    final catalogList = find.descendant(
      of: find.byType(ToolsCatalogPanel),
      matching: find.byType(ListView),
    );
    final listPadding = tester
        .widget<ListView>(catalogList)
        .padding!
        .resolve(TextDirection.ltr);
    expect(listPadding.right, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog search and rows share one aligned scroll column', (
    tester,
  ) async {
    await pumpTools(tester, size: const Size(1800, 1000));
    final panel = find.byType(ToolsCatalogPanel);
    final search = find.descendant(
      of: panel,
      matching: find.byType(SearchField),
    );
    final appBar = find.descendant(of: panel, matching: find.byType(AppBar));
    final general = find.ancestor(
      of: find.text('General'),
      matching: find.byType(DecorationListItem),
    );
    final searchRect = tester.getRect(search);
    final appBarRect = tester.getRect(appBar);
    final rowRect = tester.getRect(general.first);
    final listRect = tester.getRect(
      find.descendant(of: panel, matching: find.byType(ListView)),
    );
    expect(searchRect.top, greaterThanOrEqualTo(appBarRect.bottom));
    expect(searchRect.top - appBarRect.bottom, lessThan(16));
    expect(searchRect.left, closeTo(rowRect.left, 0.5));
    expect(searchRect.right, closeTo(rowRect.right, 0.5));
    expect(listRect.left, closeTo(searchRect.left, 0.5));
    expect(listRect.right - searchRect.right, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop landing offers recent tools and reopens them', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    await tester.tap(find.text('General').first);
    await tester.pumpAndSettle();
    await tester.state<ToolsViewState>(find.byType(ToolsView)).handleBack();
    await tester.pumpAndSettle();

    final recent = find.byKey(const ValueKey('tools-recent-page.general'));
    expect(find.text('Recently used'), findsOneWidget);
    expect(recent, findsOneWidget);
    await tester.tap(recent);
    await tester.pumpAndSettle();
    expect(
      container.read(toolsSessionProvider).path.last.page,
      ToolPage.general,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide layout caps detail width and shares one header baseline', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final panel = find.byType(ToolsCatalogPanel);
    expect(tester.getSize(panel).width, 360);
    final body = find.byType(SettingsPageScroll);
    expect(tester.getSize(body).width, lessThanOrEqualTo(840));
    expect(tester.getCenter(body).dx, closeTo(1080, 1));
    final titles = find.text('Tools');
    final detailTitle = find.text('General');
    expect(
      tester.getCenter(titles.first).dy,
      closeTo(tester.getCenter(detailTitle.last).dy, 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'deep search reconstructs ancestry and breadcrumbs return safely',
    (tester) async {
      final container = await pumpTools(tester);
      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.userAgents));
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path.map((r) => r.page), [
        ToolPage.general,
        ToolPage.userAgents,
      ]);
      final crumb = find.widgetWithText(TextButton, 'General');
      await tester.tap(crumb);
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.general),
      ]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('search opens the exact offscreen setting and repeats reveal', (
    tester,
  ) async {
    final container = await pumpTools(tester);
    await tester.enterText(find.byType(TextField).first, 'log level');
    await tester.pump();
    await tester.tap(find.text('Log level').first);
    await tester.pumpAndSettle();
    expect(
      container.read(toolsSessionProvider).path.last.settingId,
      'general.logLevel',
    );
    final target = find.byWidgetPredicate(
      (w) => w is SettingTarget && w.spec.id == 'general.logLevel',
    );
    expect(target, findsOneWidget);
    final rect = tester.getRect(target);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(900));
    final nonce = container.read(toolsSessionProvider).focusNonce;
    await tester.tap(find.text('Log level').first);
    await tester.pumpAndSettle();
    expect(container.read(toolsSessionProvider).focusNonce, greaterThan(nonce));
    expect(tester.takeException(), isNull);
  });

  testWidgets('resize keeps the actual mounted editor and search context', (
    tester,
  ) async {
    final container = await pumpTools(tester);
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general, settingId: 'general.hosts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hosts').last);
    await tester.pumpAndSettle();
    final anyEditor = find.byWidgetPredicate((w) => w is MapEditView);
    expect(anyEditor, findsOneWidget);
    expect(ViewScope.isMobileOf(tester.element(anyEditor)), isFalse);
    expect(
      ModalRoute.of(tester.element(anyEditor)),
      isA<ModalSideSheetRoute>(),
    );
    final before = tester.state(anyEditor);
    container.read(toolsSessionProvider.notifier).search('hosts');
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(identical(tester.state(anyEditor), before), isTrue);
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(identical(tester.state(anyEditor), before), isTrue);
    expect(container.read(toolsSessionProvider).query, 'hosts');
    expect(
      container.read(toolsSessionProvider).path.last.page,
      ToolPage.general,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('User-Agent settings open in a desktop side sheet', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    await tester.tap(find.text('User-Agent').last);
    await tester.pumpAndSettle();

    final view = find.byType(UserAgentsView);
    expect(view, findsOneWidget);
    expect(ModalRoute.of(tester.element(view)), isA<ModalSideSheetRoute>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('a mobile editor survives promotion to split layout', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(390, 844));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general, settingId: 'general.hosts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hosts').last);
    await tester.pumpAndSettle();

    final editor = find.byWidgetPredicate((w) => w is MapEditView);
    expect(editor, findsOneWidget);
    final before = tester.state(editor);
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();

    expect(editor, findsOneWidget);
    expect(identical(tester.state(editor), before), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a rejected editor guard keeps the draft and destination', (
    tester,
  ) async {
    final container = await pumpTools(tester);
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final host = tester.state<ToolsViewState>(find.byType(ToolsView));
    final navigator = tester.state<NavigatorState>(
      find.descendant(
        of: find.byType(ToolsView),
        matching: find.byType(Navigator),
      ),
    );
    final answer = Completer<bool>();
    unawaited(
      navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => CommonPopScope(
            onPop: (_) => answer.future,
            child: const Scaffold(body: Text('unsaved draft')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pending = host.openEntry(
      const ToolEntry(
        id: 'page.application',
        title: 'Application',
        category: ToolCategory.application,
        glyph: AppGlyphs.settings,
        route: ToolRoute(ToolPage.application),
      ),
    );
    await tester.pump();
    expect(find.text('unsaved draft'), findsOneWidget);
    expect(
      container.read(toolsSessionProvider).path.last.page,
      ToolPage.general,
    );
    answer.complete(false);
    await pending;
    await tester.pumpAndSettle();
    expect(find.text('unsaved draft'), findsOneWidget);
    expect(
      container.read(toolsSessionProvider).path.last.page,
      ToolPage.general,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text uses one column without overflowing', (tester) async {
    final container = await pumpTools(tester, size: const Size(1000, 900));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final detail = find.byType(SettingsPageScroll);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(1000, 900),
              textScaler: TextScaler.linear(2),
            ),
            child: ToolsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ToolsCatalogPanel), findsNothing);
    expect(tester.getSize(detail).width, 1000);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile Back returns to catalogue and preserves query', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(390, 844));
    final host = tester.state<ToolsViewState>(find.byType(ToolsView));
    container.read(toolsSessionProvider.notifier).search('application');
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.application));
    await tester.pumpAndSettle();
    expect(await host.handleBack(), isTrue);
    await tester.pumpAndSettle();
    expect(container.read(toolsSessionProvider).path, isEmpty);
    expect(container.read(toolsSessionProvider).query, 'application');
    expect(find.byType(SearchField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'global shortcut opens one search and cancellation preserves origin',
    (tester) async {
      final container = await pumpTools(tester);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            child: ToolsSearchLauncher(child: Scaffold(body: Text('origin'))),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byType(ToolsCatalogPanel), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(ToolsCatalogPanel), findsNothing);
      expect(find.text('origin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reveal handles offscreen rows, repeated nonce and inactive pages',
    (tester) async {
      var nonce = 0;
      var active = true;
      final spec = SettingSpec(
        id: 'test.target',
        page: ToolPage.general,
        title: (_) => 'target',
      );
      Widget view() => TestApp(
        child: Scaffold(
          body: SettingsRevealScope(
            targetId: spec.id,
            nonce: nonce,
            active: active,
            child: SettingsPageScroll(
              child: Column(
                children: [
                  const SizedBox(height: 1400),
                  SettingTarget(
                    spec: spec,
                    child: const SizedBox(height: 50, child: Text('target')),
                  ),
                  const SizedBox(height: 900),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(position.pixels, greaterThan(0));
      position.jumpTo(0);
      nonce++;
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(0));
      position.jumpTo(0);
      active = false;
      nonce++;
      await tester.pumpWidget(view());
      await tester.pumpAndSettle();
      expect(position.pixels, 0);
    },
  );
}
