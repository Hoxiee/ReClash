import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/announce.dart';
import 'package:reclash/views/dashboard/widgets/change_server_button.dart';
import 'package:reclash/views/dashboard/widgets/hero/subscription_bits.dart';
import 'package:reclash/views/dashboard/widgets/meta_info.dart';
import 'package:reclash/views/dashboard/widgets/service_info.dart';
import 'package:reclash/widgets/widgets.dart';

import '../../helpers/glyph_finders.dart';
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

    testWidgets('opens and closes the full announcement without a header URL', (
      tester,
    ) async {
      const text = 'Maintenance at 3am https://example.com/status';
      setProfile(_profile(panelMeta: const PanelMeta(announce: text)));
      await pumpWidget(tester, const Announce());

      await tester.tap(find.byType(Announce));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.byType(TonalButtonGroup), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.openExternal), findsNothing);
      expect(find.text(text), findsNWidgets(2));

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(TonalButtonGroup), findsNothing);
      expect(find.text(text), findsOneWidget);
    });

    testWidgets('groups standard link and close buttons in a narrow panel', (
      tester,
    ) async {
      const text = 'Maintenance at 3am';
      const url = 'https://example.com/status';
      setProfile(
        _profile(
          panelMeta: const PanelMeta(announce: text, announceUrl: url),
        ),
      );
      await pumpWidget(tester, const SizedBox(width: 320, child: Announce()));
      final labels = tester.element(find.byType(Announce)).appLocalizations;

      await tester.tap(find.byType(Announce));
      await tester.pumpAndSettle();

      final group = find.byType(TonalButtonGroup);
      expect(group, findsOneWidget);
      expect(
        find.descendant(of: group, matching: find.byType(IconButton)),
        findsNWidgets(2),
      );
      final open = find.widgetWithGlyph(IconButton, AppGlyphs.openExternal);
      final close = find.widgetWithGlyph(IconButton, AppGlyphs.close);
      final buttonSize = TonalButtonSize.bar.button;
      expect(tester.getSize(open), Size.square(buttonSize));
      expect(tester.getSize(close), Size.square(buttonSize));
      expect(
        tester.getCenter(close) - tester.getCenter(open),
        Offset(buttonSize, 0),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip(labels.openInBrowser));
      await tester.pumpAndSettle();

      expect(find.text(labels.externalLink), findsOneWidget);
      expect(find.text(url), findsOneWidget);
      await tester.tap(find.text(labels.cancel));
      await tester.pumpAndSettle();
      expect(group, findsOneWidget);

      await tester.tap(find.byTooltip(labels.close));
      await tester.pumpAndSettle();
      expect(group, findsNothing);
      expect(find.text(text), findsOneWidget);
    });

    for (final unitHeight in [80.0, 120.0]) {
      testWidgets('keeps the dashboard radius at unit height $unitHeight', (
        tester,
      ) async {
        setProfile(
          _profile(panelMeta: const PanelMeta(announce: 'Maintenance at 3am')),
        );
        await pumpWidget(
          tester,
          DashboardWidgetMetrics(
            unitHeight: unitHeight,
            child: const SizedBox(width: 360, child: Announce()),
          ),
        );
        final card = tester.widget<CommonCard>(
          find.descendant(
            of: find.byType(Announce),
            matching: find.byType(CommonCard),
          ),
        );

        await tester.tap(find.byType(Announce));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        final panel = find
            .ancestor(
              of: find.byType(SelectionArea),
              matching: find.byType(Material),
            )
            .first;
        expect(
          tester.widget<Material>(panel).shape,
          AppShape.all(card.radius!),
        );

        await tester.pumpAndSettle();
        expect(
          tester.widget<Material>(panel).shape,
          AppShape.all(card.radius!),
        );
        expect(tester.takeException(), isNull);
      });
    }
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

      expect(find.text('Remaining 5 days'), findsOneWidget);
    });

    testWidgets('shows the quota bar for metered subscriptions', (
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

      expect(find.byType(SubscriptionBar), findsOneWidget);
      expect(find.text('50B free of 100B'), findsOneWidget);
    });

    testWidgets('omits the free-of-total split for unlimited subscriptions', (
      tester,
    ) async {
      setProfile(
        _profile(
          subscriptionInfo: SubscriptionInfo(
            upload: 25,
            download: 25,
            expire:
                DateTime.now()
                    .add(const Duration(days: 30))
                    .millisecondsSinceEpoch ~/
                1000,
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());

      expect(find.textContaining('free of'), findsNothing);
      expect(find.byType(SubscriptionBar), findsNothing);
      expect(find.text('50B'), findsOneWidget);
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

    testWidgets('opens compact subscription details without announcements', (
      tester,
    ) async {
      const announcement = 'Maintenance at 3am';
      setProfile(
        _profile(
          subscriptionInfo: const SubscriptionInfo(
            upload: 25,
            total: 100,
            expire: 1893456000,
          ),
          panelMeta: const PanelMeta(
            announce: announcement,
            buyPlanUrl: 'https://example.com/renew',
            buyTrafficUrl: 'https://example.com/traffic',
            webPageUrl: 'https://example.com/account',
          ),
        ),
      );
      await pumpWidget(tester, const MetaInfo());
      final labels = tester.element(find.byType(MetaInfo)).appLocalizations;

      await tester.tap(find.byType(MetaInfo));
      await tester.pumpAndSettle();

      final sheet = find.byType(AdaptiveSheetScaffold);
      expect(sheet, findsOneWidget);
      expect(find.text(announcement), findsNothing);
      final headers = find.descendant(
        of: sheet,
        matching: find.byType(ListHeader),
      );
      expect(
        tester.widgetList<ListHeader>(headers).map((header) => header.title),
        [labels.subscriptionInfo, labels.profile, labels.serviceInfo],
      );
      for (final title in [
        labels.renewSubscription,
        labels.topUpTraffic,
        labels.personalCabinet,
        labels.subscriptionReport,
      ]) {
        expect(find.text(title), findsOneWidget);
      }

      final subscriptionRow = find.ancestor(
        of: find.byType(SubscriptionInfoView),
        matching: find.byType(DecorationListItem),
      );
      expect(
        tester.getRect(headers.at(1)).top,
        closeTo(tester.getRect(subscriptionRow).bottom, 0.01),
      );
      expect(
        tester.getRect(headers.at(2)).top,
        closeTo(
          tester
              .getRect(find.widgetWithText(DetailRow, labels.overrideMode))
              .bottom,
          0.01,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens even when the panel sent no subscription data', (
      tester,
    ) async {
      setProfile(_profile());
      await pumpWidget(tester, const MetaInfo());

      await tester.tap(find.byType(MetaInfo));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveSheetScaffold), findsOneWidget);
      expect(find.text('Subscription info'), findsNothing);
      expect(find.widgetWithText(ListHeader, 'Service'), findsOneWidget);
      expect(find.text('Subscription report'), findsOneWidget);
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

      expect(find.byGlyph(AppGlyphs.sync), findsOneWidget);
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
