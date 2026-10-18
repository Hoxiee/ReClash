import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/app_paths.dart';

class _SubscriptionTransport extends SubscriptionTransport {
  _SubscriptionTransport(this.body, this.responseHeaders);

  final String body;
  final Map<String, List<String>> responseHeaders;
  Map<String, String>? requestHeaders;

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    requestHeaders = headers;
    return SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(body)),
      headers: responseHeaders,
      status: 200,
      uri: source,
    );
  }
}

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
      final transport = _SubscriptionTransport(
        '# reclash-servicename: Provider\nproxies:\n  - name: node\n    type: ss\n    server: example.test\n    port: 443\n    cipher: aes-128-gcm\n    password: token\n',
        {
          'subscription-userinfo': [
            'upload=5; download=15; total=100; expire=0',
          ],
        },
      );

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
        'reclash-autoupdateinterval': ['31'],
      }),
      validate: (_, _) async => '',
    );

    expect(updated.autoUpdateDuration, const Duration(minutes: 31));
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
}
