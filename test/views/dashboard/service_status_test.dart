import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/views/dashboard/widgets/active_server.dart';
import 'package:reclash/views/dashboard/widgets/service_status.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        appRegionProvider.overrideWithValue(AppRegion.other),
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
    // The picker names the service only by glyph, so a stopped core rests the
    // egress slot on an em dash.
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Not checked'), findsOne);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('a fresh check fills the card status and node column', (
    tester,
  ) async {
    // A resolved-but-failed egress rests the IP slot on an em dash so the
    // readout settles instead of shimmering; the node column still fills.
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
    // The selected service's egress head fills the node column.
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
    expect(find.text(countryCodeToEmoji('US')!), findsWidgets);
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
        outboundIpProbeProvider.overrideWith(() => _SeededOutboundIpProbe(seed)),
        ipQualityProvider(
          '1.2.3.4',
        ).overrideWith((ref) => Completer<IpQuality>().future),
      ],
    );

    expect(find.text('1.2.3.4'), findsOneWidget);
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
    final russia = serviceTargetsForRegion(AppRegion.russia);
    expect(russia, containsAll(ruExtras));
    expect(russia.take(3), ruLeaders);
    expect(russia, isNot(contains(ServiceTarget.bilibili)));
    for (final region in [AppRegion.iran, AppRegion.other, AppRegion.china]) {
      final targets = serviceTargetsForRegion(region);
      for (final extra in [...ruExtras, ...ruLeaders]) {
        expect(targets, isNot(contains(extra)), reason: '$region has $extra');
      }
    }
    expect(
      serviceTargetsForRegion(AppRegion.china),
      contains(ServiceTarget.bilibili),
    );
  });
}
