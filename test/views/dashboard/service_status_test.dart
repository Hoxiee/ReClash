import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/service_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _SeededServiceStatus extends ServiceStatus {
  _SeededServiceStatus(this._seed);

  final RoutedProbeState<ServiceTarget, ServiceCheck> _seed;

  @override
  RoutedProbeState<ServiceTarget, ServiceCheck> build() {
    buildProbe();
    return _seed;
  }
}

class _SeededOutboundIpProbe extends OutboundIpProbe {
  _SeededOutboundIpProbe(this._seed);

  final RoutedProbeState<String, IpInfo> _seed;

  @override
  RoutedProbeState<String, IpInfo> build() {
    buildProbe();
    return _seed;
  }
}

RoutedProbeState<ServiceTarget, ServiceCheck> _freshServices({
  List<String> chains = const [],
}) {
  return RoutedProbeState<ServiceTarget, ServiceCheck>({
    for (final target in ServiceTarget.values)
      target: ProbeEntry(
        phase: ProbePhase.fresh,
        value: ServiceCheck(
          ServiceProbeStatus.available,
          delay: 42,
          region: 'us',
          checkedAt: DateTime(2026, 1, 1, 12, 30, 15),
          chains: chains,
        ),
      ),
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    TestApp(
      includeNavigatorKey: false,
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        appRegionProvider.overrideWithValue(otherRegionCode),
        ...overrides,
      ],
      child: child,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the card settles the picker on the first region service', (
    tester,
  ) async {
    await _pump(tester, const ServiceStatusCard());

    expect(find.byType(ServiceStatusCard), findsOne);
    // A stopped core leaves the settled service pending: no verdict pill
    // reads as checked, and the egress line carries no stale em dash.
    expect(find.text(String.fromCharCode(0x2014)), findsNothing);
    expect(find.text('Not checked'), findsOne);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('a fresh check fills the card status and egress head', (
    tester,
  ) async {
    // A resolved-but-failed egress drops the IP and names the node head
    // instead, so the readout settles rather than shimmering.
    await _pump(
      tester,
      const ServiceStatusCard(),
      overrides: [
        serviceStatusProvider.overrideWith(
          () => _SeededServiceStatus(_freshServices(chains: ['US-Node-01'])),
        ),
        outboundIpProbeProvider.overrideWith(
          () => _SeededOutboundIpProbe(
            const RoutedProbeState<String, IpInfo>({
              'US-Node-01': ProbeEntry(phase: ProbePhase.failed),
            }),
          ),
        ),
      ],
    );

    expect(find.text('Available'), findsWidgets);
    expect(find.text('42 ms'), findsWidgets);
    // The selected service's node answers the egress line.
    expect(find.text('US-Node-01'), findsOneWidget);
  });

  testWidgets('the sheet lists a row per enabled service', (tester) async {
    await _pump(tester, const ServiceStatusSheet());

    expect(find.text('Google'), findsOne);
    expect(find.text('YouTube'), findsOne);
    expect(find.text('Netflix'), findsOne);
    // China-only bilibili is absent from the other-region catalog.
    expect(find.text('bilibili'), findsNothing);
  });

  testWidgets('fresh checks populate the sheet rows with verdicts', (
    tester,
  ) async {
    await _pump(
      tester,
      const ServiceStatusSheet(),
      overrides: [
        serviceStatusProvider.overrideWith(
          () => _SeededServiceStatus(_freshServices()),
        ),
      ],
    );

    expect(find.text('Available'), findsWidgets);
    expect(find.text('42 ms'), findsWidgets);
  });

  testWidgets('the shown node resolves its egress IP in the readout', (
    tester,
  ) async {
    const seed = RoutedProbeState<String, IpInfo>({
      'US-Node-01': ProbeEntry(
        phase: ProbePhase.fresh,
        value: IpInfo(ip: '1.2.3.4', countryCode: 'US'),
      ),
    });
    await _pump(
      tester,
      const ServiceStatusCard(),
      overrides: [
        serviceStatusProvider.overrideWith(
          () => _SeededServiceStatus(_freshServices(chains: ['US-Node-01'])),
        ),
        outboundIpProbeProvider.overrideWith(
          () => _SeededOutboundIpProbe(seed),
        ),
        ipQualityProvider(
          '1.2.3.4',
        ).overrideWith((ref) => Completer<IpQuality>().future),
      ],
    );

    expect(find.text('1.2.3.4'), findsOneWidget);
    expect(find.text(countryCodeToEmoji('US')!), findsWidgets);
    expect(find.text('—'), findsNothing);
  });

  test('russia adds the RU-5 services while other regions do not', () {
    const ruExtras = [
      ServiceTarget.instagram,
      ServiceTarget.x,
      ServiceTarget.discord,
      ServiceTarget.twitch,
      ServiceTarget.steam,
    ];
    const ruLeaders = [
      ServiceTarget.telegram,
      ServiceTarget.whatsapp,
      ServiceTarget.yandex,
    ];
    final russia = serviceTargetsForRegion('RU');
    expect(russia, containsAll(ruExtras));
    expect(russia.take(3), ruLeaders);
    expect(russia, isNot(contains(ServiceTarget.bilibili)));
    for (final region in ['IR', otherRegionCode, 'CN']) {
      final targets = serviceTargetsForRegion(region);
      for (final extra in [...ruExtras, ...ruLeaders]) {
        expect(targets, isNot(contains(extra)), reason: '$region has $extra');
      }
    }
    expect(
      serviceTargetsForRegion('CN'),
      contains(ServiceTarget.bilibili),
    );
  });

  test('service auto-checks default to on', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(appSettingProvider, (_, _) {});
    expect(container.read(appSettingProvider).serviceAutoCheckActive, isTrue);
    expect(container.read(appSettingProvider).serviceAutoCheckAll, isTrue);
  });

  testWidgets('manage overflow toggles the auto-check options', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(appSettingProvider, (_, _) {});
    addTearDown(subscription.close);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          includeNavigatorKey: false,
          overrides: [
            profilesProvider.overrideWith(TestProfiles.new),
            appRegionProvider.overrideWithValue(otherRegionCode),
          ],
          child: const ServiceManageView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pumpAndSettle();
    expect(find.text('Auto-check active'), findsOneWidget);
    expect(find.text('Auto-check all'), findsOneWidget);

    await tester.tap(find.text('Auto-check active'));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).serviceAutoCheckActive, isFalse);

    await tester.tap(find.byGlyph(AppGlyphs.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto-check all'));
    await tester.pumpAndSettle();
    expect(container.read(appSettingProvider).serviceAutoCheckAll, isFalse);
  });
}
