import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/common/path.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/app_paths.dart';

const _nativeConfig = '''proxies:
  - name: node
    type: ss
    server: example.test
    port: 443
    cipher: aes-128-gcm
    password: fake
''';

class _NegotiationTransport extends SubscriptionTransport {
  _NegotiationTransport(this.responses);

  final List<Object> responses;
  final requests = <Map<String, String>>[];

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    final response = responses[requests.length];
    requests.add(Map<String, String>.unmodifiable(headers));
    if (response is SubscriptionException) throw response;
    return SubscriptionResponse(
      bytes: Uint8List.fromList(utf8.encode(response as String)),
      headers: const {},
      status: 200,
      uri: source,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('subscription_auto_test');
    await useAppPaths(directory);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  for (final body in [
    'unknown subscription format',
    '{"outbounds":[{"type":"mystery","server":"example.test"}]}',
  ]) {
    test('Auto negotiates a foreign HTTP 200 payload: $body', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      final transport = _NegotiationTransport([body, _nativeConfig]);
      var validations = 0;

      final prepared = await profile.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
        validate: (path, _) async {
          validations++;
          expect(await File(path).readAsString(), _nativeConfig);
          return '';
        },
      );

      expect(transport.requests, hasLength(2));
      expect(transport.requests.first['user-agent'], 'ReClash/test');
      expect(
        transport.requests.last['user-agent'],
        subscriptionClientRequestHeaders(
          SubscriptionClientPreset.flClashX,
          defaultUserAgent: 'ReClash/test',
        )['User-Agent'],
      );
      expect(prepared.client, SubscriptionClientPreset.flClashX);
      expect(prepared.payload.format, SubscriptionFormat.clash);
      expect(prepared.summary.nodes, 1);
      expect(validations, 1);
      expect(
        await File(
          await appPath.getProfilePath(profile.id.toString()),
        ).exists(),
        isFalse,
      );
    });
  }

  test('fixed client does not negotiate a second client', () async {
    final profile = Profile.normal(
      url: 'https://subs.example.test/profile',
    ).copyWith(subscriptionPreferences: const SubscriptionPreferences());
    final transport = _NegotiationTransport(['foreign format', _nativeConfig]);

    await expectLater(
      profile.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      ),
      throwsA(
        isA<SubscriptionUpdateRejected>().having(
          (error) => error.reason,
          'reason',
          SubscriptionRetryReason.incompatibleResponse,
        ),
      ),
    );
    expect(transport.requests, hasLength(1));
  });

  test('Auto bounds requests to unique clients', () async {
    final profile = Profile.normal(url: 'https://subs.example.test/profile');
    final transport = _NegotiationTransport(
      List.filled(maxAutomaticSubscriptionAttempts, 'foreign format'),
    );

    await expectLater(
      profile.prepareUpdate(
        defaultUserAgent: 'ReClash/test',
        transport: transport,
      ),
      throwsA(
        isA<SubscriptionUpdateRejected>().having(
          (error) => error.reason,
          'reason',
          SubscriptionRetryReason.incompatibleResponse,
        ),
      ),
    );
    expect(transport.requests, hasLength(maxAutomaticSubscriptionAttempts));
    expect(
      transport.requests.map((headers) => headers['user-agent']).toSet(),
      hasLength(maxAutomaticSubscriptionAttempts),
    );
  });

  const terminalFailures = <(SubscriptionException, SubscriptionRetryReason)>[
    (
      SubscriptionException(SubscriptionFailure.transport),
      SubscriptionRetryReason.transport,
    ),
    (
      SubscriptionException(SubscriptionFailure.tls),
      SubscriptionRetryReason.tls,
    ),
    (
      SubscriptionException(SubscriptionFailure.timeout),
      SubscriptionRetryReason.timeout,
    ),
    (
      SubscriptionException(SubscriptionFailure.unauthorized, status: 401),
      SubscriptionRetryReason.unauthorized,
    ),
    (
      SubscriptionException(SubscriptionFailure.unauthorized, status: 403),
      SubscriptionRetryReason.forbidden,
    ),
    (
      SubscriptionException(SubscriptionFailure.rateLimited, status: 429),
      SubscriptionRetryReason.rateLimited,
    ),
    (
      SubscriptionException(SubscriptionFailure.deviceRequired, status: 403),
      SubscriptionRetryReason.deviceConsentRequired,
    ),
    (
      SubscriptionException(SubscriptionFailure.deviceLimit, status: 403),
      SubscriptionRetryReason.deviceLimitReached,
    ),
    (
      SubscriptionException(SubscriptionFailure.oversized),
      SubscriptionRetryReason.invalidResponse,
    ),
    (
      SubscriptionException(SubscriptionFailure.invalid),
      SubscriptionRetryReason.invalidResponse,
    ),
    (
      SubscriptionException(SubscriptionFailure.empty),
      SubscriptionRetryReason.invalidResponse,
    ),
    (
      SubscriptionException(SubscriptionFailure.redirect),
      SubscriptionRetryReason.invalidResponse,
    ),
    (
      SubscriptionException(SubscriptionFailure.http, status: 500),
      SubscriptionRetryReason.invalidResponse,
    ),
  ];

  for (final (failure, reason) in terminalFailures) {
    test('Auto stops after ${failure.failure.name}', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      final transport = _NegotiationTransport([failure, _nativeConfig]);

      await expectLater(
        profile.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
        ),
        throwsA(
          isA<SubscriptionUpdateRejected>().having(
            (error) => error.reason,
            'reason',
            reason,
          ),
        ),
      );
      expect(transport.requests, hasLength(1));
    });
  }

  for (final body in ['proxies: []', ' \n\t', 'proxies: [broken\n']) {
    test('Auto stops on invalid or empty config', () async {
      final profile = Profile.normal(url: 'https://subs.example.test/profile');
      final path = File(await appPath.getProfilePath(profile.id.toString()));
      await path.parent.create(recursive: true);
      await path.writeAsString(_nativeConfig);
      final transport = _NegotiationTransport([body, _nativeConfig]);

      await expectLater(
        profile.prepareUpdate(
          defaultUserAgent: 'ReClash/test',
          transport: transport,
        ),
        throwsA(
          isA<SubscriptionUpdateRejected>().having(
            (error) => error.reason,
            'reason',
            SubscriptionRetryReason.invalidResponse,
          ),
        ),
      );
      expect(transport.requests, hasLength(1));
      expect(await path.readAsString(), _nativeConfig);
    });
  }
}
