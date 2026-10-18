import 'dart:ui';

import 'package:reclash/common/task.dart';
import 'package:reclash/models/state.dart';
import 'package:yaml/yaml.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/regional/country_profile.dart';
import 'package:reclash/common/regional/region_detection.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/clash_config.dart';
import 'package:reclash/models/config.dart';

void main() {
  group('region code normalization', () {
    test('trims and uppercases known and arbitrary values', () {
      expect(normalizedRegionCode('  ru '), 'RU');
      expect(normalizedRegionCode('other'), 'OTHER');
      expect(normalizedRegionCode(' unknown '), 'UNKNOWN');
    });

    test('sanitizes only supported codes and OTHER', () {
      expect(sanitizeRegionCode('cn'), 'CN');
      expect(sanitizeRegionCode(' other '), 'OTHER');
      expect(sanitizeRegionCode('US'), isNull);
      expect(sanitizeRegionCode(17), isNull);
      expect(sanitizeRegionCode('  '), isNull);
    });
  });

  group('country suggestions', () {
    test(
      'exposes concrete profile values only for supported country codes',
      () {
        expect(shippedCountryCodes, {'RU', 'IR', 'CN', 'EG', 'OTHER'});
        expect(hasProfileForCode('ru'), isTrue);
        expect(hasProfileForCode('us'), isFalse);
        expect(profileForCode('RU').dns.fallbackFilter.geoipCode, 'RU');
        expect(profileForCode('IR').dns.fallbackFilter.geoipCode, 'IR');
        expect(profileForCode('EG').dns.fallbackFilter.geoipCode, 'EG');
        expect(profileForCode('CN').bypassDomains, contains('*zhihu.com'));
        expect(profileForCode('CN').tunMtu, defaultTunMtu);
        expect(profileForCode('RU').tunMtu, regionalDefaultTunMtu);
        expect(profileForCode('RU').defaultServiceIds, [
          'youtube',
          'discord',
          'chatgpt',
          'claude',
        ]);
      },
    );

    test('unsupported regions receive only neutral defaults', () {
      final profile = profileForCode('US');
      expect(profile.dns, defaultDns);
      expect(profile.tunMtu, regionalDefaultTunMtu);
      expect(profile.bypassDomains, isEmpty);
    });
  });

  group('regional network overlay', () {
    test(
      'applies only profile DNS fields without replacing user overrides',
      () {
        const base = PatchClashConfig(
          dns: Dns(
            nameserver: ['https://user.example/dns-query'],
            fallbackFilter: FallbackFilter(geoipCode: 'US'),
          ),
          dnsOverrideKeys: {
            DnsOverrideKey.nameserver,
            DnsOverrideKey.fallbackFilterGeoipCode,
          },
        );

        final result = regionalNetworkConfigFor(
          regionCode: 'RU',
          base: base,
          defaultBypassDomains: defaultBypassDomain,
          bypassDomains: defaultBypassDomain,
        );

        expect(result.patchConfig.dns.nameserver, [
          'https://user.example/dns-query',
        ]);
        expect(result.patchConfig.dns.fallbackFilter.geoipCode, 'US');
        expect(result.patchConfig.dns.defaultNameserver, [
          '77.88.8.8',
          '77.88.8.1',
        ]);
        expect(result.patchConfig.dns.fallback, [
          'https://dns.adguard-dns.com/dns-query',
          'https://dns.quad9.net/dns-query',
        ]);
        expect(result.patchConfig.dns.fakeIpFilter, base.dns.fakeIpFilter);
        expect(result.patchConfig.tun.mtu, regionalDefaultTunMtu);
        expect(
          result.patchConfig.tunOverrideKeys,
          contains(TunOverrideKey.mtu),
        );
        expect(
          result.patchConfig.dnsOverrideKeys,
          containsAll(base.dnsOverrideKeys),
        );
        expect(result.bypassDomain, isNot(contains('*zhihu.com')));
      },
    );

    test('keeps custom MTU and bypass lists unchanged', () {
      const base = PatchClashConfig(
        tun: Tun(mtu: 1400),
        tunOverrideKeys: {TunOverrideKey.mtu},
      );
      final customBypass = ['custom.example'];

      final result = regionalNetworkConfigFor(
        regionCode: 'CN',
        base: base,
        defaultBypassDomains: defaultBypassDomain,
        bypassDomains: customBypass,
      );

      expect(result.patchConfig.tun.mtu, 1400);
      expect(result.bypassDomain, customBypass);
    });

    test('unset or unsupported region leaves network settings untouched', () {
      const base = PatchClashConfig(
        dns: Dns(nameserver: ['https://user.example/dns-query']),
      );
      for (final region in [null, 'US']) {
        final result = regionalNetworkConfigFor(
          regionCode: region,
          base: base,
          defaultBypassDomains: defaultBypassDomain,
          bypassDomains: const ['custom.example'],
        );
        expect(result.patchConfig, base);
        expect(result.bypassDomain, ['custom.example']);
      }
    });
  });

  group('regional profile generation', () {
    PatchClashConfig regional(
      String? code, [
      PatchClashConfig base = const PatchClashConfig(),
    ]) => regionalNetworkConfigFor(
      regionCode: code,
      base: base,
      defaultBypassDomains: defaultBypassDomain,
      bypassDomains: defaultBypassDomain,
    ).patchConfig;

    test(
      'writes regional DNS and desktop MTU into the final profile',
      () async {
        final patch = regional('RU');
        final overrides = regionalProfileOverridesFor(
          patchConfig: patch,
          appDnsOverrideKeys: const {},
        );
        final result = await makeRealProfileTask(
          MakeRealProfileState(
            profilesPath: '/profiles',
            profileId: 1,
            rawConfig: const {
              'dns': {
                'enable': true,
                'nameserver': ['1.1.1.1'],
              },
              'tun': {'mtu': 9000},
              'rules': ['MATCH,DIRECT'],
            },
            realPatchConfig: patch,
            overrides: overrides,
            appendSystemDns: false,
            proxyGroups: const [],
            rules: const [],
            addedRules: const [],
            defaultUA: 'test',
          ),
        );
        final config = loadYaml(result.yaml) as YamlMap;
        expect(config['dns']['nameserver'], [
          'tls://77.88.8.8',
          'tls://77.88.8.1',
        ]);
        expect(config['dns']['fallback-filter']['geoip-code'], 'RU');
        expect(config['tun']['mtu'], regionalDefaultTunMtu);
        expect(config['rules'], ['MATCH,DIRECT']);
      },
    );

    test('retains custom-profile DNS, MTU, NTP and routing overrides', () {
      const own = ProfileOverrides(
        dns: Dns(nameserver: ['https://custom.example/dns-query']),
        dnsOverrideKeys: {DnsOverrideKey.nameserver},
        tun: ProfileTun(mtu: 1400, routeExcludeAddress: ['10.0.0.0/8']),
        tunOverrideKeys: {
          TunOverrideKey.mtu,
          TunOverrideKey.routeExcludeAddress,
        },
        ntpOverrideKeys: {NtpOverrideKey.enable},
      );
      final overrides = regionalProfileOverridesFor(
        patchConfig: regional('RU'),
        appDnsOverrideKeys: const {},
        customOverrides: own,
      );
      expect(overrides.dns.nameserver, own.dns.nameserver);
      expect(overrides.dns.defaultNameserver, ['77.88.8.8', '77.88.8.1']);
      expect(overrides.tun.mtu, 1400);
      expect(overrides.tun.routeExcludeAddress, ['10.0.0.0/8']);
      expect(overrides.ntpOverrideKeys, own.ntpOverrideKeys);
      expect(own.dnsOverrideKeys, {DnsOverrideKey.nameserver});
    });

    test('regional changes are reversible and never accumulate', () {
      const base = PatchClashConfig(dnsOverrideKeys: {DnsOverrideKey.ipv6});
      for (final code in ['RU', 'CN', 'IR', 'EG', 'OTHER', null, 'RU']) {
        final patch = regional(code, base);
        expect(base.dnsOverrideKeys, {DnsOverrideKey.ipv6});
        final overrides = regionalProfileOverridesFor(
          patchConfig: patch,
          appDnsOverrideKeys: base.dnsOverrideKeys,
        );
        expect(
          overrides.tunOverrideKeys.length,
          code != null && code != 'CN' ? 1 : 0,
        );
      }
      expect(regional(null, base), base);
      expect(regional('CN').dns.nameserver, defaultDns.nameserver);
    });

    test('preserves Android MTU changed without desktop override keys', () {
      const base = PatchClashConfig(tun: Tun(mtu: 1420));
      expect(regional('RU', base).tun.mtu, 1420);
      expect(regional('RU', base).tunOverrideKeys, isEmpty);
    });

    test('keeps explicit desktop MTU even when Android is at its default', () {
      const base = PatchClashConfig(
        tunOverride: ProfileTun(mtu: 1280),
        tunOverrideKeys: {TunOverrideKey.mtu},
      );
      final patch = regional('RU', base);
      expect(patch.tunOverride.mtu, 1280);
      expect(patch.tun.mtu, defaultTunMtu);
    });

    test('an empty custom bypass list stays empty', () {
      final config = regionalNetworkConfigFor(
        regionCode: 'CN',
        base: const PatchClashConfig(),
        defaultBypassDomains: defaultBypassDomain,
        bypassDomains: const [],
      );
      expect(config.bypassDomain, isEmpty);
    });
  });

  group('region detection', () {
    test('prefers time zone over locale country and language', () {
      expect(
        detectRegion(
          const RegionSignals(timeZoneId: 'Africa/Cairo'),
          const Locale('ru', 'RU'),
        ),
        'EG',
      );
    });

    test('prefers locale country over locale language', () {
      expect(
        detectRegion(const RegionSignals(), const Locale('fa', 'CN')),
        'CN',
      );
    });

    test('falls back to unambiguous locale language', () {
      expect(detectRegion(const RegionSignals(), const Locale('zh')), 'CN');
      expect(detectRegion(const RegionSignals(), const Locale('ar')), isNull);
    });

    test('does not infer Russia or China from a different locale country', () {
      for (final locale in const [
        Locale('ru', 'KZ'),
        Locale('zh', 'TW'),
        Locale('zh', 'HK'),
        Locale('fa', 'AF'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ]) {
        expect(detectRegion(const RegionSignals(), locale), isNull);
      }
    });

    test('reports the signal that selected the region', () {
      final timeZoneResult = detectRegionWithSource(
        const RegionSignals(timeZoneId: 'Asia/Tehran'),
        const Locale('en', 'RU'),
      );
      expect(timeZoneResult?.countryCode, 'IR');
      expect(timeZoneResult?.source, RegionDetectionSource.timeZone);

      final localeResult = detectRegionWithSource(
        const RegionSignals(),
        const Locale('ru', 'RU'),
      );
      expect(localeResult?.countryCode, 'RU');
      expect(localeResult?.source, RegionDetectionSource.localeCountry);
    });

    test('returns null when every signal is unknown', () {
      expect(
        detectRegion(
          const RegionSignals(timeZoneId: 'Etc/UTC'),
          const Locale('en', 'US'),
        ),
        isNull,
      );
    });

    test('signals have no SIM or serving-network inputs', () {
      expect(const RegionSignals().timeZoneId, isNull);
      expect(
        detectRegion(const RegionSignals(), const Locale('en', 'US')),
        isNull,
      );
    });
  });
}
