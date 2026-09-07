import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
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
    ValueChanged<HeroOrbPhase>? onPhaseChanged,
    VoidCallback? onLongPress,
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
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(
        body: Center(
          child: HeroOrb(
            enabled: enabled,
            health: health,
            variant: variant,
            onPhaseChanged: onPhaseChanged,
            onLongPress: onLongPress,
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

  testWidgets('starts optimistically and rolls back to its source phase', (
    tester,
  ) async {
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

    expect(phases, [HeroOrbPhase.connecting, HeroOrbPhase.off]);
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNotNull,
    );
  });

  testWidgets('busy and disabled orbs reject taps but keep mode selection', (
    tester,
  ) async {
    var longPresses = 0;
    final busy = await pumpOrb(
      tester,
      phase: HeroOrbPhase.connecting,
      onLongPress: () => longPresses++,
    );

    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNull,
    );
    await tester.tap(find.byType(HeroOrb));
    await tester.longPress(find.byType(HeroOrb));
    expect(busy.action.runningToggles, 0);
    expect(longPresses, 1);

    final disabled = await pumpOrb(
      tester,
      enabled: false,
      onLongPress: () => longPresses++,
    );
    expect(
      tester.widget<FocusableTap>(find.byType(FocusableTap)).onTap,
      isNull,
    );
    await tester.tap(find.byType(HeroOrb));
    await tester.longPress(find.byType(HeroOrb));
    expect(disabled.action.runningToggles, 0);
    expect(longPresses, 2);
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

  testWidgets('reduced motion leaves no active ticker', (tester) async {
    await pumpOrb(tester, phase: HeroOrbPhase.on, reducedMotion: true);

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byKey(const ValueKey('core-mark')), findsOneWidget);
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
}

class _RecordingCommonAction extends CommonAction {
  int runningToggles = 0;
  int pauseToggles = 0;

  @override
  void toggleRunning() => runningToggles++;

  @override
  void togglePaused() => pauseToggles++;
}
