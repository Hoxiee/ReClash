import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';
import 'package:reclash/models/config.dart' show defaultBypassDomain;

typedef RegionalNetwork = ({
  PatchClashConfig patchConfig,
  List<String> bypassDomain,
});

const _equality = DeepCollectionEquality();

const _appDnsKeys = {
  ...DnsOverrideKey.normalProfileKeys,
  DnsOverrideKey.fallbackFilterGeoipCode,
};

CountryProfile? _profileOf(String? code) {
  final region = sanitizeRegionCode(code);
  return region == null ? null : profileForCode(region);
}

List<String> regionBypassDomains(String? code) => [
  ...?_profileOf(code)?.bypassDomains,
  ...defaultBypassDomain,
];

int regionTunMtu(String? code) => _profileOf(code)?.tunMtu ?? defaultTunMtu;

Set<DnsOverrideKey> regionDnsKeys(String? code) =>
    _profileOf(code)?.dnsOverrideKeys ?? const {};

/// [dns] with the region's servers written over the keys it supplies.
Dns withRegionDns(Dns dns, String? code) {
  final profile = _profileOf(code);
  return profile == null
      ? dns
      : _overlayDns(dns, profile.dns, profile.dnsOverrideKeys);
}

bool _sameDns(Dns a, Dns b, DnsOverrideKey key) => _equality.equals(
  a.overrideJson({key}, keepEmpty: true),
  b.overrideJson({key}, keepEmpty: true),
);

PatchClashConfig _withMtu(PatchClashConfig patchConfig, int mtu) {
  final isDefault = mtu == defaultTunMtu;
  return patchConfig.copyWith(
    tun: patchConfig.tun.copyWith(mtu: mtu),
    tunOverride: patchConfig.tunOverride.copyWith(
      mtu: isDefault ? defaultProfileTun.mtu : mtu,
    ),
    tunOverrideKeys: isDefault
        ? patchConfig.tunOverrideKeys.difference({TunOverrideKey.mtu})
        : {...patchConfig.tunOverrideKeys, TunOverrideKey.mtu},
  );
}

/// Moves the values that still hold the [from] region's defaults over to the
/// [to] region's; anything the user changed stays as it is.
RegionalNetwork withRegionDefaults({
  required String? from,
  required String? to,
  required PatchClashConfig patchConfig,
  required List<String> bypassDomain,
}) {
  final previous = _profileOf(from);
  final next = _profileOf(to);
  var dns = patchConfig.dns;
  final dnsKeys = {...patchConfig.dnsOverrideKeys};
  for (final key in {...regionDnsKeys(from), ...regionDnsKeys(to)}) {
    final untouched =
        !dnsKeys.contains(key) ||
        (previous != null &&
            previous.dnsOverrideKeys.contains(key) &&
            _sameDns(dns, previous.dns, key));
    if (!untouched) continue;
    if (next != null && next.dnsOverrideKeys.contains(key)) {
      dns = _overlayDns(dns, next.dns, {key});
      dnsKeys.add(key);
    } else {
      dns = _overlayDns(dns, defaultDns, {key});
      dnsKeys.remove(key);
    }
  }
  var patched = patchConfig.copyWith(dns: dns, dnsOverrideKeys: dnsKeys);

  final fromMtu = regionTunMtu(from);
  final hasMtuKey = patchConfig.tunOverrideKeys.contains(TunOverrideKey.mtu);
  final mtu = patchConfig.tun.mtu;
  final mtuUntouched =
      (mtu == defaultTunMtu && !hasMtuKey) ||
      (mtu == fromMtu && (!hasMtuKey || patchConfig.tunOverride.mtu == mtu));
  if (mtuUntouched) {
    patched = _withMtu(patched, regionTunMtu(to));
  }

  final bypassUntouched = [
    null,
    ...shippedCountryCodes,
  ].any((code) => listEquals(bypassDomain, regionBypassDomains(code)));
  return (
    patchConfig: patched,
    bypassDomain: bypassUntouched ? regionBypassDomains(to) : bypassDomain,
  );
}

/// The bypass list and MTU the [code] region starts from.
RegionalNetwork regionNetworkDefaults(
  String? code,
  PatchClashConfig patchConfig,
) => (
  patchConfig: _withMtu(patchConfig, regionTunMtu(code)),
  bypassDomain: regionBypassDomains(code),
);

ProfileOverrides regionalProfileOverridesFor({
  required PatchClashConfig patchConfig,
  required String? regionCode,
  ProfileOverrides? customOverrides,
}) {
  if (customOverrides == null) {
    return ProfileOverrides(
      dns: patchConfig.dns,
      dnsOverrideKeys: patchConfig.dnsOverrideKeys.intersection(_appDnsKeys),
      tun: patchConfig.tunOverride,
      tunOverrideKeys: patchConfig.tunOverrideKeys,
    );
  }
  final profile = _profileOf(regionCode);
  final regionalDnsKeys = regionDnsKeys(
    regionCode,
  ).difference(customOverrides.dnsOverrideKeys);
  return customOverrides
      .copyWith(
        dns: profile == null
            ? customOverrides.dns
            : _overlayDns(customOverrides.dns, profile.dns, regionalDnsKeys),
        dnsOverrideKeys: {
          ...customOverrides.dnsOverrideKeys,
          ...regionalDnsKeys,
        },
      )
      .overAppTun(patchConfig.tunOverride, patchConfig.tunOverrideKeys);
}

Dns _overlayDns(Dns base, Dns regional, Set<DnsOverrideKey> keys) {
  var dns = base;
  for (final key in keys) {
    dns = switch (key) {
      DnsOverrideKey.defaultNameserver => dns.copyWith(
        defaultNameserver: regional.defaultNameserver,
      ),
      DnsOverrideKey.nameserver => dns.copyWith(
        nameserver: regional.nameserver,
      ),
      DnsOverrideKey.fallback => dns.copyWith(fallback: regional.fallback),
      DnsOverrideKey.proxyServerNameserver => dns.copyWith(
        proxyServerNameserver: regional.proxyServerNameserver,
      ),
      DnsOverrideKey.fakeIpFilter => dns.copyWith(
        fakeIpFilter: regional.fakeIpFilter,
      ),
      DnsOverrideKey.fallbackFilterGeoipCode => dns.copyWith(
        fallbackFilter: dns.fallbackFilter.copyWith(
          geoipCode: regional.fallbackFilter.geoipCode,
        ),
      ),
      _ => dns,
    };
  }
  return dns;
}
