import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/environment/facts.dart';
import 'package:reclash/features/doctor/environment/linux.dart';
import 'package:reclash/features/doctor/environment/macos.dart';
import 'package:reclash/features/doctor/environment/reader.dart';
import 'package:reclash/features/doctor/environment/tunnels.dart';

const _procRoute = '''
Iface	Destination	Gateway 	Flags	RefCnt	Use	Metric	Mask		MTU	Window	IRTT
wlan0	00000000	0100A8C0	0003	0	0	600	00000000	0	0	0
tun0	00000000	0100000A	0003	0	0	50	00000080	0	0	0
tun0	00000080	0100000A	0003	0	0	50	00000080	0	0	0
wlan0	0000A8C0	00000000	0001	0	0	600	00FFFFFF	0	0	0
''';

void main() {
  test('parses /proc/net/route and finds split defaults', () {
    final routes = parseProcNetRoute(_procRoute);
    expect(routes, hasLength(4));
    expect(routes[0].isDefault, isTrue);
    expect(routes[1].prefix, 1);
    expect(routes[1].isDefault, isTrue);
    expect(routes[2].destination.address, '128.0.0.0');
    expect(routes[2].isDefault, isTrue);
    expect(routes[3].prefix, 24);
    expect(routes[3].isDefault, isFalse);
    expect(routes[3].destination.address, '192.168.0.0');
  });

  test('parses /proc/net/ipv6_route', () {
    final routes = parseProcNetIpv6Route(
      '00000000000000000000000000000000 00 00000000000000000000000000000000 00 '
      '00000000000000000000000000000000 00000400 00000001 00000000 00000003 wlan0\n',
    );
    expect(routes.single.isDefault, isTrue);
    expect(routes.single.metric, 0x400);
    expect(routes.single.adapter, 'wlan0');
  });

  test('classifies adapters and detects our tunnel and a foreign one', () {
    final routes = parseProcNetRoute(_procRoute);
    final fact = buildTunnels(
      adapters: [
        const AdapterInfo(name: 'tun0'),
        const AdapterInfo(name: 'ReClash'),
        const AdapterInfo(name: 'wlan0'),
        const AdapterInfo(name: 'wg0', description: 'wireguard'),
      ],
      routes: routes,
      ours: 'ReClash',
    );
    expect(fact.ours?.kind, TunnelKind.other);
    expect(fact.ours?.defaultRoute, isFalse);
    expect(
      fact.foreign.map((a) => (a.name, a.kind, a.defaultRoute, a.metric)),
      [
        ('tun0', TunnelKind.tun, true, 50),
        ('wg0', TunnelKind.wireguard, false, null),
      ],
    );
    expect(fact.routedThroughOurs, isFalse);
  });

  test('routedThroughOurs follows the longest-prefix route', () {
    final routes = [
      RouteEntry(
        adapter: 'eth0',
        destination: InternetAddress('0.0.0.0'),
        prefix: 0,
        metric: 100,
      ),
      RouteEntry(
        adapter: 'ReClash',
        destination: InternetAddress('0.0.0.0'),
        prefix: 1,
        metric: 1,
      ),
    ];
    final fact = buildTunnels(
      adapters: const [AdapterInfo(name: 'ReClash', description: 'Wintun')],
      routes: routes,
      ours: 'ReClash',
    );
    expect(fact.ours?.kind, TunnelKind.wintun);
    expect(fact.ours?.defaultRoute, isTrue);
    expect(fact.routedThroughOurs, isTrue);
    expect(buildTunnels(adapters: const [], routes: routes).ours, isNull);
  });

  test('reads sysfs tunnel adapters that are up', () {
    expect(
      parseSysNetAdapter(
        name: 'tun0',
        type: '65534\n',
        flags: '0x1091\n',
        hasTunFlags: true,
      )?.name,
      'tun0',
    );
    expect(
      parseSysNetAdapter(
        name: 'tun0',
        type: '65534',
        flags: '0x1090',
        hasTunFlags: true,
      ),
      isNull,
    );
    expect(
      parseSysNetAdapter(
        name: 'eth0',
        type: '1',
        flags: '0x1003',
        hasTunFlags: false,
      ),
      isNull,
    );
    expect(
      parseSysNetAdapter(
        name: 'wg0',
        type: '65534',
        flags: '0x80d1',
        hasTunFlags: false,
        uevent: 'DEVTYPE=wireguard',
      )?.description,
      'wireguard',
    );
  });

  test('parses resolv.conf, tcp listeners and gsettings', () {
    expect(
      parseResolvConf(
        '# x\nnameserver 127.0.0.53\nnameserver fe80::1%eth0\noptions edns0',
      ),
      ['127.0.0.53', 'fe80::1'],
    );
    expect(
      parseProcNetTcp(
        '''
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 0100007F:1ED2 00000000:0000 0A 00000000:00000000 00:00000000 00000000  1000        0 55555 1 0
   1: 0100007F:1F90 00000000:0000 01 00000000:00000000 00:00000000 00000000  1000        0 66666 1 0
''',
        {7890, 8080},
      ),
      {7890: '55555'},
    );
    final proxy = parseGsettingsProxy('''
org.gnome.system.proxy mode 'manual'
org.gnome.system.proxy autoconfig-url ''
org.gnome.system.proxy.http host '127.0.0.1'
org.gnome.system.proxy.http port 7890
org.gnome.system.proxy.socks host ''
''');
    expect(
      proxy,
      const SystemProxyFact(enabled: true, host: '127.0.0.1', port: 7890),
    );
    expect(
      parseGsettingsProxy("org.gnome.system.proxy mode 'none'")?.enabled,
      isFalse,
    );
  });

  test('parses macOS netstat, scutil and lsof', () {
    final routes = parseNetstatInet('''
Routing tables

Internet:
Destination        Gateway            Flags           Netif Expire
default            192.168.1.1        UGScg             en0
0/1                10.8.0.1           UGSc            utun4
128.0/1            10.8.0.1           UGSc            utun4
192.168.1          link#6             UCS               en0      !
1.1.1.1            10.8.0.1           UHWIig          utun4
''');
    expect(routes.map((r) => (r.adapter, r.destination.address, r.prefix)), [
      ('en0', '0.0.0.0', 0),
      ('utun4', '0.0.0.0', 1),
      ('utun4', '128.0.0.0', 1),
      ('en0', '192.168.1.0', 24),
      ('utun4', '1.1.1.1', 32),
    ]);
    expect(routes[2].isDefault, isTrue);
    expect(
      parseScutilDns('''
resolver #1
  nameserver[0] : 1.1.1.1
  nameserver[1] : 127.0.0.1
resolver #2
  nameserver[0] : 1.1.1.1
DNS configuration (for scoped queries)
resolver #1
  nameserver[0] : 8.8.8.8
'''),
      ['1.1.1.1', '127.0.0.1'],
    );
    final proxy = parseScutilProxy('''
<dictionary> {
  HTTPEnable : 1
  HTTPPort : 7890
  HTTPProxy : 127.0.0.1
  ProxyAutoConfigEnable : 0
}
''');
    expect(proxy?.enabled, isTrue);
    expect(proxy?.port, 7890);
    expect(
      parseScutilProxy('<dictionary> {\n  HTTPEnable : 0\n}')?.enabled,
      isFalse,
    );
    final owner = parseLsofOwner('p812\ncReClashCore\n');
    expect(owner?.pid, 812);
    expect(owner?.name, 'ReClashCore');
  });

  test('parses the Windows ProxyServer forms', () {
    expect(parseProxyServer('127.0.0.1:7890'), (host: '127.0.0.1', port: 7890));
    expect(
      parseProxyServer(
        'socks=1.1.1.1:1080;http=127.0.0.1:7890;https=127.0.0.1:7890',
      ),
      (host: '127.0.0.1', port: 7890),
    );
    expect(parseProxyServer(''), (host: '', port: null));
    expect(isLoopbackHost('127.0.0.5'), isTrue);
    expect(isLoopbackHost('[::1]'), isTrue);
    expect(isLoopbackHost('LOCALHOST'), isTrue);
    expect(isLoopbackHost('proxy.corp'), isFalse);
  });
}
