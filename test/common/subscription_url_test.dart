import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:reclash/common/subscription/subscription_url.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _badResponse(int status) => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: DioExceptionType.badResponse,
  response: Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: status,
  ),
);

void main() {
  group('normalizeSubscriptionUrl', () {
    test('a GitHub file page becomes its raw counterpart', () {
      expect(
        normalizeSubscriptionUrl(
          'https://github.com/owner/repo/blob/main/dir/config.yaml',
        ),
        'https://raw.githubusercontent.com/owner/repo/main/dir/config.yaml',
      );
    });

    test('the raw path and a bare http scheme land on the same URL', () {
      expect(
        normalizeSubscriptionUrl(
          '  http://www.github.com/owner/repo/raw/main/config.yaml  ',
        ),
        'https://raw.githubusercontent.com/owner/repo/main/config.yaml',
      );
    });

    test('anything else is only trimmed', () {
      const url = 'https://panel.test/sub?token=abc';

      expect(normalizeSubscriptionUrl(' $url '), url);
      expect(
        normalizeSubscriptionUrl('https://github.com/owner/repo'),
        'https://github.com/owner/repo',
      );
      expect(
        normalizeSubscriptionUrl('https://github.com/owner/repo/tree/main/dir'),
        'https://github.com/owner/repo/tree/main/dir',
      );
    });
  });

  group('subscriptionDomainCandidate', () {
    test('replaces only authority and keeps the subscription target', () {
      expect(
        subscriptionDomainCandidate(
          'https://old.test:8443/sub/path?token=abc#section',
          'new.test:9443',
        ),
        'https://new.test:9443/sub/path?token=abc#section',
      );
      expect(
        subscriptionDomainCandidate(
          'http://old.test:8080/sub?token=abc',
          'new.test',
        ),
        'http://new.test:8080/sub?token=abc',
      );
    });

    test('rejects ambiguous or malformed authorities', () {
      for (final value in [
        'https://new.test',
        'user@new.test',
        'new.test/path',
        'new.test?token=other',
        'new.test#fragment',
        'new.test:70000',
        'localhost',
        '-bad.test',
      ]) {
        expect(
          subscriptionDomainCandidate('https://old.test/sub', value),
          isNull,
          reason: value,
        );
      }
      expect(
        subscriptionDomainCandidate(
          'https://user:secret@old.test/sub',
          'new.test',
        ),
        isNull,
      );
    });

    test('ignores the current authority', () {
      expect(
        subscriptionDomainCandidate(
          'https://old.test:8443/sub',
          'OLD.TEST:8443',
        ),
        isNull,
      );
    });
  });

  group('parseFallbackHosts', () {
    test('hosts are lowercased, deduplicated and capped', () {
      final hosts = parseFallbackHosts(
        'A.example.com, a.example.com ,b.example.com,c.example.com,'
        'd.example.com,e.example.com',
      );

      expect(hosts, [
        'a.example.com',
        'b.example.com',
        'c.example.com',
        'd.example.com',
      ]);
      expect(hosts.length, maxFallbackHosts);
    });

    test('anything that is not a bare hostname is dropped', () {
      expect(
        parseFallbackHosts(
          'spare.example.com:8443,/path,localhost, ,-bad.test',
        ),
        isEmpty,
      );
      expect(parseFallbackHosts(null), isEmpty);
    });
  });

  group('subscriptionUrlCandidates', () {
    test('the primary URL comes first and its own host is not repeated', () {
      expect(
        subscriptionUrlCandidates('https://panel.test/sub?token=abc', [
          'panel.test',
          'spare.test',
          'spare.test',
        ]),
        [
          'https://panel.test/sub?token=abc',
          'https://spare.test/sub?token=abc',
        ],
      );
    });

    test('a URL without a host stands alone', () {
      expect(subscriptionUrlCandidates('not a url', ['spare.test']), [
        'not a url',
      ]);
    });
  });

  group('subscriptionDisplaySource', () {
    test('removes credentials, query parameters and fragments', () {
      expect(
        subscriptionDisplaySource(
          'https://user:secret@panel.test:8443/sub/path?token=abc#node',
        ),
        'https://panel.test:8443/sub/path',
      );
      expect(
        subscriptionDisplaySource(
          'vless://uuid@node.test:443?security=tls#Node',
        ),
        'vless://node.test:443',
      );
    });

    test('does not expose raw configuration and bounds displayed URLs', () {
      expect(subscriptionDisplaySource('proxies:\n  - name: secret'), isNull);
      expect(
        subscriptionDisplaySource(
          'https://panel.test/${List.filled(200, 'a').join()}',
        )!.length,
        120,
      );
    });
  });

  group('subscription redirects', () {
    test('cross-origin redirects strip client and device identity', () {
      final headers = subscriptionRedirectHeaders(
        {
          'User-Agent': 'INCY/3.3.1/Android',
          'x-client': 'INCY',
          'x-app-version': '3.3.1',
          'x-hwid': 'secret-hwid',
          'x-device-os': 'Android',
          'x-device-model': 'Phone',
          'Accept-Language': 'ru-RU',
          'Accept': 'application/yaml',
        },
        from: Uri.parse('https://primary.test/sub'),
        to: Uri.parse('https://cdn.test/sub'),
      );

      expect(headers, {
        'Accept-Language': 'ru-RU',
        'Accept': 'application/yaml',
      });
    });

    test('same-origin redirects preserve request headers', () {
      final headers = {'User-Agent': 'ReClash/1.0', 'x-hwid': 'secret'};

      expect(
        subscriptionRedirectHeaders(
          headers,
          from: Uri.parse('https://panel.test/sub'),
          to: Uri.parse('https://panel.test/moved'),
        ),
        same(headers),
      );
    });

    test('rejects HTTPS downgrade and non-HTTP destinations', () {
      expect(
        isAllowedSubscriptionRedirect(
          Uri.parse('https://panel.test/sub'),
          Uri.parse('http://panel.test/sub'),
        ),
        isFalse,
      );
      expect(
        isAllowedSubscriptionRedirect(
          Uri.parse('https://panel.test/sub'),
          Uri.parse('file:///tmp/config'),
        ),
        isFalse,
      );
      expect(
        isAllowedSubscriptionRedirect(
          Uri.parse('http://panel.test/sub'),
          Uri.parse('https://panel.test/sub'),
        ),
        isTrue,
      );
    });
  });

  group('shouldTryNextSubscriptionClient', () {
    test('client-specific rejections permit another preset', () {
      expect(shouldTryNextSubscriptionClient(_badResponse(400)), isTrue);
      expect(shouldTryNextSubscriptionClient(_badResponse(401)), isTrue);
      expect(shouldTryNextSubscriptionClient(_badResponse(403)), isTrue);
    });

    test(
      'missing subscriptions and transport failures keep their semantics',
      () {
        expect(shouldTryNextSubscriptionClient(_badResponse(404)), isFalse);
        expect(shouldTryNextSubscriptionClient(_badResponse(410)), isFalse);
        expect(shouldTryNextSubscriptionClient(_badResponse(503)), isFalse);
        expect(
          shouldTryNextSubscriptionClient(const SocketException('reset')),
          isFalse,
        );
      },
    );
  });

  group('shouldTryFallbackHost', () {
    test(
      'transport failures and an overloaded host are worth another host',
      () {
        expect(
          shouldTryFallbackHost(const SocketException('no route')),
          isTrue,
        );
        expect(shouldTryFallbackHost(TimeoutException('slow')), isTrue);
        expect(
          shouldTryFallbackHost(
            DioException(
              requestOptions: RequestOptions(path: '/'),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
          isTrue,
        );
        expect(shouldTryFallbackHost(_badResponse(429)), isTrue);
        expect(shouldTryFallbackHost(_badResponse(503)), isTrue);
        expect(
          shouldTryFallbackHost(
            DioException(
              requestOptions: RequestOptions(path: '/'),
              error: const SocketException('reset'),
            ),
          ),
          isTrue,
        );
      },
    );

    test('a deleted subscription or a refused client is not', () {
      expect(shouldTryFallbackHost(_badResponse(404)), isFalse);
      expect(shouldTryFallbackHost(_badResponse(410)), isFalse);
      expect(shouldTryFallbackHost(_badResponse(403)), isFalse);
      expect(
        shouldTryFallbackHost(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.cancel,
          ),
        ),
        isFalse,
      );
      expect(shouldTryFallbackHost(const FormatException('bad body')), isFalse);
    });
  });

  group('SubscriptionHostRecord', () {
    test('remembered hosts merge ahead of the known ones and stay capped', () {
      final record = const SubscriptionHostRecord().remember(
        profileId: 3,
        hosts: ['a.test', 'b.test'],
      );
      final merged = record.remember(
        profileId: 3,
        hosts: ['c.test', 'a.test', 'd.test', 'e.test'],
      );

      expect(record.hostsFor(3), ['a.test', 'b.test']);
      expect(merged.hostsFor(3), ['c.test', 'a.test', 'd.test', 'e.test']);
      expect(merged.hostsFor(4), isEmpty);
    });

    test('nothing worth keeping leaves the record alone', () {
      const record = SubscriptionHostRecord();

      expect(record.remember(profileId: 1, hosts: ['bad host']), record);
      expect(record.forget(1), record);
    });

    test('forgetting one profile keeps the others', () {
      final record = const SubscriptionHostRecord()
          .remember(profileId: 1, hosts: ['a.test'])
          .remember(profileId: 2, hosts: ['b.test']);

      final remaining = record.forget(1);

      expect(remaining.hostsFor(1), isEmpty);
      expect(remaining.hostsFor(2), ['b.test']);
    });

    test('a round trip survives, and nonsense decodes to an empty record', () {
      final record = const SubscriptionHostRecord().remember(
        profileId: 7,
        hosts: ['a.test', 'b.test'],
      );

      expect(
        SubscriptionHostRecord.fromJson(record.toJson()).hostsFor(7),
        record.hostsFor(7),
      );
      expect(SubscriptionHostRecord.fromJson('nonsense').hosts, isEmpty);
      expect(
        SubscriptionHostRecord.fromJson({'1': 'a.test', '2': []}).hosts,
        isEmpty,
      );
    });
  });
}
