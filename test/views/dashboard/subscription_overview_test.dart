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

  testWidgets('a quota is read as what is left, not as what was spent', (
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

    expect(find.textContaining('90GB'), findsOne);
    expect(find.textContaining('free of 100GB'), findsOne);
    expect(find.text('3GB'), findsOne);
    expect(find.text('7GB'), findsOne);
    expect(find.text('Remaining 11 days'), findsOne);
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

  testWidgets('the panel names the service, the url only its host', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(panelMeta: const PanelMeta(serviceName: 'Nebula VPN')),
    );

    expect(find.text('Nebula VPN'), findsOne);
    expect(find.text('panel.example.com'), findsOne);
    expect(find.text('Local label'), findsNothing);
  });

  testWidgets(
    'an interval of its own does not hide the one the panel asks for',
    (tester) async {
      await _pump(
        tester,
        _profile(panelMeta: const PanelMeta(updateIntervalMinutes: 720)),
      );

      expect(find.text('2 hours'), findsOne);
      expect(find.text('The provider suggests 12 hours'), findsOne);
    },
  );

  testWidgets('auto update that is off reads as off', (tester) async {
    await _pump(tester, _profile(autoUpdate: false));

    expect(find.text('Off'), findsOne);
    expect(find.text('Update'), findsOne);
  });

  testWidgets('every panel link is offered, not only the urgent one', (
    tester,
  ) async {
    await _pump(
      tester,
      _profile(
        panelMeta: const PanelMeta(
          buyPlanUrl: 'https://panel.example.com/plans',
          buyTrafficUrl: 'https://panel.example.com/traffic',
          supportUrl: 'https://panel.example.com/support',
        ),
      ),
    );

    expect(find.text('Renew subscription'), findsOne);
    expect(find.text('Top up traffic'), findsOne);
    expect(find.text('Support'), findsOne);
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
}
