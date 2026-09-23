import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container([
  Config config = const Config(themeProps: defaultThemeProps),
]) {
  final container = ProviderContainer(overrides: buildConfigOverrides(config));
  addTearDown(container.dispose);
  container.listen(configProvider, (_, _) {});
  return container;
}

Config _roundTrip(Config config) => Config.fromJson(
  jsonDecode(jsonEncode(config.toJson())) as Map<String, Object?>,
);

void main() {
  test('region defaults to nullable without changing HWID or routing', () {
    final container = _container();

    expect(container.read(appRegionProvider), AppRegion.other);
    expect(container.read(appSettingProvider).region, isNull);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    expect(container.read(smartRoutingSettingProvider).enabled, isFalse);
  });

  for (final region in AppRegion.values) {
    test('explicit ${region.name} persists independently of routing', () {
      final container = _container();
      selectAppRegion(container.read, region);

      final saved = _roundTrip(container.read(configProvider));
      expect(saved.appSettingProps.region, region);
      expect(
        saved.appSettingProps.sendDeviceIdentity,
        region == AppRegion.russia,
      );
      expect(saved.smartRoutingProps.enabled, isFalse);
      expect(saved.smartRoutingProps.preset, region.preset);
    });
  }

  for (final preset in SmartRoutingPreset.values) {
    for (final enabled in [false, true]) {
      test('legacy ${preset.name}/$enabled falls back without migration', () {
        final routing = SmartRoutingProps(enabled: enabled).applyPreset(preset);
        final original = Config(
          themeProps: defaultThemeProps,
          smartRoutingProps: routing,
        );
        final container = _container(_roundTrip(original));

        expect(container.read(appRegionProvider), AppRegion.fromPreset(preset));
        expect(container.read(configProvider), original);
        expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
      });
    }
  }

  test('existing RU preset enables HWID only on its first explicit choice', () {
    final routing = const SmartRoutingProps()
        .applyPreset(SmartRoutingPreset.russia)
        .copyWith(
          openMarkers: const [
            RcxMarker(url: 'https://example.com/', statuses: [200]),
          ],
        );
    final container = _container(
      Config(themeProps: defaultThemeProps, smartRoutingProps: routing),
    );

    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    selectAppRegion(container.read, AppRegion.russia);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    expect(container.read(smartRoutingSettingProvider), routing);

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(sendDeviceIdentity: false));
    selectAppRegion(container.read, AppRegion.russia);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    expect(container.read(smartRoutingSettingProvider), routing);
  });

  test(
    'manual HWID off survives save, restart and same-region confirmation',
    () {
      final first = _container();
      selectAppRegion(first.read, AppRegion.russia);
      first
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(sendDeviceIdentity: false));
      final second = _container(_roundTrip(first.read(configProvider)));
      expect(second.read(appRegionProvider), AppRegion.russia);
      selectAppRegion(second.read, AppRegion.russia);
      expect(second.read(appSettingProvider).sendDeviceIdentity, isFalse);

      selectAppRegion(second.read, AppRegion.iran);
      expect(second.read(appSettingProvider).sendDeviceIdentity, isFalse);
      selectAppRegion(second.read, AppRegion.russia);
      expect(second.read(appSettingProvider).sendDeviceIdentity, isTrue);
    },
  );

  test(
    'actual region change preserves enablement and custom strategy pacing',
    () {
      final routing = const SmartRoutingProps(enabled: true)
          .applyPreset(SmartRoutingPreset.russia)
          .applyStrategy(SmartRoutingStrategy.saver)
          .copyWith(dwellSeconds: 333, waveWidth: 7);
      final container = _container(
        Config(
          themeProps: defaultThemeProps,
          appSettingProps: const AppSettingProps(region: AppRegion.russia),
          smartRoutingProps: routing,
        ),
      );

      selectAppRegion(container.read, AppRegion.china);
      final changed = container.read(smartRoutingSettingProvider);
      expect(changed, routing.applyPreset(SmartRoutingPreset.china));
      expect(changed.enabled, isTrue);
      expect(changed.strategy, SmartRoutingStrategy.saver);
      expect(changed.dwellSeconds, 333);
      expect(changed.waveWidth, 7);
      expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    },
  );

  test(
    'same region does not reset custom markers or independently edited preset',
    () {
      final routing = const SmartRoutingProps(enabled: true)
          .applyPreset(SmartRoutingPreset.iran)
          .copyWith(
            openMarkers: const [
              RcxMarker(url: 'https://example.com/', statuses: [200]),
            ],
          );
      final container = _container(
        Config(
          themeProps: defaultThemeProps,
          appSettingProps: const AppSettingProps(region: AppRegion.russia),
          smartRoutingProps: routing,
        ),
      );

      selectAppRegion(container.read, AppRegion.russia);
      expect(container.read(smartRoutingSettingProvider), routing);
      expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
    },
  );

  test('Other retains an enabled engine with neutral operational markers', () {
    final container = _container(
      Config(
        themeProps: defaultThemeProps,
        appSettingProps: const AppSettingProps(region: AppRegion.russia),
        smartRoutingProps: const SmartRoutingProps(
          enabled: true,
        ).applyPreset(SmartRoutingPreset.russia),
      ),
    );

    selectAppRegion(container.read, AppRegion.other);
    final routing = container.read(smartRoutingSettingProvider);
    expect(routing.enabled, isTrue);
    expect(routing.rcxParams.openMarkers, isNotEmpty);
    expect(routing.censorCountries, isEmpty);
    expect(routing.canaryDomestic, isEmpty);
    expect(routing.domesticMarkers, isEmpty);
    expect(routing.breakerPatterns, isEmpty);
    expect(SmartRoutingPreset.off.bundle.openMarkers, isEmpty);
  });

  test(
    'unknown future region restores other app settings without consenting',
    () {
      final settings = AppSettingProps.safeFromJson({
        'region': 'future-region',
        'locale': 'ru',
        'autoRun': true,
        'sendDeviceIdentity': false,
      });
      expect(settings.region, isNull);
      expect(settings.locale, 'ru');
      expect(settings.autoRun, isTrue);
      expect(settings.sendDeviceIdentity, isFalse);
    },
  );

  test('legacy backup preserves explicit HWID permission either way', () {
    for (final consent in [true, false]) {
      final original = const Config(themeProps: defaultThemeProps).copyWith(
        appSettingProps: AppSettingProps(sendDeviceIdentity: consent),
        smartRoutingProps: const SmartRoutingProps(
          enabled: true,
        ).applyPreset(SmartRoutingPreset.russia),
      );
      final backup =
          jsonDecode(jsonEncode(original.toJson())) as Map<String, Object?>;
      (backup['appSettingProps'] as Map<String, Object?>).remove('region');
      final restored = _container(Config.fromJson(backup));
      expect(restored.read(appRegionProvider), AppRegion.russia);
      expect(restored.read(appSettingProvider).sendDeviceIdentity, consent);
      expect(restored.read(appSettingProvider).region, isNull);
    }
  });

  test('seed derives Russia from a native signal under an English locale', () {
    final container = _container();
    seedRegionIfUnset(
      container.read,
      const RegionSignals(simCountry: 'ru'),
      const Locale('en'),
    );
    expect(container.read(appSettingProvider).region, AppRegion.russia);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isTrue);
    expect(container.read(smartRoutingSettingProvider).preset,
        SmartRoutingPreset.russia);
    expect(container.read(smartRoutingSettingProvider).enabled, isFalse);
  });

  test('seed leaves the region unset for an unshipped region', () {
    final container = _container();
    seedRegionIfUnset(
      container.read,
      const RegionSignals(simCountry: 'us'),
      const Locale('en', 'US'),
    );
    expect(container.read(appSettingProvider).region, isNull);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });

  test('seed never overrides an explicit choice', () {
    final container = _container(
      const Config(
        themeProps: defaultThemeProps,
        appSettingProps: AppSettingProps(region: AppRegion.china),
      ),
    );
    seedRegionIfUnset(
      container.read,
      const RegionSignals(simCountry: 'ru'),
      const Locale('ru'),
    );
    expect(container.read(appSettingProvider).region, AppRegion.china);
    expect(container.read(appSettingProvider).sendDeviceIdentity, isFalse);
  });

  test('config seed applies every regional default in one value', () {
    final seeded = seedRegionIfUnsetConfig(
      const Config(themeProps: defaultThemeProps),
      const RegionSignals(simCountry: 'ru'),
      const Locale('en'),
    );
    expect(seeded.appSettingProps.region, AppRegion.russia);
    expect(seeded.appSettingProps.sendDeviceIdentity, isTrue);
    expect(seeded.smartRoutingProps.preset, SmartRoutingPreset.russia);
    expect(seeded.smartRoutingProps.enabled, isFalse);
    expect(seeded.patchClashConfig.dns, dnsForRegion(AppRegion.russia));
    expect(seeded.networkProps.bypassDomain, bypassForRegion(AppRegion.russia));
  });

  test('config seed is a no-op for an unshipped region or explicit choice', () {
    const base = Config(themeProps: defaultThemeProps);
    expect(
      identical(
        seedRegionIfUnsetConfig(
          base,
          const RegionSignals(simCountry: 'us'),
          const Locale('en'),
        ),
        base,
      ),
      isTrue,
    );
    const chosen = Config(
      themeProps: defaultThemeProps,
      appSettingProps: AppSettingProps(region: AppRegion.china),
    );
    expect(
      identical(
        seedRegionIfUnsetConfig(
          chosen,
          const RegionSignals(simCountry: 'ru'),
          const Locale('ru'),
        ),
        chosen,
      ),
      isTrue,
    );
  });

  test('bootstrap-seeded DNS and bypass survive without a listener', () async {
    final seeded = seedRegionIfUnsetConfig(
      const Config(themeProps: defaultThemeProps),
      const RegionSignals(simCountry: 'ru'),
      const Locale('en'),
    );
    final container = ProviderContainer(overrides: buildConfigOverrides(seeded));
    addTearDown(container.dispose);
    // No listener: reproduces bootstrap, where mutating auto-dispose providers
    // lost these facets before the fix baked them into the overrides.
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(patchClashConfigProvider).dns,
      dnsForRegion(AppRegion.russia),
    );
    expect(
      container.read(networkSettingProvider).bypassDomain,
      bypassForRegion(AppRegion.russia),
    );
    expect(container.read(appSettingProvider).region, AppRegion.russia);
  });
}
