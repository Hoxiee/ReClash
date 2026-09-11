import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('profile_save_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  setUp(() async {
    await preferences.clearPreferences();
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Profile.saveFile', () {
    // EditProfileView relies on this throwing rather than silently
    // succeeding, so a caller-level try/catch can surface the failure.
    test('rejects an invalid config without touching the saved file', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('bad: ['));

      await expectLater(
        profile.saveFile(bytes, validate: (_) async => 'invalid config'),
        throwsA(
          isA<ProfileValidationException>().having(
            (e) => e.diagnostic,
            'diagnostic',
            'invalid config',
          ),
        ),
      );

      final savedFile = await profile.file;
      expect(await savedFile.length(), 0);
    });

    test('copies validated bytes and stamps the update time', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('proxies: []'));

      final saved = await profile.saveFile(bytes, validate: (_) async => '');

      expect(saved.lastUpdateDate, isNotNull);
      final savedFile = await profile.file;
      expect(await savedFile.readAsString(), 'proxies: []');
    });

    test('prepares valid content without creating the target', () async {
      final profile = Profile.normal(label: 'p');

      final prepared = await profile.prepareContent(
        'proxies: []',
        validate: (_) async => '',
      );

      expect(prepared.content, 'proxies: []');
      expect(prepared.summary.format, ProfileImportFormat.clash);
      expect(prepared.summary.nodeCount, 0);
      expect(prepared.summary.groupCount, 0);
      expect(prepared.summary.hasProviders, isFalse);
      expect(
        await File(await appPath.getProfilePath('${profile.id}')).exists(),
        isFalse,
      );
    });

    test('restores the previous target when persistence fails', () async {
      final profile = Profile.normal(label: 'p');
      final target = File(await appPath.getProfilePath('${profile.id}'));
      await target.create(recursive: true);
      await target.writeAsString('old config');
      final prepared = await profile.prepareContent(
        'proxies: []',
        validate: (_) async => '',
      );

      await expectLater(
        profile.commitPreparedFile(
          prepared,
          persist: (_) async => throw StateError('database failed'),
        ),
        throwsStateError,
      );

      expect(await target.readAsString(), 'old config');
      expect(
        await target.parent
            .list()
            .where(
              (entry) => entry.path.contains('.${profile.fileName}.import-'),
            )
            .isEmpty,
        isTrue,
      );
    });

    test('removes a new target when persistence fails', () async {
      final profile = Profile.normal(label: 'p');
      final target = File(await appPath.getProfilePath('${profile.id}'));
      final prepared = await profile.prepareContent(
        'proxies: []',
        validate: (_) async => '',
      );

      await expectLater(
        profile.commitPreparedFile(
          prepared,
          persist: (_) async => throw StateError('database failed'),
        ),
        throwsStateError,
      );

      expect(await target.exists(), isFalse);
      expect(
        await target.parent
            .list()
            .where(
              (entry) => entry.path.contains('.${profile.fileName}.import-'),
            )
            .isEmpty,
        isTrue,
      );
    });

    test('preserves the persistence error when rollback also fails', () async {
      final profile = Profile.normal(label: 'p');
      final target = File(await appPath.getProfilePath('${profile.id}'));
      await target.create(recursive: true);
      await target.writeAsString('old config');
      final prepared = await profile.prepareContent(
        'proxies: []',
        validate: (_) async => '',
      );
      final persistenceError = StateError('database failed');

      await expectLater(
        profile.commitPreparedFile(
          prepared,
          persist: (_) async {
            await target.delete();
            final replacement = Directory(target.path);
            await replacement.create();
            await File(
              '${replacement.path}/occupied',
            ).writeAsString('occupied');
            throw persistenceError;
          },
        ),
        throwsA(same(persistenceError)),
      );

      expect(await Directory(target.path).exists(), isTrue);
    });

    test('serializes commits for the same profile', () async {
      final profile = Profile.normal(label: 'p');
      final target = File(await appPath.getProfilePath('${profile.id}'));
      final firstPrepared = await profile.prepareContent(
        'proxies:\n  - {name: first}',
        validate: (_) async => '',
      );
      final secondPrepared = await profile.prepareContent(
        'proxies:\n  - {name: second}',
        validate: (_) async => '',
      );
      final firstPersistStarted = Completer<void>();
      final releaseFirstPersist = Completer<void>();
      var secondPersistStarted = false;

      final first = profile.commitPreparedFile(
        firstPrepared,
        persist: (committed) async {
          firstPersistStarted.complete();
          await releaseFirstPersist.future;
          return committed;
        },
      );
      await firstPersistStarted.future;
      final second = profile.commitPreparedFile(
        secondPrepared,
        persist: (committed) async {
          secondPersistStarted = true;
          return committed;
        },
      );
      await pumpEventQueue();
      expect(secondPersistStarted, isFalse);

      releaseFirstPersist.complete();
      await Future.wait([first, second]);

      expect(secondPersistStarted, isTrue);
      expect(await target.readAsString(), contains('second'));
      expect(
        await target.parent
            .list()
            .where(
              (entry) => entry.path.contains('.${profile.fileName}.import-'),
            )
            .isEmpty,
        isTrue,
      );
    });
  });

  group('Profile.update format probing', () {
    test('auto tries identity first and Clash Meta after a 403', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
      );
      final userAgents = <String>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (path) async {
          final content = await File(path).readAsString();
          return ConfigInspection(
            servers: content.contains('node.example')
                ? const ['node.example.org']
                : const [],
          );
        },
        requestHeaders: const {'User-Agent': 'ReClash/v1.0.0'},
        fetch: (url, {headers}) async {
          userAgents.add(headers!['User-Agent']!);
          if (userAgents.length == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: url),
              response: Response(
                requestOptions: RequestOptions(path: url),
                statusCode: 403,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return _response(
            url,
            'proxies:\n'
            '  - {name: node, type: socks5, server: node.example, port: 1080}',
          );
        },
      );

      expect(userAgents, ['ReClash/v1.0.0', metaClashUserAgent]);
      expect(updated.lastWorkingClient, SubscriptionClient.clashMeta);
    });

    test('a stub on an unspecified address is not a working config', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
      );
      final userAgents = <String>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (path) async {
          final content = await File(path).readAsString();
          return ConfigInspection(
            servers: content.contains('node.example')
                ? const ['node.example.org']
                : const ['0.0.0.0'],
          );
        },
        requestHeaders: const {'User-Agent': 'ReClash/v1.0.0'},
        fetch: (url, {headers}) async {
          userAgents.add(headers!['User-Agent']!);
          return _response(
            url,
            headers['User-Agent'] == _happUserAgent
                ? 'proxies:\n'
                      '  - {name: node, type: socks5, server: node.example, '
                      'port: 1080}'
                : 'proxies:\n'
                      '  - {name: stub, type: socks5, server: 0.0.0.0, '
                      'port: 1}',
          );
        },
      );

      expect(userAgents, [
        'ReClash/v1.0.0',
        metaClashUserAgent,
        legacyClashUserAgent,
        _happUserAgent,
      ]);
      expect(updated.lastWorkingClient, SubscriptionClient.happ);
      expect(
        await (await updated.file).readAsString(),
        contains('node.example'),
      );
    });

    test('stores and clears provider active text across refreshes', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
        clientEmulation: SubscriptionClient.clash,
      );

      final withText = await profile.update(
        validate: (_) async => '',
        inspect: (_) async =>
            const ConfigInspection(servers: ['node.example.org']),
        fetch: (url, {headers}) async => _response(
          url,
          'proxies: []',
          headers: const {
            'reclash-activetext': ['Protected by provider'],
          },
        ),
      );
      expect(withText.panelMeta?.activeText, 'Protected by provider');

      final withoutText = await withText.update(
        validate: (_) async => '',
        inspect: (_) async =>
            const ConfigInspection(servers: ['node.example.org']),
        fetch: (url, {headers}) async => _response(url, 'proxies: []'),
      );
      expect(withoutText.panelMeta?.activeText, isNull);
    });

    test('a panel asking for HWID gets one consented repeat', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
      );
      final identified = <bool>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (path) async {
          final content = await File(path).readAsString();
          return ConfigInspection(
            servers: content.contains('node.example')
                ? const ['node.example.org']
                : const ['0.0.0.0'],
          );
        },
        requestHeaders: const {'User-Agent': 'ReClash/v1.0.0'},
        allowDeviceIdentityRetry: true,
        fetch: (url, {headers}) async {
          final withHwid = headers!.containsKey('x-hwid');
          identified.add(withHwid);
          return _response(
            url,
            withHwid
                ? 'proxies:\n'
                      '  - {name: node, type: socks5, server: node.example, '
                      'port: 1080}'
                : 'proxies:\n'
                      '  - {name: stub, type: socks5, server: 0.0.0.0, '
                      'port: 1}',
            headers: withHwid
                ? null
                : const {
                    'x-hwid-not-supported': ['true'],
                  },
          );
        },
      );

      expect(identified, [false, true]);
      expect(updated.undialableNodes, isFalse);
      expect(
        await (await updated.file).readAsString(),
        contains('node.example'),
      );
    });

    test('an HWID request stays anonymous without consent', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
      );
      final identified = <bool>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (_) async => const ConfigInspection(servers: ['0.0.0.0']),
        requestHeaders: const {'User-Agent': 'ReClash/v1.0.0'},
        fetch: (url, {headers}) async {
          identified.add(headers!.containsKey('x-hwid'));
          return _response(
            url,
            'proxies:\n'
            '  - {name: stub, type: socks5, server: 0.0.0.0, port: 1}',
            headers: const {
              'x-hwid-not-supported': ['true'],
            },
          );
        },
      );

      expect(identified, everyElement(isFalse));
      expect(updated.undialableNodes, isTrue);
    });

    test('a panel that keeps refusing is retried only once', () async {
      final profile = Profile.normal(
        label: 'profile',
        url: 'https://provider.test/sub',
      );
      final identified = <bool>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (_) async => const ConfigInspection(servers: ['0.0.0.0']),
        requestHeaders: const {'User-Agent': 'ReClash/v1.0.0'},
        allowDeviceIdentityRetry: true,
        fetch: (url, {headers}) async {
          identified.add(headers!.containsKey('x-hwid'));
          return _response(
            url,
            'proxies:\n'
            '  - {name: stub, type: socks5, server: 0.0.0.0, port: 1}',
            headers: const {
              'x-hwid-not-supported': ['true'],
            },
          );
        },
      );

      expect(identified.where((sent) => sent), hasLength(1));
      expect(updated.undialableNodes, isTrue);
      expect(updated.panelMeta?.hwidNotSupported, isTrue);
    });

    test(
      'recognized Xray JSON is converted before permissive validation',
      () async {
        final profile = Profile.normal(label: 'profile');
        final raw = jsonEncode({
          'outbounds': [
            {
              'tag': 'xray-node',
              'protocol': 'vless',
              'settings': {
                'vnext': [
                  {
                    'address': 'node.example',
                    'port': 443,
                    'users': [
                      {'id': '00000000-0000-0000-0000-000000000000'},
                    ],
                  },
                ],
              },
            },
          ],
        });

        final prepared = await profile.prepareContent(
          raw,
          validate: (_) async => '',
        );
        final saved = await profile.commitPreparedFile(prepared);
        final content = await (await saved.file).readAsString();

        expect(prepared.summary.format, ProfileImportFormat.xray);
        expect(prepared.summary.nodeCount, 1);
        expect(prepared.summary.groupCount, 1);
        expect(content, startsWith('proxies:\n'));
        expect(content, contains('name: "xray-node"'));
        expect(content, isNot(equals(raw)));
      },
    );

    test(
      'recognized WireGuard config is converted before validation',
      () async {
        final profile = Profile.normal(label: 'profile');
        const raw = '''
[Interface]
PrivateKey = PRIVATEKEY
Address = 10.0.0.2/32

[Peer]
PublicKey = PUBLICKEY
Endpoint = wg.example:51820
AllowedIPs = 0.0.0.0/0, ::/0
''';

        final saved = await profile.saveFileWithString(
          raw,
          validate: (_) async => '',
        );
        final content = await (await saved.file).readAsString();

        expect(content, contains('type: "wireguard"'));
        expect(content, contains('allowed-ips: ["0.0.0.0/0", "::/0"]'));
      },
    );
  });

  group('Profile.update capability manifest', () {
    test('replaces valid claims and records their origin', () async {
      final updated = await _updateWithCapabilityHeader(
        Profile.normal(
          label: 'profile',
          url: 'https://provider.test/sub',
          clientEmulation: SubscriptionClient.clash,
        ),
        _capabilityHeader([
          {
            'cap': 'youtube-adfree',
            'selectors': [
              {'name_contains': '⚡'},
            ],
          },
        ]),
      );

      expect(updated.capabilityManifest?.sourceHost, 'provider.test');
      expect(updated.capabilityManifest?.stale, isFalse);
      expect(
        updated.capabilityManifest?.claims.single.capabilityId,
        'youtube-adfree',
      );
      expect(updated.capabilityManifestIssue, isNull);
    });

    test(
      'records redirect response host without replacing the saved URL',
      () async {
        final profile = Profile.normal(
          label: 'profile',
          url: 'https://primary.test/sub',
          clientEmulation: SubscriptionClient.clash,
        );

        final updated = await profile.update(
          validate: (_) async => '',
          inspect: (_) async =>
              const ConfigInspection(servers: ['node.example.org']),
          fetch: (url, {headers}) async => Response<Uint8List>(
            requestOptions: RequestOptions(path: url),
            redirects: [
              RedirectRecord(
                HttpStatus.found,
                'GET',
                Uri.parse('https://fallback.test/sub'),
              ),
            ],
            data: Uint8List.fromList(utf8.encode('proxies: []')),
            headers: Headers.fromMap({
              'X-ReClash-Capabilities': [_capabilityHeader(const [])],
            }),
          ),
        );

        expect(updated.url, 'https://primary.test/sub');
        expect(updated.capabilityManifest?.sourceHost, 'fallback.test');
      },
    );

    test('marks retained claims stale when the header is absent', () async {
      final updated = await _updateWithCapabilityHeader(
        _profileWithManifest(),
        null,
      );

      expect(updated.capabilityManifest?.claims, isNotEmpty);
      expect(updated.capabilityManifest?.stale, isTrue);
      expect(updated.capabilityManifestIssue, isNull);
    });

    test('retains claims and records an invalid header issue', () async {
      final updated = await _updateWithCapabilityHeader(
        _profileWithManifest(),
        'v1.invalid+payload',
      );

      expect(
        updated.capabilityManifest,
        _profileWithManifest().capabilityManifest,
      );
      expect(
        updated.capabilityManifestIssue,
        CapabilityManifestIssue.invalidHeader,
      );
    });

    test('an empty valid manifest revokes all claims', () async {
      final updated = await _updateWithCapabilityHeader(
        _profileWithManifest(),
        _capabilityHeader(const []),
      );

      expect(updated.capabilityManifest?.claims, isEmpty);
      expect(updated.capabilityManifest?.stale, isFalse);
      expect(updated.capabilityManifestIssue, isNull);
    });
  });

  group('Profile.update domain migration', () {
    test('commits the separately validated candidate response', () async {
      final profile = Profile.normal(
        label: 'old',
        url: 'https://old.test:8443/sub?token=abc',
        clientEmulation: SubscriptionClient.clash,
      );
      final requests = <String>[];
      final sentHeaders = <Map<String, String>?>[];

      final updated = await profile.update(
        validate: (_) async => '',
        inspect: (path) async =>
            const ConfigInspection(servers: ['node.example.org']),
        fetch: (url, {headers}) async {
          requests.add(url);
          sentHeaders.add(headers);
          return _response(
            url,
            url.contains('new.test') ? 'candidate payload' : 'old payload',
            headers: {
              'flclashx-newdomain': [
                url.contains('new.test') ? 'ignored.test' : 'new.test:9443',
              ],
            },
          );
        },
      );

      expect(requests, [
        'https://old.test:8443/sub?token=abc',
        'https://new.test:9443/sub?token=abc',
      ]);
      expect(sentHeaders[1], sentHeaders[0]);
      expect(updated.url, 'https://new.test:9443/sub?token=abc');
      expect(await (await updated.file).readAsString(), 'candidate payload');
    });

    test('keeps the old response when the candidate fetch fails', () async {
      await _expectOldHostFallback((url, {headers}) async {
        if (url.contains('new.test')) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.connectionError,
          );
        }
        return _response(
          url,
          'old payload',
          headers: const {
            'flclashx-newdomain': ['new.test'],
          },
        );
      });
    });

    test(
      'keeps the old response when the candidate config is invalid',
      () async {
        await _expectOldHostFallback(
          (url, {headers}) async => _response(
            url,
            url.contains('new.test') ? 'invalid candidate' : 'old payload',
            headers: url.contains('new.test')
                ? null
                : const {
                    'flclashx-newdomain': ['new.test'],
                  },
          ),
          validate: (path) async =>
              (await File(path).readAsString()).contains('invalid')
              ? 'invalid config'
              : '',
        );
      },
    );

    test('keeps the old response when the candidate is undialable', () async {
      await _expectOldHostFallback(
        (url, {headers}) async => _response(
          url,
          url.contains('new.test') ? 'stub candidate' : 'old payload',
          headers: url.contains('new.test')
              ? null
              : const {
                  'flclashx-newdomain': ['new.test'],
                },
        ),
        inspect: (path) async => ConfigInspection(
          servers: (await File(path).readAsString()).contains('old')
              ? const ['node.example.org']
              : const [],
        ),
      );
    });
  });
}

const _happUserAgent = 'Happ/3.26.1';

String _capabilityHeader(List<Map<String, Object?>> claims) {
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'v': 1, 'claims': claims})))
      .replaceAll('=', '');
  return 'v1.$payload';
}

Profile _profileWithManifest() =>
    Profile.normal(
      label: 'profile',
      url: 'https://provider.test/sub',
      clientEmulation: SubscriptionClient.clash,
    ).copyWith(
      capabilityManifest: ProviderCapabilityManifest(
        version: 1,
        claims: const [
          CapabilityClaim(
            capabilityId: 'gemini-access',
            selectors: [CapabilitySelector(nameContains: '⭐')],
          ),
        ],
        receivedAt: DateTime.utc(2026, 9, 8),
        sourceHost: 'provider.test',
      ),
    );

Future<Profile> _updateWithCapabilityHeader(Profile profile, String? header) {
  return profile.update(
    validate: (_) async => '',
    inspect: (_) async => const ConfigInspection(servers: ['node.example']),
    fetch: (url, {headers}) async => _response(
      url,
      'proxies: []',
      headers: header == null
          ? null
          : {
              'X-ReClash-Capabilities': [header],
            },
    ),
  );
}

Response<Uint8List> _response(
  String url,
  String content, {
  Map<String, List<String>>? headers,
}) {
  return Response<Uint8List>(
    requestOptions: RequestOptions(path: url),
    data: Uint8List.fromList(utf8.encode(content)),
    headers: Headers.fromMap(headers ?? const {}),
  );
}

Future<void> _expectOldHostFallback(
  FetchProfileResponse fetch, {
  ValidateConfig? validate,
  InspectConfig? inspect,
}) async {
  final profile = Profile.normal(
    label: 'old',
    url: 'https://old.test/sub?token=abc',
    clientEmulation: SubscriptionClient.clash,
  );
  final updated = await profile.update(
    validate: validate ?? (_) async => '',
    inspect:
        inspect ??
        (_) async => const ConfigInspection(servers: ['node.example']),
    fetch: fetch,
  );

  expect(updated.url, 'https://old.test/sub?token=abc');
  expect(await (await updated.file).readAsString(), 'old payload');
}
