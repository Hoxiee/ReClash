import 'package:reclash/common/regional/regional.dart';
import 'package:reclash/models/models.dart';

/// Data for one shipped country. Replaces the scattered `Map<AppRegion, T>`
/// tables that used to live across `common/regional/`. Adding a country is a
/// data entry in [_profiles] (plus package-matcher assets), never a new enum
/// value or a `switch` arm.
class CountryProfile {
  const CountryProfile({
    required this.dns,
    this.bypassHead = const [],
    this.restrictedCapabilities = const {},
    this.simNetworkCountries = const {},
    this.timeZones = const {},
    this.languageCodes = const {},
  });

  final Dns dns;
  final List<String> bypassHead;

  /// The gated facets this country may use. Facets absent from [_gatedFacets]
  /// are available everywhere and are never listed here.
  final Set<RegionalFacetId> restrictedCapabilities;

  /// Upper-case ISO alpha-2 codes (SIM or serving network) that resolve here.
  final Set<String> simNetworkCountries;
  final Set<String> timeZones;

  /// Lower-case language codes, only where a language names one country.
  final Set<String> languageCodes;
}

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

// Neutral public DoH, same as _dnsOther, only the geoip home differs.
const _dnsEgypt = Dns(
  defaultNameserver: ['1.1.1.1', '8.8.8.8'],
  nameserver: [
    'https://cloudflare-dns.com/dns-query',
    'https://dns.google/dns-query',
  ],
  fallback: [],
  proxyServerNameserver: ['https://cloudflare-dns.com/dns-query'],
  fakeIpFilter: ['*.lan'],
  nameserverPolicy: {},
  fallbackFilter: FallbackFilter(geoipCode: 'EG'),
);

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

const _bypassChina = [
  '*zhihu.com',
  '*zhimg.com',
  '*jd.com',
  '100ime-iat-api.xfyun.cn',
  '*360buyimg.com',
];

// A faked locale can't hide the time zone, and it needs no SIM.
const _russianZones = {
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
};

const _chineseZones = {
  'Asia/Shanghai',
  'Asia/Urumqi',
  'Asia/Chongqing',
  'Asia/Harbin',
  'Asia/Kashgar',
};

const _profiles = <String, CountryProfile>{
  'RU': CountryProfile(
    dns: _dnsRussia,
    restrictedCapabilities: {
      RegionalFacetId.desync,
      RegionalFacetId.deviceIdentity,
      RegionalFacetId.packageMatcher,
    },
    simNetworkCountries: {'RU'},
    timeZones: _russianZones,
    languageCodes: {'ru'},
  ),
  'IR': CountryProfile(
    dns: _dnsIran,
    restrictedCapabilities: {
      RegionalFacetId.desync,
      RegionalFacetId.packageMatcher,
    },
    simNetworkCountries: {'IR'},
    timeZones: {'Asia/Tehran'},
    languageCodes: {'fa'},
  ),
  'CN': CountryProfile(
    dns: defaultDns,
    bypassHead: _bypassChina,
    restrictedCapabilities: {RegionalFacetId.packageMatcher},
    simNetworkCountries: {'CN'},
    timeZones: _chineseZones,
    languageCodes: {'zh'},
  ),
  // First data-only country: no enum, no switch. Arabic names too many countries
  // to disambiguate, so no languageCodes; SIM/network EG and Africa/Cairo detect.
  'EG': CountryProfile(
    dns: _dnsEgypt,
    restrictedCapabilities: {RegionalFacetId.packageMatcher},
    simNetworkCountries: {'EG'},
    timeZones: {'Africa/Cairo'},
  ),
};

const _fallbackProfile = CountryProfile(dns: _dnsOther);

// The only facets a country can be denied; every other facet is available
// everywhere. Mirrors the keys of the former `_facetRegions` table.
const _gatedFacets = {
  RegionalFacetId.desync,
  RegionalFacetId.deviceIdentity,
  RegionalFacetId.packageMatcher,
};

/// Upper-case ISO alpha-2 codes of every country that ships a profile.
Iterable<String> get shippedCountryCodes => _profiles.keys;

/// The identity a device carries when no shipped profile matches it. Distinct
/// from `null`, which means the region has not been detected or chosen yet.
const otherRegionCode = 'OTHER';

/// Upper-case ISO code, or null for empty input. The canonical form every
/// region comparison and store write normalizes through.
String? normalizedRegionCode(String? code) => _normalizeCode(code);

String? _normalizeCode(String? code) {
  final trimmed = code?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed.toUpperCase();
}

/// Deserializes a persisted region: shipped codes and the [otherRegionCode]
/// sentinel round-trip, anything else (a future or corrupt value) restores as
/// unset so it never masquerades as a region the build does not ship.
String? sanitizeRegionCode(Object? value) {
  final code = _normalizeCode(value is String ? value : null);
  if (code == null) return null;
  if (code == otherRegionCode || _profiles.containsKey(code)) return code;
  return null;
}

CountryProfile profileForCode(String? code) =>
    _profiles[_normalizeCode(code)] ?? _fallbackProfile;

bool hasProfileForCode(String? code) =>
    _profiles.containsKey(_normalizeCode(code));

Set<RegionalFacetId> capabilitiesForCode(String? code) {
  final profile = profileForCode(code);
  return {
    for (final id in RegionalFacetId.values)
      if (!_gatedFacets.contains(id) ||
          profile.restrictedCapabilities.contains(id))
        id,
  };
}

Dns dnsForCode(String? code) => profileForCode(code).dns;

bool isShippedDnsValue(Dns dns) =>
    dns == _fallbackProfile.dns ||
    _profiles.values.any((profile) => profile.dns == dns);

List<String> bypassForCode(String? code) => [
  ...profileForCode(code).bypassHead,
  ..._sharedBypass,
];

bool isShippedBypassValue(List<String> domains) =>
    _listEquals(bypassForCode(null), domains) ||
    _profiles.keys.any((code) => _listEquals(bypassForCode(code), domains));

String? codeForCountryCode(String? code) {
  final normalized = _normalizeCode(code);
  return (normalized != null && _profiles.containsKey(normalized))
      ? normalized
      : null;
}

String? codeForTimeZone(String? id) {
  final zone = id?.trim();
  if (zone == null || zone.isEmpty) return null;
  for (final entry in _profiles.entries) {
    if (entry.value.timeZones.contains(zone)) return entry.key;
  }
  return null;
}

String? codeForLanguage(String? code) {
  final language = code?.trim().toLowerCase();
  if (language == null || language.isEmpty) return null;
  for (final entry in _profiles.entries) {
    if (entry.value.languageCodes.contains(language)) return entry.key;
  }
  return null;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
