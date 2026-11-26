import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/desktop/model.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/tools.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/tools.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';
import '../helpers/test_profiles.dart';

class _Core extends CoreHandlerInterface {
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

const _size = Size(420, 860);

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('page_swipe_tools_test');
    await useAppPaths(root);
    await File(await appPath.configFilePath).writeAsString('mode: rule\n');
    SharedPreferences.setMockInitialValues({});
    await preferences.rebind();
  });

  tearDown(() => root.delete(recursive: true));

  Future<ProviderContainer> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = _size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(_Core())),
        navigationItemsStateProvider.overrideWithValue(
          NavigationItemsState(
            value: [
              for (final label in [PageLabel.dashboard, PageLabel.proxies])
                NavigationItem(
                  glyph: AppGlyphs.dashboard,
                  label: label,
                  builder: (_) => CommonScaffold(
                    key: GlobalObjectKey(label),
                    title: label.name,
                    body: const SizedBox.expand(),
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
        scriptsProvider.overrideWith(() => TestScripts(const [])),
        globalRulesProvider.overrideWith(() => TestGlobalRules(const [])),
        iconSetsProvider.overrideWith(TestIconSets.new),
        clashProvidersProvider.overrideWith(TestClashProviders.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(profilesProvider.notifier)
        .put(const Profile(id: 1, autoUpdateDuration: Duration.zero));
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(pageSwipe: true));
    container.read(viewSizeProvider.notifier).value = _size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: HomePage()),
      ),
    );
    await tester.pump();
    container.read(currentPageLabelProvider.notifier).toPage(PageLabel.tools);
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> fling(WidgetTester tester, double dx) async {
    await tester.flingFrom(const Offset(210, 420), Offset(dx, 0), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('a Tools page takes swipes, its catalog turns the app page', (
    tester,
  ) async {
    final container = await pumpHome(tester);
    PageLabel shown() => container.read(currentPageLabelProvider);
    List<ToolRoute> path() => container.read(toolsSessionProvider).path;

    await tester.tap(find.widgetWithText(ListItem<dynamic>, 'General').first);
    await tester.pumpAndSettle();
    expect(path(), [const ToolRoute(ToolPage.general)]);

    await fling(tester, -200);
    expect(shown(), PageLabel.tools);
    expect(path(), [const ToolRoute(ToolPage.general)]);

    await fling(tester, 200);
    expect(shown(), PageLabel.tools);
    expect(path(), isEmpty);

    await fling(tester, 200);
    expect(shown(), PageLabel.proxies);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a swipe back follows the finger on a Tools page', (
    tester,
  ) async {
    final container = await pumpHome(tester);

    await tester.tap(find.widgetWithText(ListItem<dynamic>, 'General').first);
    await tester.pumpAndSettle();
    final route = ModalRoute.of(
      tester.element(find.byType(SettingsRevealScope)),
    )!;

    final gesture = await tester.startGesture(const Offset(120, 420));
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(route.animation!.value, lessThan(0.95));
    expect(container.read(toolsSessionProvider).path, isNotEmpty);
    expect(container.read(currentPageLabelProvider), PageLabel.tools);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(container.read(toolsSessionProvider).path, isNotEmpty);
    expect(container.read(currentPageLabelProvider), PageLabel.tools);
  });

  testWidgets('a swipe back on a Tools page still sliding in goes back', (
    tester,
  ) async {
    final container = await pumpHome(tester);

    await tester.tap(find.widgetWithText(ListItem<dynamic>, 'General').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await fling(tester, 200);

    expect(container.read(currentPageLabelProvider), PageLabel.tools);
    expect(container.read(toolsSessionProvider).path, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
