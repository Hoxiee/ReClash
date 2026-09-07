import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/change_server_button.dart';
import 'package:reclash/views/dashboard/widgets/meta_info.dart';
import 'package:reclash/views/dashboard/widgets/service_info.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

Profile _profile({PanelMeta? panelMeta, SubscriptionInfo? subscriptionInfo}) {
  return Profile(
    id: 1,
    label: 'Panel',
    url: 'https://example.com/sub',
    autoUpdateDuration: const Duration(hours: 1),
    subscriptionInfo: subscriptionInfo,
    panelMeta: panelMeta,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  void setProfile(Profile profile) {
    (container.read(profilesProvider.notifier) as TestProfiles).replace([
      profile,
    ]);
  }

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
    container.read(currentProfileIdProvider.notifier).value = 1;
  });

  tearDown(() => container.dispose());

  Future<void> pumpWidget(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: ListView(
              children: [Align(alignment: Alignment.topLeft, child: widget)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Announce', () {
    testWidgets('shows the panel text', (tester) async {
      setProfile(
        _profile(panelMeta: const PanelMeta(announce: 'Maintenance at 3am')),
      );
      await pumpWidget(tester, const Announce());

      expect(find.text('Maintenance at 3am'), findsOneWidget);
    });

    testWidgets('falls back without panel data', (tester) async {
      setProfile(_profile());
      await pumpWidget(tester, const Announce());

      expect(find.text('No announcements'), findsOneWidget);
    });

    testWidgets('keeps long announcement text inside the card', (tester) async {
      setProfile(
        _profile(
          panelMeta: const PanelMeta(
            announce:
                'Очень длинный анонс сервиса с переносом строки и подробным '
                'описанием технических работ, которое не должно ломать плитку',
          ),
        ),
      );
      await pumpWidget(tester, const SizedBox(width: 360, child: Announce()));

      expect(tester.takeException(), null);
    });

    testWidgets('opens the full announcement on tap', (tester) async {
      const text = 'Maintenance at 3am https://example.com/status';
      setProfile(_profile(panelMeta: const PanelMeta(announce: text)));
      await pumpWidget(tester, const Announce());

      await tester.tap(find.byType(Announce));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveSheetScaffold), findsOneWidget);
      expect(find.text(text), findsNWidgets(2));
    });
  });

  group('MetaInfo', () {
    testWidgets('marks a 2099 subscription as perpetual', (tester) async {
      setProfile(
        _profile(
          subscriptionInfo: SubscriptionInfo(
            expire: DateTime.utc(2099, 1, 1).millisecondsSinceEpoch ~/ 1000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.text('Perpetual subscription'), findsOneWidget);
    });

    testWidgets('shows the days left', (tester) async {
      setProfile(
        _profile(
          subscriptionInfo: SubscriptionInfo(
            total: 100,
            expire:
                DateTime.now()
                    .add(const Duration(days: 5, hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.text('5 days left'), findsOneWidget);
    });

    testWidgets('shows the traffic progress for metered subscriptions', (
      tester,
    ) async {
      setProfile(
        _profile(
          subscriptionInfo: const SubscriptionInfo(
            upload: 25,
            download: 25,
            total: 100,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('50B / 100B'), findsOneWidget);
    });

    testWidgets('hides the traffic progress for unlimited subscriptions', (
      tester,
    ) async {
      setProfile(
        _profile(
          subscriptionInfo: SubscriptionInfo(
            expire:
                DateTime.now()
                    .add(const Duration(days: 30))
                    .millisecondsSinceEpoch ~/
                1000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('fits long localized subscription values', (tester) async {
      setProfile(
        _profile(
          subscriptionInfo: SubscriptionInfo(
            upload: 5 * 1024 * 1024 * 1024,
            download: 8 * 1024 * 1024 * 1024,
            total: 10 * 1024 * 1024 * 1024,
            expire:
                DateTime.now()
                    .add(const Duration(days: 120, hours: 1))
                    .millisecondsSinceEpoch ~/
                1000,
          ),
        ),
      );
      await pumpWidget(tester, const SizedBox(width: 360, child: MetaInfo()));

      expect(tester.takeException(), null);
    });

    testWidgets('opens the subscription overview on tap', (tester) async {
      setProfile(
        _profile(
          subscriptionInfo: const SubscriptionInfo(
            upload: 25,
            total: 100,
            expire: 1893456000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      await tester.tap(find.byType(MetaInfo));
      await tester.pumpAndSettle();

      expect(find.text('Traffic usage'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('opens even when the panel sent no subscription data', (
      tester,
    ) async {
      setProfile(_profile());
      await pumpWidget(tester, const MetaInfo());

      await tester.tap(find.byType(MetaInfo));
      await tester.pumpAndSettle();

      expect(
        find.text('This subscription reports no traffic quota or end date'),
        findsOneWidget,
      );
    });

    testWidgets('offers a sync action for url profiles', (tester) async {
      setProfile(
        _profile(
          subscriptionInfo: const SubscriptionInfo(
            total: 100,
            expire: 1893456000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });
  });

  group('ServiceInfo', () {
    testWidgets('fits a long service name in a compact card', (tester) async {
      setProfile(
        _profile(
          panelMeta: const PanelMeta(
            serviceName:
                'Очень длинное название сервиса для компактной карточки',
          ),
        ),
      );
      await pumpWidget(
        tester,
        const SizedBox(width: 177, child: ServiceInfo()),
      );

      expect(tester.takeException(), null);
    });

    testWidgets('shows the service name', (tester) async {
      setProfile(
        _profile(
          panelMeta: const PanelMeta(
            serviceName: 'Example VPN',
            serviceLogo: 'https://example.com/logo.svg',
          ),
        ),
      );
      await pumpWidget(tester, const ServiceInfo());

      expect(find.text('Example VPN'), findsOneWidget);
    });
  });

  group('ChangeServerButton', () {
    testWidgets('fits a long server name in a compact card', (tester) async {
      const server = ActiveServerInfo(
        name: 'Очень длинное название выбранного сервера',
        displayName: 'Очень длинное название выбранного сервера',
        countryCode: 'RU',
        testUrl: null,
        delay: 123,
        measuring: false,
        otherCodes: [],
        otherLocations: 0,
        smartRouting: false,
      );
      final scopedContainer = ProviderContainer(
        overrides: [activeServerProvider.overrideWithValue(server)],
      );
      addTearDown(scopedContainer.dispose);
      globalState.container = scopedContainer;

      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scopedContainer,
          child: const TestApp(
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: 177, child: ChangeServerButton()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), null);
    });

    testWidgets('falls back without the serverinfo header', (tester) async {
      setProfile(_profile());
      await pumpWidget(tester, const ChangeServerButton());

      expect(find.text('Change server'), findsOneWidget);
    });
  });
}
