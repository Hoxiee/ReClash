import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';

void main() {
  group('TUN settings', () {
    test('legacy settings retain the stack and route configuration', () {
      final tun = Tun.fromJson({
        'stack': 'gvisor',
        'route-address': ['10.0.0.0/8'],
        'dns-hijack': ['8.8.8.8:53'],
      });

      expect(tun.stack, TunStack.gvisor);
      expect(tun.routeAddress, ['10.0.0.0/8']);
      expect(tun.dnsHijack, ['8.8.8.8:53']);
      expect(tun.mtu, isNull);
      expect(tun.congestionController, 'cubic');
      expect(tun.strictRoute, isFalse);
      expect(tun.routeExcludeAddress, isEmpty);
      expect(const Tun().stack, TunStack.mixed);
    });

    test('automatic MTU follows country data, with China as the exception', () {
      const tun = Tun();
      for (final region in [null, 'RU', 'IR', 'EG', 'OTHER', 'US', 'JP']) {
        expect(tun.resolveMtu(region), 1500, reason: '$region');
      }
      for (final region in ['CN', 'cn', ' CN ']) {
        expect(tun.resolveMtu(region), 9000, reason: region);
      }
      for (final region in shippedCountryCodes) {
        expect(profileForCode(region).tunMtu, region == 'CN' ? 9000 : 1500);
      }
      expect(tun.toJson(), isNot(contains('mtu')));
    });

    test('explicit MTU survives serialization and region changes', () {
      for (final mtu in [1280, 1400, 1500, 9000, 65535]) {
        final tun = Tun.fromJson(
          jsonDecode(jsonEncode(Tun(mtu: mtu).toJson()))
              as Map<String, Object?>,
        );
        expect(tun.resolveMtu('CN'), mtu);
        expect(tun.resolveMtu('RU'), mtu);
        expect(tun.copyWith(mtu: null).resolveMtu('CN'), 9000);
        expect(tun.copyWith(mtu: null).resolveMtu('OTHER'), 1500);
      }
    });

    test('MTU decoding normalizes just the malformed field', () {
      for (final value in [null, 0, -1, 'broken', false]) {
        final tun = Tun.fromJson({'mtu': value, 'stack': 'system'});
        expect(tun.mtu, isNull, reason: '$value');
        expect(tun.stack, TunStack.system);
      }
      for (final (value, expected) in [
        (1, 1280),
        (1279, 1280),
        (1280, 1280),
        (1500, 1500),
        (65535, 65535),
        (65536, 65535),
        ('1400', 1400),
      ]) {
        expect(Tun.fromJson({'mtu': value}).mtu, expected);
      }
    });

    test(
      'congestion control has a safe default without resetting the stack',
      () {
        for (final value in ['', '  ', null, 12]) {
          final tun = Tun.fromJson({
            'congestion-controller': value,
            'stack': 'mips',
          });
          expect(tun.congestionController, 'cubic');
          expect(tun.stack, TunStack.mips);
        }
        expect(
          Tun.fromJson({
            'congestion-controller': ' bbr3 ',
          }).congestionController,
          'bbr3',
        );
      },
    );

    test(
      'effective TUN resolves the region without mutating saved settings',
      () {
        const tun = Tun(
          stack: TunStack.mips,
          congestionController: 'bbr',
          strictRoute: true,
          routeExcludeAddress: ['192.0.2.0/24', '2001:db8::/32'],
        );
        final effective = tun.getRealTun(RouteMode.config, region: 'CN');
        expect(effective.mtu, 9000);
        expect(effective.congestionController, 'bbr');
        expect(effective.strictRoute, isTrue);
        expect(effective.routeExcludeAddress, tun.routeExcludeAddress);
        expect(tun.mtu, isNull);
        expect(
          effective.toJson(),
          containsPair('route-exclude-address', tun.routeExcludeAddress),
        );
        expect(effective.toJson(), containsPair('strict-route', true));
        expect(
          effective.toJson(),
          containsPair('congestion-controller', 'bbr'),
        );
      },
    );
  });

  group('profile-owned TUN keys', () {
    test('inherit omits both keys', () {
      const tun = Tun();
      expect(tun.disableIcmpForwarding, isNull);
      expect(tun.excludeInterface, isNull);
      expect(tun.toJson(), isNot(contains('disable-icmp-forwarding')));
      expect(tun.toJson(), isNot(contains('exclude-interface')));
    });

    test('explicit false and empty list are not inheritance', () {
      const tun = Tun(disableIcmpForwarding: false, excludeInterface: []);
      expect(
        tun.toJson(),
        allOf(
          containsPair('disable-icmp-forwarding', false),
          containsPair('exclude-interface', <String>[]),
        ),
      );
      expect(Tun.fromJson(jsonDecode(jsonEncode(tun.toJson()))), tun);
      expect(
        tun.copyWith(disableIcmpForwarding: null).toJson(),
        isNot(contains('disable-icmp-forwarding')),
      );
      expect(
        tun.copyWith(excludeInterface: null).toJson(),
        isNot(contains('exclude-interface')),
      );
    });

    test('both keys survive getRealTun', () {
      const tun = Tun(disableIcmpForwarding: true, excludeInterface: ['eth0']);
      final effective = tun.getRealTun(RouteMode.config);
      expect(effective.disableIcmpForwarding, isTrue);
      expect(effective.excludeInterface, ['eth0']);
    });
  });
}
