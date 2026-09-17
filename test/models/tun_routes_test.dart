import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';

bool _contains(String cidr, String address) {
  final parts = cidr.split('/');
  final network = InternetAddress(parts.first).rawAddress;
  final ip = InternetAddress(address).rawAddress;
  if (network.length != ip.length) return false;
  final bits = int.parse(parts.last);
  for (var bit = 0; bit < bits; bit++) {
    final mask = 1 << (7 - bit % 8);
    if (network[bit ~/ 8] & mask != ip[bit ~/ 8] & mask) return false;
  }
  return true;
}

void main() {
  test(
    'empty config routes bypass LAN while retaining public IPs and TUN DNS',
    () {
      const tun = Tun();
      final routes = tun.resolveRouteAddress(RouteMode.config);
      expect(routes, defaultBypassPrivateRouteAddress);
      for (final address in [
        '192.168.1.2',
        '10.1.2.3',
        '172.16.0.1',
        'fd00::1',
        'fe80::1',
      ]) {
        expect(
          routes.any((route) => _contains(route, address)),
          isFalse,
          reason: address,
        );
      }
      for (final address in [
        '1.1.1.1',
        '8.8.8.8',
        '2606:4700:4700::1111',
        '172.19.0.2',
        'fdfe:dcba:9876::2',
      ]) {
        expect(
          routes.any((route) => _contains(route, address)),
          isTrue,
          reason: address,
        );
      }
      expect(tun.routeAddress, isEmpty);
    },
  );

  test('explicit custom routes remain exact including full capture', () {
    for (final routes in [
      ['0.0.0.0/0', '::/0'],
      ['192.168.1.0/24', 'fd00::/8'],
    ]) {
      final tun = Tun(routeAddress: routes);
      expect(tun.resolveRouteAddress(RouteMode.config), routes);
      expect(
        tun.resolveRouteAddress(RouteMode.bypassPrivate),
        defaultBypassPrivateRouteAddress,
      );
      expect(tun.routeAddress, routes);
    }
  });
}
