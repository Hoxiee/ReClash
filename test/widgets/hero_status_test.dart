import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
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
      expect(
        heroHealthOf(delay: null, measuring: false),
        HeroHealth.unknown,
      );
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
      expect(HeroStatus.secured.isAlert, isFalse);
      expect(HeroStatus.off.isLive, isFalse);
      expect(HeroStatus.degraded.flows, isTrue);
      expect(HeroStatus.broken.flows, isFalse);
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
    }) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = Profile.normal().copyWith(
        selectedMap: const {'Selector': 'Node A'},
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
      expect(
        find.text('Traffic is paused, protection is on hold'),
        findsOne,
      );
    });
  });
}
