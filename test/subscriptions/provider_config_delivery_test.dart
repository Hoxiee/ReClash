import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/metadata/provider_config_store.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/app_paths.dart';
import '../helpers/provider_presentation.dart';

const _configUrl = 'https://cdn.example.test/reclash.yaml';
const _nodeBody =
    'proxies:\n  - name: node\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n';

String _config(String title) =>
    '''
version: 1
power-labels:
  off: $title
cards:
  - type: note
    id: note
    text: $title
''';

class _Transport extends SubscriptionTransport {
  _Transport({this.header = _configUrl, this.config});

  final String? header;
  final Future<SubscriptionResponse> Function(Uri uri)? config;
  Map<String, String>? configHeaders;
  int configRequests = 0;

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => SubscriptionResponse(
    bytes: Uint8List.fromList(utf8.encode(_nodeBody)),
    headers: {
      if (header != null) 'reclash-config': [header!],
    },
    status: 200,
    uri: source,
  );

  @override
  Future<SubscriptionResponse> fetchCapped(
    Uri source, {
    required int limit,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) {
    configRequests++;
    configHeaders = headers;
    return config!(source);
  }
}

Future<SubscriptionResponse> Function(Uri) _serves(
  String body, {
  String? etag,
}) =>
    (uri) async => SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(body)),
      headers: {
        if (etag != null) 'etag': [etag],
      },
      status: 200,
      uri: uri,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('provider_config_test');
    await useAppPaths(tempDir);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<Profile> update(Profile profile, _Transport transport) =>
      profile.update(
        validate: (_, _) async => '',
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      );

  Profile newProfile() => Profile.normal(url: 'https://subs.example.test/p');

  Future<Profile> seeded() async {
    final profile = newProfile();
    await update(
      profile,
      _Transport(config: _serves(_config('First'), etag: '"v1"')),
    );
    return profile;
  }

  test('a valid file is stored with its ETag and no private headers', () async {
    final transport = _Transport(
      config: _serves(_config('First'), etag: '"v1"'),
    );
    final profile = newProfile();
    final saved = await update(profile, transport);

    final stored = await readStoredProviderConfig(profile.id);
    expect(stored?.source, _config('First'));
    expect(stored?.etag, '"v1"');
    expect(transport.configHeaders, {'user-agent': 'ReClash/test'});
    expect(saved.subscriptionSnapshot?.warnings, isEmpty);
  });

  test('a stored ETag is revalidated and 304 keeps the copy', () async {
    final profile = await seeded();
    final transport = _Transport(
      config: (_) async => throw const SubscriptionException(
        SubscriptionFailure.http,
        status: 304,
      ),
    );
    final saved = await update(profile, transport);

    expect(transport.configHeaders, {
      'user-agent': 'ReClash/test',
      'if-none-match': '"v1"',
    });
    expect(saved.subscriptionSnapshot?.warnings, isEmpty);
    final stored = await readStoredProviderConfig(profile.id);
    expect(stored?.source, _config('First'));
  });

  test('an ETag is not sent to a different config URL', () async {
    final profile = await seeded();
    final transport = _Transport(
      header: 'https://cdn.example.test/other.yaml',
      config: _serves(_config('Other')),
    );
    await update(profile, transport);
    expect(transport.configHeaders, {'user-agent': 'ReClash/test'});
  });

  test('a network failure keeps the copy and the update succeeds', () async {
    final profile = await seeded();
    final saved = await update(
      profile,
      _Transport(
        config: (_) async =>
            throw const SubscriptionException(SubscriptionFailure.transport),
      ),
    );

    expect(saved.lastUpdateDate, isNotNull);
    expect(
      saved.subscriptionSnapshot?.warnings,
      contains('Provider config: transport'),
    );
    final stored = await readStoredProviderConfig(profile.id);
    expect(stored?.source, _config('First'));
  });

  test('an invalid document keeps the copy and warns', () async {
    final profile = await seeded();
    final saved = await update(
      profile,
      _Transport(config: _serves('version: 99\n', etag: '"bad"')),
    );

    expect(saved.subscriptionSnapshot?.warnings, isNotEmpty);
    final stored = await readStoredProviderConfig(profile.id);
    expect(stored?.source, _config('First'));
    expect(stored?.etag, '"v1"');
  });

  test('a document that is not UTF-8 keeps the copy', () async {
    final profile = await seeded();
    final saved = await update(
      profile,
      _Transport(
        config: (uri) async => SubscriptionResponse(
          bytes: Uint8List.fromList([0xff, 0xfe, 0xfd]),
          headers: const {},
          status: 200,
          uri: uri,
        ),
      ),
    );
    expect(saved.subscriptionSnapshot?.warnings, isNotEmpty);
    expect(await readStoredProviderConfig(profile.id), isNotNull);
  });

  test('a withdrawn header deletes the copy', () async {
    final profile = await seeded();
    final transport = _Transport(header: null);
    await update(profile, transport);

    expect(transport.configRequests, 0);
    expect(await readStoredProviderConfig(profile.id), isNull);
  });

  test('a config header on plain http is not followed', () async {
    final transport = _Transport(config: _serves(_config('First')));
    final profile = Profile.normal(url: 'http://subs.example.test/p');
    await update(profile, transport);

    expect(transport.configRequests, 0);
    expect(await readStoredProviderConfig(profile.id), isNull);
  });

  test('deleting the stored copy removes its file', () async {
    final profile = await seeded();
    final path = await appPath.getProfileProviderConfigPath(
      profile.id.toString(),
    );
    expect(File(path).existsSync(), isTrue);
    await deleteStoredProviderConfig(profile.id);
    expect(File(path).existsSync(), isFalse);
  });

  group('the routing section', () {
    const routing = '''
version: 1
routing:
  scenario: home
''';

    Future<File> routingFile(Profile profile) async =>
        File(await appPath.getProfileRoutingPath(profile.id.toString()));

    test(
      'is stored as the whole manifest and removed when withdrawn',
      () async {
        final profile = newProfile();
        await update(profile, _Transport(config: _serves(routing)));
        expect((await routingFile(profile)).readAsStringSync(), routing);

        await update(profile, _Transport(config: _serves(_config('Plain'))));
        expect((await routingFile(profile)).existsSync(), isFalse);
      },
    );

    test('is removed with the manifest header', () async {
      final profile = newProfile();
      await update(profile, _Transport(config: _serves(routing)));
      await update(profile, _Transport(header: null));
      expect((await routingFile(profile)).existsSync(), isFalse);
    });
  });

  group('a superseded update', () {
    Future<PreparedSubscriptionUpdate> prepare(Profile profile) =>
        profile.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: _Transport(config: _serves(_config('Second'))),
        );

    test('does not write the file', () async {
      final profile = await seeded();
      final prepared = await prepare(profile);
      await expectLater(
        profile.commitPreparedUpdate(
          prepared,
          validate: (_, _) async => '',
          isCurrent: () => false,
        ),
        throwsA(isA<SubscriptionUpdateSuperseded>()),
      );
      final stored = await readStoredProviderConfig(profile.id);
      expect(stored?.source, _config('First'));
    });

    test('that rolls back at publish restores the file', () async {
      final profile = await seeded();
      final prepared = await prepare(profile);
      await expectLater(
        profile.commitPreparedUpdate(
          prepared,
          validate: (_, _) async => '',
          onCommitted: (_) async => throw const SubscriptionUpdateSuperseded(),
        ),
        throwsA(isA<SubscriptionUpdateSuperseded>()),
      );
      final stored = await readStoredProviderConfig(profile.id);
      expect(stored?.source, _config('First'));
    });
  });

  group('the transport cap', () {
    final servers = <HttpServer>[];
    late HttpOverrides? overrides;

    setUp(() {
      overrides = HttpOverrides.current;
      HttpOverrides.global = null;
    });

    tearDown(() async {
      for (final server in servers) {
        await server.close(force: true);
      }
      servers.clear();
      HttpOverrides.global = overrides;
    });

    Future<Uri> serve(void Function(HttpRequest) handle) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      servers.add(server);
      server.listen(handle);
      return Uri.parse('http://127.0.0.1:${server.port}/config');
    }

    test('rejects wire bytes over the limit', () async {
      final uri = await serve((request) {
        request.response.add(List.filled(providerConfigSizeLimit + 1, 0x20));
        request.response.close();
      });
      await expectLater(
        SubscriptionTransport().fetchCapped(
          uri,
          limit: providerConfigSizeLimit,
        ),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.failure,
            'failure',
            SubscriptionFailure.oversized,
          ),
        ),
      );
    });

    test('rejects decompressed bytes over the limit', () async {
      final compressed = gzip.encode(
        List.filled(providerConfigSizeLimit + 1, 0x20),
      );
      expect(compressed.length, lessThan(providerConfigSizeLimit));
      final uri = await serve((request) {
        request.response.headers.set('content-encoding', 'gzip');
        request.response.add(compressed);
        request.response.close();
      });
      await expectLater(
        SubscriptionTransport().fetchCapped(
          uri,
          limit: providerConfigSizeLimit,
        ),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.failure,
            'failure',
            SubscriptionFailure.oversized,
          ),
        ),
      );
    });

    test('reports 304 as a status and sends If-None-Match', () async {
      String? received;
      final uri = await serve((request) {
        received = request.headers.value(HttpHeaders.ifNoneMatchHeader);
        request.response.statusCode = 304;
        request.response.close();
      });
      await expectLater(
        SubscriptionTransport().fetchCapped(
          uri,
          limit: providerConfigSizeLimit,
          headers: {HttpHeaders.ifNoneMatchHeader: '"v1"'},
        ),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.status,
            'status',
            304,
          ),
        ),
      );
      expect(received, '"v1"');
    });
  });

  group('consumption', () {
    final headers =
        readSubscriptionMetadata({
          'reclash-config': [_configUrl],
        }, secure: true).metadata.merge(
          manifestMetadata({
            'policy': {'global': 'off'},
          }),
        );

    test('the file holds the cards and labels', () {
      final config = parseProviderConfig(_config('File'), 'en').config;
      final hints = ProviderHints(headers, config: config);
      expect(hints.cards.single.id, 'note');
      expect(hints.powerLabels['off']!.single.title, 'File');
    });

    test('no stored file means no cards or labels', () {
      final hints = ProviderHints(headers);
      expect(hints.cards, isEmpty);
      expect(hints.powerLabels, isEmpty);
    });

    Profile withSnapshot(Profile profile, DateTime receivedAt) =>
        profile.copyWith(
          subscriptionSnapshot: SubscriptionSnapshot(
            metadata: headers,
            receivedAt: receivedAt,
          ),
        );

    ({ProviderContainer container, void Function(Profile) show}) watch(
      Profile first, {
      String locale = 'en',
    }) {
      final current = NotifierProvider<_Current, Profile>(
        () => _Current(first),
      );
      final container = ProviderContainer(
        overrides: [
          currentProfileIdProvider.overrideWithBuild(
            (ref, _) => ref.watch(current).id,
          ),
          currentProfileProvider.overrideWith((ref) => ref.watch(current)),
          appSettingProvider.overrideWithBuild(
            (_, _) => defaultAppSettingProps.copyWith(locale: locale),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(providerHintsProvider, (_, _) {});
      container.listen(providerSettingsInputProvider, (_, _) {});
      return (
        container: container,
        show: (profile) => container.read(current.notifier).show(profile),
      );
    }

    Future<ProviderHints> settled(ProviderContainer container) async {
      for (var i = 0; i < 200; i++) {
        final hints = container.read(providerHintsProvider)!;
        if (!hints.configPending && hints.config != null) return hints;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fail('The stored file never loaded');
    }

    test(
      'a file not yet read holds the settings back but not the restrictions',
      () async {
        final profile = await seeded();
        final (:container, :show) = watch(
          withSnapshot(profile, DateTime.utc(2026)),
        );
        final pending = container.read(providerHintsProvider)!;
        expect(pending.configPending, isTrue);
        expect(pending.restrictions, {ProviderRestriction.noGlobal});
        expect(container.read(providerSettingsInputProvider), isNull);

        final loaded = await settled(container);
        expect(loaded.cards.single.id, 'note');
        expect(container.read(providerSettingsInputProvider), isNotNull);
      },
    );

    test('an update keeps the file while it is read again', () async {
      final profile = await seeded();
      final (:container, :show) = watch(
        withSnapshot(profile, DateTime.utc(2026)),
      );
      await settled(container);

      show(withSnapshot(profile, DateTime.utc(2026, 2)));
      final reloading = container.read(providerHintsProvider)!;
      expect(reloading.configPending, isFalse);
      expect(reloading.cards.single.id, 'note');
      expect(container.read(providerSettingsInputProvider), isNotNull);
    });

    test('another profile never shows the previous one\'s file', () async {
      final first = await seeded();
      final second = await seeded();
      final (:container, :show) = watch(
        withSnapshot(first, DateTime.utc(2026)),
      );
      await settled(container);

      show(withSnapshot(second, DateTime.utc(2026)));
      final switched = container.read(providerHintsProvider)!;
      expect(switched.configPending, isTrue);
      expect(switched.cards, isEmpty);
      expect(container.read(providerSettingsInputProvider), isNull);
      await settled(container);
    });

    test('text resolves for the app locale', () async {
      final profile = newProfile();
      await update(
        profile,
        _Transport(
          config: _serves('''
version: 1
power-labels:
  off:
    title:
      en: Hello
      ru: Privet
'''),
        ),
      );
      final (:container, :show) = watch(
        withSnapshot(profile, DateTime.utc(2026)),
        locale: 'ru',
      );
      final hints = await settled(container);
      expect(hints.powerLabels['off']!.single.title, 'Privet');
    });
  });
}

class _Current extends Notifier<Profile> {
  _Current(this._first);

  final Profile _first;

  @override
  Profile build() => _first;

  void show(Profile profile) => state = profile;
}
