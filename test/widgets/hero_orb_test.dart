import 'package:flutter/foundation.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/seasonal_overlay.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<({ProviderContainer container, _RecordingCommonAction action})>
  pumpOrb(
    WidgetTester tester, {
    HeroOrbPhase phase = HeroOrbPhase.off,
    bool enabled = true,
    bool reducedMotion = false,
    HeroHealth health = HeroHealth.unknown,
    HeroOrbVariant variant = HeroOrbVariant.vpn,
    bool subscriptionExpired = false,
    ValueChanged<HeroOrbPhase>? onPhaseChanged,
    GlobalKey? mediaKey,
  }) async {
    final container = ProviderContainer(
      overrides: [
        heroLifecycleProvider.overrideWithValue(phase),
        isStartProvider.overrideWithValue(
          phase != HeroOrbPhase.off && phase != HeroOrbPhase.offline,
        ),
        commonActionProvider.overrideWith(_RecordingCommonAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    final child = MediaQuery(
      key: mediaKey,
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(
        body: Center(
          child: HeroOrb(
            enabled: enabled,
            health: health,
            variant: variant,
            subscriptionExpired: subscriptionExpired,
            onPhaseChanged: onPhaseChanged,
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(includeNavigatorKey: false, child: child),
      ),
    );
    await tester.pump();
    return (
      container: container,
      action:
          container.read(commonActionProvider.notifier)
              as _RecordingCommonAction,
    );
  }

  testWidgets('new year keeps snow without adding an orb decoration', (
    tester,
  ) async {
    final result = await pumpOrb(
      tester,
      phase: HeroOrbPhase.on,
      health: HeroHealth.healthy,
      reducedMotion: true,
    );
    result.container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(developerMode: true, reduceMotion: true),
        );
    final preview = result.container.read(findingPreviewProvider.notifier);
    preview.setSeason(SeasonalMotif.drift);
    await tester.pumpAndSettle();
    final paints = find.descendant(
      of: find.byType(HeroOrb),
      matching: find.byType(CustomPaint),
    );
    final count = paints.evaluate().length;

    preview.setSeason(SeasonalMotif.newYear);
    await tester.pumpAndSettle();
    expect(paints, findsNWidgets(count));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: result.container,
        child: const TestApp(
          child: SeasonalDashboardOverlay(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final snow = find.descendant(
      of: find.byType(SeasonalDashboardOverlay),
      matching: find.byType(CustomPaint),
    );
    expect(snow, findsOneWidget);
    preview.setSeason(SeasonalMotif.drift);
    await tester.pumpAndSettle();
    expect(snow, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('meridian unlock and preview leave the orb unchanged', (
    tester,
  ) async {
    final result = await pumpOrb(
      tester,
      phase: HeroOrbPhase.on,
      health: HeroHealth.healthy,
      reducedMotion: true,
    );
    List<Type?> paintLayers() => tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(HeroOrb),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((paint) => paint.painter?.runtimeType)
        .toList();

    await tester.pumpAndSettle();
    final initial = paintLayers();
    expect(initial, isNotEmpty);
    result.container
        .read(milestoneSettingProvider.notifier)
        .update((state) => state.copyWith(unlocked: {'meridian'}));
    await tester.pumpAndSettle();
    expect(paintLayers(), initial);
    expect(find.text('IS'), findsNothing);

    result.container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: true));
    result.container
        .read(findingPreviewProvider.notifier)
        .showFinding('meridian');
    await tester.pumpAndSettle();
    expect(paintLayers(), initial);
    expect(find.text('IS'), findsNothing);
    expect(result.action.runningToggles, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two-finger finding never toggles the connection', (
    tester,
  ) async {
    final result = await pumpOrb(tester, phase: HeroOrbPhase.on);
    final center = tester.getCenter(find.byType(HeroOrb));
    final first = await tester.startGesture(
      center - const Offset(20, 0),
      pointer: 1,
    );
    final second = await tester.startGesture(
      center + const Offset(20, 0),
      pointer: 2,
    );
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.byKey(const ValueKey('hero-oscilloscope')), findsOneWidget);
    await first.up();
    await second.up();
    await tester.pump();
    expect(result.action.runningToggles, 0);
    expect(
      result.container.read(milestoneSettingProvider).unlocked,
      contains('oscilloscope'),
    );
    await tester.pump(const Duration(seconds: 7));
    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    expect(result.action.runningToggles, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'starts optimistically and stays pending for the real operation',
    (tester) async {
      final phases = <HeroOrbPhase>[];
      final result = await pumpOrb(tester, onPhaseChanged: phases.add);

      await tester.tap(find.byType(HeroOrb));
      await tester.pump();

      expect(result.action.runningToggles, 1);
      expect(phases, [HeroOrbPhase.connecting]);
      expect(
        tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
        isNull,
      );

      await tester.pump(const Duration(seconds: 15));

      expect(phases, [HeroOrbPhase.connecting]);
      expect(
        tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
        isNull,
      );
    },
  );

  testWidgets('provider success keeps connecting visible for one transition', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(tester, onPhaseChanged: phases.add);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    result.container.updateOverrides([
      heroLifecycleProvider.overrideWithValue(HeroOrbPhase.on),
      isStartProvider.overrideWithValue(true),
      commonActionProvider.overrideWith(_RecordingCommonAction.new),
    ]);
    await tester.pump();

    expect(phases, [HeroOrbPhase.connecting]);
    expect(find.byKey(const ValueKey('core-mark')), findsNothing);

    await tester.pump(const Duration(milliseconds: 619));
    expect(phases, [HeroOrbPhase.connecting]);
    await tester.pump(const Duration(milliseconds: 1));
    expect(phases, [HeroOrbPhase.connecting, HeroOrbPhase.on]);
    expect(find.byKey(const ValueKey('core-mark')), findsOneWidget);
  });

  testWidgets('provider failure bypasses the connecting hold', (tester) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(tester, onPhaseChanged: phases.add);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    result.container.updateOverrides([
      heroLifecycleProvider.overrideWithValue(HeroOrbPhase.failed),
      isStartProvider.overrideWithValue(true),
      commonActionProvider.overrideWith(_RecordingCommonAction.new),
    ]);
    await tester.pump();

    expect(phases, [HeroOrbPhase.connecting, HeroOrbPhase.failed]);
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNotNull,
    );
  });

  testWidgets('provider offline bypasses the connecting hold', (tester) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(tester, onPhaseChanged: phases.add);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    result.container.updateOverrides([
      heroLifecycleProvider.overrideWithValue(HeroOrbPhase.offline),
      isStartProvider.overrideWithValue(true),
      commonActionProvider.overrideWith(_RecordingCommonAction.new),
    ]);
    await tester.pump();

    expect(phases, [HeroOrbPhase.connecting, HeroOrbPhase.offline]);
  });

  testWidgets('busy and disabled orbs reject taps', (tester) async {
    final busy = await pumpOrb(tester, phase: HeroOrbPhase.connecting);

    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNull,
    );
    await tester.tap(find.byType(HeroOrb));
    expect(busy.action.runningToggles, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    busy.container.dispose();
    await tester.pump();

    final disabled = await pumpOrb(tester, enabled: false);
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNull,
    );
    await tester.tap(find.byType(HeroOrb));
    expect(disabled.action.runningToggles, 0);
  });

  testWidgets('the orb has no long-press action', (tester) async {
    await pumpOrb(tester);

    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onLongPress,
      isNull,
    );
  });

  testWidgets('live checking still stops the running tunnel', (tester) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(
      tester,
      phase: HeroOrbPhase.on,
      health: HeroHealth.checking,
      onPhaseChanged: phases.add,
    );

    await tester.tap(find.byType(HeroOrb));

    expect(result.action.runningToggles, 1);
    expect(phases, [HeroOrbPhase.off]);
  });

  testWidgets('an expired subscription gives a live orb its own mark', (
    tester,
  ) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on, subscriptionExpired: true);

    expect(find.byIcon(Icons.event_busy_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('core-mark')), findsNothing);
  });

  testWidgets('paused orb delegates resume without changing lifecycle itself', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(
      tester,
      phase: HeroOrbPhase.paused,
      onPhaseChanged: phases.add,
    );

    await tester.tap(find.byType(HeroOrb));

    expect(result.action.pauseToggles, 1);
    expect(result.action.runningToggles, 0);
    expect(phases, isEmpty);
  });

  testWidgets('a mid-flight retarget cancels the pending timeout', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    final result = await pumpOrb(tester, onPhaseChanged: phases.add);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    expect(phases.last, HeroOrbPhase.connecting);

    // A second lifecycle update arrives before the timeout can fire.
    result.container.updateOverrides([
      heroLifecycleProvider.overrideWithValue(HeroOrbPhase.on),
      isStartProvider.overrideWithValue(true),
      commonActionProvider.overrideWith(_RecordingCommonAction.new),
    ]);
    await tester.pump(const Duration(milliseconds: 620));
    expect(phases.last, HeroOrbPhase.on);

    await tester.pump(const Duration(seconds: 16));
    expect(phases.last, HeroOrbPhase.on);
    // Taps work again: no stale connecting hold.
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNotNull,
    );
  });

  testWidgets('a pending start has no arbitrary timeout rollback', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    await pumpOrb(tester, onPhaseChanged: phases.add);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump(const Duration(seconds: 30));

    expect(phases, [HeroOrbPhase.connecting]);
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNull,
    );
  });

  testWidgets('reduced motion leaves no active ticker', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on, reducedMotion: true);

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byKey(const ValueKey('core-mark')), findsOneWidget);
  });

  testWidgets('reduced motion keeps pending start authoritative', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    await pumpOrb(
      tester,
      phase: HeroOrbPhase.off,
      reducedMotion: true,
      onPhaseChanged: phases.add,
    );

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();

    expect(phases, [HeroOrbPhase.connecting]);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('enabling reduced motion releases a deferred success', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    final mediaKey = GlobalKey();
    final result = await pumpOrb(
      tester,
      onPhaseChanged: phases.add,
      mediaKey: mediaKey,
    );

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    result.container.updateOverrides([
      heroLifecycleProvider.overrideWithValue(HeroOrbPhase.on),
      isStartProvider.overrideWithValue(true),
      commonActionProvider.overrideWith(_RecordingCommonAction.new),
    ]);
    await tester.pump();
    expect(phases, [HeroOrbPhase.connecting]);

    final media = tester.widget<MediaQuery>(find.byKey(mediaKey));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: result.container,
        child: TestApp(
          includeNavigatorKey: false,
          child: MediaQuery(
            key: mediaKey,
            data: media.data.copyWith(disableAnimations: true),
            child: Scaffold(
              body: Center(child: HeroOrb(onPhaseChanged: phases.add)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(phases, [HeroOrbPhase.connecting, HeroOrbPhase.on]);
  });

  testWidgets('variant changes its core without changing lifecycle', (
    tester,
  ) async {
    final phases = <HeroOrbPhase>[];
    final first = await pumpOrb(
      tester,
      phase: HeroOrbPhase.on,
      onPhaseChanged: phases.add,
    );
    expect(find.byKey(const ValueKey('core-mark')), findsOneWidget);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: first.container,
        child: TestApp(
          includeNavigatorKey: false,
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: HeroOrb(
                  variant: HeroOrbVariant.byedpi,
                  onPhaseChanged: phases.add,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('byedpi-core-mark')), findsOneWidget);
    expect(phases, isEmpty);
  });
  testWidgets('a deliberate hold detonates the nova', (tester) async {
    final result = await pumpOrb(tester, phase: HeroOrbPhase.on);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(HeroOrb.novaKey), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(result.action.runningToggles, 0);

    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(HeroOrb.novaKey), findsNothing);

    await tester.tap(find.byType(HeroOrb));
    await tester.pump();
    expect(result.action.runningToggles, 1);
  });

  testWidgets('a desktop release never toggles the tunnel', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final result = await pumpOrb(tester, phase: HeroOrbPhase.on);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(HeroOrb)),
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2400));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 120));
      await gesture.up();
      await tester.pump();

      expect(result.action.runningToggles, 0);
      await tester.pump(const Duration(seconds: 3));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a hold shorter than the charge leaves the tap alone', (
    tester,
  ) async {
    final result = await pumpOrb(tester, phase: HeroOrbPhase.on);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1200));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(HeroOrb.novaKey), findsNothing);
    expect(result.action.runningToggles, 1);
  });

  testWidgets('a hold that turns into a drag arms nothing', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 400));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byKey(HeroOrb.novaKey), findsNothing);
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the wind-up gathers before the blast', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byKey(HeroOrb.chargeKey), findsOneWidget);
    expect(find.byKey(HeroOrb.novaKey), findsNothing);

    await gesture.up();
    // The reverse ticker only stamps its start on the first tick.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(HeroOrb.chargeKey), findsNothing);
  });

  testWidgets('the blast throws the orb off its rest position', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on);
    // The recoil rides inside the orb's own box, so only a descendant of the
    // transform moves; the orb's layout footprint never does.
    final body = find.byType(FocusableTap);
    final rest = tester.getCenter(body);
    final gesture = await tester.startGesture(rest);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2400));
    // The nova ticker stamps its start on this tick, so the kick only shows
    // up on the one after it.
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 200));
    expect((tester.getCenter(body) - rest).distance, greaterThan(1.0));

    await gesture.up();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect((tester.getCenter(body) - rest).distance, lessThan(0.5));
  });

  testWidgets('the landing beat lands after the blast', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(HeroOrb.novaKey), findsOneWidget);

    // 0.74 of 2800ms, so the orb is still mid-egg when the second hit fires.
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.byKey(HeroOrb.novaKey), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.byKey(HeroOrb.novaKey), findsNothing);
    expect(find.byKey(HeroOrb.chargeKey), findsNothing);
  });

  testWidgets('reduced motion never arms the nova', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on, reducedMotion: true);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroOrb)),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(HeroOrb.novaKey), findsNothing);

    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
  });
}

class _RecordingCommonAction extends CommonAction {
  int runningToggles = 0;
  int pauseToggles = 0;

  @override
  void toggleRunning() => runningToggles++;

  @override
  void togglePaused() => pauseToggles++;
}
