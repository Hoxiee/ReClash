import 'dart:convert';

import 'package:reclash/common/migration.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Migration', () {
    test('returns current config without rewriting storage', () async {
      final configMap = _createConfigMap(
        davProps: const DAVProps(
          uri: 'https://example.com/dav',
          user: 'user',
          password: 'secret',
        ),
      );
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config, Config.realFromJson(configMap));
      expect(config.davProps?.password, 'secret');
      expect(store.events, ['getConfigMap', 'getVersion']);
    });

    test('restores the strategy left by an interrupted DPI test', () async {
      const original = ['-d1', '-s1'];
      final configMap = _createConfigMap(
        desyncProps: const DesyncProps(
          strategyArgs: ['-f-1', '-a1'],
          testRunning: true,
          testRestoreArgs: original,
        ),
      );
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config.desyncProps.strategyArgs, original);
      expect(config.desyncProps.testRunning, isFalse);
      expect(config.desyncProps.testRestoreArgs, isNull);
      expect(store.savedConfig, config);
      expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
    });

    test('still restores when persisting DPI recovery fails', () async {
      final configMap = _createConfigMap(
        desyncProps: const DesyncProps(
          strategyArgs: ['-f-1', '-a1'],
          testRunning: true,
          testRestoreArgs: ['-d1', '-s1'],
        ),
      );
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
        configSaveResult: false,
      );

      final config = await Migration(store: store).run();

      expect(config.desyncProps.strategyArgs, ['-d1', '-s1']);
      expect(config.desyncProps.testRunning, isFalse);
      expect(config.desyncProps.testRestoreArgs, isNull);
      expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
    });

    test(
      'obfuscates a compatible DAV password without a version migration',
      () async {
        final configMap = _createConfigMap(
          davProps: const DAVProps(
            uri: 'https://example.com/dav',
            user: 'user',
          ),
        );
        final davProps = configMap['davProps']! as Map<String, Object?>;
        davProps['password'] = 'secret';
        final store = _FakeMigrationStore(
          configMap: configMap,
          version: Migration.currentVersion,
        );

        final config = await Migration(store: store).run();

        expect(config.davProps?.user, 'user');
        expect(config.davProps?.password, 'secret');
        expect(store.savedConfig, config);
        expect(store.version, Migration.currentVersion);
        expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
        final savedConfigMap =
            jsonDecode(jsonEncode(store.savedConfig)) as Map<String, Object?>;
        final savedDavProps =
            savedConfigMap['davProps']! as Map<String, Object?>;
        expect(savedDavProps['password'], startsWith('v1.'));
        expect(savedDavProps['password'], isNot(contains('secret')));
      },
    );

    test(
      'commits v0 cleanup and version only after migrated data is saved',
      () async {
        final configMap = <String, Object?>{
          'proxiesStyle': <String, Object?>{},
          'dav': <String, Object?>{
            'uri': 'https://example.com/dav',
            'user': 'user',
            'password': 'secret',
          },
        };
        final store = _FakeMigrationStore(
          configMap: configMap,
          version: 0,
          clashConfigMap: <String, Object?>{'mixed-port': 7890},
        );
        final migration = Migration(
          store: store,
          migrateV0: (configMap) async {
            store.events.add('migrateV0');
            expect(configMap['patchClashConfig'], store.clashConfigMap);
            return MigrationData(
              configMap: _createConfigMap(
                davProps: const DAVProps(
                  uri: 'https://example.com/dav',
                  user: 'user',
                  password: 'secret',
                ),
              ),
            );
          },
        );

        await migration.run();

        expect(store.events, [
          'getConfigMap',
          'getVersion',
          'getClashConfigMap',
          'migrateV0',
          'restore',
          'saveConfig',
          'clearClashConfig',
          'setVersion',
        ]);
        expect(store.savedConfig?.davProps?.password, 'secret');
        expect(store.didClearClashConfig, isTrue);
        expect(store.version, Migration.currentVersion);
      },
    );

    test(
      'preserves legacy clash config when current-shaped data has version zero',
      () async {
        final configMap = _createConfigMap()..remove('patchClashConfig');
        final clashConfigMap = _createClashConfigMap(mixedPort: 1234);
        final store = _FakeMigrationStore(
          configMap: configMap,
          version: 0,
          clashConfigMap: clashConfigMap,
        );

        final config = await Migration(store: store).run();

        expect(config.patchClashConfig.mixedPort, 1234);
        expect(store.savedConfig?.patchClashConfig.mixedPort, 1234);
        expect(store.didClearClashConfig, isTrue);
        expect(store.events, [
          'getConfigMap',
          'getVersion',
          'getClashConfigMap',
          'restore',
          'saveConfig',
          'clearClashConfig',
          'setVersion',
        ]);
      },
    );

    test('does not clear legacy clash config when saving fails', () async {
      final configMap = _createConfigMap()..remove('patchClashConfig');
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: 0,
        clashConfigMap: _createClashConfigMap(mixedPort: 1234),
        configSaveResult: false,
      );

      await expectLater(
        Migration(store: store).run(),
        throwsA(isA<StateError>()),
      );

      expect(store.didClearClashConfig, isFalse);
      expect(store.version, 0);
      expect(store.events, [
        'getConfigMap',
        'getVersion',
        'getClashConfigMap',
        'restore',
        'saveConfig',
        'isAvailable',
      ]);
    });

    test('starts with defaults when the store cannot be opened', () async {
      final store = _FakeMigrationStore(
        configMap: null,
        version: 0,
        configSaveResult: false,
        available: false,
      );

      final config = await Migration(store: store).run();

      expect(config, isNotNull);
      expect(store.didClearClashConfig, isFalse);
      expect(store.version, 0);
      expect(store.events, [
        'getConfigMap',
        'getVersion',
        'getClashConfigMap',
        'restore',
        'saveConfig',
        'isAvailable',
      ]);
    });

    test('keeps the current version when password obfuscation fails', () async {
      final configMap = _createConfigMap(
        davProps: const DAVProps(uri: 'https://example.com/dav', user: 'user'),
      );
      final davProps = configMap['davProps']! as Map<String, Object?>;
      davProps['password'] = 'secret';
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
        configSaveResult: false,
      );

      await expectLater(
        Migration(store: store).run(),
        throwsA(isA<StateError>()),
      );

      expect(store.events, ['getConfigMap', 'getVersion', 'saveConfig']);
      expect(store.version, Migration.currentVersion);
    });

    test(
      'v1 to v2 defaults an unset global-ua to the FlClashX preset',
      () async {
        final configMap = _createConfigMap();
        final patch = configMap['patchClashConfig']! as Map<String, Object?>;
        patch['global-ua'] = null;
        final store = _FakeMigrationStore(configMap: configMap, version: 1);

        final config = await Migration(store: store).run();

        expect(config.patchClashConfig.globalUa, flClashXCompatUa);
        expect(store.savedConfig?.patchClashConfig.globalUa, flClashXCompatUa);
        expect(store.version, Migration.currentVersion);
        expect(store.events, [
          'getConfigMap',
          'getVersion',
          'restore',
          'saveConfig',
          'setVersion',
        ]);
      },
    );

    test('v2 to v3 marks an existing install as already set up', () async {
      final store = _FakeMigrationStore(
        configMap: _createConfigMap(),
        version: 2,
      );

      final config = await Migration(store: store).run();

      expect(config.appSettingProps.setupCompleted, isTrue);
      expect(store.savedConfig?.appSettingProps.setupCompleted, isTrue);
      expect(store.version, Migration.currentVersion);
    });

    test('v2 to v3 leaves a clean install to the wizard', () async {
      final store = _FakeMigrationStore(configMap: null, version: 2);

      final config = await Migration(store: store).run();

      expect(config.appSettingProps.setupCompleted, isFalse);
    });

    test('v1 to v2 keeps a user-chosen global-ua', () async {
      final configMap = _createConfigMap();
      final patch = configMap['patchClashConfig']! as Map<String, Object?>;
      patch['global-ua'] = 'clash-verge/v2.4.2';
      final store = _FakeMigrationStore(configMap: configMap, version: 1);

      final config = await Migration(store: store).run();

      expect(config.patchClashConfig.globalUa, 'clash-verge/v2.4.2');
    });

    test('moves a legacy excludeSSIDs list into smart pause', () async {
      final configMap = _createConfigMap();
      configMap['excludeSSIDs'] = ['Home', 'Office'];
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config.vpnProps.smartPauseEnabled, isTrue);
      expect(config.vpnProps.smartPauseNetworks, ['Home', 'Office']);
    });

    test('keeps explicit smart pause networks over a legacy list', () async {
      final configMap = _createConfigMap();
      final vpnProps = configMap['vpnProps']! as Map<String, Object?>;
      vpnProps['smartPauseEnabled'] = true;
      vpnProps['smartPauseNetworks'] = ['Cafe'];
      configMap['excludeSSIDs'] = ['Home'];
      final store = _FakeMigrationStore(
        configMap: configMap,
        version: Migration.currentVersion,
      );

      final config = await Migration(store: store).run();

      expect(config.vpnProps.smartPauseEnabled, isTrue);
      expect(config.vpnProps.smartPauseNetworks, ['Cafe']);
    });

    test('v4 to v5 re-parses the seeded routing bundle in-process', () async {
      final configMap = _createConfigMap();
      configMap['smartRoutingProps'] = {'enabled': true, 'preset': 'ru'};
      final store = _FakeMigrationStore(configMap: configMap, version: 4);

      final config = await Migration(store: store).run();

      expect(store.version, Migration.currentVersion);
      expect(store.savedConfig?.smartRoutingProps.enabled, isTrue);
      expect(
        store.savedConfig?.smartRoutingProps.preset,
        SmartRoutingPreset.russia,
      );
      expect(store.savedConfig?.smartRoutingProps.openMarkers, isNotEmpty);
      expect(config.smartRoutingProps.openMarkers, isNotEmpty);
    });

    test('v5 to v6 drops the youtube open marker and keeps Telegram', () async {
      final configMap = _createConfigMap();
      configMap['smartRoutingProps'] = {
        'enabled': true,
        'preset': 'ru',
        'openMarkers': [
          {
            'url': 'https://www.youtube.com/generate_204',
            'statuses': [204],
          },
          {
            'url': 'https://api.telegram.org/',
            'statuses': [200, 404],
          },
        ],
      };
      final store = _FakeMigrationStore(configMap: configMap, version: 5);

      final config = await Migration(store: store).run();

      expect(store.version, Migration.currentVersion);
      final markers = config.smartRoutingProps.openMarkers;
      expect(markers, isNotEmpty);
      expect(markers.any((marker) => marker.url.contains('youtube')), isFalse);
      expect(markers.first.url, contains('telegram'));
    });

    test('v6 to v7 disables implicit network metadata sharing', () async {
      final configMap = _createConfigMap();
      final settings = configMap['appSettingProps']! as Map<String, Object?>;
      settings['autoCheckUpdate'] = true;
      settings['sendDeviceIdentity'] = true;
      final store = _FakeMigrationStore(configMap: configMap, version: 6);

      final config = await Migration(store: store).run();

      expect(config.appSettingProps.autoCheckUpdate, isFalse);
      expect(config.appSettingProps.sendDeviceIdentity, isFalse);
      expect(store.savedConfig?.appSettingProps.autoCheckUpdate, isFalse);
      expect(store.savedConfig?.appSettingProps.sendDeviceIdentity, isFalse);
      expect(store.version, Migration.currentVersion);
    });
  });
}

Map<String, Object?> _createConfigMap({
  DAVProps? davProps,
  DesyncProps desyncProps = defaultDesyncProps,
}) {
  return jsonDecode(
        jsonEncode(
          Config(
            themeProps: defaultThemeProps,
            davProps: davProps,
            desyncProps: desyncProps,
          ),
        ),
      )
      as Map<String, Object?>;
}

Map<String, Object?> _createClashConfigMap({required int mixedPort}) {
  return jsonDecode(jsonEncode(PatchClashConfig(mixedPort: mixedPort)))
      as Map<String, Object?>;
}

class _FakeMigrationStore implements MigrationStore {
  final Map<String, Object?>? configMap;
  final Map<String, Object?>? clashConfigMap;
  final bool configSaveResult;
  final bool available;
  final List<String> events = [];

  int version;
  Config? savedConfig;
  MigrationData? restoredData;
  bool didClearClashConfig = false;

  _FakeMigrationStore({
    required this.configMap,
    required this.version,
    this.clashConfigMap,
    this.configSaveResult = true,
    this.available = true,
  });

  @override
  Future<bool> get isAvailable async {
    events.add('isAvailable');
    return available;
  }

  @override
  Future<void> clearClashConfig() async {
    events.add('clearClashConfig');
    didClearClashConfig = true;
  }

  @override
  Future<Map<String, Object?>?> getClashConfigMap() async {
    events.add('getClashConfigMap');
    return clashConfigMap;
  }

  @override
  Future<Map<String, Object?>?> getConfigMap() async {
    events.add('getConfigMap');
    return configMap;
  }

  @override
  Future<int> getVersion() async {
    events.add('getVersion');
    return version;
  }

  @override
  Future<void> restore(MigrationData data) async {
    events.add('restore');
    restoredData = data;
  }

  @override
  Future<bool> saveConfig(Config config) async {
    events.add('saveConfig');
    savedConfig = config;
    return configSaveResult;
  }

  @override
  Future<void> setVersion(int version) async {
    events.add('setVersion');
    this.version = version;
  }
}
