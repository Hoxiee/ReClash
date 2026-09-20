import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/dashboard/widgets/subscription_overview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

final _expire = DateTime.now().add(const Duration(days: 12));

Profile _profile({
  SubscriptionInfo? subscriptionInfo,
  PanelMeta? panelMeta,
  bool autoUpdate = true,
  bool undialableNodes = false,
}) {
  return Profile(
    id: 7,
    label: 'Local label',
    url: 'https://panel.example.com/sub/token',
    lastUpdateDate: DateTime.now(),
    autoUpdateDuration: const Duration(hours: 2),
    autoUpdate: autoUpdate,
    subscriptionInfo: subscriptionInfo,
    panelMeta: panelMeta,
    undialableNodes: undialableNodes,
  );
}

Future<void> _pump(WidgetTester tester, Profile? profile) async {
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(
        () => TestProfiles(profile == null ? const [] : [profile]),
      ),
      currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(
        includeNavigatorKey: false,
        setTheme: false,
        child: SubscriptionOverviewView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a tree without a profile says so instead of an empty page', (
    tester,
  ) async {
    await _pump(tester, null);

    expect(find.text('No profiles yet, please add one first'), findsOne);
    expect(find.text('Traffic usage'), findsNothing);
  });

  testWidgets('the end date reads short, and the quota is gone', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(
        subscriptionInfo: SubscriptionInfo(
          upload: 3 * 1024 * 1024 * 1024,
          download: 7 * 1024 * 1024 * 1024,
          total: 100 * 1024 * 1024 * 1024,
          expire: _expire.millisecondsSinceEpoch ~/ 1000,
        ),
      ),
    );

    expect(find.text('Traffic usage'), findsNothing);
    expect(find.textContaining('100GB'), findsNothing);
    expect(find.text(_expire.show), findsOne);
    expect(find.text(_expire.showFull), findsNothing);
  });

  testWidgets('a plan without quota or end date explains the blank', (
    tester,
  ) async {
    await _pump(tester, _profile());

    expect(
      find.text('This subscription reports no traffic quota or end date'),
      findsOne,
    );
    expect(find.text('Traffic usage'), findsNothing);
  });

  testWidgets('the provider card names the service and its local label', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(panelMeta: const PanelMeta(serviceName: 'Nebula VPN')),
    );

    expect(find.text('Nebula VPN'), findsOne);
    expect(find.text('Local label'), findsOne);
  });

  testWidgets('auto update on shows its own interval, not the suggestion', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(panelMeta: const PanelMeta(updateIntervalMinutes: 720)),
    );

    expect(find.text('2 hours'), findsOne);
    expect(find.textContaining('suggested'), findsNothing);
  });

  testWidgets('auto update that is off names the suggested interval', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(
        autoUpdate: false,
        panelMeta: const PanelMeta(updateIntervalMinutes: 720),
      ),
    );

    expect(find.text('Off (suggested 12 hours)'), findsOne);
  });

  testWidgets('a panel that moved or blocked the device says it up front', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(
        panelMeta: const PanelMeta(
          hwidMaxDevicesReached: true,
          newDomain: 'new.example.com',
          announce: 'Maintenance tonight',
        ),
      ),
    );

    expect(find.text('Device limit reached'), findsOne);
    expect(find.text('Maintenance tonight'), findsOne);
    expect(find.text('The provider moved to new.example.com'), findsOne);
  });

  testWidgets('a subscription whose nodes are all stubs warns about it', (
    tester,
  ) async {
    await _pump(tester, _profile(undialableNodes: true));

    expect(
      find.text(
        'No regular node addresses were found in this subscription. '
        'The panel may have returned a placeholder. Server connectivity was not tested.',
      ),
      findsOne,
    );
  });

  testWidgets('a dialable subscription shows no stub warning', (tester) async {
    await _pump(tester, _profile());

    expect(
      find.textContaining('No regular node addresses were found'),
      findsNothing,
    );
  });
}
