import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';

const regionalDefaultTunMtu = 1500;

class CountryProfile {
  const CountryProfile({
    this.dns = defaultDns,
    this.dnsOverrideKeys = const {},
    this.tunMtu = regionalDefaultTunMtu,
    this.bypassDomains = const [],
    this.defaultServiceIds = const [],
  });

  final Dns dns;
  final Set<DnsOverrideKey> dnsOverrideKeys;
  final int tunMtu;
  final List<String> bypassDomains;
  final List<String> defaultServiceIds;
}

const otherCountryProfile = CountryProfile(
  defaultServiceIds: ['google', 'youtube', 'chatgpt', 'claude', 'netflix'],
);

const _regionalDnsOverrideKeys = {
  DnsOverrideKey.defaultNameserver,
  DnsOverrideKey.nameserver,
  DnsOverrideKey.fallback,
  DnsOverrideKey.proxyServerNameserver,
  DnsOverrideKey.fallbackFilterGeoipCode,
};

const _russiaDns = Dns(
  defaultNameserver: ['77.88.8.8', '77.88.8.1'],
  nameserver: ['tls://77.88.8.8', 'tls://77.88.8.1'],
  fallback: [
    'https://dns.adguard-dns.com/dns-query',
    'https://dns.quad9.net/dns-query',
  ],
  proxyServerNameserver: ['tls://77.88.8.8'],
  fallbackFilter: FallbackFilter(geoipCode: 'RU'),
);

const _iranDns = Dns(
  defaultNameserver: ['178.22.122.100', '185.51.200.2'],
  nameserver: ['https://free.shecan.ir/dns-query'],
  fallback: ['https://dns.quad9.net/dns-query'],
  proxyServerNameserver: ['178.22.122.100'],
  fallbackFilter: FallbackFilter(geoipCode: 'IR'),
);

const _egyptDns = Dns(
  defaultNameserver: ['1.1.1.1', '8.8.8.8'],
  nameserver: [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/dns-query',
  ],
  proxyServerNameserver: ['https://cloudflare-dns.com/dns-query'],
  fallbackFilter: FallbackFilter(geoipCode: 'EG'),
);

const _chinaBypassDomains = [
  '*zhihu.com',
  '*zhimg.com',
  '*jd.com',
  '100ime-iat-api.xfyun.cn',
  '*360buyimg.com',
];

const _profiles = <String, CountryProfile>{
  'CN': CountryProfile(
    dns: defaultDns,
    dnsOverrideKeys: _regionalDnsOverrideKeys,
    tunMtu: defaultTunMtu,
    bypassDomains: _chinaBypassDomains,
    defaultServiceIds: ['google', 'youtube', 'chatgpt', 'claude', 'bilibili'],
  ),
  'RU': CountryProfile(
    dns: _russiaDns,
    dnsOverrideKeys: _regionalDnsOverrideKeys,
    defaultServiceIds: ['youtube', 'discord', 'chatgpt', 'claude'],
  ),
  'IR': CountryProfile(
    dns: _iranDns,
    dnsOverrideKeys: _regionalDnsOverrideKeys,
    defaultServiceIds: ['youtube', 'chatgpt', 'claude'],
  ),
  'EG': CountryProfile(
    dns: _egyptDns,
    dnsOverrideKeys: _regionalDnsOverrideKeys,
    defaultServiceIds: ['google', 'youtube', 'chatgpt', 'claude'],
  ),
};

const otherRegionCode = 'OTHER';

const shippedCountryCodes = {'RU', 'IR', 'CN', 'EG', otherRegionCode};

String? normalizedRegionCode(Object? value) {
  if (value is! String) return null;
  final code = value.trim().toUpperCase();
  return code.isEmpty ? null : code;
}

String? sanitizeRegionCode(Object? value) {
  final code = normalizedRegionCode(value);
  return code != null && shippedCountryCodes.contains(code) ? code : null;
}

CountryProfile profileForCode(String? code) =>
    _profiles[normalizedRegionCode(code)] ?? otherCountryProfile;

bool hasProfileForCode(String? code) =>
    _profiles.containsKey(normalizedRegionCode(code));

String? codeForCountryCode(String? code) {
  final normalized = normalizedRegionCode(code);
  return normalized != null && _profiles.containsKey(normalized)
      ? normalized
      : null;
}

String? codeForTimeZone(String? id) {
  final zone = id?.trim();
  if (zone == null || zone.isEmpty) return null;
  for (final entry in _timeZones.entries) {
    if (entry.value.contains(zone)) return entry.key;
  }
  return null;
}

String? codeForLanguage(String? code) => switch (code?.trim().toLowerCase()) {
  'ru' => 'RU',
  'fa' => 'IR',
  'zh' => 'CN',
  _ => null,
};

const _timeZones = <String, Set<String>>{
  'RU': {
    'Europe/Kaliningrad',
    'Europe/Moscow',
    'Europe/Simferopol',
    'Europe/Kirov',
    'Europe/Volgograd',
    'Europe/Astrakhan',
    'Europe/Saratov',
    'Europe/Ulyanovsk',
    'Europe/Samara',
    'Asia/Yekaterinburg',
    'Asia/Omsk',
    'Asia/Novosibirsk',
    'Asia/Barnaul',
    'Asia/Tomsk',
    'Asia/Novokuznetsk',
    'Asia/Krasnoyarsk',
    'Asia/Irkutsk',
    'Asia/Chita',
    'Asia/Yakutsk',
    'Asia/Khandyga',
    'Asia/Vladivostok',
    'Asia/Ust-Nera',
    'Asia/Magadan',
    'Asia/Sakhalin',
    'Asia/Srednekolymsk',
    'Asia/Kamchatka',
    'Asia/Anadyr',
  },
  'IR': {'Asia/Tehran'},
  'CN': {
    'Asia/Shanghai',
    'Asia/Urumqi',
    'Asia/Chongqing',
    'Asia/Harbin',
    'Asia/Kashgar',
  },
  'EG': {'Africa/Cairo'},
};
