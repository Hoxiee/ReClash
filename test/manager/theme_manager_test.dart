import 'dart:ui' show FrameTiming;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/theme_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('following the system picks up a font scale changed while the '
      'app runs', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    double? scaled;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ThemeManager(
            child: Builder(
              builder: (context) {
                scaled = MediaQuery.textScalerOf(context).scale(10);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(scaled, 10);

    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pump();

    expect(scaled, closeTo(13, 1e-9));
  });

  testWidgets('a theme setting the theme does not read keeps the same theme', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final themes = <ThemeData>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            ref.watch(themeSettingProvider);
            themes.add(watchAppTheme(ref, Brightness.dark));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    void update(ThemeProps Function(ThemeProps props) change) {
      final notifier = container.read(themeSettingProvider.notifier);
      notifier.value = change(notifier.value);
    }

    update((props) => props.copyWith(sidebarBlur: !props.sidebarBlur));
    await tester.pump();
    update((props) => props.copyWith(pureBlack: !props.pureBlack));
    await tester.pump();

    expect(themes, hasLength(3));
    expect(themes[1], same(themes[0]));
    expect(themes[2], isNot(same(themes[1])));
  });

  group('adaptive glass', () {
    late ProviderContainer container;
    late bool enabled;
    late LiquidGlassQuality quality;

    setUp(() {
      container = ProviderContainer();
      container.read(appVisibleProvider.notifier).value = true;
    });

    tearDown(() => container.dispose());

    void choose(LiquidGlassMode mode) {
      final settings = container.read(themeSettingProvider.notifier);
      settings.value = settings.value.copyWith(liquidGlass: mode);
    }

    Future<void> mount(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            withStatusManager: true,
            child: ThemeManager(
              child: Builder(
                builder: (context) {
                  final scope = context
                      .dependOnInheritedWidgetOfExactType<LiquidGlassScope>()!;
                  enabled = scope.enabled;
                  quality = scope.quality;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    void report(WidgetTester tester, int frames) {
      final timing = FrameTiming(
        vsyncStart: 0,
        buildStart: 0,
        buildFinish: 1000,
        rasterStart: 1000,
        rasterFinish: 21000,
        rasterFinishWallTime: 21000,
      );
      tester.binding.platformDispatcher.onReportTimings?.call(
        List.filled(frames, timing),
      );
    }

    testWidgets('steps down for this session without changing preferences', (
      tester,
    ) async {
      choose(LiquidGlassMode.ultra);
      await mount(tester);
      expect(quality, LiquidGlassQuality.ultra);

      report(tester, 179);
      await tester.pump();
      expect(quality, LiquidGlassQuality.ultra);
      report(tester, 1);
      await tester.pumpAndSettle();
      expect(enabled, isTrue);
      expect(quality, LiquidGlassQuality.standard);
      expect(
        container.read(themeSettingProvider).liquidGlass,
        LiquidGlassMode.ultra,
      );

      report(tester, 180);
      await tester.pumpAndSettle();
      expect(enabled, isFalse);
      expect(
        container.read(themeSettingProvider).liquidGlass,
        LiquidGlassMode.ultra,
      );
      expect(
        find.text(currentAppLocalizations.liquidGlassReduced),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('restore keeps the chosen quality despite later overload', (
      tester,
    ) async {
      choose(LiquidGlassMode.ultra);
      await mount(tester);
      report(tester, 180);
      await tester.pumpAndSettle();
      expect(quality, LiquidGlassQuality.standard);

      await tester.tap(find.text(currentAppLocalizations.restore));
      await tester.pumpAndSettle();
      expect(quality, LiquidGlassQuality.ultra);
      report(tester, 360);
      await tester.pumpAndSettle();
      expect(enabled, isTrue);
      expect(quality, LiquidGlassQuality.ultra);
      expect(
        container.read(themeSettingProvider).liquidGlass,
        LiquidGlassMode.ultra,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('hiding the app discards partial overload observations', (
      tester,
    ) async {
      choose(LiquidGlassMode.ultra);
      await mount(tester);
      report(tester, 90);
      container.read(appVisibleProvider.notifier).value = false;
      report(tester, 180);
      container.read(appVisibleProvider.notifier).value = true;
      report(tester, 90);
      await tester.pump();
      expect(quality, LiquidGlassQuality.ultra);
      report(tester, 90);
      await tester.pumpAndSettle();
      expect(quality, LiquidGlassQuality.standard);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'an explicit quality change resets the session cap and samples',
      (tester) async {
        choose(LiquidGlassMode.ultra);
        await mount(tester);
        report(tester, 179);
        choose(LiquidGlassMode.standard);
        await tester.pump();
        report(tester, 1);
        await tester.pump();
        expect(enabled, isTrue);
        expect(quality, LiquidGlassQuality.standard);
        report(tester, 179);
        await tester.pumpAndSettle();
        expect(enabled, isFalse);
        choose(LiquidGlassMode.ultra);
        await tester.pump();
        expect(enabled, isTrue);
        expect(quality, LiquidGlassQuality.ultra);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'disabled and disposed glass neither counts frames nor leaks state',
      (tester) async {
        choose(LiquidGlassMode.none);
        await mount(tester);
        report(tester, 180);
        choose(LiquidGlassMode.ultra);
        await tester.pump();
        report(tester, 90);
        await tester.pump();
        expect(quality, LiquidGlassQuality.ultra);
        await tester.pumpWidget(const SizedBox.shrink());
        report(tester, 360);
        expect(tester.takeException(), isNull);

        await mount(tester);
        report(tester, 90);
        await tester.pump();
        expect(quality, LiquidGlassQuality.ultra);
        report(tester, 90);
        await tester.pumpAndSettle();
        expect(quality, LiquidGlassQuality.standard);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  });
}
