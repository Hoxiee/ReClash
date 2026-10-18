import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/identity/device_identity.dart';

const _origin = 'https://subs.example.test';

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

      expect(await store.requestFields(1, Uri.parse(_origin)), isNull);
      expect(sourceCalls, 0);
      await store.setProfileSendOverride(1, true);
      final fields = await store.requestFields(1, Uri.parse(_origin));
      expect(sourceCalls, 1);
      expect(fields, hasLength(1));
      expect(fields!.keys.single, 'x-hwid');
      expect(fields['x-hwid'], matches(RegExp(r'^[a-f0-9]{32}$')));
      expect(storage.value, isNot(contains('raw-machine-value')));
    });

    test('derives one 32-character HWID with domain separation', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => _material('source-value'),
      );
      await store.setGlobalSendEnabled(true);
      final fields = await store.requestFields(1, Uri.parse(_origin));
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
        final first = await store.requestFields(1, Uri.parse(_origin));
        final second = await store.requestFields(1, Uri.parse(_origin));

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
        final first = await store.requestFields(1, Uri.parse(_origin));
        current = 'upgraded-source';
        expect(
          (await store.requestFields(1, Uri.parse(_origin)))?['x-hwid'],
          first?['x-hwid'],
        );
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
        final first = await firstStore.requestFields(5, Uri.parse(_origin));

        final restoredStore = DeviceIdentityStore(
          storage: storage,
          source: () async {
            sourceCalls++;
            return _material('replacement-source');
          },
        );
        expect(
          (await restoredStore.requestFields(5, Uri.parse(_origin)))?['x-hwid'],
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
        expect(await store.requestFields(7, Uri.parse(_origin)), isNull);
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
        expect(await store.requestFields(7, Uri.parse(_origin)), isNull);
        expect(storage.value, isNot(contains('private-source')));
      },
    );

    test(
      'consent is profile and normalized-origin scoped; details are optional',
      () async {
        final store = DeviceIdentityStore(
          storage: _MemoryStorage(),
          source: () async => _material('stable'),
        );
        final pathful = Uri.parse('HTTPS://Subs.Example.Test:443/path?token=x');
        await store.setGlobalSendEnabled(true);
        await store.allow(3, pathful);
        expect(await store.consent(3, Uri.parse(_origin)), isNotNull);
        expect(await store.consent(4, Uri.parse(_origin)), isNull);
        expect(
          await store.consent(3, Uri.parse('https://other.example.test')),
          isNull,
        );

        final privateFields = await store.requestFields(3, Uri.parse(_origin));
        expect(privateFields, hasLength(1));
        expect(privateFields!.keys, {'x-hwid'});

        await store.allow(3, Uri.parse(_origin), sendDetails: true);
        expect(await store.requestFields(3, pathful), {
          'x-hwid': privateFields['x-hwid'],
          'x-device-os': 'test-os',
          'x-ver-os': '1.2',
          'x-device-model': 'test-model',
        });
      },
    );

    test('revoke scopes to profile and optional origin', () async {
      final store = DeviceIdentityStore(
        storage: _MemoryStorage(),
        source: () async => _material('stable'),
      );
      final firstOrigin = Uri.parse(_origin);
      final secondOrigin = Uri.parse('https://other.example.test');
      await store.setProfileSendOverride(1, true);
      await store.setProfileSendOverride(2, true);
      await store.allow(1, firstOrigin);
      await store.allow(1, secondOrigin);
      await store.allow(2, firstOrigin);
      await store.requestFields(1, firstOrigin);

      await store.revoke(1, firstOrigin);
      expect(await store.consent(1, firstOrigin), isNull);
      expect(await store.consent(1, secondOrigin), isNotNull);
      expect(await store.consent(2, firstOrigin), isNotNull);
      expect(await store.requestFields(1, firstOrigin), isNotNull);

      await store.revoke(1);
      expect(await store.consent(1, secondOrigin), isNull);
      expect(await store.profileSendOverride(1), isNull);
      expect(await store.requestFields(1, firstOrigin), isNull);
      expect(await store.requestFields(2, firstOrigin), isNotNull);
    });

    test(
      'profile override follows or replaces the global identity setting',
      () async {
        final store = DeviceIdentityStore(
          storage: _MemoryStorage(),
          source: () async => _material('stable'),
        );
        final origin = Uri.parse(_origin);

        expect(await store.requestFields(9, origin), isNull);
        await store.setGlobalSendEnabled(true);
        expect(await store.requestFields(9, origin), isNotNull);
        await store.setProfileSendOverride(9, false);
        expect(await store.requestFields(9, origin), isNull);
        await store.setProfileSendOverride(9, true);
        expect(await store.requestFields(9, origin), isNotNull);
        await store.setProfileSendOverride(9, null);
        expect(await store.requestFields(9, origin), isNotNull);
        await store.setGlobalSendEnabled(false);
        expect(await store.requestFields(9, origin), isNull);
      },
    );

    test('normalizes origins and rejects non-web or credentialed values', () {
      expect(
        normalizeIdentityOrigin(Uri.parse('HTTPS://Example.test:443/path')),
        'https://example.test',
      );
      expect(
        normalizeIdentityOrigin(Uri.parse('http://Example.test:8080/path')),
        'http://example.test:8080',
      );
      expect(
        () => normalizeIdentityOrigin(Uri.parse('ftp://example.test')),
        throwsArgumentError,
      );
      expect(
        () => normalizeIdentityOrigin(Uri.parse('https://user@example.test')),
        throwsArgumentError,
      );
    });
  });
}
