import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/views/dashboard/widgets/service_status.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

Map<ServiceTarget, ServiceCheck> _stubResults(List<ServiceTarget> targets) {
  return {
    for (final target in targets)
      target: ServiceCheck(
        ServiceProbeStatus.available,
        delay: 42,
        region: 'us',
        checkedAt: DateTime(2026, 1, 1, 12, 30, 15),
      ),
  };
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool started = false,
}) async {
  await tester.pumpWidget(
    TestApp(
      includeNavigatorKey: false,
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        appRegionProvider.overrideWithValue(AppRegion.other),
        isStartProvider.overrideWithValue(started),
        serviceCheckerProvider.overrideWithValue(
          (targets, {CancelToken? cancelToken}) async => _stubResults(targets),
        ),
      ],
      child: child,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the card renders one glyph per region service', (tester) async {
    await _pump(tester, const ServiceStatusCard());

    expect(find.byType(ServiceStatusCard), findsOne);
    expect(find.text('Service status'), findsOne);
    // AppRegion.other ships eleven services (bilibili is China-only).
    expect(find.byType(SvgPicture), findsNWidgets(11));
  });

  testWidgets('the sheet lists a row per enabled service', (tester) async {
    await _pump(tester, const ServiceStatusSheet());

    expect(find.text('Google'), findsOne);
    expect(find.text('YouTube'), findsOne);
    expect(find.text('Netflix'), findsOne);
    // China-only bilibili is absent from the other-region catalog.
    expect(find.text('bilibili'), findsNothing);
  });

  testWidgets('a started core populates the rows with probe verdicts', (
    tester,
  ) async {
    await _pump(tester, const ServiceStatusSheet(), started: true);

    expect(find.text('Available'), findsWidgets);
    expect(find.text('42 ms'), findsWidgets);
    expect(find.text('US'), findsWidgets);
  });

  test('russia adds the RU-5 services while other regions do not', () {
    const ruExtras = [
      ServiceTarget.instagram,
      ServiceTarget.x,
      ServiceTarget.discord,
      ServiceTarget.twitch,
      ServiceTarget.steam,
    ];
    final russia = serviceTargetsForRegion(AppRegion.russia);
    expect(russia, containsAll(ruExtras));
    expect(russia, isNot(contains(ServiceTarget.bilibili)));
    for (final region in [AppRegion.iran, AppRegion.other]) {
      final targets = serviceTargetsForRegion(region);
      for (final extra in ruExtras) {
        expect(targets, isNot(contains(extra)), reason: '$region has $extra');
      }
    }
    expect(
      serviceTargetsForRegion(AppRegion.china),
      contains(ServiceTarget.bilibili),
    );
  });
}
