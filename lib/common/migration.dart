import 'package:reclash/common/constant.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/ui/color.dart';

import 'preferences.dart';
import 'task.dart';

typedef MigrationTransform =
    Future<MigrationData> Function(Map<String, Object?> configMap);

abstract interface class MigrationStore {
  /// False when the backing store could not be opened at all, as opposed to a
  /// store that opened but holds nothing.
  Future<bool> get isAvailable;

  Future<Map<String, Object?>?> getConfigMap();

  Future<int> getVersion();

  Future<Map<String, Object?>?> getClashConfigMap();

  Future<void> restore(MigrationData data);

  Future<bool> saveConfig(Config config);

  Future<void> clearClashConfig();

  Future<void> setVersion(int version);

  Future<int> getUpgradeVersion();

  Future<void> setUpgradeVersion(int version);
}

class _AppMigrationStore implements MigrationStore {
  const _AppMigrationStore();

  @override
  Future<bool> get isAvailable => preferences.isInit;

  @override
  Future<Map<String, Object?>?> getConfigMap() => preferences.getConfigMap();

  @override
  Future<int> getVersion() => preferences.getVersion();

  @override
  Future<Map<String, Object?>?> getClashConfigMap() =>
      preferences.getClashConfigMap();

  @override
  Future<void> restore(MigrationData data) {
    return database.restore(
      data.profiles,
      data.scripts,
      data.rules,
      data.disabledRules,
      data.proxyGroups,
      clashProviders: data.clashProviders,
    );
  }

  @override
  Future<bool> saveConfig(Config config) => preferences.saveConfig(config);

  @override
  Future<void> clearClashConfig() => preferences.clearClashConfig();

  @override
  Future<void> setVersion(int version) => preferences.setVersion(version);

  @override
  Future<int> getUpgradeVersion() => preferences.getUpgradeVersion();

  @override
  Future<void> setUpgradeVersion(int version) =>
      preferences.setUpgradeVersion(version);
}

class Migration {
  final MigrationStore _store;
  final MigrationTransform _migrateV0;

  Migration({required MigrationStore store, MigrationTransform? migrateV0})
    : _store = store,
      _migrateV0 = migrateV0 ?? oldToNowTask;

  static const currentVersion = 1;

  /// One-off setting changes for upgrades, apart from [currentVersion], which
  /// backups carry and an older app refuses when it is newer than its own.
  static const upgradeVersion = 5;

  static const Map<int, Config Function(Config config)> _upgrades = {
    1: _resetThemeColors,
    2: _keepGlassLook,
    3: _followSystemColors,
    4: _turnOffSidebarBlur,
    5: _linkSiteLockPresets,
  };

  Future<Config> run() async {
    final configMap = await _store.getConfigMap();
    final int version;
    final int upgrade;
    try {
      version = await _store.getVersion();
      upgrade = await _store.getUpgradeVersion();
    } catch (_) {
      if (await _store.isAvailable) rethrow;
      return Config.realFromJson(null);
    }
    final config = await _migrate(configMap, version);
    return _upgrade(config, installed: configMap != null, from: upgrade);
  }

  Future<Config> _upgrade(
    Config config, {
    required bool installed,
    required int from,
  }) async {
    if (from >= upgradeVersion) {
      return config;
    }
    var upgraded = config;
    if (installed) {
      for (var version = from + 1; version <= upgradeVersion; version++) {
        upgraded = _upgrades[version]!(upgraded);
      }
    }
    if (upgraded != config && !await _store.saveConfig(upgraded)) {
      return config;
    }
    await _store.setUpgradeVersion(upgradeVersion);
    return upgraded;
  }

  Future<Config> _migrate(
    Map<String, Object?>? configMap,
    int storedVersion,
  ) async {
    var oldVersion = storedVersion;
    Config? config;
    if (oldVersion > currentVersion) {
      throw StateError(
        'Local data version $oldVersion is newer than $currentVersion.',
      );
    }
    if (oldVersion == currentVersion) {
      if (configMap != null && _isV0(configMap)) {
        try {
          config = Config.strictFromJson(configMap);
        } catch (_) {
          oldVersion = 0;
        }
      } else {
        config = Config.realFromJson(configMap);
      }
      if (config != null) {
        final storedDavPassword = _getStoredDavPassword(configMap);
        final hasPlainTextDavPassword =
            storedDavPassword != null &&
            storedDavPassword == config.davProps?.password;
        if (hasPlainTextDavPassword && !await _store.saveConfig(config)) {
          throw StateError('Failed to obfuscate the legacy WebDAV password');
        }
        return config;
      }
    }

    MigrationData data = MigrationData(configMap: configMap);
    var shouldClearClashConfig = false;
    if (oldVersion == 0) {
      final clashConfigMap = await _store.getClashConfigMap();
      if (_isV0(configMap) && configMap != null) {
        final legacyConfigMap = Map<String, Object?>.from(configMap);
        if (clashConfigMap != null) {
          legacyConfigMap['patchClashConfig'] = clashConfigMap;
          shouldClearClashConfig = true;
        }
        data = await _migrateV0(legacyConfigMap);
      } else if (clashConfigMap != null) {
        final currentConfigMap = Map<String, Object?>.from(
          configMap ?? const {},
        );
        currentConfigMap.putIfAbsent('patchClashConfig', () => clashConfigMap);
        data = MigrationData(configMap: currentConfigMap);
        shouldClearClashConfig = true;
      }
    }

    config = Config.realFromJson(data.configMap);
    await _store.restore(data);
    if (!await _store.saveConfig(config)) {
      // An unopenable store is reported later by the corrupt-cache dialog,
      // which offers a reset; failing here would hide that path.
      if (await _store.isAvailable) {
        throw StateError('Failed to save migrated preferences');
      }
      return config;
    }
    if (shouldClearClashConfig) {
      await _store.clearClashConfig();
    }
    await _store.setVersion(currentVersion);
    return config;
  }
}

Config _resetThemeColors(Config config) => config.copyWith(
  themeProps: config.themeProps.copyWith(
    primaryColor: defaultPrimaryColor,
    primaryColors: defaultPrimaryColors,
    colorStyle: ColorStyle.vivid,
  ),
);

// The standard glass became the ultra tier when a lighter standard joined it.
Config _keepGlassLook(Config config) =>
    config.themeProps.liquidGlass == LiquidGlassMode.standard
    ? config.copyWith(
        themeProps: config.themeProps.copyWith(
          liquidGlass: LiquidGlassMode.ultra,
        ),
      )
    : config;

const _formerSystemColors = {
  0xFFAF52DE: 0xFFCB30E0,
  0xFFFF3B30: 0xFFFF383C,
  0xFFFF9500: 0xFFFF8D28,
};

// Every preset but blue moved to iOS 27's system color; one picked before moves.
Config _followSystemColors(Config config) {
  final theme = config.themeProps;
  return config.copyWith(
    themeProps: theme.copyWith(
      primaryColor:
          _formerSystemColors[theme.primaryColor] ?? theme.primaryColor,
      primaryColors: [
        ...{
          for (final color in theme.primaryColors)
            _formerSystemColors[color] ?? color,
        },
      ],
    ),
  );
}

// Releases stored sidebar blur on while its switch stayed hidden.
Config _turnOffSidebarBlur(Config config) =>
    config.copyWith(themeProps: config.themeProps.copyWith(sidebarBlur: false));

// Releases copied a preset's entries into the lock. A lock still holding a
// shipped copy follows that preset instead and keeps only entries of its own.
const _shippedSiteLockPresets = <String, List<String>>{
  'claude': [
    'DOMAIN-SUFFIX,anthropic.com',
    'DOMAIN-SUFFIX,claude.ai',
    'DOMAIN-SUFFIX,claude.com',
    'DOMAIN-SUFFIX,claudeusercontent.com',
    'DOMAIN-SUFFIX,claudemcpcontent.com',
    'DOMAIN-SUFFIX,clau.de',
    'DOMAIN,http-intake.logs.us5.datadoghq.com',
    'DOMAIN,browser-intake-us5-datadoghq.com',
    'DOMAIN,o1158394.ingest.us.sentry.io',
    'IP-CIDR,160.79.104.0/21,no-resolve',
    'IP-CIDR,153.61.208.0/20,no-resolve',
    'IP-CIDR,153.61.224.0/22,no-resolve',
    'IP-CIDR6,2607:6bc0::/48,no-resolve',
  ],
  'chatgpt': [
    'GEOSITE,openai',
    'DOMAIN-SUFFIX,chatgpt.com',
    'DOMAIN-SUFFIX,oaistatic.com',
    'DOMAIN-SUFFIX,oaiusercontent.com',
    'DOMAIN-SUFFIX,openai.com',
  ],
  'gemini': ['GEOSITE,google-gemini'],
  'grok': ['DOMAIN-SUFFIX,x.ai', 'DOMAIN-SUFFIX,grok.com'],
  'perplexity': ['GEOSITE,perplexity'],
  'deepseek': ['GEOSITE,deepseek'],
  'cursor': ['GEOSITE,cursor'],
};

Config _linkSiteLockPresets(Config config) => config.copyWith(
  siteLocks: [for (final lock in config.siteLocks) _linkSiteLockPreset(lock)],
);

SiteLock _linkSiteLockPreset(SiteLock lock) {
  if (lock.preset.isNotEmpty) return lock;
  for (final MapEntry(key: id, value: copy)
      in _shippedSiteLockPresets.entries) {
    final preset = siteLockPresetOf(id);
    if (preset == null || !copy.every(lock.match.contains)) continue;
    final covered = {...copy, ...preset.match};
    return lock.copyWith(
      preset: id,
      match: [
        for (final entry in lock.match)
          if (!covered.contains(entry)) entry,
      ],
    );
  }
  return lock;
}

bool _isV0(Map<String, Object?>? configMap) =>
    configMap?['proxiesStyle'] != null;

String? _getStoredDavPassword(Map<String, Object?>? configMap) {
  final dav = configMap?['davProps'] ?? configMap?['dav'];
  if (dav is! Map) {
    return null;
  }
  final password = dav['password'];
  return password is String && password.isNotEmpty ? password : null;
}

final migration = Migration(store: const _AppMigrationStore());
