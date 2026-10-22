import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:code_forge/code_forge.dart';
import 'package:flutter/rendering.dart';

import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/features/connection/tracker_info_list.dart';
import 'package:reclash/pages/editor.dart';
import 'package:reclash/views/tools/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/features/url_scheme/inspect.dart';
import 'package:reclash/views/url_scheme.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/ui/icons/icons.dart';

import 'package:reclash/views/config/user_agents.dart';
import 'package:reclash/views/tools/catalog.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/tools.dart';
import 'package:reclash/views/region.dart';
import 'package:reclash/views/tools/global_search.dart';
import 'package:reclash/views/tools/search.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/wallpaper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';
import '../plugins/code_forge/support.dart' show initEditorNative, settle;

class _WorkspaceCore extends CoreHandlerInterface {
  @override
  Future<CoreLifecycleResult> start() async => const CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  @override
  Future<CoreLifecycleResult> restart() => start();

  @override
  Future<CoreLifecycleResult> stop() => start();

  @override
  Future<CoreLifecycleResult> close() => start();

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async => null;
}

class _WorkspaceBackdrop extends StatelessWidget {
  const _WorkspaceBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => PageBackgroundScope(
    cardOpacity: 0.4,
    route: ModalRoute.of(context),
    child: ColoredBox(color: const Color(0xff2060a0), child: child),
  );
}

Future<Color> _pixelAt(
  WidgetTester tester,
  Finder boundary,
  Offset position,
) async {
  return (await tester.runAsync(() async {
    final render = tester.renderObject<RenderRepaintBoundary>(boundary);
    final image = await render.toImage();
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final offset =
        (position.dy.toInt() * image.width + position.dx.toInt()) * 4;
    final color = Color.fromARGB(
      bytes.getUint8(offset + 3),
      bytes.getUint8(offset),
      bytes.getUint8(offset + 1),
      bytes.getUint8(offset + 2),
    );
    image.dispose();
    return color;
  }))!;
}

void main() {
  late Directory root;

  setUpAll(initEditorNative);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('tools_workspace_test');
    await useAppPaths(root);
    await File(await appPath.configFilePath).writeAsString('mode: rule\n');
    SharedPreferences.setMockInitialValues({});
    await preferences.rebind();
  });

  tearDown(() async {
    await root.delete(recursive: true);
  });

  Future<ProviderContainer> pumpTools(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    bool home = false,
    bool wallpaper = false,
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(_WorkspaceCore()),
        ),
        if (wallpaper)
          effectiveWallpaperImageProvider.overrideWithValue(
            MemoryImage(
              base64Decode(
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
              ),
            ),
          ),
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
        detectedRegionProvider.overrideWith((ref) async => null),
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
    }
    container.read(viewSizeProvider.notifier).value = size;
    final app = TestApp(
      theme: theme,
      homeBuilder: (child) => wallpaper
          ? PageBackgroundRegistration(
              builder: (_, _, content) => _WorkspaceBackdrop(child: content),
              child: child,
            )
          : child,
      child: home ? const HomePage() : const ToolsView(),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: wallpaper
            ? RepaintBoundary(
                key: const ValueKey('workspace-render'),
                child: app,
              )
            : app,
      ),
    );
    await tester.pump();
    return container;
  }

  for (final brightness in Brightness.values) {
    testWidgets('native window blur preserves the sidebar backdrop in '
        '$brightness', (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      );
      final container = await pumpTools(tester, home: true, theme: theme);
      container.read(windowBlurProvider.notifier).value = true;
      const boundaryKey = ValueKey('native-shell-render');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: boundaryKey,
            child: TestApp(
              theme: theme,
              homeBuilder: (child) => AppWallpaperScope(child: child),
              child: const AppSidebarContainer(
                child: SizedBox.expand(key: ValueKey('native-shell-content')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final sidebarFinder = find.byType(NavigationSidebar);
      final sidebar = tester.getRect(sidebarFinder);
      final sample = Offset(sidebar.left + 2, sidebar.bottom - 100);
      final boundary = find.byKey(boundaryKey);
      final colorScheme = tester.element(sidebarFinder).colorScheme;
      final expected = colorScheme.chromeSurface.withValues(
        alpha: kSidebarBlurOpacity,
      );
      final actual = await _pixelAt(tester, boundary, sample);
      expect(actual.a, closeTo(expected.a, 1 / 255));
      expect(actual.r, closeTo(expected.r * actual.a, 1 / 255));
      expect(actual.g, closeTo(expected.g * actual.a, 1 / 255));
      expect(actual.b, closeTo(expected.b * actual.a, 1 / 255));
      final body = tester.getRect(
        find.byKey(const ValueKey('native-shell-content')),
      );
      expect(
        await _pixelAt(
          tester,
          boundary,
          Offset(body.right - 2, body.bottom - 100),
        ),
        SurfaceLevel.page.colorOf(colorScheme),
      );
      final sidebarState = tester.state(sidebarFinder);
      container.read(windowBlurProvider.notifier).value = false;
      await tester.pumpAndSettle();
      expect(
        await _pixelAt(tester, boundary, sample),
        colorScheme.chromeSurface,
      );
      expect(tester.state(sidebarFinder), same(sidebarState));
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(390, 844), const Size(1800, 1000)]) {
    testWidgets('Tools shares one wallpaper across its routes at $size', (
      tester,
    ) async {
      final container = await pumpTools(
        tester,
        size: size,
        home: true,
        wallpaper: true,
      );
      container.read(currentPageLabelProvider.notifier).value = PageLabel.tools;
      await tester.pumpAndSettle();
      expect(find.byType(_WorkspaceBackdrop), findsOneWidget);
      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.general));
      await tester.pumpAndSettle();
      expect(find.byType(_WorkspaceBackdrop), findsOneWidget);
      expect(
        PageBackgroundScope.opacityOf(
          tester.element(find.byType(SettingsPageScroll)),
        ),
        0.4,
      );
      final header = find.descendant(
        of: find.byType(SettingsPageScroll).first,
        matching: find.byType(AppBar),
      );
      expect(header, findsNothing);
      final boundary = find.byKey(const ValueKey('workspace-render'));
      final body = tester.getRect(find.byType(SettingsPageScroll));
      final background = await _pixelAt(
        tester,
        boundary,
        Offset(body.right - 1, body.bottom - 100),
      );
      expect(background, const Color(0xff2060a0));
      final detailContext = tester.element(find.byType(SettingsPageScroll));
      unawaited(
        Navigator.of(detailContext).push(
          MaterialPageRoute<void>(
            builder: (_) => const CommonScaffold(
              title: 'Editor overlay',
              body: Text('editor overlay content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(_WorkspaceBackdrop), findsNWidgets(2));
      expect(find.text('Editor overlay'), findsOneWidget);
      expect(
        find.text('General'),
        size.width >= 960 ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
        'Tools header stays fixed through replacement at $size in $brightness',
        (tester) async {
          final container = await pumpTools(
            tester,
            size: size,
            wallpaper: true,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: brightness,
              ),
            ),
          );
          container
              .read(toolsSessionProvider.notifier)
              .open(const ToolRoute(ToolPage.general));
          await tester.pumpAndSettle();
          final header = find.descendant(
            of: find.byType(CommonScaffold).last,
            matching: find.byType(FloatingHeader),
          );
          final rect = tester.getRect(header);
          final boundary = find.byKey(const ValueKey('workspace-render'));
          final sample = Offset(rect.right - 2, rect.top + 1);
          final before = await _pixelAt(tester, boundary, sample);
          container
              .read(toolsSessionProvider.notifier)
              .open(const ToolRoute(ToolPage.application));
          await tester.pump();
          for (var frame = 0; frame < 30; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
            final headers = find.descendant(
              of: find.byType(CommonScaffold).last,
              matching: find.byType(FloatingHeader),
            );
            expect(tester.getRect(headers), rect);
            expect(await _pixelAt(tester, boundary, sample), before);
            expect(find.text('Recently used'), findsNothing);
          }
          expect(find.byType(_WorkspaceBackdrop), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('Tools header stays fixed on pop at $size in $brightness', (
        tester,
      ) async {
        final container = await pumpTools(
          tester,
          size: size,
          wallpaper: true,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: brightness,
            ),
          ),
        );
        container
            .read(toolsSessionProvider.notifier)
            .open(const ToolRoute(ToolPage.general));
        await tester.pumpAndSettle();
        container
            .read(toolsSessionProvider.notifier)
            .open(const ToolRoute(ToolPage.application), push: true);
        await tester.pumpAndSettle();
        final header = find.descendant(
          of: find.byType(CommonScaffold).last,
          matching: find.byType(FloatingHeader),
        );
        final rect = tester.getRect(header);
        final boundary = find.byKey(const ValueKey('workspace-render'));
        final sample = Offset(rect.right - 2, rect.top + 1);
        final before = await _pixelAt(tester, boundary, sample);
        final host = tester.state<ToolsViewState>(find.byType(ToolsView));
        await host.handleBack();
        await tester.pump();
        for (var frame = 0; frame < 20; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          final header = find.descendant(
            of: find.byType(SettingsPageScroll),
            matching: find.byType(AppBar),
          );
          expect(header, findsNothing);
          expect(await _pixelAt(tester, boundary, sample), before);
        }
        expect(
          container.read(toolsSessionProvider).path.last.page,
          ToolPage.general,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final animation in TabAnimation.values) {
    testWidgets('Home keeps its header fixed during $animation tab motion', (
      tester,
    ) async {
      final container = await pumpTools(
        tester,
        size: const Size(390, 844),
        home: true,
        wallpaper: true,
      );
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(tabAnimation: animation));
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(FloatingHeader));
      final boundary = find.byKey(const ValueKey('workspace-render'));
      final sample = Offset(rect.right - 2, rect.top + 1);
      final before = await _pixelAt(tester, boundary, sample);
      container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
      await tester.pump();
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(FloatingHeader), findsOneWidget);
        expect(tester.getRect(find.byType(FloatingHeader)), rect);
        expect(await _pixelAt(tester, boundary, sample), before);
      }
      expect(find.byType(_WorkspaceBackdrop), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'a Tools side sheet dims the shell without taking its navigation',
    (tester) async {
      final container = await pumpTools(
        tester,
        size: const Size(1800, 1000),
        home: true,
        wallpaper: true,
      );
      container.read(currentPageLabelProvider.notifier).value = PageLabel.tools;
      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.general, settingId: 'general.hosts'));
      await tester.pumpAndSettle();
      final sidebar = tester.getRect(find.byType(NavigationSidebar));
      final sample = Offset(sidebar.left + 2, sidebar.bottom - 100);
      final boundary = find.byKey(const ValueKey('workspace-render'));
      final before = await _pixelAt(tester, boundary, sample);
      await tester.tap(find.text('Hosts').last);
      await tester.pumpAndSettle();
      final editor = find.byWidgetPredicate((widget) => widget is MapEditView);
      expect(editor, findsOneWidget);
      expect(await _pixelAt(tester, boundary, sample), isNot(before));
      final sheet = tester.getRect(find.byType(SideSheet));
      expect(sheet.left, greaterThan(sidebar.right));
      container
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.dashboard);
      await tester.pumpAndSettle();
      expect(editor, findsNothing);
      expect(await _pixelAt(tester, boundary, sample), before);
      container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
      await tester.pumpAndSettle();
      expect(editor, findsOneWidget);
      expect(await _pixelAt(tester, boundary, sample), isNot(before));
      final host = tester.state<ToolsViewState>(find.byType(ToolsView));
      await host.handleBack();
      await tester.pumpAndSettle();
      expect(editor, findsNothing);
      expect(await _pixelAt(tester, boundary, sample), before);
      expect(
        container.read(toolsSessionProvider).path.last.page,
        ToolPage.general,
      );
      expect(tester.takeException(), isNull);
    },
  );

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

  for (final floating in [true, false]) {
    testWidgets(
      'mobile navigation follows Tools depth with floating=$floating',
      (tester) async {
        final container = await pumpTools(
          tester,
          size: const Size(390, 844),
          home: true,
        );
        container
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(floatingNavigationBar: floating));
        container.read(currentPageLabelProvider.notifier).value =
            PageLabel.tools;
        await tester.pumpAndSettle();
        final navigation = find.byType(
          floating ? FloatingNavigationBar : NavigationBar,
        );
        expect(navigation, findsOneWidget);
        await tester.tap(find.text('General').first);
        await tester.pumpAndSettle();
        expect(navigation, findsNothing);
        final detail = find.byType(SettingsPageScroll);
        expect(BottomInsetScope.of(tester.element(detail)), 0);
        final host = tester.state<ToolsViewState>(find.byType(ToolsView));
        await host.openEntry(
          const ToolEntry(
            id: 'page.application',
            title: 'Application',
            category: ToolCategory.application,
            glyph: AppGlyphs.settings,
            route: ToolRoute(ToolPage.application),
          ),
        );
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(navigation, findsNothing);
        }
        container.read(currentPageLabelProvider.notifier).value =
            PageLabel.dashboard;
        await tester.pumpAndSettle();
        expect(navigation, findsOneWidget);
        container.read(currentPageLabelProvider.notifier).value =
            PageLabel.tools;
        await tester.pumpAndSettle();
        expect(navigation, findsNothing);
        await host.handleBack();
        await tester.pumpAndSettle();
        expect(navigation, findsOneWidget);
        expect(container.read(toolsSessionProvider).path, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mobile keyboard hides navigation with floating=$floating', (
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
      container.read(currentPageLabelProvider.notifier).value = PageLabel.tools;
      await tester.pumpAndSettle();
      final navigation = find.byType(
        floating ? FloatingNavigationBar : NavigationBar,
      );
      await tester.tap(find.byType(TextField).first);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(navigation, findsNothing);
      expect(container.read(toolsSessionProvider).path, isEmpty);
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();
      expect(navigation, findsOneWidget);
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

  testWidgets('desktop hotkey commands stay inside the Tools workspace', (
    tester,
  ) async {
    final container = await pumpTools(tester);
    container
        .read(hotKeyPlatformProvider.notifier)
        .value = const HotkeyPlatformState(
      systemSupported: false,
      applicationId: 'com.reclash',
      exportDirectory: '/tmp/reclash-hotkeys',
    );
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.hotkey));
    await tester.pumpAndSettle();

    final commands = find.widgetWithText(
      DecorationListItem,
      currentAppLocalizations.hotkeyDesktopCommands,
    );
    await tester.ensureVisible(commands);
    await tester.pumpAndSettle();
    await tester.tap(commands);
    await tester.pumpAndSettle();

    expect(container.read(toolsSessionProvider).path, [
      const ToolRoute(ToolPage.hotkey),
      const ToolRoute(ToolPage.hotkeyDesktop),
    ]);
    expect(find.byType(ToolsView), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.hotkeyCompositorConfig),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(390, 844), const Size(1800, 1000)]) {
    testWidgets('URL scheme remains in Tools with back navigation at $size', (
      tester,
    ) async {
      final container = await pumpTools(tester, size: size, home: true);
      container.read(currentPageLabelProvider.notifier).value = PageLabel.tools;
      await tester.pumpAndSettle();
      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.urlScheme));
      await tester.pumpAndSettle();
      expect(find.byType(UrlSchemeView), findsOneWidget);
      expect(container.read(shownPageLabelProvider), PageLabel.tools);
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.urlScheme),
      ]);
      expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
      await tester.tap(
        find.byTooltip(currentAppLocalizations.urlSchemeInspect),
      );
      await tester.pumpAndSettle();
      expect(find.byType(UrlSchemeInspector), findsOneWidget);
      expect(globalState.navigatorKey.currentState!.canPop(), isFalse);
      final tools = tester.state<ToolsViewState>(find.byType(ToolsView));
      expect(await tools.handleBack(), isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(UrlSchemeInspector), findsNothing);
      expect(find.byType(UrlSchemeView), findsOneWidget);
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.urlScheme),
      ]);
      expect(await tools.handleBack(), isTrue);
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path, isEmpty);
      expect(find.byType(UrlSchemeView), findsNothing);
      expect(container.read(shownPageLabelProvider), PageLabel.tools);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

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

  for (final size in [
    const Size(390, 844),
    const Size(1200, 900),
    const Size(1800, 1000),
  ]) {
    testWidgets('Core and recent rows match the settings gutters at $size', (
      tester,
    ) async {
      final container = await pumpTools(tester, size: size);
      final host = tester.state<ToolsViewState>(find.byType(ToolsView));
      await host.openEntry(
        const ToolEntry(
          id: 'page.general',
          title: 'General',
          category: ToolCategory.application,
          glyph: AppGlyphs.settings,
          route: ToolRoute(ToolPage.general),
        ),
      );
      await tester.pumpAndSettle();
      final settings = tester.getRect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SettingTarget && widget.spec.id == 'general.port',
        ),
      );
      expect(
        settings.width,
        lessThan(tester.getSize(find.byType(SettingsPageScroll)).width),
      );

      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.coreDetails));
      await tester.pumpAndSettle();
      final coreRow = find
          .descendant(
            of: find.byType(CoreDetailView),
            matching: find.byType(DecorationListItem),
          )
          .first;
      final core = tester.getRect(coreRow);
      expect(core.left, closeTo(settings.left, 0.5));
      expect(core.right, closeTo(settings.right, 0.5));

      await host.handleBack();
      await tester.pumpAndSettle();
      final recent = find.byKey(const ValueKey('tools-recent-page.general'));
      if (size.width >= 960) {
        final landing = tester.getRect(recent);
        expect(landing.left, closeTo(settings.left, 0.5));
        expect(landing.right, closeTo(settings.right, 0.5));
      } else {
        expect(recent, findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(390, 844), const Size(1800, 1000)]) {
    testWidgets('section replacements never expose recent tools at $size', (
      tester,
    ) async {
      final container = await pumpTools(tester, size: size);
      final host = tester.state<ToolsViewState>(find.byType(ToolsView));
      ToolEntry entry(ToolPage page, String title) => ToolEntry(
        id: 'page.${page.name}',
        title: title,
        category: ToolCategory.application,
        glyph: AppGlyphs.settings,
        route: ToolRoute(page),
      );
      final general = entry(ToolPage.general, 'General');
      final application = entry(ToolPage.application, 'Application');
      final core = entry(ToolPage.coreDetails, 'Core');
      await host.openEntry(general);
      await tester.pumpAndSettle();

      for (final next in [application, general, core, application]) {
        await host.openEntry(next);
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            find.text('Recently used', skipOffstage: false),
            findsNothing,
            reason: 'section ${next.id}, frame $frame',
          );
          expect(tester.takeException(), isNull);
        }
        expect(container.read(toolsSessionProvider).path, [next.route]);
      }
      await host.handleBack();
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path, isEmpty);
      expect(
        find.text('Recently used'),
        size.width >= 960 ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('returning to a removed section keeps the latest Tools path', (
    tester,
  ) async {
    final container = await pumpTools(tester);
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final host = tester.state<ToolsViewState>(find.byType(ToolsView));
    ToolEntry entry(ToolPage page) => ToolEntry(
      id: 'page.${page.name}',
      title: page.name,
      category: ToolCategory.application,
      glyph: AppGlyphs.settings,
      route: ToolRoute(page),
    );
    await host.openEntry(entry(ToolPage.application));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    await host.openEntry(entry(ToolPage.general));
    await tester.pumpAndSettle();
    expect(container.read(toolsSessionProvider).path, [
      const ToolRoute(ToolPage.general),
    ]);
    expect(find.byType(SettingsPageScroll), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a nested sheet keeps its own header inside Tools', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general, settingId: 'general.hosts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hosts').last);
    await tester.pumpAndSettle();
    final sheet = find.byWidgetPredicate((widget) => widget is MapEditView);
    final header = find.descendant(of: sheet, matching: find.byType(AppBar));
    expect(
      find.descendant(of: header, matching: find.text('Hosts')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: header, matching: find.text('Tools')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('all Tools pages keep one path header and fill their pane', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final paneWidth = tester.getSize(find.byType(SettingsPageScroll)).width;
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(openLogs: true));
    for (final (page, title) in [
      (ToolPage.coreDetails, 'Core'),
      (ToolPage.coreRuntimeConfig, 'Runtime configuration'),
      (ToolPage.requests, 'Requests'),
      (ToolPage.connections, 'Connections'),
      (ToolPage.dnsQueries, 'DNS queries'),
      (ToolPage.logs, 'Logs'),
    ]) {
      container.read(toolsSessionProvider.notifier).open(ToolRoute(page));
      if (page == ToolPage.coreRuntimeConfig) {
        await settle(tester, 12);
      } else {
        await tester.pumpAndSettle();
      }
      final titleRow = find.byType(AppBar);
      expect(
        find.widgetWithText(TextButton, 'Tools'),
        findsNothing,
        reason: page.name,
      );
      if (page == ToolPage.coreRuntimeConfig) {
        expect(
          find.descendant(of: titleRow, matching: find.text('Core')),
          findsOneWidget,
        );
        final editor = find.byType(EditorView);
        final controller = tester
            .widget<CodeForge>(find.byType(CodeForge))
            .controller;
        expect(controller.text, 'mode: rule\n');
        expect(tester.getSize(editor).width, greaterThan(paneWidth));
        expect(tester.getSize(editor).height, greaterThan(600));
      } else if (page == ToolPage.coreDetails) {
        final body = find.descendant(
          of: find.byType(CoreDetailView),
          matching: find.byType(ListView),
        );
        expect(tester.getSize(body).width, closeTo(paneWidth, 0.5));
      }
      expect(
        find.descendant(of: titleRow, matching: find.text(title)),
        findsOneWidget,
        reason: page.name,
      );
      expect(tester.takeException(), isNull);
    }
    container.read(toolsSessionProvider.notifier).popTo(0);
    await tester.pumpAndSettle();
    final landing = find.widgetWithText(CommonScaffold, 'Recently used');
    expect(landing, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short request lists use the same Tools body width as settings', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1800, 1000));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();
    final width = tester.getSize(find.byType(SettingsPageScroll)).width;
    container
        .read(requestsProvider.notifier)
        .addRequest(
          TrackerInfo(
            id: 'workspace-request',
            start: DateTime.utc(2026),
            metadata: Metadata(host: 'example.test', network: 'tcp'),
            chains: const ['Proxy'],
            rule: 'DOMAIN',
            rulePayload: 'example.test',
          ),
        );
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.requests));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(TrackerInfoList)).width,
      closeTo(width, 0.5),
    );
    expect(find.textContaining('example.test'), findsWidgets);
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

  for (final size in [const Size(1800, 1000), const Size(390, 844)]) {
    testWidgets('regional settings share workspace width and back at $size', (
      tester,
    ) async {
      final container = await pumpTools(tester, size: size);
      container
          .read(toolsSessionProvider.notifier)
          .open(const ToolRoute(ToolPage.application));
      await tester.pumpAndSettle();
      final applicationRect = tester.getRect(find.byType(SettingsPageScroll));
      final initialRegion = container.read(appSettingProvider).regionCode;
      final target = find.byWidgetPredicate(
        (widget) =>
            widget is SettingTarget && widget.spec.id == 'application.region',
      );
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path.map((r) => r.page), [
        ToolPage.application,
        ToolPage.appRegion,
      ]);
      final regionScroll = find.descendant(
        of: find.byType(RegionView),
        matching: find.byType(SettingsPageScroll),
      );
      final regionRect = tester.getRect(regionScroll);
      expect(regionRect.width, closeTo(applicationRect.width, 0.5));
      expect(regionRect.center.dx, closeTo(applicationRect.center.dx, 0.5));
      if (size.width >= 960) {
        expect(regionRect.width, lessThanOrEqualTo(840));
      }
      await tester.tap(find.text('Choose a country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iran').last);
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).regionCode, initialRegion);
      final back = find.byTooltip('Back');
      await tester.ensureVisible(back);
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.application),
      ]);
      expect(container.read(appSettingProvider).regionCode, initialRegion);
      await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iran').last);
      await tester.pumpAndSettle();
      final apply = find.byTooltip('Apply region');
      await tester.ensureVisible(apply);
      await tester.tap(apply);
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).regionCode, 'IR');
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.application),
      ]);
      expect(tester.takeException(), isNull);
    });
  }

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
    await tester.ensureVisible(find.text('User-Agent').last);
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

  testWidgets('mobile catalogue starts below the app bar and status inset', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 40);
    addTearDown(tester.view.resetPadding);
    await pumpTools(tester, size: const Size(420, 860));

    final bar = tester.getRect(find.byType(AppBar));
    expect(tester.getTopLeft(find.byType(SearchField)).dy, bar.bottom);
  });

  testWidgets(
    'mobile page grows out of its row and drags back to the catalogue',
    (tester) async {
      final container = await pumpTools(tester, size: const Size(420, 860));
      final row = find.widgetWithText(ListItem<dynamic>, 'General').first;
      final rowRect = tester.getRect(row);

      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final growing = tester.getRect(find.byType(SettingsPageScroll));
      expect(growing.top, greaterThan(0));
      expect(growing.top, lessThan(rowRect.top));
      expect(find.text('Tools'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Tools'), findsNothing);
      expect(container.read(toolsSessionProvider).path, [
        const ToolRoute(ToolPage.general),
      ]);
      expect(find.byType(SearchField), findsNothing);

      final gesture = await tester.startGesture(const Offset(10, 400));
      for (var step = 0; step < 6; step++) {
        await gesture.moveBy(const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.text('Tools'), findsNothing);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Tools'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(container.read(toolsSessionProvider).path, isEmpty);
      expect(find.byType(SearchField), findsOneWidget);
    },
  );

  testWidgets('mobile Back shrinks the page into its row', (tester) async {
    await pumpTools(tester, size: const Size(420, 860));
    final row = find.widgetWithText(ListItem<dynamic>, 'General').first;
    final rowRect = tester.getRect(row);
    await tester.tap(row);
    await tester.pumpAndSettle();

    final host = tester.state<ToolsViewState>(find.byType(ToolsView));
    await host.handleBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final shrinking = tester.getRect(find.byType(SettingsPageScroll));
    expect(shrinking.top, greaterThan(0));
    expect(shrinking.top, lessThan(rowRect.top));
    expect(find.text('Tools'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(SearchField), findsOneWidget);
  });

  testWidgets('desktop Tools routes do not pop on a horizontal drag', (
    tester,
  ) async {
    final container = await pumpTools(tester, size: const Size(1200, 900));
    container
        .read(toolsSessionProvider.notifier)
        .open(const ToolRoute(ToolPage.general));
    await tester.pumpAndSettle();

    final title = find.text('General').last;
    final start = tester.getCenter(title);
    await tester.dragFrom(start, const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(container.read(toolsSessionProvider).path, [
      const ToolRoute(ToolPage.general),
    ]);
    expect(find.byType(ToolsView), findsOneWidget);
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
