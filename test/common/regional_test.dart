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

  group('regional defaults', () {
    RegionalNetwork switchRegion(
      String? from,
      String? to, {
      PatchClashConfig patchConfig = const PatchClashConfig(),
      List<String>? bypassDomain,
    }) => withRegionDefaults(
      from: from,
      to: to,
      patchConfig: patchConfig,
      bypassDomain: bypassDomain ?? regionBypassDomains(from),
    );

    test('writes the region DNS, MTU and bypass list into settings', () {
      final result = switchRegion(null, 'RU');

      expect(result.patchConfig.dnsOverrideKeys, regionDnsKeys('RU'));
      expect(result.patchConfig.dns.nameserver, [
        'tls://77.88.8.8',
        'tls://77.88.8.1',
      ]);
      expect(result.patchConfig.dns.fallbackFilter.geoipCode, 'RU');
      expect(result.patchConfig.tun.mtu, regionalDefaultTunMtu);
      expect(result.patchConfig.tunOverride.mtu, regionalDefaultTunMtu);
      expect(result.patchConfig.tunOverrideKeys, {TunOverrideKey.mtu});
      expect(result.bypassDomain, defaultBypassDomain);
    });

    test('keeps values the user changed', () {
      const base = PatchClashConfig(
        dns: Dns(
          nameserver: ['https://user.example/dns-query'],
          fallbackFilter: FallbackFilter(geoipCode: 'US'),
        ),
        dnsOverrideKeys: {
          DnsOverrideKey.nameserver,
          DnsOverrideKey.fallbackFilterGeoipCode,
          DnsOverrideKey.ipv6,
        },
        tun: Tun(mtu: 1400),
        tunOverride: ProfileTun(mtu: 1400),
        tunOverrideKeys: {TunOverrideKey.mtu},
      );

      final result = switchRegion(
        null,
        'RU',
        patchConfig: base,
        bypassDomain: const ['custom.example'],
      );

      expect(result.patchConfig.dns.nameserver, [
        'https://user.example/dns-query',
      ]);
      expect(result.patchConfig.dns.fallbackFilter.geoipCode, 'US');
      expect(result.patchConfig.dns.defaultNameserver, [
        '77.88.8.8',
        '77.88.8.1',
      ]);
      expect(
        result.patchConfig.dnsOverrideKeys,
        containsAll(base.dnsOverrideKeys),
      );
      expect(result.patchConfig.tun.mtu, 1400);
      expect(result.bypassDomain, ['custom.example']);
    });

    test('switching replaces only the previous region defaults', () {
      final russia = switchRegion(null, 'RU');
      final edited = russia.patchConfig.copyWith(
        dns: russia.patchConfig.dns.copyWith(
          fallback: const ['https://user.example/dns-query'],
        ),
      );

      final egypt = switchRegion(
        'RU',
        'EG',
        patchConfig: edited,
        bypassDomain: russia.bypassDomain,
      );

      expect(egypt.patchConfig.dns.nameserver, [
        'https://cloudflare-dns.com/dns-query',
        'https://dns.google/dns-query',
      ]);
      expect(egypt.patchConfig.dns.fallbackFilter.geoipCode, 'EG');
      expect(egypt.patchConfig.dns.fallback, [
        'https://user.example/dns-query',
      ]);
    });

    test('switching away and back never accumulates', () {
      const base = PatchClashConfig(
        dns: Dns(ipv6: true),
        dnsOverrideKeys: {DnsOverrideKey.ipv6},
      );
      var current = (patchConfig: base, bypassDomain: defaultBypassDomain);
      String? from;
      for (final code in ['RU', 'CN', 'IR', 'EG', 'OTHER', null, 'RU']) {
        current = switchRegion(
          from,
          code,
          patchConfig: current.patchConfig,
          bypassDomain: current.bypassDomain,
        );
        from = code;
        expect(current.patchConfig.dnsOverrideKeys, {
          DnsOverrideKey.ipv6,
          ...regionDnsKeys(code),
        });
        expect(current.bypassDomain, regionBypassDomains(code));
        expect(current.patchConfig.tun.mtu, regionTunMtu(code));
      }
      final cleared = switchRegion(
        'RU',
        null,
        patchConfig: current.patchConfig,
        bypassDomain: current.bypassDomain,
      );
      expect(cleared.patchConfig, base);
      expect(cleared.bypassDomain, defaultBypassDomain);
    });

    test('China adds its bypass domains and keeps the core MTU', () {
      final result = switchRegion(null, 'CN');
      expect(result.bypassDomain, contains('*zhihu.com'));
      expect(result.patchConfig.tun.mtu, defaultTunMtu);
      expect(result.patchConfig.tunOverrideKeys, isEmpty);
      expect(defaultBypassDomain, isNot(contains('*zhihu.com')));
    });

    test('an untouched list from any region follows the new region', () {
      final result = switchRegion(
        'RU',
        'EG',
        bypassDomain: regionBypassDomains('CN'),
      );
      expect(result.bypassDomain, regionBypassDomains('EG'));
    });

    test('an empty custom bypass list stays empty', () {
      expect(
        switchRegion(null, 'CN', bypassDomain: const []).bypassDomain,
        isEmpty,
      );
    });

    test('preserves Android MTU changed without desktop override keys', () {
      const base = PatchClashConfig(tun: Tun(mtu: 1420));
      final patch = switchRegion(null, 'RU', patchConfig: base).patchConfig;
      expect(patch.tun.mtu, 1420);
      expect(patch.tunOverrideKeys, isEmpty);
    });

    test('keeps explicit desktop MTU even when Android is at its default', () {
      const base = PatchClashConfig(
        tunOverride: ProfileTun(mtu: 1280),
        tunOverrideKeys: {TunOverrideKey.mtu},
      );
      final patch = switchRegion(null, 'RU', patchConfig: base).patchConfig;
      expect(patch.tunOverride.mtu, 1280);
      expect(patch.tun.mtu, defaultTunMtu);
    });

    test('restoring network defaults resets the bypass list and MTU', () {
      const edited = PatchClashConfig(
        tun: Tun(mtu: 1400),
        tunOverride: ProfileTun(mtu: 1400),
        tunOverrideKeys: {TunOverrideKey.mtu},
      );
      final russia = regionNetworkDefaults('RU', edited);
      expect(russia.patchConfig.tun.mtu, regionalDefaultTunMtu);
      expect(russia.patchConfig.tunOverride.mtu, regionalDefaultTunMtu);
      expect(russia.bypassDomain, defaultBypassDomain);
      final china = regionNetworkDefaults('CN', edited);
      expect(china.patchConfig.tun.mtu, defaultTunMtu);
      expect(china.patchConfig.tunOverrideKeys, isEmpty);
      expect(china.bypassDomain, contains('*zhihu.com'));
    });
  });

  group('regional profile generation', () {
    PatchClashConfig regional(String? code) => withRegionDefaults(
      from: null,
      to: code,
      patchConfig: const PatchClashConfig(),
      bypassDomain: defaultBypassDomain,
    ).patchConfig;

    test(
      'writes regional DNS and desktop MTU into the final profile',
      () async {
        final patch = regional('RU');
        final overrides = regionalProfileOverridesFor(
          patchConfig: patch,
          regionCode: 'RU',
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
        regionCode: 'RU',
        customOverrides: own,
      );
      expect(overrides.dns.nameserver, own.dns.nameserver);
      expect(overrides.dns.defaultNameserver, ['77.88.8.8', '77.88.8.1']);
      expect(overrides.tun.mtu, 1400);
      expect(overrides.tun.routeExcludeAddress, ['10.0.0.0/8']);
      expect(overrides.ntpOverrideKeys, own.ntpOverrideKeys);
      expect(own.dnsOverrideKeys, {DnsOverrideKey.nameserver});
    });

    test('custom profiles take no regional DNS without a region', () {
      const own = ProfileOverrides(
        dns: Dns(nameserver: ['https://custom.example/dns-query']),
        dnsOverrideKeys: {DnsOverrideKey.nameserver},
      );
      final overrides = regionalProfileOverridesFor(
        patchConfig: const PatchClashConfig(),
        regionCode: null,
        customOverrides: own,
      );
      expect(overrides.dnsOverrideKeys, own.dnsOverrideKeys);
      expect(overrides.dns, own.dns);
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
