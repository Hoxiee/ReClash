import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  group('hero health', () {
    test('withholds a verdict while nothing has been measured', () {
      expect(heroHealthOf(delay: null, measuring: false), HeroHealth.unknown);
      expect(heroHealthOf(delay: 0, measuring: false), HeroHealth.unknown);
      expect(heroHealthOf(delay: -1, measuring: true), HeroHealth.unknown);
    });

    test('reads a failed measurement as broken', () {
      expect(heroHealthOf(delay: -1, measuring: false), HeroHealth.broken);
    });

    test('splits healthy from degraded at the amber threshold', () {
      expect(
        heroHealthOf(delay: heroDegradedDelay - 1, measuring: false),
        HeroHealth.healthy,
      );
      expect(
        heroHealthOf(delay: heroDegradedDelay, measuring: false),
        HeroHealth.degraded,
      );
    });
  });

  group('hero core mark', () {
    test('a flowing tunnel wears the panel logo, else the app mark', () {
      expect(
        heroCoreMarkOf(HeroStatus.secured, 'https://x/l.png'),
        HeroCoreMark.serviceLogo,
      );
      expect(
        heroCoreMarkOf(HeroStatus.degraded, 'https://x/l.png'),
        HeroCoreMark.serviceLogo,
      );
      expect(
        heroCoreMarkOf(HeroStatus.secured, null),
        HeroCoreMark.appMark,
      );
      expect(heroCoreMarkOf(HeroStatus.secured, ''), HeroCoreMark.appMark);
    });

    test('every other state keeps its action icon', () {
      for (final status in [
        HeroStatus.off,
        HeroStatus.offline,
        HeroStatus.checking,
        HeroStatus.connecting,
        HeroStatus.reconnecting,
        HeroStatus.broken,
        HeroStatus.paused,
      ]) {
        expect(
          heroCoreMarkOf(status, 'https://x/l.png'),
          HeroCoreMark.statusIcon,
          reason: '$status',
        );
      }
    });
  });

  group('hero status', () {
    test('keeps an unmeasured live tunnel secured', () {
      expect(
        heroStatusOf(HeroOrbPhase.on, HeroHealth.unknown),
        HeroStatus.secured,
      );
    });

    test('lets the phase outrank the health verdict', () {
      expect(
        heroStatusOf(HeroOrbPhase.paused, HeroHealth.broken),
        HeroStatus.paused,
      );
      expect(
        heroStatusOf(HeroOrbPhase.off, HeroHealth.degraded),
        HeroStatus.off,
      );
      expect(
        heroStatusOf(HeroOrbPhase.connecting, HeroHealth.broken),
        HeroStatus.connecting,
      );
    });

    test('marks every state that must not read as calm', () {
      expect(HeroStatus.paused.isAlert, isTrue);
      expect(HeroStatus.degraded.isAlert, isTrue);
      expect(HeroStatus.broken.isAlert, isTrue);
      expect(HeroStatus.offline.isAlert, isTrue);
      expect(HeroStatus.secured.isAlert, isFalse);
      expect(HeroStatus.off.isLive, isFalse);
      expect(HeroStatus.offline.isLive, isFalse);
      expect(HeroStatus.offline.flows, isFalse);
      expect(HeroStatus.degraded.flows, isTrue);
      expect(HeroStatus.broken.flows, isFalse);
    });

    test('a probe is not a live tunnel', () {
      expect(HeroStatus.checking.isLive, isFalse);
      expect(HeroStatus.checking.isTransitioning, isFalse);
      expect(HeroStatus.reconnecting.isLive, isTrue);
      expect(HeroStatus.reconnecting.isTransitioning, isTrue);
    });

    test('only a travelling segment sweeps', () {
      for (final status in HeroStatus.values) {
        expect(
          status.isSweeping,
          status == HeroStatus.checking ||
              status == HeroStatus.connecting ||
              status == HeroStatus.reconnecting,
          reason: '$status',
        );
      }
    });

    test('ON is never the most active ring', () {
      expect(HeroStatus.secured.isSweeping, isFalse);
      expect(HeroStatus.secured.isTransitioning, isFalse);
    });

    test('offline maps and paints as its own state', () {
      expect(
        heroStatusOf(HeroOrbPhase.offline, HeroHealth.broken),
        HeroStatus.offline,
      );
      expect(HeroStatus.offline.isSweeping, isFalse);
    });
  });

  group('hero lifecycle', () {
    test('a stopped tunnel outranks everything else', () {
      expect(
        heroLifecycleOf(isStart: false, paused: true, coreConnecting: true),
        HeroOrbPhase.off,
      );
    });

    test('a core restarting under a live tunnel reads as recovery', () {
      expect(
        heroLifecycleOf(isStart: true, paused: false, coreConnecting: true),
        HeroOrbPhase.reconnecting,
      );
      expect(
        heroLifecycleOf(isStart: true, paused: false, coreConnecting: false),
        HeroOrbPhase.on,
      );
    });

    test('a pause is not a recovery', () {
      expect(
        heroLifecycleOf(isStart: true, paused: true, coreConnecting: true),
        HeroOrbPhase.paused,
      );
    });

    test('a probe only shows while the tunnel is down', () {
      expect(heroPhaseWithProbe(HeroOrbPhase.off, true), HeroOrbPhase.checking);
      expect(heroPhaseWithProbe(HeroOrbPhase.off, false), HeroOrbPhase.off);
      for (final phase in [
        HeroOrbPhase.on,
        HeroOrbPhase.paused,
        HeroOrbPhase.connecting,
        HeroOrbPhase.reconnecting,
      ]) {
        expect(heroPhaseWithProbe(phase, true), phase, reason: '$phase');
      }
    });
  });

  group('hero activity band', () {
    test('holds its band through the gap between the thresholds', () {
      expect(
        heroActivityBandOf(HeroOrbActivity.idle, 0.22),
        HeroOrbActivity.idle,
      );
      expect(
        heroActivityBandOf(HeroOrbActivity.active, 0.22),
        HeroOrbActivity.active,
      );
    });

    test('crosses on the far side of each threshold', () {
      expect(
        heroActivityBandOf(HeroOrbActivity.idle, 0.4),
        HeroOrbActivity.active,
      );
      expect(
        heroActivityBandOf(HeroOrbActivity.active, 0.1),
        HeroOrbActivity.idle,
      );
    });
  });

  group('hero activity', () {
    test('grows with throughput and stays inside the unit range', () {
      expect(heroActivityOf(null), 0);
      expect(heroActivityOf(const Traffic(up: 0, down: 0)), 0);
      final slow = heroActivityOf(const Traffic(up: 0, down: 32 * 1024));
      final fast = heroActivityOf(const Traffic(up: 0, down: 4 * 1024 * 1024));
      expect(slow, greaterThan(0));
      expect(fast, greaterThan(slow));
      expect(
        heroActivityOf(const Traffic(up: 0, down: 512 * 1024 * 1024)),
        lessThanOrEqualTo(1),
      );
    });
  });

  group('hero palette', () {
    testWidgets('gives each alert state its own accent', (tester) async {
      late Map<HeroStatus, HeroPalette> palettes;
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          child: Builder(
            builder: (context) {
              palettes = {
                for (final status in HeroStatus.values)
                  status: heroPaletteOf(context, status),
              };
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final accents = {
        for (final status in [
          HeroStatus.secured,
          HeroStatus.paused,
          HeroStatus.degraded,
          HeroStatus.broken,
        ])
          palettes[status]!.accent,
      };
      expect(accents, hasLength(4));
      // Recovery must not be mistaken for a fault that has settled.
      expect(
        palettes[HeroStatus.reconnecting]!.ring,
        isNot(palettes[HeroStatus.broken]!.ring),
      );
      expect(
        palettes[HeroStatus.checking]!.ring,
        isNot(palettes[HeroStatus.off]!.ring),
      );
      expect(palettes[HeroStatus.off]!.ring, hasLength(3));
      expect(
        palettes[HeroStatus.connecting]!.accent,
        palettes[HeroStatus.secured]!.accent,
      );
    });
  });

  group('HeroLinkRow', () {
    Future<void> pumpRow(WidgetTester tester, HeroStatus status) {
      return tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          child: Builder(
            builder: (context) => Scaffold(
              body: HeroLinkRow(
                status: status,
                accent: heroPaletteOf(context, status).accent,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('holds the routing line while nothing is wrong', (
      tester,
    ) async {
      for (final status in [
        HeroStatus.off,
        HeroStatus.connecting,
        HeroStatus.secured,
      ]) {
        await pumpRow(tester, status);
        await tester.pumpAndSettle();
        expect(find.text('Smart routing is off'), findsOne);
      }
    });

    testWidgets('names the fault for every alert state', (tester) async {
      await pumpRow(tester, HeroStatus.paused);
      expect(find.text('Traffic is paused, protection is on hold'), findsOne);

      await pumpRow(tester, HeroStatus.degraded);
      await tester.pumpAndSettle();
      expect(find.text('The node is responding slowly'), findsOne);

      await pumpRow(tester, HeroStatus.broken);
      await tester.pumpAndSettle();
      expect(find.text('The node is not responding'), findsOne);
    });
  });

  group('HeroConnect', () {
    Future<ProviderContainer> pumpHero(
      WidgetTester tester, {
      int? delay,
      bool paused = false,
      bool running = true,
      CoreStatus coreStatus = CoreStatus.connected,
      Set<String> pendingTests = const {},
      bool? reachable,
      RcxStatus? rcxStatus,
      String? serviceLogo,
    }) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = Profile.normal().copyWith(
        selectedMap: const {'Selector': 'Node A'},
        panelMeta: serviceLogo == null
            ? null
            : PanelMeta(serviceName: 'Panel', serviceLogo: serviceLogo),
      );
      const group = Group(
        name: 'Selector',
        type: GroupType.Selector,
        hidden: false,
        now: 'Node A',
        all: [Proxy(name: 'Node A', type: 'Shadowsocks')],
      );
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          groupsProvider.overrideWithValue([group]),
          pausedProvider.overrideWithValue(paused),
          delayProvider(proxyName: 'Node A').overrideWithValue(delay),
          coreStatusProvider.overrideWithBuild((_, _) => coreStatus),
          pendingDelayTestsProvider.overrideWithBuild((_, _) => pendingTests),
          if (reachable != null)
            networkReachableProvider.overrideWithBuild((_, _) => reachable),
          if (rcxStatus != null)
            smartRoutingSettingProvider.overrideWithBuild((_, _) {
              return const SmartRoutingProps(enabled: true);
            }),
          if (rcxStatus != null)
            smartRoutingStatusProvider.overrideWithBuild((_, _) => rcxStatus),
          initProvider.overrideWithBuild((_, _) => true),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container.read(runTimeProvider.notifier).value = running ? 90000 : null;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            child: Scaffold(body: HeroConnect()),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    testWidgets('reports a healthy tunnel as protected', (tester) async {
      await pumpHero(tester, delay: 140);
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Smart routing is off'), findsOne);
    });

    testWidgets('the flowing core shows the panel logo, not the power icon', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, serviceLogo: 'https://panel/l.png');
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
      final mark = find.byKey(const ValueKey('core-mark'));
      expect(mark, findsOne);
      expect(
        find.descendant(of: mark, matching: find.byType(ColorFiltered)),
        findsWidgets,
      );
    });

    testWidgets('without a panel logo the flowing core shows the app mark', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140);
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
      expect(find.byKey(const ValueKey('core-mark')), findsOne);
    });

    testWidgets('a paused orb keeps its action icon over any logo', (
      tester,
    ) async {
      await pumpHero(
        tester,
        delay: 140,
        paused: true,
        serviceLogo: 'https://p/l.png',
      );
      final orbScope = find.byType(HeroOrb);
      expect(
        find.descendant(
          of: orbScope,
          matching: find.byIcon(Icons.power_settings_new_rounded),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: orbScope,
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsOne,
      );
    });

    testWidgets('the engine node outranks the panel selector', (tester) async {
      await pumpHero(
        tester,
        delay: 140,
        rcxStatus: const RcxStatus(
          enabled: true,
          node: 'Engine Node',
          delay: 90,
        ),
      );
      expect(find.text('Engine Node'), findsOne);
      expect(find.text('Node A'), findsNothing);
      expect(find.text('90 ms'), findsOne);
    });

    testWidgets('the card falls back to the panel while deciding', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, rcxStatus: const RcxStatus());
      expect(find.text('Node A'), findsOne);
    });

    testWidgets('a missing network outranks the tunnel state', (tester) async {
      await pumpHero(tester, delay: 140, reachable: false);
      expect(find.text('No network'), findsOne);
      expect(find.text('Waiting for a connection'), findsOne);
      expect(find.text('You are protected'), findsNothing);
    });

    testWidgets('an unconfirmed network claims nothing', (tester) async {
      await pumpHero(tester, running: false);
      expect(find.text('No network'), findsNothing);
      expect(find.text('Not protected'), findsOne);
    });

    testWidgets('keeps protection wording while the node is slow', (
      tester,
    ) async {
      await pumpHero(tester, delay: 1200);
      expect(find.text('You are protected'), findsOne);
      expect(find.text('The node is responding slowly'), findsOne);
    });

    testWidgets('accuses the link only when a test actually failed', (
      tester,
    ) async {
      await pumpHero(tester, delay: -1);
      expect(find.text('Connection is not working'), findsOne);
      expect(find.text('The node is not responding'), findsOne);
    });

    testWidgets('a stale failure cannot accuse a stopped tunnel', (
      tester,
    ) async {
      await pumpHero(tester, delay: -1, running: false);
      expect(find.text('Not protected'), findsOne);
      expect(find.text('Connection is not working'), findsNothing);
    });

    testWidgets('pause outranks the delay verdict', (tester) async {
      await pumpHero(tester, delay: -1, paused: true);
      expect(find.text('Paused — trusted network'), findsOne);
      expect(find.text('Traffic is paused, protection is on hold'), findsOne);
    });

    testWidgets('a core restarting under a live tunnel reads as recovery', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, coreStatus: CoreStatus.connecting);
      expect(find.text('Reconnecting…'), findsOne);
      expect(find.text('You are protected'), findsNothing);
    });

    testWidgets('a probe on a stopped tunnel reads as a check', (tester) async {
      await pumpHero(tester, running: false, pendingTests: const {'probe'});
      expect(find.text('Checking the network…'), findsOne);
    });

    testWidgets('a probe on a live tunnel leaves the wording alone', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, pendingTests: const {'probe'});
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Checking the network…'), findsNothing);
    });
  });
}
