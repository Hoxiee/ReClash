import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/context.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/kill_switch_policy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/kill_switch.dart';
import 'package:reclash/views/config/network.dart';

import '../../helpers/test_app.dart';

HelperKillSwitch _info({bool configured = true, bool armed = false}) =>
    HelperKillSwitch(
      configured: configured,
      mode: KillSwitchMode.standard,
      allowLan: true,
      tun: 'tun0',
      armed: armed,
      active: false,
    );

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    required KillSwitchMode? mode,
    required KillSwitchHostSnapshot? snapshot,
  }) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          networkSettingProvider.overrideWithBuild(
            (_, _) => NetworkProps(killSwitch: mode),
          ),
          killSwitchHostStateProvider.overrideWithBuild((_, _) => snapshot),
        ],
        child: const Material(child: KillSwitchTile()),
      ),
    );
    await tester.pump();
  }

  KillSwitchMode? modeOf(WidgetTester tester) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(KillSwitchTile)),
    );
    return container.read(networkSettingProvider).killSwitch;
  }

  testWidgets('turning the host kill switch on stores the standard mode', (
    tester,
  ) async {
    await pumpTile(tester, mode: null, snapshot: null);
    final l = tester.element(find.byType(KillSwitchTile)).appLocalizations;

    await tester.tap(find.text(l.killSwitch));
    await tester.pump();

    expect(modeOf(tester), KillSwitchMode.standard);
  });

  testWidgets('turning the host kill switch off clears the mode', (
    tester,
  ) async {
    await pumpTile(
      tester,
      mode: KillSwitchMode.standard,
      snapshot: (readiness: HelperReadiness.ready, info: _info()),
    );
    final l = tester.element(find.byType(KillSwitchTile)).appLocalizations;

    await tester.tap(find.text(l.killSwitch));
    await tester.pump();

    expect(modeOf(tester), isNull);
  });

  testWidgets('a Helper that is not ready replaces the status line', (
    tester,
  ) async {
    await pumpTile(
      tester,
      mode: KillSwitchMode.standard,
      snapshot: (readiness: HelperReadiness.notReady, info: null),
    );
    final l = tester.element(find.byType(KillSwitchTile)).appLocalizations;

    expect(find.text(l.killSwitchHelperMissing), findsOneWidget);
  });

  testWidgets('an armed but idle block reads as armed', (tester) async {
    await pumpTile(
      tester,
      mode: KillSwitchMode.standard,
      snapshot: (readiness: HelperReadiness.ready, info: _info(armed: true)),
    );
    final l = tester.element(find.byType(KillSwitchTile)).appLocalizations;

    expect(find.text(l.killSwitchStatusArmed), findsOneWidget);
  });
}
