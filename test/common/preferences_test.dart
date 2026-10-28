import 'dart:convert';

import 'package:reclash/common/boot_record.dart';
import 'package:reclash/common/constant.dart';
import 'package:reclash/common/migration.dart';
import 'package:reclash/common/preferences.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/preferences.dart';

const _sharedState = SharedState(
  stopTip: 'stop',
  startTip: 'start',
  localNetworkTip: 'local',
  currentProfileName: 'profile',
  stopText: 'stopped',
  onlyStatisticsProxy: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences store;

  setUp(() async {
    await mockPreferences();
    store = await SharedPreferences.getInstance();
  });

  tearDown(() => mockPreferences());

  group('applied config md5', () {
    test('round-trips a written md5 and forgets a cleared one', () async {
      expect(await preferences.getAppliedConfigMd5(), isNull);

      await preferences.saveAppliedConfigMd5('abc');
      expect(await preferences.getAppliedConfigMd5(), 'abc');

      await preferences.saveAppliedConfigMd5(null);
      expect(store.containsKey(appliedConfigMd5Key), isFalse);
    });
  });

  group('version', () {
    test('defaults to 0 when never written', () async {
      expect(await preferences.getVersion(), 0);
    });

    test('round-trips a written version', () async {
      await preferences.setVersion(7);

      expect(await preferences.getVersion(), 7);
    });
  });

  group('unreadable version markers', () {
    for (final key in ['version', 'upgradeVersion']) {
      for (final value in ['invalid', -1]) {
        test('rejects $value in $key without overwriting settings', () async {
          await store.setString(
            configKey,
            json.encode({'currentProfileId': 42}),
          );
          if (value is int) {
            await store.setInt(key, value);
          } else {
            await store.setString(key, value as String);
          }

          await expectLater(
            key == 'version'
                ? preferences.getVersion()
                : preferences.getUpgradeVersion(),
            throwsFormatException,
          );
          expect(await preferences.isInit, isFalse);
          expect(
            await preferences.saveConfig(Config.realFromJson(null)),
            isFalse,
          );
          expect(await migration.run(), Config.realFromJson(null));
          expect(store.get(key), value);
          expect(store.getKeys(), {configKey, key});
          expect(json.decode(store.getString(configKey)!), {
            'currentProfileId': 42,
          });
        });
      }
    }
  });

  group('config', () {
    test('getConfig returns null when nothing is stored', () async {
      expect(await preferences.getConfig(), isNull);
      expect(await preferences.isInit, isTrue);
      expect(await preferences.saveConfig(Config.realFromJson(null)), isTrue);
    });

    test('saveConfig then getConfig round-trips the model', () async {
      const config = Config(
        themeProps: defaultThemeProps,
        currentProfileId: 42,
        excludeSSIDs: ['home'],
      );

      expect(await preferences.saveConfig(config), isTrue);
      final restored = await preferences.getConfig();

      expect(restored, isNotNull);
      expect(restored!.currentProfileId, 42);
      expect(restored.excludeSSIDs, ['home']);
    });

    test('getConfigMap returns null for malformed JSON', () async {
      await store.setString(configKey, 'not-json');

      expect(await preferences.getConfigMap(), isNull);
    });

    test('getConfigMap returns null when the payload is not a map', () async {
      await store.setString(configKey, '123');

      expect(await preferences.getConfigMap(), isNull);
    });
  });

  group('unreadable config', () {
    for (final key in [configKey, clashConfigKey]) {
      test('does not log the contents of unreadable $key', () async {
        const raw = '{"secret":"private-token-123",}';
        await store.setString(key, raw);
        final messages = <String>[];
        final previousPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) messages.add(message);
        };
        try {
          expect(
            await (key == configKey
                ? preferences.getConfigMap()
                : preferences.getClashConfigMap()),
            isNull,
          );
        } finally {
          debugPrint = previousPrint;
        }

        expect(messages, isNotEmpty);
        expect(messages.join('\n'), isNot(contains('private-token-123')));
        expect(store.getString(key), raw);
      });
    }

    for (final raw in ['not-json', '[]', 'null', '123']) {
      test('preserves $raw instead of saving defaults', () async {
        await store.setString(configKey, raw);

        expect(await preferences.getConfig(), isNull);
        expect(
          await preferences.saveConfig(Config.realFromJson(null)),
          isFalse,
        );
        expect(store.getString(configKey), raw);
        expect(await preferences.isInit, isFalse);
        expect(await preferences.getConfigMap(), isNull);
        expect(store.getString(configKey), raw);
      });
    }

    test('preserves a config entry with the wrong storage type', () async {
      await store.setInt(configKey, 42);

      expect(await preferences.getConfigMap(), isNull);
      expect(await preferences.saveConfig(Config.realFromJson(null)), isFalse);
      expect(store.get(configKey), 42);
      expect(await preferences.isInit, isFalse);
    });

    test('an explicit reset restores normal writes', () async {
      await store.setString(configKey, 'not-json');
      expect(await preferences.getConfigMap(), isNull);
      expect(await preferences.saveConfig(Config.realFromJson(null)), isFalse);

      await preferences.clearPreferences();

      expect(await preferences.isInit, isTrue);
      expect(store.containsKey(configKey), isFalse);
      const config = Config(
        themeProps: defaultThemeProps,
        currentProfileId: 42,
      );
      expect(await preferences.saveConfig(config), isTrue);
      expect(await preferences.getConfig(), config);
    });

    test('a reset can keep subsequent writes blocked', () async {
      await store.setString(configKey, 'not-json');
      expect(await preferences.getConfigMap(), isNull);

      await preferences.clearPreferences(preventWrites: true);

      expect(await preferences.isInit, isTrue);
      expect(await preferences.saveConfig(Config.realFromJson(null)), isFalse);
      expect(store.getKeys(), isEmpty);
    });

    test('readable maps still salvage individual fields', () async {
      await store.setString(
        configKey,
        json.encode({
          'currentProfileId': 42,
          'themeProps': {'colorStyle': 'unknown'},
          'excludeSSIDs': ['home'],
        }),
      );

      final config = await preferences.getConfig();

      expect(config!.currentProfileId, 42);
      expect(config.excludeSSIDs, ['home']);
      expect(await preferences.isInit, isTrue);
      expect(await preferences.saveConfig(config), isTrue);
    });
  });

  group('clash config', () {
    test('getClashConfigMap returns null when nothing is stored', () async {
      expect(await preferences.getClashConfigMap(), isNull);
    });

    test('getClashConfigMap decodes a stored map', () async {
      await store.setString(clashConfigKey, json.encode({'mode': 'rule'}));

      expect(await preferences.getClashConfigMap(), {'mode': 'rule'});
    });

    test('getClashConfigMap returns null for malformed JSON', () async {
      await store.setString(clashConfigKey, '{oops');

      expect(await preferences.getClashConfigMap(), isNull);
    });

    test('clearClashConfig removes only the clash config entry', () async {
      await store.setString(clashConfigKey, json.encode({'mode': 'rule'}));
      await preferences.setVersion(3);

      await preferences.clearClashConfig();

      expect(await preferences.getClashConfigMap(), isNull);
      expect(await preferences.getVersion(), 3);
    });
  });

  test('saveShareState writes the encoded shared state', () async {
    await preferences.saveShareState(_sharedState);

    final raw = store.getString('sharedState');
    expect(raw, isNotNull);
    expect(
      SharedState.fromJson(json.decode(raw!) as Map<String, Object?>),
      _sharedState,
    );
  });

  test('clearPreferences empties every stored key', () async {
    await preferences.setVersion(9);
    await preferences.saveConfig(const Config(themeProps: defaultThemeProps));

    await preferences.clearPreferences();

    expect(await preferences.getVersion(), 0);
    expect(await preferences.getConfig(), isNull);
  });

  test('isInit resolves true once shared preferences are available', () async {
    expect(await preferences.isInit, isTrue);
  });

  group('boot record', () {
    test('getBootRecord returns null when nothing is stored', () async {
      expect(await preferences.getBootRecord(), isNull);
    });

    test('saveBootRecord then getBootRecord round-trips the record', () async {
      const record = BootRecord(
        stage: BootStage.starting,
        profileId: 5,
        startedAt: 111,
        failureCount: 1,
        lastFailedProfileId: 4,
        handledExitAt: 99,
      );

      await preferences.saveBootRecord(record);

      expect(await preferences.getBootRecord(), record);
    });

    test('getBootRecord survives a corrupt entry', () async {
      await store.setString(bootRecordKey, 'not json');

      expect(await preferences.getBootRecord(), isNull);
    });
  });
}
