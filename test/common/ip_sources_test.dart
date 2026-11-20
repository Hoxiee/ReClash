import 'package:reclash/common/ip_sources.dart';
import 'package:flutter_test/flutter_test.dart';

List<IpSource> _enabled(
  String? region, {
  Set<String> enabled = const {},
  Set<String> disabled = const {},
}) => enabledIpSourcesForRegion(
  regionCode: region,
  order: const [],
  enabled: enabled,
  disabled: disabled,
);

void main() {
  test('Russia starts from its own services, other regions from all', () {
    expect(_enabled('RU'), [
      IpSource.ipInfo,
      IpSource.ipQuery,
      IpSource.identMe,
      IpSource.ipApiCom,
      IpSource.seeIp,
    ]);
    expect(_enabled('CN'), IpSource.values);
    expect(_enabled(null), IpSource.values);
  });

  test('a switch the user flipped outlives the region default', () {
    final sources = _enabled(
      'RU',
      enabled: {IpSource.ipLocate.name},
      disabled: {IpSource.ipInfo.name},
    );

    expect(sources, contains(IpSource.ipLocate));
    expect(sources, isNot(contains(IpSource.ipInfo)));
  });

  test('the user order comes first, the rest keeps the catalog order', () {
    final order = orderIpSources([IpSource.seeIp.name, 'gone']);

    expect(order.first, IpSource.seeIp);
    expect(order, hasLength(IpSource.values.length));
  });

  test('the last source of a kind cannot be switched off', () {
    const enabled = [IpSource.cloudflare, IpSource.ipLocate];

    expect(isLastIpSourceOfKind(IpSource.cloudflare, enabled), isTrue);
    expect(isLastIpSourceOfKind(IpSource.ipLocate, enabled), isTrue);
    expect(
      isLastIpSourceOfKind(IpSource.cloudflare, const [
        IpSource.cloudflare,
        IpSource.identMe,
      ]),
      isFalse,
    );
  });
}
