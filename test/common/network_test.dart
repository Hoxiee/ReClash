import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/net/network.dart';

class _FakeAddress implements InterfaceAddress {
  _FakeAddress(this.address, this.type);

  @override
  final String address;

  @override
  final InternetAddressType type;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInterface implements NetworkInterface {
  _FakeInterface(this.name, this.addresses);

  @override
  final String name;

  @override
  final List<InterfaceAddress> addresses;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InterfaceAddress _v4(String address) =>
    _FakeAddress(address, InternetAddressType.IPv4);

InterfaceAddress _v6(String address) =>
    _FakeAddress(address, InternetAddressType.IPv6);

void main() {
  tearDown(() {
    listNetworkInterfaces = ({bool includeLoopback = false}) =>
        NetworkInterface.list(includeLoopback: includeLoopback);
  });

  void listing(List<NetworkInterface> interfaces) {
    listNetworkInterfaces = ({bool includeLoopback = false}) async =>
        interfaces;
  }

  group('isWifi', () {
    test('recognises the usual wireless interface names', () {
      for (final name in ['wlan0', 'Wi-Fi', 'WLAN1', 'en0', 'eth0', 'ETH0']) {
        expect(_FakeInterface(name, const []).isWifi, isTrue, reason: name);
      }
    });

    test('does not match an unrelated or suffixed interface', () {
      for (final name in ['en1', 'eth1', 'utun3', 'lo0', '']) {
        expect(_FakeInterface(name, const []).isWifi, isFalse, reason: name);
      }
    });
  });

  test('includesIPv4 only counts IPv4 addresses', () {
    expect(_FakeInterface('en1', [_v4('10.0.0.2')]).includesIPv4, isTrue);
    expect(_FakeInterface('en1', [_v6('fe80::1')]).includesIPv4, isFalse);
    expect(_FakeInterface('en1', const []).includesIPv4, isFalse);
  });

  test('isIPv4 reads the address type', () {
    expect(_v4('10.0.0.2').isIPv4, isTrue);
    expect(_v6('fe80::1').isIPv4, isFalse);
  });

  group('getLocalIpAddress', () {
    test('prefers a wireless interface over a wired one', () async {
      listing([
        _FakeInterface('utun0', [_v4('10.9.0.1')]),
        _FakeInterface('wlan0', [_v4('192.168.1.20')]),
      ]);

      expect(await getLocalIpAddress(), '192.168.1.20');
    });

    test(
      'prefers an IPv4-carrying interface when neither is wireless',
      () async {
        listing([
          _FakeInterface('utun0', [_v6('fe80::1')]),
          _FakeInterface('utun1', [_v4('10.9.0.1')]),
        ]);

        expect(await getLocalIpAddress(), '10.9.0.1');
      },
    );

    test('prefers the IPv4 address inside the chosen interface', () async {
      listing([
        _FakeInterface('wlan0', [_v6('fe80::1'), _v4('192.168.1.20')]),
      ]);

      expect(await getLocalIpAddress(), '192.168.1.20');
    });

    test('skips an interface that carries no address at all', () async {
      listing([
        _FakeInterface('wlan0', const []),
        _FakeInterface('utun0', [_v4('10.9.0.1')]),
      ]);

      expect(await getLocalIpAddress(), '10.9.0.1');
    });

    test('returns an empty string when nothing is listed', () async {
      listing([]);

      expect(await getLocalIpAddress(), '');
    });

    test('never asks for the loopback interface', () async {
      bool? asked;
      listNetworkInterfaces = ({bool includeLoopback = false}) async {
        asked = includeLoopback;
        return [];
      };

      await getLocalIpAddress();

      expect(asked, isFalse);
    });
  });

  group('getLocalIPv4s', () {
    test('drops the mihomo TUN address from the enumeration', () async {
      listing([
        _FakeInterface('wlan0', [_v4('192.168.1.20')]),
        _FakeInterface('ReClash', [_v4('198.18.0.1')]),
      ]);

      expect(await getLocalIPv4s(), ['192.168.1.20']);
    });

    test('keeps IPv6 and duplicate interfaces out of the list', () async {
      listing([
        _FakeInterface('wlan0', [_v6('fe80::1'), _v4('192.168.1.20')]),
        _FakeInterface('eth0', [_v4('10.0.0.2')]),
      ]);

      expect(await getLocalIPv4s(), ['192.168.1.20', '10.0.0.2']);
    });
  });

  group('smartPauseMatches', () {
    test('matches an SSID case-insensitively', () {
      expect(smartPauseMatches(['Office Wi-Fi'], ssid: 'office wi-fi'), isTrue);
      expect(smartPauseMatches(['Office Wi-Fi'], ssid: 'Cafe'), isFalse);
    });

    test('trims the SSID before comparing', () {
      expect(smartPauseMatches([' Office '], ssid: ' Office '), isTrue);
      expect(smartPauseMatches(['Office'], ssid: '  '), isFalse);
    });

    test('matches a subnet rule against the local IPv4s', () {
      expect(
        smartPauseMatches(
          ['192.168.1.0/24'],
          ssid: 'Cafe',
          ipv4s: ['192.168.1.20'],
        ),
        isTrue,
      );
      expect(
        smartPauseMatches(['192.168.2.0/24'], ipv4s: ['192.168.1.20']),
        isFalse,
      );
    });

    test('treats a bare IPv4 rule as a /32 host rule', () {
      expect(smartPauseMatches(['10.1.2.3'], ipv4s: ['10.1.2.3']), isTrue);
      expect(smartPauseMatches(['10.1.2.3'], ipv4s: ['10.1.2.4']), isFalse);
    });

    test('never matches a /0 rule', () {
      expect(smartPauseMatches(['0.0.0.0/0'], ipv4s: ['10.0.0.1']), isFalse);
    });

    test('an SSID rule never matches by address', () {
      expect(
        smartPauseMatches(['192.168.1.0/24 Home'], ipv4s: ['192.168.1.5']),
        isFalse,
      );
    });

    test('matches an IPv6 subnet rule against the local IPv6s', () {
      expect(
        smartPauseMatches(['fd00:db8:1::/48'], ipv6s: ['fd00:db8:1::42']),
        isTrue,
      );
      expect(
        smartPauseMatches(['fd00:db8:2::/48'], ipv6s: ['fd00:db8:1::42']),
        isFalse,
      );
    });

    test('treats a bare IPv6 rule as a /128 host rule', () {
      expect(smartPauseMatches(['fe80::1'], ipv6s: ['fe80::1']), isTrue);
      expect(smartPauseMatches(['fe80::1'], ipv6s: ['fe80::2']), isFalse);
    });

    test('matches a non-byte-aligned IPv6 prefix', () {
      expect(
        smartPauseMatches(['2001:db8::/33'], ipv6s: ['2001:db8:8000::1']),
        isFalse,
      );
      expect(
        smartPauseMatches(['2001:db8::/32'], ipv6s: ['2001:db8:8000::1']),
        isTrue,
      );
    });

    test('never matches a ::/0 rule', () {
      expect(smartPauseMatches(['::/0'], ipv6s: ['fd00::1']), isFalse);
    });

    test('an IPv4 rule never matches an IPv6 address', () {
      expect(
        smartPauseMatches(['192.168.1.0/24'], ipv6s: ['fd00::1']),
        isFalse,
      );
      expect(smartPauseMatches(['fd00::/8'], ipv4s: ['192.168.1.5']), isFalse);
    });

    test('strict lists need both an SSID and a subnet hit', () {
      const networks = ['Home', '192.168.1.0/24'];
      expect(
        smartPauseMatches(
          networks,
          ssid: 'Home',
          ipv4s: ['192.168.1.20'],
          strict: true,
        ),
        isTrue,
      );
      expect(smartPauseMatches(networks, ssid: 'Home', strict: true), isFalse);
      expect(
        smartPauseMatches(
          networks,
          ssid: 'Evil Twin',
          ipv4s: ['192.168.1.20'],
          strict: true,
        ),
        isFalse,
      );
      expect(
        smartPauseMatches(networks, ssid: 'Home', ipv4s: ['192.168.1.20']),
        isTrue,
      );
    });

    test('strict falls back to either hit without both rule kinds', () {
      expect(smartPauseMatches(['Home'], ssid: 'Home', strict: true), isTrue);
      expect(
        smartPauseMatches(
          ['192.168.1.0/24'],
          ipv4s: ['192.168.1.20'],
          strict: true,
        ),
        isTrue,
      );
    });
  });

  group('smartPauseMatchedRules', () {
    test('names the rules that hit', () {
      expect(
        smartPauseMatchedRules(
          ['Home', '192.168.1.0/24', 'Office'],
          ssid: 'Home',
          ipv4s: ['192.168.1.20'],
        ),
        ['Home', '192.168.1.0/24'],
      );
    });

    test('is empty when nothing hits', () {
      expect(
        smartPauseMatchedRules(['Home'], ssid: 'Cafe', ipv4s: ['10.0.0.9']),
        isEmpty,
      );
    });
  });

  group('smartPauseIsBroadRule', () {
    test('flags wide subnets', () {
      expect(smartPauseIsBroadRule('10.0.0.0/8'), isTrue);
      expect(smartPauseIsBroadRule('192.168.0.0/16'), isTrue);
      expect(smartPauseIsBroadRule('fd00::/8'), isTrue);
      expect(smartPauseIsBroadRule('0.0.0.0/0'), isTrue);
    });

    test('accepts home-sized subnets and SSIDs', () {
      expect(smartPauseIsBroadRule('192.168.1.0/24'), isFalse);
      expect(smartPauseIsBroadRule('fd00:db8:1::/48'), isFalse);
      expect(smartPauseIsBroadRule('fe80::1'), isFalse);
      expect(smartPauseIsBroadRule('Home'), isFalse);
    });
  });

  group('getLocalIPv6s', () {
    test('lists IPv6 addresses and skips IPv4 ones', () async {
      listing([
        _FakeInterface('wlan0', [_v6('fd00::1'), _v4('192.168.1.20')]),
        _FakeInterface('eth0', [_v6('fe80::2')]),
      ]);

      expect(await getLocalIPv6s(), ['fd00::1', 'fe80::2']);
    });
  });

  group('isSubnetRule', () {
    test('accepts IPv4 CIDRs and bare IPv4s', () {
      expect(isSubnetRule('192.168.1.0/24'), isTrue);
      expect(isSubnetRule('10.1.2.3'), isTrue);
      expect(isSubnetRule(' 10.1.2.3/32 '), isTrue);
    });

    test('accepts IPv6 CIDRs and bare IPv6s', () {
      expect(isSubnetRule('fd00::/8'), isTrue);
      expect(isSubnetRule('fe80::1'), isTrue);
      expect(isSubnetRule(' [fd00::1]/64 '), isTrue);
    });

    test('rejects SSIDs and malformed CIDRs', () {
      expect(isSubnetRule('Home'), isFalse);
      expect(isSubnetRule('192.168.1.0/33'), isFalse);
      expect(isSubnetRule('192.168.1.0/abc'), isFalse);
      expect(isSubnetRule('192.168.1.2.3'), isFalse);
      expect(isSubnetRule(''), isFalse);
    });
  });

  group('ipv4ToSubnetCidr', () {
    test('reduces an address to its /24', () {
      expect(ipv4ToSubnetCidr('192.168.1.20'), '192.168.1.0/24');
      expect(ipv4ToSubnetCidr('10.0.0.1'), '10.0.0.0/24');
    });

    test('passes a non-IPv4 string through untouched', () {
      expect(ipv4ToSubnetCidr('fe80::1'), 'fe80::1');
    });
  });

  group('ipv6ToSubnetCidr', () {
    test('reduces an address to its /64', () {
      expect(ipv6ToSubnetCidr('fd00:db8:1:2:3:4:5:6'), 'fd00:db8:1:2::/64');
      expect(ipv6ToSubnetCidr('fd00::42'), 'fd00:0:0:0::/64');
    });

    test('passes a non-IPv6 string through untouched', () {
      expect(ipv6ToSubnetCidr('192.168.1.20'), '192.168.1.20');
    });
  });
}
