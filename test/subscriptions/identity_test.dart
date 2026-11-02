import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';

class _MemoryStorage implements DeviceIdentityStorage {
  String? value;
  bool failWrite = false;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String next) async {
    if (failWrite) throw StateError('write failed');
    value = next;
  }
}

DeviceIdentityMaterial _material(String value) => DeviceIdentityMaterial(
  value: value,
  source: 'test-source',
  os: 'test-os',
  osVersion: '1.2',
  model: 'test-model',
);

void main() {
  group('DeviceIdentityStore', () {
    test('identity source is lazy until global or profile opt-in', () async {
      final storage = _MemoryStorage();
      var sourceCalls = 0;
      final store = DeviceIdentityStore(
        storage: storage,
        source: () async {
          sourceCalls++;
          return _material('raw-machine-value');
        },
      );

      expect(await store.requestFields(1), isNull);
      expect(sourceCalls, 0);
      await store.setProfileSendOverride(1, true);
      final fields = await store.requestFields(1);
      expect(sourceCalls, 1);
      expect(fields, {
        'x-hwid': matches(RegExp(r'^[a-f0-9]{32}$')),
        'x-device-os': 'test-os',
        'x-ver-os': '1.2',
        'x-device-model': 'test-model',
      });
      expect(storage.value, isNot(contains('raw-machine-value')));
    });

    test('derives one 32-character HWID with domain separation', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => _material('source-value'),
      );
      await store.setGlobalSendEnabled(true);
      final fields = await store.requestFields(1);
      expect(
        fields?['x-hwid'],
        sha256
            .convert(utf8.encode('ReClash/HWID/v1\u0000source-value'))
            .toString()
            .substring(0, 32),
      );
    });

    test(
      'an unavailable source creates one stable persisted random identity',
      () async {
        final storage = _MemoryStorage();
        var sourceCalls = 0;
        final store = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return null;
          },
        );
        await store.setGlobalSendEnabled(true);
        final first = await store.requestFields(1);
        final second = await store.requestFields(1);

        expect(first?['x-hwid'], matches(RegExp(r'^[a-f0-9]{32}$')));
        expect(second?['x-hwid'], first?['x-hwid']);
        expect(sourceCalls, 1);
      },
    );

    test(
      'cached identity never changes when a better source later appears',
      () async {
        final storage = _MemoryStorage();
        var current = 'first-source';
        var sourceCalls = 0;
        final store = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return _material(current);
          },
        );
        await store.setGlobalSendEnabled(true);
        final first = await store.requestFields(1);
        current = 'upgraded-source';
        expect((await store.requestFields(1))?['x-hwid'], first?['x-hwid']);
        expect(sourceCalls, 1);
      },
    );

    test(
      'loads persisted identity without reading the platform again',
      () async {
        final storage = _MemoryStorage();
        var sourceCalls = 0;
        final firstStore = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return _material('original-source');
          },
        );
        await firstStore.setGlobalSendEnabled(true);
        final first = await firstStore.requestFields(5);

        final restoredStore = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return _material('replacement-source');
          },
        );
        expect(
          (await restoredStore.requestFields(5))?['x-hwid'],
          first?['x-hwid'],
        );
        expect(sourceCalls, 1);
        expect(storage.value, isNot(contains('original-source')));
      },
    );

    test(
      'storage failure never returns an unpersisted transient identity',
      () async {
        final storage = _MemoryStorage()..failWrite = true;
        var sourceCalls = 0;
        final store = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return _material('must-not-escape');
          },
        );
        await expectLater(store.setGlobalSendEnabled(true), throwsStateError);
        expect(await store.requestFields(7), isNull);
        expect(sourceCalls, 0);
      },
    );

    test(
      'failed identity persistence does not leak a generated value',
      () async {
        final storage = _MemoryStorage();
        final store = DeviceIdentityStore(
          storage: storage,
          source: () async => _material('private-source'),
        );
        await store.setGlobalSendEnabled(true);
        storage.failWrite = true;
        expect(await store.requestFields(7), isNull);
        expect(storage.value, isNot(contains('private-source')));
      },
    );

    test('device details always accompany the identifier', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => _material('stable'),
      );
      await store.setGlobalSendEnabled(true);
      final fields = await store.requestFields(3);
      expect(fields, {
        'x-hwid': fields!['x-hwid'],
        'x-device-os': 'test-os',
        'x-ver-os': '1.2',
        'x-device-model': 'test-model',
      });
    });

    test('unavailable details keep all four identity headers', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => const DeviceIdentityMaterial(
          value: 'stable',
          source: 'test-source',
          os: '',
          osVersion: '',
          model: '',
        ),
      );
      await store.setGlobalSendEnabled(true);
      expect(await store.requestFields(3), {
        'x-hwid': matches(RegExp(r'^[a-f0-9]{32}$')),
        'x-device-os': '',
        'x-ver-os': '',
        'x-device-model': '',
      });
    });

    test(
      'clearing a profile override preserves other profiles and identity',
      () async {
        final store = DeviceIdentityStore(
          storage: _MemoryStorage(),
          source: () async => _material('stable'),
        );
        await store.setGlobalSendEnabled(false);
        await store.setProfileSendOverride(1, true);
        await store.setProfileSendOverride(2, true);
        final fields = await store.requestFields(1);

        await store.setProfileSendOverride(1, null);
        expect(await store.profileSendOverride(1), isNull);
        expect(await store.globalSendEnabled(), isFalse);
        expect(await store.requestFields(1), isNull);
        expect(await store.requestFields(2), fields);
      },
    );

    test(
      'profile override follows or replaces the global identity setting',
      () async {
        final store = DeviceIdentityStore(
          storage: _MemoryStorage(),
          source: () async => _material('stable'),
        );

        expect(await store.requestFields(9), isNull);
        await store.setGlobalSendEnabled(true);
        expect(await store.requestFields(9), isNotNull);
        await store.setProfileSendOverride(9, false);
        expect(await store.requestFields(9), isNull);
        await store.setProfileSendOverride(9, true);
        expect(await store.requestFields(9), isNotNull);
        await store.setProfileSendOverride(9, null);
        expect(await store.requestFields(9), isNotNull);
        await store.setGlobalSendEnabled(false);
        expect(await store.requestFields(9), isNull);
      },
    );

    test('an unset global setting follows the regional default', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => _material('stable'),
      );

      expect(await store.globalSendEnabled(), isFalse);
      expect(await store.globalSendEnabled(byDefault: true), isTrue);
      expect(await store.requestFields(3, sendByDefault: true), isNotNull);
      await store.setGlobalSendEnabled(false);
      expect(await store.globalSendEnabled(byDefault: true), isFalse);
      expect(await store.requestFields(3, sendByDefault: true), isNull);
      expect(sendsDeviceIdentityByDefault('RU'), isTrue);
      expect(sendsDeviceIdentityByDefault('CN'), isFalse);
      expect(sendsDeviceIdentityByDefault(null), isFalse);
    });

    test(
      'legacy consent data preserves identity and active send settings',
      () async {
        const identity = DeviceIdentity(
          hwid: '0123456789abcdef0123456789abcdef',
          source: 'stored-source',
          os: 'test-os',
          osVersion: '1.2',
          model: 'test-model',
        );
        for (final consents in <Object>[
          [
            {
              'profileId': 1,
              'origin': 'https://subs.example.test',
              'sendDetails': false,
            },
          ],
          'invalid legacy data',
        ]) {
          final storage = _MemoryStorage()
            ..value = jsonEncode({
              'version': 1,
              'identity': identity.toJson(),
              'globalSendEnabled': true,
              'profileSendOverrides': {'2': false},
              'consents': consents,
            });
          var sourceCalls = 0;
          final store = DeviceIdentityStore(
            storage: storage,
            source: () async {
              sourceCalls++;
              return _material('replacement-source');
            },
          );
          expect(await store.globalSendEnabled(), isTrue);
          expect(await store.profileSendOverride(2), isFalse);
          expect(await store.requestFields(1), {
            'x-hwid': identity.hwid,
            'x-device-os': identity.os,
            'x-ver-os': identity.osVersion,
            'x-device-model': identity.model,
          });
          expect(await store.requestFields(2), isNull);
          await store.setProfileSendOverride(2, null);
          expect((await store.requestFields(2))?['x-hwid'], identity.hwid);
          final saved = jsonDecode(storage.value!) as Map<String, dynamic>;
          expect(saved.containsKey('consents'), isFalse);
          expect(saved['identity'], identity.toJson());
          expect(sourceCalls, 0);
        }
      },
    );
  });
}
