import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/hero_routing.dart';
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

void main() {
  group('routingRowStateOf', () {
    test('a disabled engine keeps the stub line', () {
      expect(
        routingRowStateOf(enabled: false, mode: Mode.rule, status: null),
        RoutingRowState.off,
      );
      expect(
        routingRowStateOf(enabled: false, mode: Mode.rule, status: statusOf()),
        RoutingRowState.off,
      );
    });

    test('only rule mode exposes the engine', () {
      for (final mode in [Mode.global, Mode.direct]) {
        expect(
          routingRowStateOf(enabled: true, mode: mode, status: statusOf()),
          RoutingRowState.ruleOnly,
        );
      }
    });

    test('a missing status reads as starting, not failing', () {
      expect(
        routingRowStateOf(enabled: true, mode: Mode.rule, status: null),
        RoutingRowState.searching,
      );
    });

    test('dead-incumbent reasons outrank the terrain view', () {
      expect(
        routingRowStateOf(
          enabled: true,
          mode: Mode.rule,
          status: statusOf(reason: 'no-candidate', terrain: 'whitelist'),
        ),
        RoutingRowState.noServers,
      );
      for (final reason in ['stranded', 'incumbent-dead']) {
        expect(
          routingRowStateOf(
            enabled: true,
            mode: Mode.rule,
            status: statusOf(reason: reason, terrain: 'portal'),
          ),
          RoutingRowState.retrying,
        );
      }
    });

    test('a probing engine is searching whatever it last published', () {
      expect(
        routingRowStateOf(
          enabled: true,
          mode: Mode.rule,
          status: statusOf(searching: true, terrain: 'whitelist'),
        ),
        RoutingRowState.searching,
      );
    });

    test('terrain names the restricted networks', () {
      expect(
        routingRowStateOf(
          enabled: true,
          mode: Mode.rule,
          status: statusOf(terrain: 'portal'),
        ),
        RoutingRowState.portal,
      );
      expect(
        routingRowStateOf(
          enabled: true,
          mode: Mode.rule,
          status: statusOf(terrain: 'whitelist'),
        ),
        RoutingRowState.restricted,
      );
      expect(
        routingRowStateOf(
          enabled: true,
          mode: Mode.rule,
          status: statusOf(terrain: 'unknown'),
        ),
        RoutingRowState.on,
      );
    });
  });

  group('HeroRoutingRow', () {
    Future<void> pumpRow(
      WidgetTester tester, {
      required SmartRoutingProps props,
      required Mode mode,
      RcxStatus? status,
    }) {
      final container = ProviderContainer(
        overrides: [
          smartRoutingSettingProvider.overrideWithValue(props),
          patchClashConfigProvider.overrideWithValue(
            PatchClashConfig(mode: mode),
          ),
          smartRoutingStatusProvider.overrideWithValue(status),
        ],
      );
      addTearDown(container.dispose);
      return tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            includeNavigatorKey: false,
            setTheme: false,
            child: Scaffold(body: HeroRoutingRow(accent: Color(0xFF000000))),
          ),
        ),
      );
    }

    testWidgets('renders every state line from its own status', (tester) async {
      final cases = (
        props: const SmartRoutingProps(enabled: true),
        mode: Mode.rule,
        expectations: <RcxStatus?, String>{
          null: 'Picking a server…',
          statusOf(searching: true): 'Picking a server…',
          statusOf(reason: 'no-candidate'): 'No reachable servers',
          statusOf(reason: 'stranded'):
              'Server is not answering, looking for another',
          statusOf(terrain: 'portal'): 'Wi-Fi sign-in required',
          statusOf(terrain: 'whitelist'):
              'Restricted network · local services stay direct',
          statusOf(): 'Smart routing is on',
        },
      );
      for (final entry in cases.expectations.entries) {
        await pumpRow(
          tester,
          props: cases.props,
          mode: cases.mode,
          status: entry.key,
        );
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOne);
      }
    });

    testWidgets('a non-rule mode says so instead of pretending', (
      tester,
    ) async {
      await pumpRow(
        tester,
        props: const SmartRoutingProps(enabled: true),
        mode: Mode.global,
        status: statusOf(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Available in Rule mode only'), findsOne);
    });
  });
}
