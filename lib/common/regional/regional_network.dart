import 'package:flutter/foundation.dart' show listEquals;
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';
import 'package:reclash/models/config.dart' show defaultBypassDomain;

typedef RegionalNetwork = ({
  PatchClashConfig patchConfig,
  List<String> bypassDomain,
});

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
  var patched = patchConfig;

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
  return customOverrides.overAppTun(
    patchConfig.tunOverride,
    patchConfig.tunOverrideKeys,
  );
}
