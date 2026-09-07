import 'package:reclash/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'developer subscriptions have unique bundled configs and logos',
    () async {
      expect(developerSubscriptions, hasLength(3));
      expect(
        developerSubscriptions.map((fixture) => fixture.id).toSet(),
        hasLength(3),
      );
      expect(
        developerSubscriptions.map((fixture) => fixture.logo).toSet(),
        hasLength(3),
      );

      for (final fixture in developerSubscriptions) {
        final config = await rootBundle.loadString(fixture.configAsset);
        final logo = await rootBundle.loadString(
          fixture.logo.substring('asset:'.length),
        );
        expect(config, contains('proxy-groups:'));
        expect(config, contains('rules:'));
        expect(logo, contains('<svg'));
        expect(fixture.panelMeta.serviceLogo, fixture.logo);
      }
    },
  );

  test('each fixture exercises a separate panel surface', () {
    final prism = developerSubscriptions[0];
    final orbit = developerSubscriptions[1];
    final atlas = developerSubscriptions[2];

    expect(prism.panelMeta.themeHex, isNotNull);
    expect(prism.panelMeta.heroRing, isNotNull);
    expect(prism.subscriptionInfo, isNull);

    expect(orbit.subscriptionInfo?.total, greaterThan(0));
    expect(orbit.panelMeta.buyPlanUrl, isNotNull);
    expect(orbit.panelMeta.newDomain, isNotNull);

    expect(atlas.panelMeta.widgetsApplyMode, PanelWidgetsApplyMode.update);
    expect(atlas.panelMeta.serverInfoGroup, 'Atlas Select');
    expect(atlas.panelMeta.proxiesView, isNotNull);
  });
}
