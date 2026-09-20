import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/appearance/appearance.dart';
import 'package:reclash/views/appearance/color_sections.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    // The key-driven visibility handler does not survive the test framework's
    // between-test teardown, so drive the seam directly: a keyboard highlight
    // is what makes the ring eligible to show.
    FocusHighlightVisibility.visibleForTesting = true;
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 1400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpAppearanceView(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          homeBuilder: (child) => MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: child,
          ),
          child: const AppearanceView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder tabBar() => find.byType(CommonTabBar<int>);

  Finder focusRing() => find
      .descendant(
        of: find.descendant(
          of: tabBar(),
          matching: find.byType(FocusableActionDetector),
        ),
        matching: find.byType(Container),
      )
      .first;

  BorderSide focusRingBorder(WidgetTester tester) =>
      ((tester.widget<Container>(focusRing()).foregroundDecoration
                      as ShapeDecoration)
                  .shape
              as RoundedSuperellipseBorder)
          .side;

  Future<void> focusTabBar(WidgetTester tester) async {
    for (
      var i = 0;
      i < 10 &&
          FocusManager.instance.primaryFocus?.context
                  ?.findAncestorWidgetOfExactType<CommonTabBar<int>>() ==
              null;
      i++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<CommonTabBar<int>>(),
      isNotNull,
    );
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    // Every segment renders its label twice, once per selection style.
    await tester.tap(
      find.descendant(of: tabBar(), matching: find.text(label)).first,
    );
    await tester.pumpAndSettle();
  }

  Finder switchOf(String title) {
    final item = find.ancestor(
      of: find.text(title),
      matching: find.byType(DecorationListItem),
    );
    return find.descendant(of: item, matching: find.byType(Switch)).first;
  }

  ThemeProps readTheme() => container.read(themeSettingProvider);

  testWidgets('every tab renders on a phone-sized view', (tester) async {
    container.read(viewSizeProvider.notifier).value = const Size(360, 800);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: AppearanceView()),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Background', 'Other', 'Theme']) {
      await openTab(tester, label);
      expect(tester.takeException(), isNull, reason: label);
    }
    expect(find.text('Show sidebar labels'), findsNothing);
  });

  testWidgets('arrow keys move between tabs', (tester) async {
    await pumpAppearanceView(tester);
    await focusTabBar(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard style'), findsNothing);
    expect(find.text('Choose image'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard style'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard style'), findsNothing);
    expect(find.text('Choose image'), findsOneWidget);
  });

  testWidgets('the focus ring color snaps under reduced motion', (
    tester,
  ) async {
    await pumpAppearanceView(tester, disableAnimations: true);
    expect(
      focusRingBorder(tester).color,
      Colors.transparent,
      reason: 'transparent while unfocused',
    );

    // Key events flip the highlight mode to traditional, so the ring only
    // becomes primary once a keyboard interaction has happened.
    await focusTabBar(tester);

    expect(
      focusRingBorder(tester).color,
      Theme.of(tester.element(focusRing())).colorScheme.primary,
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  group('app icon', () {
    Future<void> pumpIconSections(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
    }) async {
      tester.view.physicalSize = const Size(360, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            locale: locale,
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [AppearanceColorSections(isAndroid: true)],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(locale.languageCode == 'ru' ? 'По умолчанию' : 'Default'),
        300,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('all app icons are always available', (tester) async {
      await pumpIconSections(tester);

      expect(find.text('Vigil'), findsOneWidget);
      expect(find.text('Topo'), findsOneWidget);
      expect(find.text('Spark'), findsOneWidget);
      expect(find.text('Fractal'), findsOneWidget);
    });

    testWidgets('cancels installation without changing the selected icon', (
      tester,
    ) async {
      await pumpIconSections(tester);

      await tester.tap(find.text('Velvet'));
      await tester.pumpAndSettle();

      expect(find.text('Icon preview'), findsOneWidget);
      expect(container.read(appSettingProvider).iconVariant, 'default');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Icon preview'), findsNothing);
      expect(container.read(appSettingProvider).iconVariant, 'default');
    });

    testWidgets('installs the icon only after confirmation', (tester) async {
      await pumpIconSections(tester);

      await tester.tap(find.text('Echo'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).iconVariant, 'default');

      await tester.tap(find.text('Install'));
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).iconVariant, 'echo');
    });

    testWidgets('keeps Russian icon cards aligned without overflow', (
      tester,
    ) async {
      await pumpIconSections(tester, locale: const Locale('ru'));

      expect(tester.takeException(), isNull);
      final cards = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 112,
      );
      expect(cards, findsNWidgets(12));
      for (var index = 0; index < 12; index++) {
        expect(tester.getSize(cards.at(index)).height, 112);
      }
    });
  });

  group('theme mode', () {
    testWidgets('defaults to the dark theme', (tester) async {
      await pumpAppearanceView(tester);

      expect(readTheme().themeMode, ThemeMode.dark);
    });

    testWidgets('switches to light and back to dark', (tester) async {
      await pumpAppearanceView(tester);

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

  group('schedule', () {
    testWidgets('enabling it writes the default window', (tester) async {
      await pumpAppearanceView(tester);

      expect(readTheme().scheduledTheme, isFalse);
      expect(find.text('Dark at'), findsNothing);

      await tester.tap(switchOf('Scheduled'));
      await tester.pumpAndSettle();

      expect(readTheme().scheduledTheme, isTrue);
      expect(readTheme().darkAt, '22:00');
      expect(readTheme().lightAt, '07:00');
      expect(find.text('Dark at'), findsOneWidget);
      expect(find.text('Light at'), findsOneWidget);
    });
  });

  group('contrast', () {
    bool resetVisible(WidgetTester tester) {
      final visibility = tester.widget<Visibility>(
        find.ancestor(
          of: find.byIcon(Icons.replay),
          matching: find.byType(Visibility),
        ),
      );
      return visibility.visible;
    }

    testWidgets('resets back to the neutral level', (tester) async {
      await pumpAppearanceView(tester);

      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(resetVisible(tester), isFalse);

      container
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(contrastLevel: 0.5));
      await tester.pumpAndSettle();
      expect(find.text('+50%'), findsOneWidget);
      expect(resetVisible(tester), isTrue);

      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();

      expect(readTheme().contrastLevel, 0);
      expect(resetVisible(tester), isFalse);
    });
  });

  group('pure black', () {
    testWidgets('toggles both ways', (tester) async {
      await pumpAppearanceView(tester);
      final toggle = switchOf('Pure black mode');

      expect(readTheme().pureBlack, isFalse);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isTrue);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(readTheme().pureBlack, isFalse);
    });
  });

  group('dashboard style', () {
    testWidgets('selecting the new dashboard writes the setting', (
      tester,
    ) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');

      expect(container.read(appSettingProvider).newDashboard, isTrue);

      await tester.tap(find.text('Classic'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).newDashboard, isFalse);

      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(container.read(appSettingProvider).newDashboard, isTrue);
    });
  });

  group('text scale', () {
    testWidgets('hides the slider until its toggle is enabled', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');

      expect(readTheme().textScale.enable, isFalse);
      expect(find.byType(Slider), findsNothing);

      await tester.tap(switchOf('Text scaling'));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.enable, isTrue);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('the slider writes a new scale once enabled', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');
      await tester.tap(switchOf('Text scaling'));
      await tester.pumpAndSettle();
      final before = readTheme().textScale.scale;

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(120, 0));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, isNot(before));
    });

    testWidgets('renders the scale as a rounded percentage', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');

      expect(find.text('120%'), findsOneWidget);
    });

    testWidgets('resets back to the default scale', (tester) async {
      container
          .read(themeSettingProvider.notifier)
          .update(
            (state) => state.copyWith.textScale(enable: true, scale: 1.2),
          );

      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pumpAndSettle();

      expect(readTheme().textScale.scale, 1);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('motion', () {
    testWidgets('reduce motion is left to the user', (tester) async {
      await pumpAppearanceView(tester);
      await openTab(tester, 'Other');

      expect(container.read(appSettingProvider).reduceMotion, isFalse);

      await tester.tap(switchOf('Reduce motion'));
      await tester.pumpAndSettle();

      expect(container.read(appSettingProvider).reduceMotion, isTrue);
    });
  });
}
