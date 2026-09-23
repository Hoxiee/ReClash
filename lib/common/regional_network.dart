import 'package:reclash/common/constant.dart';
import 'package:reclash/common/regional.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

// Yandex DoT, not the plaintext 1.1.1.1/8.8.8.8 that ТСПУ poisons in-path.
const _dnsRussia = Dns(
  defaultNameserver: ['77.88.8.8', '77.88.8.1'],
  nameserver: ['tls://77.88.8.8', 'tls://77.88.8.1'],
  fallback: [
    'https://dns.adguard-dns.com/dns-query',
    'https://dns.quad9.net/dns-query',
  ],
  proxyServerNameserver: ['tls://77.88.8.8'],
  fakeIpFilter: ['*.lan'],
  nameserverPolicy: {},
  fallbackFilter: FallbackFilter(geoipCode: 'RU'),
);

// Shecan, the anti-sanction resolver reachable from inside Iran.
const _dnsIran = Dns(
  defaultNameserver: ['178.22.122.100', '185.51.200.2'],
  nameserver: ['https://free.shecan.ir/dns-query'],
  fallback: ['https://dns.quad9.net/dns-query'],
  proxyServerNameserver: ['178.22.122.100'],
  fakeIpFilter: ['*.lan'],
  nameserverPolicy: {},
  fallbackFilter: FallbackFilter(geoipCode: 'IR'),
);

const _dnsOther = Dns(
  defaultNameserver: ['1.1.1.1', '8.8.8.8'],
  nameserver: [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/dns-query',
  ],
  fallback: [],
  proxyServerNameserver: ['https://cloudflare-dns.com/dns-query'],
  fakeIpFilter: ['*.lan'],
  nameserverPolicy: {},
  fallbackFilter: FallbackFilter(geoipCode: ''),
);

const _regionalDns = RegionalDefaults<Dns>({
  AppRegion.russia: _dnsRussia,
  AppRegion.iran: _dnsIran,
  AppRegion.china: defaultDns,
  AppRegion.other: _dnsOther,
}, _dnsOther);

Dns dnsForRegion(AppRegion region) => _regionalDns.forRegion(region);

bool isShippedDns(Dns dns) => _regionalDns.isShipped(dns);

const _sharedBypass = [
  'localhost',
  '*.local',
  '127.*',
  '10.*',
  '172.16.*',
  '172.17.*',
  '172.18.*',
  '172.19.*',
  '172.2*',
  '172.30.*',
  '172.31.*',
  '192.168.*',
];

const _regionalBypassHead = <AppRegion, List<String>>{
  AppRegion.china: ['*zhihu.com', '*zhimg.com', '*jd.com', '100ime-iat-api.xfyun.cn', '*360buyimg.com'],
};

List<String> bypassForRegion(AppRegion region) => [
  ...?_regionalBypassHead[region],
  ..._sharedBypass,
];

bool isShippedBypass(List<String> domains) =>
    AppRegion.values.any((region) => _listEquals(bypassForRegion(region), domains));

String systemDnsFallbackForRegion(AppRegion region) {
  final servers = dnsForRegion(region).defaultNameserver;
  return servers.isEmpty ? defaultSystemDnsFallback : servers.first;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
