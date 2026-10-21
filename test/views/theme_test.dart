import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/constant.dart';
import 'package:reclash/common/feature.dart';
import 'package:reclash/common/system_fonts.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/font_family.dart';
import 'package:reclash/views/theme.dart';
import 'package:reclash/views/wallpaper.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/views/theme_preview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 2400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpThemeView(
    WidgetTester tester, {
    bool interface = false,
    Size size = const Size(1400, 2400),
  }) async {
    container.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ThemeView()),
      ),
    );
    await tester.pumpAndSettle();
    if (interface) {
      await tester.tap(find.text('Interface'));
      await tester.pumpAndSettle();
    }
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  group('appearance tabs', () {
    Finder destination(String label) => find.descendant(
      of: find.byType(NavigationDock),
      matching: find.text(label),
    );

    Finder page(String id, {bool skipOffstage = true}) =>
        find.byKey(PageStorageKey('theme-tab-$id'), skipOffstage: skipOffstage);

    ScrollController scrollOf(WidgetTester tester, String id) => tester
        .widget<SingleChildScrollView>(page(id, skipOffstage: false))
        .controller!;

    double opacityOf(WidgetTester tester, String id) => tester
        .widget<Opacity>(
          find.ancestor(of: page(id), matching: find.byType(Opacity)).first,
        )
        .opacity;

    FocusNode focusOf(WidgetTester tester, String id) => tester
        .widget<Focus>(
          find
              .descendant(
                of: find.byWidgetPredicate(
                  (widget) => widget is SettingTarget && widget.spec.id == id,
                  skipOffstage: false,
                ),
                matching: find.byWidgetPredicate(
                  (widget) => widget is Focus && widget.focusNode != null,
                  skipOffstage: false,
                ),
              )
              .first,
        )
        .focusNode!;

    testWidgets('each category retains its own scroll and preview state', (
      tester,
    ) async {
      await pumpThemeView(tester, size: const Size(390, 844));
      final themeElement = tester.element(page('theme'));
      final themeScroll = scrollOf(tester, 'theme');
      final preview = find.byType(ThemeLivePreview);
      final themeOffset = showThemeLivePreview ? 250.0 : 30.0;
      if (showThemeLivePreview) {
        await tester.tap(
          find
              .descendant(of: preview, matching: find.byType(GestureDetector))
              .at(2),
        );
        await tester.pumpAndSettle();
      }
      themeScroll.jumpTo(themeOffset);
      await tester.pumpAndSettle();

      await tester.tap(destination('Background'));
      await tester.pumpAndSettle();
      final backgroundElement = tester.element(page('background'));
      final backgroundScroll = scrollOf(tester, 'background');
      expect(backgroundScroll.offset, 0);
      backgroundScroll.jumpTo(190);
      await tester.pumpAndSettle();

      await tester.tap(destination('Interface'));
      await tester.pumpAndSettle();
      final interfaceScroll = scrollOf(tester, 'interface');
      expect(interfaceScroll.offset, 0);
      interfaceScroll.jumpTo(320);
      await tester.pumpAndSettle();

      await tester.tap(destination('Theme'));
      await tester.pumpAndSettle();
      expect(tester.element(page('theme')), same(themeElement));
      expect(themeScroll.offset, themeOffset);
      if (showThemeLivePreview) {
        expect(
          tester
              .widget<MiniScreen>(
                find.descendant(of: preview, matching: find.byType(MiniScreen)),
              )
              .selected,
          2,
        );
      }
      await tester.tap(destination('Background'));
      await tester.pumpAndSettle();
      expect(tester.element(page('background')), same(backgroundElement));
      expect(backgroundScroll.offset, 190);
      await tester.tap(destination('Interface'));
      await tester.pumpAndSettle();
      expect(interfaceScroll.offset, 320);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the dock rises after the route has half opened and fades '
        'before it closes', (tester) async {
      await pumpThemeView(tester, size: const Size(390, 844));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(MaterialPageRoute(builder: (_) => const ThemeView())),
      );
      await tester.pump();
      double dockOpacity() => tester
          .widget<FadeTransition>(
            find
                .ancestor(
                  of: find.byType(NavigationDock).last,
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;
      final route = ModalRoute.of(
        tester.element(find.byType(NavigationDock).last),
      )!;
      await tester.pump(route.transitionDuration * 0.4);
      expect(dockOpacity(), 0);
      await tester.pumpAndSettle();
      expect(dockOpacity(), 1);
      navigator.pop();
      await tester.pump();
      await tester.pump(route.reverseTransitionDuration * 0.2);
      expect(dockOpacity(), 0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final animation in TabAnimation.values) {
      testWidgets('$animation animates category changes and keeps the dock '
          'stationary', (tester) async {
        container
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(tabAnimation: animation));
        await pumpThemeView(tester, size: const Size(390, 844));
        final dock = tester.getRect(find.byType(NavigationDock));
        await tester.tap(destination('Background'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 70));
        expect(page('theme'), findsOneWidget);
        expect(page('background'), findsOneWidget);
        expect(tester.getRect(find.byType(NavigationDock)), dock);
        if (animation == TabAnimation.fade) {
          expect(opacityOf(tester, 'theme'), inExclusiveRange(0, 1));
          expect(opacityOf(tester, 'background'), inExclusiveRange(0, 1));
        } else {
          expect(tester.getTopLeft(page('theme')).dx, lessThan(0));
          expect(
            tester.getTopLeft(page('background')).dx,
            inExclusiveRange(0, 390),
          );
        }
        await tester.pumpAndSettle();
        expect(page('theme'), findsNothing);
        expect(page('background'), findsOneWidget);
        expect(tester.getTopLeft(page('background')).dx, 0);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$animation reverses without jumping or duplicating a page', (
        tester,
      ) async {
        container
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(tabAnimation: animation));
        await pumpThemeView(tester, size: const Size(390, 844));
        final themeElement = tester.element(page('theme'));
        await tester.tap(destination('Background'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        final themePosition = tester.getTopLeft(page('theme'));
        final backgroundPosition = tester.getTopLeft(page('background'));
        final themeOpacity = animation == TabAnimation.fade
            ? opacityOf(tester, 'theme')
            : 1.0;
        final backgroundOpacity = animation == TabAnimation.fade
            ? opacityOf(tester, 'background')
            : 1.0;

        await tester.tap(destination('Theme'));
        await tester.pump();
        expect(tester.getTopLeft(page('theme')), themePosition);
        expect(tester.getTopLeft(page('background')), backgroundPosition);
        if (animation == TabAnimation.fade) {
          expect(opacityOf(tester, 'theme'), themeOpacity);
          expect(opacityOf(tester, 'background'), backgroundOpacity);
        }
        expect(page('theme', skipOffstage: false), findsOneWidget);
        expect(page('background', skipOffstage: false), findsOneWidget);
        await tester.pumpAndSettle();
        expect(page('theme'), findsOneWidget);
        expect(page('background'), findsNothing);
        expect(tester.element(page('theme')), same(themeElement));
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$animation rapid category changes honor the last selection',
        (tester) async {
          container
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(tabAnimation: animation));
          await pumpThemeView(tester, size: const Size(390, 844));
          await tester.tap(destination('Background'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          await tester.tap(destination('Interface'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 40));
          await tester.tap(destination('Theme'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 30));
          await tester.tap(destination('Interface'));
          await tester.pumpAndSettle();
          expect(page('theme'), findsNothing);
          expect(page('background'), findsNothing);
          expect(page('interface'), findsOneWidget);
          for (final id in ['theme', 'background', 'interface']) {
            expect(page(id, skipOffstage: false), findsOneWidget);
          }
          expect(
            tester
                .widget<NavigationDock>(find.byType(NavigationDock))
                .selectedIndex,
            2,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('hidden settings cannot reclaim keyboard focus', (
      tester,
    ) async {
      await pumpThemeView(tester);
      final themeFocus = focusOf(tester, 'theme.themeMode');
      themeFocus.requestFocus();
      await tester.pump();
      expect(themeFocus.hasPrimaryFocus, isTrue);
      await tester.tap(destination('Interface'));
      await tester.pumpAndSettle();
      themeFocus.requestFocus();
      await tester.pump();
      expect(themeFocus.hasPrimaryFocus, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion settles an in-progress category change', (
      tester,
    ) async {
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpThemeView(tester);
      await tester.tap(destination('Background'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(page('theme'), findsOneWidget);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      await tester.pump();
      expect(page('theme'), findsNothing);
      expect(page('background'), findsOneWidget);
      await tester.tap(destination('Interface'));
      await tester.pump();
      expect(page('background'), findsNothing);
      expect(page('interface'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search reveal follows the latest target after the category '
        'transition', (tester) async {
      final reveal = ValueNotifier<(String?, int)>((null, 0));
      addTearDown(reveal.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: ValueListenableBuilder(
              valueListenable: reveal,
              builder: (_, request, _) => SettingsRevealScope(
                targetId: request.$1,
                nonce: request.$2,
                child: const ThemeView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      reveal.value = ('theme.wallpaper.fit', 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(focusOf(tester, 'theme.wallpaper.fit').hasPrimaryFocus, isFalse);
      reveal.value = ('theme.textScale', 2);
      await tester.pumpAndSettle();
      expect(page('interface'), findsOneWidget);
      expect(focusOf(tester, 'theme.textScale').hasPrimaryFocus, isTrue);
      expect(focusOf(tester, 'theme.wallpaper.fit').hasPrimaryFocus, isFalse);
      await tester.tap(destination('Theme'));
      await tester.pumpAndSettle();
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(pureBlack: !state.pureBlack));
      await tester.pumpAndSettle();
      expect(page('theme'), findsOneWidget);
      reveal.value = ('theme.textScale', 3);
      await tester.pumpAndSettle();
      expect(page('interface'), findsOneWidget);
      expect(focusOf(tester, 'theme.textScale').hasPrimaryFocus, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposing during a category transition stops its animation', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await tester.tap(destination('Background'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reopening within a route restores its category and scroll', (
      tester,
    ) async {
      final shown = ValueNotifier(true);
      addTearDown(shown.dispose);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: ValueListenableBuilder(
              valueListenable: shown,
              builder: (_, visible, _) =>
                  visible ? const ThemeView() : const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(destination('Background'));
      await tester.pumpAndSettle();
      scrollOf(tester, 'background').jumpTo(210);
      await tester.pumpAndSettle();
      shown.value = false;
      await tester.pumpAndSettle();
      shown.value = true;
      await tester.pumpAndSettle();
      expect(page('background'), findsOneWidget);
      expect(scrollOf(tester, 'background').offset, 210);
      expect(page('theme', skipOffstage: false), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a covered theme page settles and honors a pending search '
        'when it returns', (tester) async {
      final visible = ValueNotifier(true);
      final reveal = ValueNotifier<(String?, int)>((null, 0));
      addTearDown(visible.dispose);
      addTearDown(reveal.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: ValueListenableBuilder(
              valueListenable: visible,
              builder: (_, active, _) => PageActivityScope(
                isActive: active,
                child: ValueListenableBuilder(
                  valueListenable: reveal,
                  builder: (_, request, _) => SettingsRevealScope(
                    targetId: request.$1,
                    nonce: request.$2,
                    child: const ThemeView(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(destination('Background'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      visible.value = false;
      reveal.value = ('theme.textScale', 1);
      await tester.pump();
      expect(page('theme'), findsNothing);
      expect(page('background'), findsOneWidget);
      expect(page('interface', skipOffstage: false), findsNothing);
      expect(TickerMode.of(tester.element(page('background'))), isFalse);
      visible.value = true;
      await tester.pumpAndSettle();
      expect(page('interface'), findsOneWidget);
      expect(focusOf(tester, 'theme.textScale').hasPrimaryFocus, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('slide direction follows the reading direction', (
      tester,
    ) async {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(tabAnimation: TabAnimation.slide));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ThemeView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(destination('Background'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      expect(tester.getTopLeft(page('theme')).dx, greaterThan(0));
      expect(tester.getTopLeft(page('background')).dx, lessThan(0));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(page('background')).dx, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the background library allows four images but not a fifth', (
      tester,
    ) async {
      const images = [
        '00000000000000000000000000000001.png',
        '00000000000000000000000000000002.png',
        '00000000000000000000000000000003.png',
        '00000000000000000000000000000004.png',
      ];
      final image = MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        ),
      );
      container.dispose();
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          wallpaperThumbnailProvider.overrideWith((ref, name) async => image),
          wallpaperSaveProvider.overrideWithValue(() async => true),
        ],
      );
      globalState.container = container;
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              wallpaper: WallpaperProps(library: images.take(3).toList()),
            ),
          );
      await pumpThemeView(tester);
      await tester.tap(destination('Background'));
      await tester.pumpAndSettle();
      final choose = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Choose image',
      );
      expect(tester.widget<IconButton>(choose).onPressed, isNotNull);
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith(
              wallpaper: const WallpaperProps(library: images),
            ),
          );
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(choose).onPressed, isNull);
      expect(find.text('Background 4'), findsOneWidget);
      await tester.tap(find.text('Background 4'));
      await tester.pumpAndSettle();
      expect(
        container.read(themeSettingProvider).wallpaper.fileName,
        images.last,
      );
      expect(container.read(themeSettingProvider).wallpaper.enabled, isTrue);
      await tester.tap(destination('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(destination('Background'));
      await tester.pumpAndSettle();
      expect(
        container.read(themeSettingProvider).wallpaper.fileName,
        images.last,
      );
      expect(
        find.text(
          'You can keep up to 4 backgrounds. Remove one to add another.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Keep up to three images and adjust how the background looks '
          'across the app.',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('bottom tabs preserve visited page state', (tester) async {
      await pumpThemeView(tester);
      expect(find.text('Theme').last, findsOneWidget);
      await tester.tap(find.text('Background'));
      await tester.pumpAndSettle();
      expect(find.byType(WallpaperView), findsOneWidget);
      await tester.tap(find.text('Interface'));
      await tester.pumpAndSettle();
      expect(find.text('Bottom bar'), findsOneWidget);
      await tester.tap(find.text('Theme').first);
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('wallpaper tab fits a phone-width layout', (tester) async {
      await pumpThemeView(tester, size: const Size(390, 844));
      await tester.tap(find.text('Background'));
      await tester.pumpAndSettle();

      expect(find.byType(WallpaperView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('live previews follow the window layout in every category', (
      tester,
    ) async {
      for (final size in [
        const Size(390, 844),
        const Size(1400, 2400),
        const Size(390, 844),
      ]) {
        await pumpThemeView(tester, size: size);
        for (final label in ['Theme', 'Background', 'Interface']) {
          await tester.tap(destination(label));
          await tester.pumpAndSettle();
          expect(
            find.byType(ThemeLivePreview),
            showThemeLivePreview && size.width <= maxMobileWidth
                ? findsOneWidget
                : findsNothing,
          );
          if (label != 'Background') {
            expect(find.byType(MiniScreenThumb), findsWidgets);
          }
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('search reveal selects the tab and focuses its setting', (
      tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            child: SettingsRevealScope(
              targetId: 'theme.wallpaper.fit',
              nonce: 1,
              child: ThemeView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Image fit'), findsOneWidget);
      expect(find.text('Background'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('theme mode', () {
    testWidgets('defaults to following the system', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().themeMode, ThemeMode.system);
    });

    testWidgets('switches to light and back to dark', (tester) async {
      await pumpThemeView(tester);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.light);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.dark);

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();
      expect(readTheme().themeMode, ThemeMode.system);
    });
  });

  group('primary color', () {
    Finder swatch(int color) => find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == Color(color).hex,
    );

    testWidgets('starts on blue among the system colors', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update((_) => defaultThemeProps);
      await pumpThemeView(tester);

      expect(readTheme().primaryColor, 0xFF007AFF);
      for (final color in defaultPrimaryColors) {
        expect(swatch(color), findsOneWidget);
      }
      expect(find.byTooltip('Reset'), findsNothing);
    });

    testWidgets('picks a color and the style of its scheme', (tester) async {
      await pumpThemeView(tester);

      await tester.tap(swatch(0xFFAF52DE));
      await tester.pumpAndSettle();
      expect(readTheme().primaryColor, 0xFFAF52DE);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Follow system',
        ),
      );
      await tester.pumpAndSettle();
      expect(readTheme().primaryColor, isNull);

      await tester.tap(find.text('Color style'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Soft').last);
      await tester.pumpAndSettle();
      expect(readTheme().colorStyle, ColorStyle.soft);
    });

    testWidgets('deletes a color from its context menu', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFFFF9500));
      await tester.pumpAndSettle();

      await tester.longPress(swatch(0xFFFF9500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(readTheme().primaryColors, isNot(contains(0xFFFF9500)));
      expect(readTheme().primaryColor, defaultPrimaryColor);
      expect(swatch(0xFFFF9500), findsNothing);
    });

    Future<void> editColor(WidgetTester tester, int color, String hex) async {
      await tester.longPress(swatch(color));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(HexColorField),
          matching: find.byType(TextField),
        ),
        hex,
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Confirm'));
      await tester.pumpAndSettle();
    }

    testWidgets('edits a color in place from its context menu', (tester) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFFFF9500));
      await tester.pumpAndSettle();
      final index = readTheme().primaryColors.indexOf(0xFFFF9500);

      await editColor(tester, 0xFFFF9500, '123456');

      expect(readTheme().primaryColors, isNot(contains(0xFFFF9500)));
      expect(readTheme().primaryColors[index], 0xFF123456);
      expect(readTheme().primaryColor, 0xFF123456);
      expect(swatch(0xFF123456), findsOneWidget);
    });

    testWidgets('merges a color edited into one already listed', (
      tester,
    ) async {
      await pumpThemeView(tester);
      await tester.tap(swatch(0xFF007AFF));
      await tester.pumpAndSettle();
      final count = readTheme().primaryColors.length;

      await editColor(tester, 0xFFAF52DE, '007AFF');

      expect(readTheme().primaryColors, hasLength(count - 1));
      expect(readTheme().primaryColors, isNot(contains(0xFFAF52DE)));
      expect(readTheme().primaryColor, 0xFF007AFF);
      expect(swatch(0xFF007AFF), findsOneWidget);
    });

    testWidgets('adds a custom color once and selects it', (tester) async {
      await pumpThemeView(tester);
      final count = readTheme().primaryColors.length;

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(HexColorField),
            matching: find.byType(TextField),
          ),
          '123456',
        );
        await tester.pump();
        await tester.tap(find.byTooltip('Confirm'));
        await tester.pumpAndSettle();
      }

      expect(readTheme().primaryColors, hasLength(count + 1));
      expect(readTheme().primaryColors.last, 0xFF123456);
      expect(readTheme().primaryColor, 0xFF123456);
      expect(swatch(0xFF123456), findsOneWidget);
    });

    testWidgets('keeps the custom color palette clear of the edge back '
        'swipe', (tester) async {
      const size = Size(400, 860);
      container.read(viewSizeProvider.notifier).value = size;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.systemGestureInsets = const FakeViewPadding(
        left: 30,
        right: 30,
      );
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ThemeView()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byTooltip('Add'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Add'));
      await tester.pumpAndSettle();

      final pad = tester.getRect(
        find.descendant(
          of: find.byType(Palette),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(pad.left, 30);
      expect(pad.right, size.width - 30);
    });
  });

  group('sidebar blur', () {
    testWidgets('stays hidden while the feature is off', (tester) async {
      await pumpThemeView(tester, interface: true);

      expect(find.text('Sidebar blur'), findsNothing);
    });

    testWidgets('shows a working toggle only on supported platforms', (
      tester,
    ) async {
      feature = const Feature(sidebarBlur: true);
      addTearDown(() => feature = const Feature());
      await pumpThemeView(tester, interface: true);
      final toggle = find.text('Sidebar blur');

      expect(readTheme().sidebarBlur, isTrue);
      if (!Platform.isMacOS && !Platform.isWindows) {
        expect(toggle, findsNothing);
        return;
      }

      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().sidebarBlur, isFalse);
    });
  });

  group('liquid glass', () {
    testWidgets('is off until a tier is chosen, and switches back', (
      tester,
    ) async {
      await pumpThemeView(tester, interface: true);
      final group = find.ancestor(
        of: find.text('Liquid Glass').first,
        matching: find.byType(PreviewChoiceGroup<LiquidGlassMode>),
      );
      Finder choice(String label) =>
          find.descendant(of: group, matching: find.text(label)).last;

      expect(readTheme().liquidGlass, LiquidGlassMode.none);

      await tester.tap(choice('Standard'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, LiquidGlassMode.standard);

      await tester.tap(choice('None'));
      await tester.pumpAndSettle();
      expect(readTheme().liquidGlass, LiquidGlassMode.none);
    });
  });

  group('pure black', () {
    testWidgets('switches both ways', (tester) async {
      await pumpThemeView(tester);

      expect(readTheme().pureBlack, isFalse);

      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);

      await tester.tap(find.text('Standard').first);
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isFalse);
    });
  });

  group('home navigation', () {
    AppSettingProps readSetting() => container.read(appSettingProvider);

    testWidgets('picks a floating or docked bottom bar', (tester) async {
      await pumpThemeView(tester, interface: true);

      expect(readSetting().floatingNavigationBar, isTrue);

      await tester.tap(find.text('Docked'));
      await tester.pumpAndSettle();
      expect(readSetting().floatingNavigationBar, isFalse);

      await tester.tap(find.text('Floating'));
      await tester.pumpAndSettle();
      expect(readSetting().floatingNavigationBar, isTrue);
    });

    testWidgets('overrides the automatic navigation layout', (tester) async {
      await pumpThemeView(tester, interface: true);

      expect(readSetting().navigationLayout, NavigationLayout.auto);

      await tester.tap(find.text('Sidebar'));
      await tester.pumpAndSettle();
      expect(readSetting().navigationLayout, NavigationLayout.sidebar);

      await tester.tap(find.text('Tab bar'));
      await tester.pumpAndSettle();
      expect(readSetting().navigationLayout, NavigationLayout.bar);
      expect(container.read(isMobileViewProvider), isTrue);

      await tester.tap(find.text('Auto').first);
      await tester.pumpAndSettle();
      expect(readSetting().navigationLayout, NavigationLayout.auto);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picks a sliding or fading tab switch', (tester) async {
      await pumpThemeView(tester, interface: true);

      expect(readSetting().tabAnimation, TabAnimation.fade);

      await tester.tap(find.text('Slide'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.slide);

      await tester.tap(find.text('Fade'));
      await tester.pumpAndSettle();
      expect(readSetting().tabAnimation, TabAnimation.fade);
    });

    testWidgets('the preview switches to the destination tapped', (
      tester,
    ) async {
      if (!showThemeLivePreview) return;
      await pumpThemeView(tester, interface: true, size: const Size(390, 844));
      Finder inPreview(Type type) => find.descendant(
        of: find.byType(ThemeLivePreview),
        matching: find.byType(type),
      );
      int selected() =>
          tester.widget<MiniScreen>(inPreview(MiniScreen)).selected;

      for (final destination in [2, 1]) {
        await tester.tap(inPreview(GestureDetector).at(destination));
        await tester.pumpAndSettle();
        expect(selected(), destination);
      }
    });
  });

  group('font family', () {
    setUp(() {
      final reader = systemFontFamiliesReader;
      addTearDown(() => systemFontFamiliesReader = reader);
      systemFontFamiliesReader = () async => ['Alpha Sans', 'Beta Serif'];
    });

    Finder inPage(String text) => find.descendant(
      of: find.byType(FontFamilyView),
      matching: find.text(text),
    );

    final fontsIllustration = find.descendant(
      of: find.byType(FontFamilyView),
      matching: find.byKey(const ValueKey(NullStatusIllustration.fonts)),
    );

    String? previewFamilyOf(WidgetTester tester, String text) =>
        DefaultTextStyle.of(tester.element(inPage(text))).style.fontFamily;

    Future<void> pumpSettled(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    Future<void> openFonts(WidgetTester tester) async {
      await tester.tap(find.text('Aa').first);
      await tester.pumpAndSettle();
      await pumpSettled(tester);
    }

    testWidgets('picks an installed font on its page and back to default', (
      tester,
    ) async {
      await pumpThemeView(tester, interface: true);

      expect(readTheme().fontFamily, isNull);
      expect(find.text('Default'), findsOneWidget);

      await openFonts(tester);
      expect(
        SheetProvider.of(tester.element(find.byType(FontFamilyView)))?.type,
        SheetType.sideSheet,
      );
      expect(inPage('Installed fonts'), findsOneWidget);
      expect(previewFamilyOf(tester, 'Beta Serif'), 'Beta Serif');

      await tester.tap(inPage('Beta Serif'));
      await tester.pumpAndSettle();
      expect(readTheme().fontFamily, 'Beta Serif');
      expect(find.byType(FontFamilyView), findsOneWidget);

      await tester.tap(inPage('Default'));
      await tester.pumpAndSettle();
      expect(readTheme().fontFamily, isNull);
    });

    testWidgets('lists the fonts as the sheet opens and gives the names '
        'their fonts once it has stopped', (tester) async {
      var reads = 0;
      systemFontFamiliesReader = () async {
        reads++;
        return ['Arrival Sans'];
      };
      await pumpThemeView(tester, interface: true);

      await tester.tap(find.text('Aa').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 16));
      expect(reads, 1);
      expect(fontsIllustration, findsNothing);
      expect(inPage('Arrival Sans'), findsOneWidget);
      expect(
        isRouteMoving(tester.element(find.byType(FontFamilyView))),
        isTrue,
      );
      expect(previewFamilyOf(tester, 'Arrival Sans'), isNot('Arrival Sans'));

      await pumpSettled(tester);
      expect(previewFamilyOf(tester, 'Arrival Sans'), 'Arrival Sans');
    });

    testWidgets('shows the loading illustration while the fonts take long', (
      tester,
    ) async {
      final families = Completer<List<String>>();
      systemFontFamiliesReader = () => families.future;
      await pumpThemeView(tester, interface: true);

      await tester.tap(find.text('Aa').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(fontsIllustration, findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(fontsIllustration, findsOneWidget);
      expect(inPage('Default'), findsNothing);

      families.complete(['Alpha Sans']);
      await pumpSettled(tester);
      expect(inPage('Alpha Sans'), findsOneWidget);
      expect(fontsIllustration, findsNothing);
    });

    testWidgets('previews the chosen font on its card', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(fontFamily: 'Beta Serif'));
      await pumpThemeView(tester, interface: true);

      expect(
        tester.widget<Text>(find.text('Beta Serif')).style?.fontFamily,
        'Beta Serif',
      );
      expect(
        tester.widget<Text>(find.text('Aa').first).style?.fontFamily,
        'Beta Serif',
      );
    });

    testWidgets('gives each name its own font one per frame', (tester) async {
      const families = ['Preview One', 'Preview Two', 'Preview Three'];
      var loaded = false;
      systemFontFamiliesReader = () async {
        loaded = true;
        return families;
      };
      await pumpThemeView(tester, interface: true);
      await tester.tap(find.text('Aa').first);
      for (var i = 0; i < 20 && !loaded; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(seconds: 1));

      int shown() => families
          .where(
            (family) =>
                inPage(family).evaluate().isNotEmpty &&
                previewFamilyOf(tester, family) == family,
          )
          .length;
      final counts = [shown()];
      while (counts.last < families.length && counts.length < 10) {
        await tester.pump();
        counts.add(shown());
      }

      expect(counts.first, lessThan(families.length));
      expect(counts.last, families.length);
      for (var i = 1; i < counts.length; i++) {
        expect(counts[i] - counts[i - 1], lessThanOrEqualTo(1));
      }
    });

    testWidgets('still offers the default when no font can be listed', (
      tester,
    ) async {
      systemFontFamiliesReader = () async => throw const OSError('fc', 1);
      await pumpThemeView(tester, interface: true);

      await openFonts(tester);

      expect(inPage('Default'), findsOneWidget);
      expect(inPage('Installed fonts'), findsNothing);
      expect(fontsIllustration, findsNothing);
    });
  });

  group('text scale', () {
    testWidgets('follows the system until custom is picked', (tester) async {
      await pumpThemeView(tester, interface: true);

      expect(readTheme().textScale.enable, isFalse);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isTrue);
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);

      await tester.tap(find.text('Follow system'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isFalse);
    });

    testWidgets('writes the scale only when the drag ends', (tester) async {
      await pumpThemeView(tester, interface: true);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      final before = readTheme().textScale.scale;

      final slider = find.byType(Slider);
      final gesture = await tester.startGesture(tester.getCenter(slider));
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(readTheme().textScale.scale, before);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(readTheme().textScale.scale, isNot(before));
    });

    testWidgets('resets a custom scale to 100%', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpThemeView(tester, interface: true);

      expect(find.text('120%'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset').last);
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, 1);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
