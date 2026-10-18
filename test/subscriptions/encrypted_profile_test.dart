import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/compatibility/cache.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/app_paths.dart';

const _encrypted = '-----BEGIN AGE ENCRYPTED FILE-----\nYWdl\n';
const _plain = '''# reclash-servicename: Body provider
proxies:
  - name: node
    type: ss
    server: example.test
    port: 443
    cipher: aes-128-gcm
    password: fake
''';

class _Core extends Mock implements CoreHandlerInterface {}

class _Transport extends SubscriptionTransport {
  _Transport(this.body, {this.headers = const {}});

  final String body;
  final Map<String, List<String>> headers;
  int calls = 0;

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    calls++;
    return SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(body)),
      headers: this.headers,
      status: 200,
      uri: source,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late _Core core;
  late CoreController controller;

  setUpAll(() async {
    directory = Directory.systemTemp.createTempSync('subscription_age_');
    await useAppPaths(directory);
  });

  setUp(() {
    core = _Core();
    controller = CoreController.scoped(core);
    when(() => core.validateConfig(any())).thenAnswer((_) async => '');
  });

  tearDownAll(() => directory.deleteSync(recursive: true));

  Profile profile({bool withKey = true}) => Profile.normal(
    label: 'Mine',
    url: 'https://subscription.example.test/feed',
  ).copyWith(ageSecretKey: withKey ? 'AGE-SECRET-KEY-TEST' : '');

  Future<bool> hasFile(Profile value) async =>
      File(await appPath.getProfilePath(value.id.toString())).exists();

  test(
    'decrypts before metadata, format detection and Core validation',
    () async {
      final value = profile();
      String? encryptedPath;
      when(() => core.decryptConfig(any(), value.ageSecretKey)).thenAnswer((
        call,
      ) async {
        encryptedPath = call.positionalArguments.first as String;
        expect(await File(encryptedPath!).readAsString(), _encrypted);
        return _plain;
      });
      when(() => core.validateConfig(any())).thenAnswer((call) async {
        expect(
          await File(call.positionalArguments.first as String).readAsString(),
          _plain,
        );
        return '';
      });
      final prepared = await value.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: _Transport(
          _encrypted,
          headers: {
            'reclash-servicename': ['HTTP provider'],
          },
        ),
        decrypt: controller.decryptProfilePayload,
        validate: (path, _) => controller.validateConfig(path),
      );

      expect(prepared.payload.format, SubscriptionFormat.clash);
      expect(prepared.summary.nodes, 1);
      expect(prepared.snapshot.metadata.name, 'HTTP provider');
      expect(await hasFile(value), isFalse);
      expect(await File(encryptedPath!).exists(), isFalse);
      await value.commitPreparedUpdate(
        prepared,
        validate: (path, _) => controller.validateConfig(path),
      );
      expect(await (await value.file).readAsString(), _plain);
      verify(() => core.decryptConfig(any(), value.ageSecretKey)).called(1);
      verify(() => core.validateConfig(any())).called(2);
    },
  );

  test(
    'an encrypted subscription without a key does not probe other clients',
    () async {
      final value = profile(withKey: false);
      final transport = _Transport(_encrypted);
      await expectLater(
        value.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
          decrypt: controller.decryptProfilePayload,
        ),
        throwsA(isA<AgeSecretKeyRequiredException>()),
      );
      expect(transport.calls, 1);
      expect(await hasFile(value), isFalse);
      verifyNever(() => core.decryptConfig(any(), any()));
    },
  );

  test(
    'failed decryption cleans staging and never commits or retries',
    () async {
      final value = profile();
      final transport = _Transport(_encrypted);
      String? encryptedPath;
      when(() => core.decryptConfig(any(), value.ageSecretKey)).thenAnswer((
        call,
      ) async {
        encryptedPath = call.positionalArguments.first as String;
        throw StateError('wrong test key');
      });
      await expectLater(
        value.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
          decrypt: controller.decryptProfilePayload,
        ),
        throwsStateError,
      );
      expect(transport.calls, 1);
      expect(await File(encryptedPath!).exists(), isFalse);
      expect(await hasFile(value), isFalse);
      verifyNever(() => core.validateConfig(any()));
    },
  );

  test(
    'cancellation during decryption cannot produce a prepared update',
    () async {
      final value = profile();
      final cancellation = SubscriptionCancellation();
      final decrypting = Completer<void>();
      final landing = Completer<String>();
      addTearDown(() {
        if (!landing.isCompleted) landing.complete(_plain);
      });
      when(() => core.decryptConfig(any(), value.ageSecretKey)).thenAnswer((_) {
        decrypting.complete();
        return landing.future;
      });
      final pending = value.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: _Transport(_encrypted),
        cancellation: cancellation,
        decrypt: controller.decryptProfilePayload,
        validate: (path, _) => controller.validateConfig(path),
      );
      final rejected = expectLater(
        pending,
        throwsA(isA<SubscriptionUpdateCancelled>()),
      );
      await decrypting.future;
      cancellation.cancel();
      landing.complete(_plain);
      await rejected;
      expect(await hasFile(value), isFalse);
      verifyNever(() => core.validateConfig(any()));
    },
  );

  test(
    'Core rejection is terminal and cannot cache a successful client',
    () async {
      final value = profile();
      final transport = _Transport(_plain);
      when(
        () => core.validateConfig(any()),
      ).thenAnswer((_) async => 'invalid test config');
      await expectLater(
        value.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
          validate: (path, _) => controller.validateConfig(path),
        ),
        throwsA(isA<SubscriptionUpdateRejected>()),
      );
      expect(transport.calls, 1);
      expect(await hasFile(value), isFalse);
      expect(
        await File(
          '${directory.path}/subscription_clients/${value.id}.json',
        ).exists(),
        isFalse,
      );
    },
  );

  test(
    'changed URL, AGE key or request policy supersedes a prepared candidate',
    () async {
      final value = profile();
      final prepared = await value.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: _Transport(_plain),
      );
      for (final edited in [
        value.copyWith(url: '${value.url}/new'),
        value.copyWith(ageSecretKey: 'OTHER-KEY'),
        value.copyWith(
          subscriptionPreferences: const SubscriptionPreferences(
            headers: {'x-token': 'new'},
          ),
        ),
      ]) {
        await expectLater(
          edited.commitPreparedUpdate(prepared, validate: (_, _) async => ''),
          throwsA(isA<SubscriptionUpdateSuperseded>()),
        );
      }
      expect(await hasFile(value), isFalse);
      final key = subscriptionClientCacheKey(
        prepared.clientFingerprint,
        value.subscriptionPreferences.client.importPolicy.toJson(),
      );
      expect(await const SubscriptionClientCache().read(value.id, key), isNull);
    },
  );

  test(
    'missing usage remains last-known and stale instead of unlimited',
    () async {
      final value = profile().copyWith(
        subscriptionInfo: const SubscriptionInfo(
          upload: 5,
          download: 10,
          total: 100,
          expire: 1700000000,
        ),
        subscriptionSnapshot: SubscriptionSnapshot(
          metadata: const SubscriptionMetadata({
            'provider.name': 'Previous provider',
            'subscription.upload': 5,
            'subscription.download': 10,
            'subscription.total': 100,
            'subscription.unlimited': false,
            'subscription.expire': 1700000000,
            'subscription.perpetual': false,
          }),
          receivedAt: DateTime.utc(2025),
        ),
      );
      final prepared = await value.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: _Transport(_plain),
      );
      expect(prepared.subscriptionInfo, value.subscriptionInfo);
      expect(prepared.snapshot.usageStale, isTrue);
      expect(prepared.snapshot.metadata.unlimited, isFalse);
      expect(prepared.snapshot.metadata.perpetual, isFalse);
      expect(prepared.snapshot.metadata.count('subscription.total'), 100);
    },
  );

  test('only a committed client is cached after owner persistence', () async {
    final value = profile().copyWith(
      subscriptionPreferences: const SubscriptionPreferences(
        client: SubscriptionClientSettings(
          preset: SubscriptionClientPreset.clash,
        ),
      ),
    );
    final prepared = await value.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _Transport(_plain),
    );
    final key = subscriptionClientCacheKey(
      prepared.clientFingerprint,
      value.subscriptionPreferences.client.importPolicy.toJson(),
    );
    expect(await const SubscriptionClientCache().read(value.id, key), isNull);
    await expectLater(
      value.commitPreparedUpdate(
        prepared,
        validate: (_, _) async => '',
        onCommitted: (_) async => throw StateError('database failed'),
      ),
      throwsStateError,
    );
    expect(await const SubscriptionClientCache().read(value.id, key), isNull);
    await value.commitPreparedUpdate(prepared, validate: (_, _) async => '');
    expect(
      await const SubscriptionClientCache().read(value.id, key),
      SubscriptionClientPreset.clash,
    );
  });

  test('queued deletion runs after the committed client is cached', () async {
    final value = profile().copyWith(
      subscriptionPreferences: const SubscriptionPreferences(
        client: SubscriptionClientSettings(
          preset: SubscriptionClientPreset.clash,
        ),
      ),
    );
    final prepared = await value.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _Transport(_plain),
    );
    final key = subscriptionClientCacheKey(
      prepared.clientFingerprint,
      value.subscriptionPreferences.client.importPolicy.toJson(),
    );
    final persisting = Completer<void>();
    final release = Completer<void>();
    addTearDown(() {
      if (!release.isCompleted) release.complete();
    });
    final committing = value.commitPreparedUpdate(
      prepared,
      validate: (_, _) async => '',
      onCommitted: (_) async {
        persisting.complete();
        await release.future;
      },
    );
    await persisting.future;
    final deleting = serializeProfileMutation(value.id, () async {
      expect(
        File(
          '${directory.path}/subscription_clients/${value.id}.json',
        ).existsSync(),
        isTrue,
      );
      await const SubscriptionClientCache().forget(value.id);
      await (await value.file).delete();
    });
    release.complete();
    await Future.wait([committing, deleting]);
    expect(await const SubscriptionClientCache().read(value.id, key), isNull);
    expect(await hasFile(value), isFalse);
  });
}
