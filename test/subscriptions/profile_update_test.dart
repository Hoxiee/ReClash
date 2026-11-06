import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/app_paths.dart';

class _SubscriptionTransport extends SubscriptionTransport {
  _SubscriptionTransport(
    this.body,
    Map<String, List<String>> headers, {
    this.manifest,
  }) : responseHeaders = {
         ...headers,
         if (manifest != null) 'reclash-config': [_manifestUrl],
       };

  final String body;
  final String? manifest;
  final Map<String, List<String>> responseHeaders;
  Map<String, String>? requestHeaders;
  int requests = 0;

  @override
  Future<SubscriptionResponse> fetchCapped(
    Uri source, {
    required int limit,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => SubscriptionResponse(
    bytes: Uint8List.fromList(utf8.encode(manifest!)),
    headers: const {},
    status: 200,
    uri: source,
  );

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    requests++;
    requestHeaders = headers;
    return SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(body)),
      headers: responseHeaders,
      status: 200,
      uri: source,
    );
  }
}

class _FailingManifestTransport extends _SubscriptionTransport {
  _FailingManifestTransport(String body) : super(body, const {}, manifest: '');

  @override
  Future<SubscriptionResponse> fetchCapped(
    Uri source, {
    required int limit,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => throw const SubscriptionException(SubscriptionFailure.transport);
}

class _HostTransport extends SubscriptionTransport {
  _HostTransport(this.hosts, {this.manifest});

  final Map<String, Map<String, List<String>>?> hosts;
  final String? manifest;
  final fetched = <Uri>[];

  @override
  Future<SubscriptionResponse> fetchCapped(
    Uri source, {
    required int limit,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => SubscriptionResponse(
    bytes: Uint8List.fromList(utf8.encode(manifest!)),
    headers: const {},
    status: 200,
    uri: source,
  );

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    fetched.add(source);
    final responseHeaders = hosts[source.authority];
    if (responseHeaders == null) {
      throw const SubscriptionException(SubscriptionFailure.transport);
    }
    return SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(_nodeBody)),
      headers: responseHeaders,
      status: 200,
      uri: source,
    );
  }
}

const _manifestUrl = 'https://cdn.example.test/reclash.yaml';
const _newDomainManifest =
    'version: 1\ntransport:\n  new-domain: new.example.test\n';
const _configHeader = {
  'reclash-config': [_manifestUrl],
};
const _nodeBody =
    'proxies:\n  - name: node\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('profile_prepare_test');
    await useAppPaths(tempDir);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test(
    'prepares provider metadata and request settings without committing',
    () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile')
          .copyWith(
            subscriptionPreferences: const SubscriptionPreferences(
              headers: {'x-user-token': 'private'},
            ),
          );
      final transport = _SubscriptionTransport(_nodeBody, {
        'subscription-userinfo': ['upload=5; download=15; total=100; expire=0'],
      }, manifest: 'version: 1\nprovider:\n  name: Provider\n');

      final prepared = await profile.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      );

      expect(prepared.summary.hasLosses, isFalse);
      expect(prepared.snapshot.metadata.name, 'Provider');
      expect(prepared.snapshot.metadata.unlimited, isFalse);
      expect(prepared.subscriptionInfo?.upload, 5);
      expect(prepared.subscriptionInfo?.download, 15);
      expect(prepared.subscriptionInfo?.expire, 0);
      expect(transport.requestHeaders?['x-user-token'], 'private');
      expect(transport.requestHeaders?['user-agent'], isNotEmpty);
      expect(
        await File(
          await appPath.getProfilePath(profile.id.toString()),
        ).exists(),
        isFalse,
      );
    },
  );

  test('required policy follows the manifest and its withdrawal', () async {
    const manifest = 'version: 1\npolicy:\n  apps: required\n';
    const body = 'tun:\n  exclude-package: [com.bank.app]\n$_nodeBody';
    final profile = Profile.normal(url: 'https://subs.example.test/policy');
    final prepared = await profile.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(body, const {}, manifest: manifest),
    );
    final saved = await profile.commitPreparedUpdate(
      prepared,
      validate: (_, _) async => '',
    );
    expect(saved.subscriptionSnapshot?.providerPolicy?.requiredExcludedApps, {
      'com.bank.app',
    });
    final failed = await saved.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _FailingManifestTransport(body),
    );
    expect(failed.snapshot.providerPolicy?.requiredExcludedApps, {
      'com.bank.app',
    });
    final withdrawn = await saved.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(body, const {}),
    );
    expect(withdrawn.snapshot.providerPolicy, isNull);
  });

  group('global listed asks the Core', () {
    const manifest = 'version: 1\npolicy:\n  global: listed\n';

    Future<PreparedSubscriptionUpdate> prepare(
      ResolveProviderGlobalNodes? resolve, {
      String manifest = manifest,
      String body = _nodeBody,
    }) => Profile.normal(url: 'https://subs.example.test/global').prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(body, const {}, manifest: manifest),
      globalNodes: resolve,
    );

    test('the body goes to the Core and its count decides Global', () async {
      List<int>? asked;
      final prepared = await prepare((body) async {
        asked = body;
        return const ProviderGlobalNodes(allowed: 1, inline: 3);
      });
      expect(utf8.decode(asked!), _nodeBody);
      expect(prepared.snapshot.providerPolicy?.isGlobalRestricted, isFalse);
      expect(prepared.snapshot.warnings, isEmpty);
    });

    test('a filter that matches nothing removes Global', () async {
      final prepared = await prepare(
        (_) async => const ProviderGlobalNodes(allowed: 0, inline: 3),
      );
      expect(prepared.snapshot.providerPolicy?.isGlobalRestricted, isTrue);
      expect(prepared.snapshot.warnings, isEmpty);
    });

    test('a lock that restricts nothing warns in the snapshot', () async {
      final prepared = await prepare(
        (_) async => const ProviderGlobalNodes(allowed: 3, inline: 3),
      );
      expect(prepared.snapshot.warnings, [providerGlobalUnrestrictedWarning]);
    });

    test('remote providers keep the lock meaningful', () async {
      const body =
          '${_nodeBody}proxy-providers:\n  remote: {type: http, url: https://example.test/p}\n';
      final prepared = await prepare(
        (_) async => const ProviderGlobalNodes(allowed: 1, inline: 1),
        body: body,
      );
      expect(prepared.snapshot.warnings, isEmpty);
    });

    test('without the switch the Core is not asked', () async {
      var asked = false;
      final prepared = await prepare((_) async {
        asked = true;
        return const ProviderGlobalNodes(allowed: 0, inline: 0);
      }, manifest: 'version: 1\npolicy:\n  global: off\n');
      expect(asked, isFalse);
      expect(prepared.snapshot.providerPolicy, isNull);
    });

    test('a bad pattern rejects the update and keeps the old body', () async {
      await expectLater(
        prepare((_) async => throw Exception('invalid filter')),
        throwsA(isA<SubscriptionUpdateRejected>()),
      );
    });
  });

  test('an invalid policy value never blocks the update', () async {
    final transport = _SubscriptionTransport(
      _nodeBody,
      const {},
      manifest: 'version: 1\npolicy:\n  apps: sometimes\n',
    );
    final prepared = await Profile.normal(
      url: 'https://subs.example.test/policy-error',
    ).prepareUpdate(defaultUserAgent: 'ReClash/test', transport: transport);
    expect(prepared.snapshot.providerPolicy, isNull);
    expect(transport.requests, 1);
  });

  test('a provider refresh never renames an existing profile', () async {
    final profile = Profile.normal(url: 'https://subs.example.test/profile');
    final prepared = await profile.prepareUpdate(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(
        'proxies:\n  - name: node\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n',
        {
          'content-disposition': ['attachment; filename="provider.yaml"'],
        },
      ),
    );

    final saved = await profile.commitPreparedUpdate(
      prepared,
      validate: (_, _) async => '',
    );

    expect(saved.label, profile.label);
    expect(saved.realLabel, profile.realLabel);
  });

  test('provider interval only changes when the user permits the hint', () async {
    const body =
        'proxies:\n  - name: node\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n';
    final profile = Profile.normal(url: 'https://subs.example.test/profile')
        .copyWith(
          autoUpdateDuration: const Duration(minutes: 17),
          subscriptionPreferences: const SubscriptionPreferences(
            intervalOverride: false,
          ),
        );
    final updated = await profile.update(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(body, {
        'profile-update-interval': ['31'],
      }),
      validate: (_, _) async => '',
    );

    expect(updated.autoUpdateDuration, const Duration(hours: 31));
  });

  test('lossy conversion requires explicit approval before writing', () async {
    const source =
        '{"inbounds":[{"port":1080}],"dns":{"servers":["1.1.1.1"]},"routing":{"rules":[]},"outbounds":[{"tag":"edge","protocol":"vless","settings":{"vnext":[{"address":"edge.example","port":443,"users":[{"id":"11111111-1111-4111-8111-111111111111","encryption":"none"}]}]},"streamSettings":{"network":"tcp"}}]}';
    final profile = Profile.normal(url: 'https://subs.example.test/profile');
    final transport = _SubscriptionTransport(source, const {});

    await expectLater(
      profile.update(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
        validate: (_, _) async => '',
      ),
      throwsA(isA<SubscriptionUpdateCancelled>()),
    );
    expect(
      await File(await appPath.getProfilePath(profile.id.toString())).exists(),
      isFalse,
    );
  });

  test(
    'accepted lossy update validates and atomically stores the candidate',
    () async {
      const source =
          '{"inbounds":[{"port":1080}],"dns":{"servers":["1.1.1.1"]},"routing":{"rules":[]},"outbounds":[{"tag":"edge","protocol":"vless","settings":{"vnext":[{"address":"edge.example","port":443,"users":[{"id":"11111111-1111-4111-8111-111111111111","encryption":"none"}]}]},"streamSettings":{"network":"tcp"}}]}';
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      final updated = await profile.update(
        defaultUserAgent: 'ReClash/test',
        transport: _SubscriptionTransport(source, const {}),
        approveLosses: (prepared) async => prepared.summary.hasLosses,
        validate: (path, _) async {
          expect(await File(path).readAsString(), contains('proxies:'));
          return '';
        },
      );

      expect(updated.lastUpdateDate, isNotNull);
      expect(updated.subscriptionSnapshot?.stale, isFalse);
      expect(await (await profile.file).readAsString(), contains('proxies:'));
      expect(
        await File('${(await profile.file).path}.previous').exists(),
        isFalse,
      );
    },
  );

  group('manifest routing', () {
    const routing = 'version: 1\nrouting:\n  profiles: {}\n';

    Future<File> routingFile(Profile profile) async =>
        File(await appPath.getProfileRoutingPath(profile.id.toString()));

    Future<Profile> update(Profile profile, String manifest) => profile.update(
      defaultUserAgent: 'ReClash/test',
      transport: _SubscriptionTransport(
        _nodeBody,
        const {},
        manifest: manifest,
      ),
      validate: (_, _) async => '',
    );

    test('a routing section stores the manifest for the Core', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      await update(profile, routing);

      expect(await (await routingFile(profile)).readAsString(), routing);
    });

    test('a manifest without routing leaves no bundle', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      await update(profile, 'version: 1\n');

      expect(await (await routingFile(profile)).exists(), isFalse);
    });

    test('dropping the section deletes the stored bundle', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      await update(profile, routing);
      await update(profile, 'version: 1\n');

      expect(await (await routingFile(profile)).exists(), isFalse);
    });

    test('a malformed section is not stored', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      await update(profile, 'version: 1\nrouting: [1]\n');

      expect(await (await routingFile(profile)).exists(), isFalse);
    });
  });

  group('provider hosts', () {
    Profile profile([String? fallback]) =>
        Profile.normal(url: 'https://main.example.test/sub?token=1').copyWith(
          subscriptionSnapshot: fallback == null
              ? null
              : SubscriptionSnapshot(
                  metadata: SubscriptionMetadata({
                    'transport.fallbackHosts': [fallback],
                  }),
                  receivedAt: DateTime.utc(2026),
                ),
        );

    test('a fallback host serves an update the main host cannot', () async {
      final transport = _HostTransport({'backup.example.test': const {}});

      final prepared = await profile(
        'backup.example.test',
      ).prepareUpdate(defaultUserAgent: 'ReClash/test', transport: transport);

      expect(prepared.migratedUrl, isNull);
      expect(
        transport.fetched.last.toString(),
        startsWith('https://backup.example.test/sub?token=1'),
      );
    });

    test('without a fallback the failure is reported', () async {
      final transport = _HostTransport({});

      await expectLater(
        profile().prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
        ),
        throwsA(isA<SubscriptionUpdateRejected>()),
      );
    });

    test('a validated new domain moves the profile', () async {
      final transport = _HostTransport({
        'main.example.test': _configHeader,
        'new.example.test': const {},
      }, manifest: _newDomainManifest);

      final prepared = await profile().prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      );

      expect(prepared.migratedUrl, 'https://new.example.test/sub?token=1');
    });

    test('a new domain that fails validation is ignored', () async {
      final transport = _HostTransport({
        'main.example.test': _configHeader,
      }, manifest: _newDomainManifest);

      final prepared = await profile().prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      );

      expect(prepared.migratedUrl, isNull);
    });

    test('a manifest on a plain http subscription is not followed', () async {
      final transport = _HostTransport({
        'main.example.test': _configHeader,
        'new.example.test': const {},
      }, manifest: _newDomainManifest);

      final prepared = await Profile.normal(
        url: 'http://main.example.test/sub',
      ).prepareUpdate(defaultUserAgent: 'ReClash/test', transport: transport);

      expect(prepared.migratedUrl, isNull);
      expect(transport.fetched, hasLength(1));
    });
  });
}
