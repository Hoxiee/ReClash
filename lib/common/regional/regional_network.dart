import 'package:flutter/foundation.dart' show listEquals;
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';

({PatchClashConfig patchConfig, List<String> bypassDomain})
regionalNetworkConfigFor({
  required String? regionCode,
  required PatchClashConfig base,
  required List<String> defaultBypassDomains,
  required List<String> bypassDomains,
}) {
  final code = sanitizeRegionCode(regionCode);
  if (code == null) {
    return (patchConfig: base, bypassDomain: bypassDomains);
  }

  final profile = profileForCode(code);
  final appliedDnsKeys = profile.dnsOverrideKeys.difference(
    base.dnsOverrideKeys,
  );
  final tunKeys = base.tunOverrideKeys;
  final applyMtu =
      profile.tunMtu != defaultTunMtu &&
      base.tun.mtu == defaultTunMtu &&
      !tunKeys.contains(TunOverrideKey.mtu);
  final patchConfig = base.copyWith(
    dns: _overlayDns(base.dns, profile.dns, appliedDnsKeys),
    dnsOverrideKeys: {...base.dnsOverrideKeys, ...appliedDnsKeys},
    tun: applyMtu ? base.tun.copyWith(mtu: profile.tunMtu) : base.tun,
    tunOverride: applyMtu
        ? base.tunOverride.copyWith(mtu: profile.tunMtu)
        : base.tunOverride,
    tunOverrideKeys: applyMtu ? {...tunKeys, TunOverrideKey.mtu} : tunKeys,
  );
  if (!listEquals(bypassDomains, defaultBypassDomains)) {
    return (patchConfig: patchConfig, bypassDomain: bypassDomains);
  }
  final countryDomains = {
    for (final country in shippedCountryCodes)
      ...profileForCode(country).bypassDomains,
  };
  return (
    patchConfig: patchConfig,
    bypassDomain: {
      ...defaultBypassDomains.where(
        (domain) =>
            !countryDomains.contains(domain) ||
            profile.bypassDomains.contains(domain),
      ),
      ...profile.bypassDomains,
    }.toList(),
  );
}

ProfileOverrides regionalProfileOverridesFor({
  required PatchClashConfig patchConfig,
  required Set<DnsOverrideKey> appDnsOverrideKeys,
  ProfileOverrides? customOverrides,
}) {
  if (customOverrides == null) {
    return ProfileOverrides(
      dns: patchConfig.dns,
      dnsOverrideKeys: {
        ...patchConfig.dnsOverrideKeys.intersection(
          DnsOverrideKey.normalProfileKeys,
        ),
        ...patchConfig.dnsOverrideKeys.difference(appDnsOverrideKeys),
      },
      tun: patchConfig.tunOverride,
      tunOverrideKeys: patchConfig.tunOverrideKeys,
    );
  }
  final regionalDnsKeys = patchConfig.dnsOverrideKeys
      .difference(appDnsOverrideKeys)
      .difference(customOverrides.dnsOverrideKeys);
  return customOverrides
      .copyWith(
        dns: _overlayDns(customOverrides.dns, patchConfig.dns, regionalDnsKeys),
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
