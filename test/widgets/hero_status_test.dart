import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero_status.dart';
import 'package:reclash/widgets/icon.dart' show ImageCacheWidget;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

DoctorSnapshot _doctorSnapshot({
  bool supported = true,
  bool fresh = true,
  DoctorExamState state = DoctorExamState.complete,
  DoctorHealth health = DoctorHealth.healthy,
  DoctorPathKind pathKind = DoctorPathKind.unknown,
  DoctorCaptureState captureState = DoctorCaptureState.unknown,
  DoctorLayer layer = DoctorLayer.unknown,
  DoctorProgress progress = const DoctorProgress(),
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return DoctorSnapshot(
    revision: 1,
    supported: supported,
    state: state,
    health: health,
    confidence: DoctorConfidence.confirmed,
    pathKind: pathKind,
    captureState: captureState,
    layer: layer,
    progress: progress,
    freshUntil: fresh ? now + 60000 : now - 1,
  );
}

// The orb is elastic, so the core mark can only be pinned to the core it sits
// in, never to a diameter.
double _coreExtent(WidgetTester tester) =>
    tester.getSize(find.byKey(const ValueKey('orb-core'))).width;

void main() {
  group('hero health', () {
    test('withholds a verdict while nothing has been measured', () {
      expect(heroHealthOf(delay: null, measuring: false), HeroHealth.unknown);
      expect(heroHealthOf(delay: 0, measuring: false), HeroHealth.unknown);
      expect(heroHealthOf(delay: -1, measuring: true), HeroHealth.checking);
    });

    test('a live measurement becomes the checking status', () {
      expect(
        heroStatusOf(HeroOrbPhase.on, HeroHealth.checking),
        HeroStatus.diagnosing,
      );
    });

    test('treats a failed measurement as unavailable', () {
      expect(heroHealthOf(delay: -1, measuring: false), HeroHealth.unknown);
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

  group('hero doctor health', () {
    test('withholds unsupported and stale verdicts', () {
      expect(heroDoctorHealthOf(const DoctorSnapshot()), HeroHealth.unknown);
      expect(
        heroDoctorHealthOf(
          _doctorSnapshot(health: DoctorHealth.broken, fresh: false),
        ),
        HeroHealth.unknown,
      );
    });

    test('maps a fresh authoritative snapshot', () {
      expect(
        heroDoctorHealthOf(_doctorSnapshot(state: DoctorExamState.examining)),
        HeroHealth.checking,
      );
      expect(heroDoctorHealthOf(_doctorSnapshot()), HeroHealth.healthy);
      expect(
        heroDoctorHealthOf(_doctorSnapshot(health: DoctorHealth.degraded)),
        HeroHealth.degraded,
      );
      expect(
        heroDoctorHealthOf(_doctorSnapshot(health: DoctorHealth.broken)),
        HeroHealth.broken,
      );
    });

    test('does not invent a capture verdict absent from Core', () {
      expect(
        heroDoctorHealthOf(
          _doctorSnapshot(
            health: DoctorHealth.unknown,
            pathKind: DoctorPathKind.tun,
            captureState: DoctorCaptureState.inactive,
          ),
        ),
        HeroHealth.unknown,
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
        heroCoreMarkOf(HeroStatus.diagnosing, 'https://x/l.png'),
        HeroCoreMark.serviceLogo,
      );
      expect(
        heroCoreMarkOf(HeroStatus.degraded, 'https://x/l.png'),
        HeroCoreMark.serviceLogo,
      );
      expect(heroCoreMarkOf(HeroStatus.secured, null), HeroCoreMark.appMark);
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
      expect(HeroStatus.offline.isAlert, isFalse);
      expect(HeroStatus.secured.isAlert, isFalse);
      expect(HeroStatus.off.isLive, isFalse);
      expect(HeroStatus.offline.isLive, isFalse);
      expect(HeroStatus.offline.flows, isFalse);
      expect(HeroStatus.diagnosing.flows, isTrue);
      expect(HeroStatus.degraded.flows, isTrue);
      expect(HeroStatus.broken.flows, isFalse);
    });

    test('a probe is not a live tunnel', () {
      expect(HeroStatus.checking.isLive, isFalse);
      expect(HeroStatus.diagnosing.isLive, isTrue);
      expect(HeroStatus.checking.isTransitioning, isFalse);
      expect(HeroStatus.reconnecting.isLive, isTrue);
      expect(HeroStatus.reconnecting.isTransitioning, isTrue);
    });

    test('only a travelling segment sweeps', () {
      for (final status in HeroStatus.values) {
        expect(
          status.isSweeping,
          status == HeroStatus.checking ||
              status == HeroStatus.diagnosing ||
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

  group('hero transitions', () {
    test('classifies every directed topology change', () {
      const cases = <(HeroStatus, HeroStatus, HeroOrbTransition)>[
        (HeroStatus.off, HeroStatus.connecting, HeroOrbTransition.ignition),
        (HeroStatus.connecting, HeroStatus.secured, HeroOrbTransition.lockOn),
        (HeroStatus.secured, HeroStatus.off, HeroOrbTransition.shutdown),
        (HeroStatus.offline, HeroStatus.off, HeroOrbTransition.shutdown),
        (HeroStatus.secured, HeroStatus.paused, HeroOrbTransition.pause),
        (HeroStatus.paused, HeroStatus.secured, HeroOrbTransition.resume),
        (HeroStatus.secured, HeroStatus.broken, HeroOrbTransition.fault),
        (
          HeroStatus.broken,
          HeroStatus.reconnecting,
          HeroOrbTransition.recovery,
        ),
        (HeroStatus.secured, HeroStatus.offline, HeroOrbTransition.networkLoss),
        (
          HeroStatus.offline,
          HeroStatus.connecting,
          HeroOrbTransition.networkReturn,
        ),
        (
          HeroStatus.secured,
          HeroStatus.degraded,
          HeroOrbTransition.healthShift,
        ),
        (HeroStatus.off, HeroStatus.checking, HeroOrbTransition.crossfade),
      ];

      for (final (from, to, expected) in cases) {
        expect(heroOrbTransitionOf(from, to), expected, reason: '$from → $to');
      }
    });

    test('fault destination outranks the previous topology', () {
      for (final from in HeroStatus.values.where(
        (status) => status != HeroStatus.broken,
      )) {
        expect(
          heroOrbTransitionOf(from, HeroStatus.broken),
          HeroOrbTransition.fault,
          reason: '$from → ${HeroStatus.broken}',
        );
      }
    });

    test('leaves an unchanged status steady', () {
      for (final status in HeroStatus.values) {
        expect(
          heroOrbTransitionOf(status, status),
          HeroOrbTransition.steady,
          reason: '$status',
        );
      }
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

    test('a disconnected core outranks pause', () {
      expect(
        heroLifecycleOf(
          isStart: true,
          paused: true,
          coreConnecting: false,
          coreDisconnected: true,
        ),
        HeroOrbPhase.failed,
      );
    });

    test('a disconnected core cannot appear protected', () {
      expect(
        heroLifecycleOf(
          isStart: true,
          paused: false,
          coreConnecting: false,
          coreDisconnected: true,
        ),
        HeroOrbPhase.failed,
      );
      expect(
        heroStatusOf(HeroOrbPhase.failed, HeroHealth.unknown),
        HeroStatus.broken,
      );
    });

    test('provider projects the authoritative start request', () {
      final container = ProviderContainer(
        overrides: [
          isStartProvider.overrideWithValue(false),
          coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
          initProvider.overrideWithBuild((_, _) => true),
          networkReachableProvider.overrideWithBuild((_, _) => true),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(heroLifecycleProvider), HeroOrbPhase.off);
      final revision = container
          .read(runRequestStateProvider.notifier)
          .begin(true);
      expect(container.read(heroLifecycleProvider), HeroOrbPhase.connecting);
      container.read(runRequestStateProvider.notifier).finish(revision);
      expect(container.read(heroLifecycleProvider), HeroOrbPhase.off);
    });

    test('a disconnected core outranks a pending start request', () {
      final container = ProviderContainer(
        overrides: [
          isStartProvider.overrideWithValue(false),
          coreStatusProvider.overrideWithBuild(
            (_, _) => CoreStatus.disconnected,
          ),
          initProvider.overrideWithBuild((_, _) => true),
          networkReachableProvider.overrideWithBuild((_, _) => true),
        ],
      );
      addTearDown(container.dispose);

      container.read(runRequestStateProvider.notifier).begin(true);
      expect(container.read(heroLifecycleProvider), HeroOrbPhase.failed);
    });

    test('a probe only shows while the tunnel is down', () {
      expect(heroPhaseWithProbe(HeroOrbPhase.off, true), HeroOrbPhase.checking);
      expect(heroPhaseWithProbe(HeroOrbPhase.off, false), HeroOrbPhase.off);
      for (final phase in [
        HeroOrbPhase.on,
        HeroOrbPhase.paused,
        HeroOrbPhase.connecting,
        HeroOrbPhase.reconnecting,
        HeroOrbPhase.failed,
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

    testWidgets('uses the provider gradient only for normal live states', (
      tester,
    ) async {
      const providerRing = [
        Color(0xFF35B5FF),
        Color(0xFF3657FF),
        Color(0xFFA638F4),
      ];
      late HeroPalette secured;
      late HeroPalette broken;
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          child: Builder(
            builder: (context) {
              secured = heroPaletteOf(
                context,
                HeroStatus.secured,
                heroRing: providerRing,
              );
              broken = heroPaletteOf(
                context,
                HeroStatus.broken,
                heroRing: providerRing,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(secured.ring, providerRing);
      expect(secured.glow, providerRing[1]);
      expect(broken.ring, isNot(providerRing));
    });
  });

  group('HeroServiceRow', () {
    Future<void> pumpRow(
      WidgetTester tester,
      HeroStatus status, {
      DoctorSnapshot doctor = const DoctorSnapshot(),
    }) {
      return tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          wrapInProviderScope: true,
          overrides: [connectionDoctorProvider.overrideWithValue(doctor)],
          child: Builder(
            builder: (context) => Scaffold(
              body: HeroServiceRow(
                status: status,
                accent: heroPaletteOf(context, status).accent,
                easterEggRoll: 1,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('holds the routing line while Doctor has no verdict', (
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

    testWidgets('shows the rare calm status only on its winning roll', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          includeNavigatorKey: false,
          setTheme: false,
          wrapInProviderScope: true,
          overrides: [
            connectionDoctorProvider.overrideWithValue(const DoctorSnapshot()),
          ],
          child: Builder(
            builder: (context) => Scaffold(
              body: HeroServiceRow(
                status: HeroStatus.secured,
                accent: heroPaletteOf(context, HeroStatus.secured).accent,
                easterEggRoll: 0,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('The packets are unusually well-behaved today.'),
        findsOne,
      );
    });

    testWidgets('shows fresh Doctor progress and causal layer', (tester) async {
      await pumpRow(
        tester,
        HeroStatus.secured,
        doctor: _doctorSnapshot(
          state: DoctorExamState.examining,
          progress: const DoctorProgress(completed: 2, total: 5),
        ),
      );
      expect(find.text('Checking connection: 2/5'), findsOne);

      await pumpRow(
        tester,
        HeroStatus.broken,
        doctor: _doctorSnapshot(
          health: DoctorHealth.broken,
          layer: DoctorLayer.dns,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Connection issue: DNS'), findsOne);
    });

    testWidgets('lifecycle and freshness outrank Doctor takeover', (
      tester,
    ) async {
      final broken = _doctorSnapshot(
        health: DoctorHealth.broken,
        layer: DoctorLayer.dns,
      );
      await pumpRow(tester, HeroStatus.paused, doctor: broken);
      expect(find.text('Traffic is paused, protection is on hold'), findsOne);
      expect(find.text('Connection issue: DNS'), findsNothing);

      await pumpRow(
        tester,
        HeroStatus.secured,
        doctor: _doctorSnapshot(
          health: DoctorHealth.broken,
          layer: DoctorLayer.dns,
          fresh: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Smart routing is off'), findsOne);
      expect(find.text('Connection issue: DNS'), findsNothing);
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
      String? heroRing,
      String? activeText,
      DoctorSnapshot doctor = const DoctorSnapshot(),
    }) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = Profile.normal().copyWith(
        selectedMap: const {'Selector': 'Node A'},
        panelMeta: serviceLogo == null && heroRing == null && activeText == null
            ? null
            : PanelMeta(
                serviceName: 'Panel',
                serviceLogo: serviceLogo,
                heroRing: heroRing,
                activeText: activeText,
              ),
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
          connectionDoctorProvider.overrideWithValue(doctor),
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

    testWidgets('uses the provider active text for a healthy tunnel', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, activeText: 'Protected by provider');
      expect(find.text('Protected by provider'), findsOne);
      expect(find.text('You are protected'), findsNothing);
    });

    testWidgets('the flowing core shows the panel logo, not the power icon', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, serviceLogo: 'https://panel/l.png');
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
      final mark = find.byKey(const ValueKey('core-mark'));
      expect(mark, findsOne);
      final markBox = tester.widget<SizedBox>(mark);
      expect(markBox.width, closeTo(_coreExtent(tester) * 0.54, 0.01));
      expect(markBox.height, markBox.width);
      final cachedLogo = find.descendant(
        of: mark,
        matching: find.byType(ImageCacheWidget),
      );
      expect(cachedLogo, findsOne);
      expect(
        find.descendant(of: cachedLogo, matching: find.byType(ColorFiltered)),
        findsNothing,
      );
    });

    testWidgets('without a panel logo the flowing core shows the app mark', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140);
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
      final mark = find.byKey(const ValueKey('core-mark'));
      expect(mark, findsOne);
      final core = _coreExtent(tester);
      final markBox = tester.widget<SizedBox>(mark);
      expect(markBox.width, closeTo(core * 0.54, 0.01));
      expect(markBox.height, markBox.width);
      final padding = tester.widget<Padding>(
        find.descendant(of: mark, matching: find.byType(Padding)),
      );
      expect(padding.padding, EdgeInsets.all(core * 0.0216));
      expect(
        find.descendant(of: mark, matching: find.byType(ColorFiltered)),
        findsOne,
      );
    });

    testWidgets('passes the panel gradient into the orb', (tester) async {
      await pumpHero(tester, delay: 140, heroRing: '35B5FF,3657FF,A638F4');
      expect(tester.widget<HeroOrb>(find.byType(HeroOrb)).heroRing, const [
        Color(0xFF35B5FF),
        Color(0xFF3657FF),
        Color(0xFFA638F4),
      ]);
    });

    testWidgets('a paused orb keeps its action icon over any logo', (
      tester,
    ) async {
      await pumpHero(
        tester,
        delay: 140,
        paused: true,
        serviceLogo: 'https://p/l.png',
        activeText: 'Protected by provider',
      );
      expect(find.text('Paused — trusted network'), findsOne);
      expect(find.text('Protected by provider'), findsNothing);
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

    testWidgets('keeps latency informational when the node is slow', (
      tester,
    ) async {
      await pumpHero(tester, delay: 1200);
      expect(find.text('You are protected'), findsOne);
      expect(find.text('1200 ms'), findsOne);
      expect(find.text('The node is responding slowly'), findsNothing);
    });

    testWidgets('an unavailable latency measurement is not a link failure', (
      tester,
    ) async {
      await pumpHero(tester, delay: -1);
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Connection is not working'), findsNothing);
      expect(find.text('The node is not responding'), findsNothing);
    });

    testWidgets('fresh Doctor verdict controls live connectivity', (
      tester,
    ) async {
      await pumpHero(
        tester,
        doctor: _doctorSnapshot(
          health: DoctorHealth.broken,
          layer: DoctorLayer.dns,
        ),
      );
      expect(find.text('Connection is not working'), findsOne);
      expect(find.text('Stop'), findsOne);
      expect(find.text('Tap to turn protection on'), findsNothing);
      expect(find.text('Connection issue: DNS'), findsOne);

      await pumpHero(
        tester,
        doctor: _doctorSnapshot(
          health: DoctorHealth.degraded,
          layer: DoctorLayer.transport,
        ),
      );
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Connection issue: Transport'), findsOne);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('stale Doctor verdict cannot accuse a live tunnel', (
      tester,
    ) async {
      await pumpHero(
        tester,
        doctor: _doctorSnapshot(
          health: DoctorHealth.broken,
          layer: DoctorLayer.dns,
          fresh: false,
        ),
      );
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Connection is not working'), findsNothing);
      expect(find.text('Connection issue: DNS'), findsNothing);
    });

    testWidgets('a stopped tunnel outranks a fresh Doctor failure', (
      tester,
    ) async {
      await pumpHero(
        tester,
        running: false,
        doctor: _doctorSnapshot(health: DoctorHealth.broken),
      );
      expect(find.text('Not protected'), findsOne);
      expect(find.text('Connection is not working'), findsNothing);
    });

    testWidgets('pause outranks a fresh Doctor failure', (tester) async {
      await pumpHero(
        tester,
        paused: true,
        doctor: _doctorSnapshot(health: DoctorHealth.broken),
      );
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

    testWidgets('a selected-node probe does not become connectivity', (
      tester,
    ) async {
      await pumpHero(
        tester,
        pendingTests: {delayTestKey(defaultTestUrl, 'Node A')},
      );
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Checking the network…'), findsNothing);
    });

    testWidgets('a live Doctor exam becomes the checking state', (
      tester,
    ) async {
      await pumpHero(
        tester,
        doctor: _doctorSnapshot(
          state: DoctorExamState.examining,
          progress: const DoctorProgress(completed: 3, total: 8),
        ),
      );
      expect(find.text('Checking the network…'), findsOne);
    });

    testWidgets('Doctor takes over Smart Route only for actionable state', (
      tester,
    ) async {
      const routing = RcxStatus(enabled: true, node: 'Engine Node', delay: 90);
      await pumpHero(tester, rcxStatus: routing);
      expect(find.text('Connection issue: DNS'), findsNothing);

      await pumpHero(
        tester,
        rcxStatus: routing,
        doctor: _doctorSnapshot(
          health: DoctorHealth.broken,
          layer: DoctorLayer.dns,
        ),
      );
      expect(find.text('Connection issue: DNS'), findsOne);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('an unrelated live probe leaves the wording alone', (
      tester,
    ) async {
      await pumpHero(tester, delay: 140, pendingTests: const {'probe'});
      expect(find.text('You are protected'), findsOne);
      expect(find.text('Checking the network…'), findsNothing);
    });
  });
}
