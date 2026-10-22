import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/on_demand.dart';

void main() {
  test('SSID matching preserves case and meaningful whitespace', () {
    expect(onDemandMatches(['Home'], ssid: 'home'), isFalse);
    expect(onDemandMatches([' Home '], ssid: 'Home'), isFalse);
    expect(onDemandMatches(['Home'], ssid: 'Home'), isTrue);
  });

  test('IPv4 and IPv6 subnet rules match physical addresses', () {
    expect(
      onDemandMatchedRules(
        ['192.168.1.0/24', '2001:db8:1234::/48'],
        ipv4s: ['192.168.1.56'],
        ipv6s: ['2001:db8:1234:abcd::5'],
      ),
      ['192.168.1.0/24', '2001:db8:1234::/48'],
    );
    expect(
      onDemandMatches(['192.168.1.0/24'], ipv4s: ['192.168.2.1']),
      isFalse,
    );
    expect(onDemandMatches(['2001:db8::/32'], ipv6s: ['2001:db9::1']), isFalse);
  });

  test('strict mode needs both rule kinds only when both are configured', () {
    final rules = ['Home', '192.168.1.0/24'];
    expect(onDemandMatches(rules, ssid: 'Home', strict: true), isFalse);
    expect(
      onDemandMatches(rules, ipv4s: ['192.168.1.5'], strict: true),
      isFalse,
    );
    expect(
      onDemandMatches(
        rules,
        ssid: 'Home',
        ipv4s: ['192.168.1.5'],
        strict: true,
      ),
      isTrue,
    );
    expect(onDemandMatches(['Home'], ssid: 'Home', strict: true), isTrue);
  });

  test('a default route never trusts every network', () {
    expect(
      onDemandMatches(
        ['0.0.0.0/0', '::/0'],
        ipv4s: ['8.8.8.8'],
        ipv6s: ['2001:db8::1'],
      ),
      isFalse,
    );
  });

  test('IPv6 anchors survive address renewal and zone identifiers', () {
    expect(
      ipv6ToSubnetCidr('2001:db8:1234:abcd::1%wlan0'),
      '2001:db8:1234:abcd::/64',
    );
    expect(ipv4ToSubnetCidr('192.168.1.25'), '192.168.1.0/24');
  });
}
