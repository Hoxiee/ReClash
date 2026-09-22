import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/focusable_tap.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_routing.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

RcxStatus statusOf({
  String reason = 'hold',
  bool searching = false,
  String terrain = 'normal',
}) {
  return RcxStatus(reason: reason, searching: searching, terrain: terrain);
}

DoctorSnapshot doctorOf({
  bool supported = true,
  bool fresh = true,
  DoctorExamState state = DoctorExamState.complete,
  DoctorHealth health = DoctorHealth.broken,
  DoctorLayer layer = DoctorLayer.dns,
  DoctorProgress progress = const DoctorProgress(),
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return DoctorSnapshot(
    revision: 1,
    supported: supported,
    state: state,
    health: health,
    confidence: DoctorConfidence.confirmed,
    layer: layer,
    progress: progress,
    freshUntil: fresh ? now + 60000 : now - 1,
  );
}

HeroServiceLine lineOf(
  HeroStatus status, {
  bool doctorAlerts = false,
  bool routingEnabled = true,
  Mode mode = Mode.rule,
  RcxStatus? routingStatus,
}) {
  return heroServiceLineOf(
    status: status,
    doctorAlerts: doctorAlerts,
    routingEnabled: routingEnabled,
    mode: mode,
    routingStatus: routingStatus,
  );
}

void main() {
  group('heroServiceLineOf', () {
    test('a pause outranks every other voice', () {
      expect(
        lineOf(
          HeroStatus.paused,
          doctorAlerts: true,
          routingStatus: statusOf(reason: 'no-candidate'),
        ),
        HeroServiceLine.paused,
      );
    });

    test('the doctor only speaks about a tunnel that exists', () {
      expect(
        lineOf(HeroStatus.secured, doctorAlerts: true),
        HeroServiceLine.doctor,
      );
      for (final status in [
        HeroStatus.off,
        HeroStatus.offline,
        HeroStatus.checking,
      ]) {
        expect(
          lineOf(status, doctorAlerts: true),
          isNot(HeroServiceLine.doctor),
        );
      }
    });

    test('an enabled engine never reports itself off', () {
      for (final status in HeroStatus.values) {
        expect(lineOf(status), isNot(HeroServiceLine.idle));
      }
    });

    test('a down tunnel leaves the engine waiting, not stopped', () {
      expect(lineOf(HeroStatus.off), HeroServiceLine.routingWaitingTunnel);
      expect(lineOf(HeroStatus.checking), HeroServiceLine.routingWaitingTunnel);
      expect(lineOf(HeroStatus.offline), HeroServiceLine.routingWaitingNetwork);
      for (final status in [HeroStatus.connecting, HeroStatus.reconnecting]) {
        expect(lineOf(status), HeroServiceLine.routingSearching);
      }
    });

    test('a status outliving its run cannot claim a live terrain', () {
      for (final status in [HeroStatus.off, HeroStatus.broken]) {
        expect(
          lineOf(status, routingStatus: statusOf(terrain: 'whitelist')),
          isNot(HeroServiceLine.routingRestricted),
        );
      }
    });

    test('a disabled engine hands the line back to the tunnel', () {
      expect(
        lineOf(HeroStatus.secured, routingEnabled: false),
        HeroServiceLine.idle,
      );
      expect(
        lineOf(HeroStatus.broken, routingEnabled: false),
        HeroServiceLine.linkBroken,
      );
      expect(
        lineOf(HeroStatus.degraded, routingEnabled: false),
        HeroServiceLine.linkSlow,
      );
    });

    test('only rule mode exposes the engine, whatever the lifecycle', () {
      for (final mode in [Mode.global, Mode.direct]) {
        for (final status in [HeroStatus.off, HeroStatus.secured]) {
          expect(
            lineOf(status, mode: mode, routingStatus: statusOf()),
            HeroServiceLine.routingRuleOnly,
          );
        }
      }
    });

    test('dead-incumbent reasons outrank the terrain view', () {
      expect(
        lineOf(
          HeroStatus.secured,
          routingStatus: statusOf(reason: 'no-candidate', terrain: 'whitelist'),
        ),
        HeroServiceLine.routingNoServers,
      );
      for (final reason in ['stranded', 'incumbent-dead']) {
        expect(
          lineOf(
            HeroStatus.secured,
            routingStatus: statusOf(reason: reason, terrain: 'portal'),
          ),
          HeroServiceLine.routingRetrying,
        );
      }
    });

    test('a probing engine is searching whatever it last published', () {
      expect(
        lineOf(
          HeroStatus.secured,
          routingStatus: statusOf(searching: true, terrain: 'whitelist'),
        ),
        HeroServiceLine.routingSearching,
      );
    });

    test('terrain names the restricted networks', () {
      expect(
        lineOf(HeroStatus.secured, routingStatus: statusOf(terrain: 'portal')),
        HeroServiceLine.routingPortal,
      );
      expect(
        lineOf(
          HeroStatus.secured,
          routingStatus: statusOf(terrain: 'whitelist'),
        ),
        HeroServiceLine.routingRestricted,
      );
      expect(
        lineOf(HeroStatus.secured, routingStatus: statusOf(terrain: 'unknown')),
        HeroServiceLine.routingOn,
      );
    });

    test('a routing fault explains a slow tunnel better than the tunnel', () {
      expect(
        lineOf(
          HeroStatus.degraded,
          routingStatus: statusOf(reason: 'stranded'),
        ),
        HeroServiceLine.routingRetrying,
      );
      expect(
        lineOf(HeroStatus.degraded, routingStatus: statusOf(terrain: 'portal')),
        HeroServiceLine.routingPortal,
      );
      expect(
        lineOf(HeroStatus.degraded, routingStatus: statusOf()),
        HeroServiceLine.linkSlow,
      );
    });
  });

  group('HeroServiceRow', () {
    Future<void> pumpRow(
      WidgetTester tester, {
      HeroStatus status = HeroStatus.secured,
      SmartRoutingProps props = const SmartRoutingProps(enabled: true),
      Mode mode = Mode.rule,
      RcxStatus? routingStatus,
      DoctorSnapshot doctor = const DoctorSnapshot(),
      bool reducedMotion = false,
    }) {
      final container = ProviderContainer(
        overrides: [
          smartRoutingSettingProvider.overrideWithValue(props),
          patchClashConfigProvider.overrideWithValue(
            PatchClashConfig(mode: mode),
          ),
          smartRoutingStatusProvider.overrideWithValue(routingStatus),
          connectionDoctorProvider.overrideWithValue(doctor),
        ],
      );
      addTearDown(container.dispose);
      final row = TestApp(
        includeNavigatorKey: false,
        setTheme: false,
        child: Scaffold(
          body: HeroServiceRow(
            status: status,
            accent: const Color(0xFF000000),
            easterEggRoll: 1,
          ),
        ),
      );
      return tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: reducedMotion
              ? MediaQuery(
                  data: const MediaQueryData(disableAnimations: true),
                  child: row,
                )
              : row,
        ),
      );
    }

    testWidgets('renders every state line from its own status', (tester) async {
      final expectations = <RcxStatus?, String>{
        null: 'Picking a server…',
        statusOf(searching: true): 'Picking a server…',
        statusOf(reason: 'no-candidate'): 'No reachable servers',
        statusOf(reason: 'stranded'):
            'Server is not answering, looking for another',
        statusOf(terrain: 'portal'): 'Wi-Fi sign-in required',
        statusOf(terrain: 'whitelist'):
            'Restricted network · local services stay direct',
        statusOf(): 'Smart routing is on',
      };
      for (final entry in expectations.entries) {
        await pumpRow(tester, routingStatus: entry.key);
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOne);
      }
    });

    testWidgets('an enabled engine says what it waits for', (tester) async {
      await pumpRow(tester, status: HeroStatus.off, routingStatus: statusOf());
      await tester.pumpAndSettle();
      expect(
        find.text('Smart routing is on · waiting for the tunnel'),
        findsOne,
      );

      await pumpRow(
        tester,
        status: HeroStatus.offline,
        routingStatus: statusOf(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Smart routing is waiting for a network'), findsOne);
    });

    testWidgets('a stopped core reads as a dead link, not a dead node', (
      tester,
    ) async {
      await pumpRow(
        tester,
        status: HeroStatus.broken,
        props: const SmartRoutingProps(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Connection is not working'), findsOne);
    });

    testWidgets('every line keeps the row at one height', (tester) async {
      final heights = <double>{};
      Future<void> measure({
        HeroStatus status = HeroStatus.secured,
        SmartRoutingProps props = const SmartRoutingProps(enabled: true),
        Mode mode = Mode.rule,
        RcxStatus? routingStatus,
        DoctorSnapshot doctor = const DoctorSnapshot(),
      }) async {
        await pumpRow(
          tester,
          status: status,
          props: props,
          mode: mode,
          routingStatus: routingStatus,
          doctor: doctor,
        );
        await tester.pumpAndSettle();
        heights.add(tester.getSize(find.byType(HeroServiceRow)).height);
      }

      await measure(doctor: doctorOf(state: DoctorExamState.examining));
      await measure(doctor: doctorOf());
      await measure(status: HeroStatus.paused);
      await measure(
        status: HeroStatus.degraded,
        routingStatus: statusOf(),
        props: const SmartRoutingProps(),
      );
      await measure(
        status: HeroStatus.broken,
        props: const SmartRoutingProps(),
      );
      await measure(mode: Mode.global);
      await measure(status: HeroStatus.off);
      await measure(status: HeroStatus.offline);
      await measure(status: HeroStatus.connecting);
      await measure(routingStatus: statusOf());
      await measure(routingStatus: statusOf(terrain: 'whitelist'));
      await measure(routingStatus: statusOf(terrain: 'portal'));
      await measure(routingStatus: statusOf(reason: 'stranded'));
      await measure(routingStatus: statusOf(reason: 'no-candidate'));
      await measure(props: const SmartRoutingProps());

      expect(heights, hasLength(1));
    });

    testWidgets('the row keeps its focus box even when nothing opens', (
      tester,
    ) async {
      await pumpRow(tester, status: HeroStatus.paused);
      await tester.pumpAndSettle();
      expect(find.text('Traffic is paused, protection is on hold'), findsOne);
      expect(find.byType(FocusableTap), findsOne);
    });

    testWidgets('reduced motion settles instantly with no ticker', (
      tester,
    ) async {
      await pumpRow(tester, reducedMotion: true);
      await tester.pump();

      expect(find.text('Picking a server…'), findsOne);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
