import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/subscriptions/transport/header_policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

void main() {
  group('subscription headers', () {
    test(
      'normalizes names and lets a per-request value override stored values',
      () {
        expect(
          overlaySubscriptionHeaders(
            {'User-Agent': 'stored', 'X-Test': 'one'},
            {'user-agent': 'request'},
          ),
          {'user-agent': 'request', 'x-test': 'one'},
        );
      },
    );

    test('rejects duplicate, controlled, identity and malformed headers', () {
      for (final headers in [
        {'X-Test': 'one', 'x-test': 'two'},
        {'Host': 'subs.example.test'},
        {'x-hwid': 'a' * 32},
        {'X-Test': 'line\r\ninjected: yes'},
        {'Bad Header': 'value'},
      ]) {
        expect(
          () => validateSubscriptionHeaders(headers),
          throwsA(isA<SubscriptionHeaderException>()),
        );
      }
      expect(
        validateSubscriptionHeaders({'X-HWID': 'a' * 32}, allowManaged: true),
        {'x-hwid': 'a' * 32},
      );
    });

    test(
      'redirects preserve only non-sensitive standard request headers cross-origin',
      () {
        final headers = {
          'authorization': 'secret',
          'x-hwid': 'a' * 32,
          'x-custom-token': 'secret',
          'user-agent': 'ReClash',
          'accept-language': 'en',
        };
        expect(
          redirectSubscriptionHeaders(
            headers,
            Uri.parse('https://one.example/sub'),
            Uri.parse('https://two.example/sub'),
          ),
          {'user-agent': 'ReClash', 'accept-language': 'en'},
        );
        expect(
          redirectSubscriptionHeaders(
            headers,
            Uri.parse('https://one.example/sub'),
            Uri.parse('https://one.example/next'),
          ),
          same(headers),
        );
      },
    );

    test('normalizes HTTP origins and rejects non-HTTP schemes', () {
      expect(
        subscriptionOrigin(Uri.parse('HTTPS://Example.test:443/path')),
        'https://example.test',
      );
      expect(
        () => subscriptionOrigin(Uri.parse('file:///etc/passwd')),
        throwsFormatException,
      );
    });

    test('redacts credentials and custom values in diagnostics', () {
      expect(
        redactSubscriptionHeaders({
          'User-Agent': 'ReClash',
          'Authorization': 'secret',
        }),
        {'User-Agent': 'ReClash', 'Authorization': '[redacted]'},
      );
    });
  });

  group('provider metadata contract', () {
    test('declares only implemented metadata consumers', () {
      expect(subscriptionFields.map((field) => field.consumer).toSet(), {
        'panel',
        'scheduler',
      });
      expect(
        subscriptionFields.map((field) => field.path).toSet(),
        hasLength(subscriptionFields.length),
      );
      expect(
        subscriptionFields.map((field) => field.header).toSet(),
        hasLength(subscriptionFields.length),
      );
    });

    test('unsupported domain and fallback hints cannot enter metadata', () {
      final result = readSubscriptionMetadata({
        'reclash-servicename': ['Provider'],
        'reclash-newdomain': ['other.example.test'],
        'reclash-fallbackhosts': ['one.example.test,two.example.test'],
      }, body: '# reclash-newdomain: body.example.test\nproxies: []');
      expect(result.metadata.fields, {'provider.name': 'Provider'});
      expect(
        result.warnings,
        contains('Unsupported provider field: reclash-newdomain'),
      );
      expect(
        result.warnings,
        contains('Unsupported provider field: reclash-fallbackhosts'),
      );
      expect(
        SubscriptionMetadata.fromJson({
          'update': {
            'newDomain': 'other.example.test',
            'fallbackHosts': ['one.example.test'],
          },
        }).fields,
        isEmpty,
      );
    });

    test('FlClashX aliases normalize only for its selected preset', () {
      final alias = {
        'flclashx-servicename': ['FlClashX provider'],
      };
      expect(readSubscriptionMetadata(alias).metadata.name, isNull);
      expect(
        readSubscriptionMetadata(alias).warnings,
        contains('Unsupported provider field: flclashx-servicename'),
      );
      expect(
        readSubscriptionMetadata(
          alias,
          clientPreset: SubscriptionClientPreset.flClashX,
        ).metadata.name,
        'FlClashX provider',
      );
      expect(
        readSubscriptionMetadata(
          {
            ...alias,
            'reclash-servicename': ['Native provider'],
          },
          body:
              '# flclashx-supporturl: https://support.example.test\nproxies: []',
          clientPreset: SubscriptionClientPreset.flClashX,
        ).metadata.fields,
        {
          'provider.name': 'Native provider',
          'provider.supportUrl': 'https://support.example.test',
        },
      );
    });

    test('valid HTTP metadata wins over body fields independently', () {
      final result = readSubscriptionMetadata(
        {
          'ReClash-ServiceName': ['HTTP provider'],
          'reclash-supporturl': ['javascript:invalid'],
        },
        body:
            '# reclash-servicename: Body provider\n# reclash-supporturl: https://support.example.test\nproxies: []',
      );
      expect(result.metadata.name, 'HTTP provider');
      expect(
        result.metadata.text('provider.supportUrl'),
        'https://support.example.test',
      );
      expect(result.source, SubscriptionDataSource.http);
      expect(
        result.warnings,
        contains('Invalid provider field: reclash-supporturl'),
      );
    });

    test('allows Telegram only for provider support links', () {
      final metadata = SubscriptionMetadata.fromJson({
        'provider': {
          'supportUrl': 'tg://resolve?domain=support_bot',
          'logo': 'tg://resolve?domain=logo_bot',
          'webUrl': 'tg://resolve?domain=web_bot',
        },
      });
      expect(
        metadata.text('provider.supportUrl'),
        'tg://resolve?domain=support_bot',
      );
      expect(metadata.text('provider.logo'), isNull);
      expect(metadata.text('provider.webUrl'), isNull);
    });

    test('explicit Base64 text round-trips without guessing plain text', () {
      const metadata = SubscriptionMetadata({'provider.name': 'Províder'});
      final encoded = encodeSubscriptionMetadata(metadata);
      expect(encoded['reclash-servicename'], startsWith('base64:'));
      expect(
        readSubscriptionMetadata({
          for (final entry in encoded.entries) entry.key: [entry.value],
        }).metadata,
        metadata,
      );
      expect(
        readSubscriptionMetadata({
          'reclash-servicename': ['UHJvdmlkZXI='],
        }).metadata.name,
        'UHJvdmlkZXI=',
      );
    });
  });

  group('subscription payload', () {
    test('bounds decoded output and preserves uncompressed input', () async {
      final bytes = Uint8List.fromList(utf8.encode('small payload'));
      expect(await decompressSubscriptionPayload(bytes), bytes);
      await expectLater(
        decompressSubscriptionPayload(Uint8List(32 * 1024 * 1024 + 1)),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.failure,
            'failure',
            SubscriptionFailure.oversized,
          ),
        ),
      );
    });

    test(
      'classifies device response headers before payload interpretation',
      () {
        expect(
          readSubscriptionMetadata({
            'X-HWID-Max-Devices-Reached': ['true'],
          }).deviceStatus,
          SubscriptionDeviceStatus.limitReached,
        );
        expect(
          readSubscriptionMetadata({
            'x-hwid-not-supported': ['1'],
          }).deviceStatus,
          SubscriptionDeviceStatus.unsupported,
        );
      },
    );
  });

  group('subscription preference persistence', () {
    test(
      'keeps custom headers and client settings but defaults old rows safely',
      () {
        final old = SubscriptionPreferences.safeFromJson(null);
        expect(old.intervalOverride, isTrue);
        expect(old.headers, isEmpty);
        expect(old.client.preset.name, 'reclash');

        final saved = SubscriptionPreferences(
          headers: {'x-token': 'secret'},
          client: const SubscriptionClientSettings(customUserAgent: 'Custom/1'),
        );
        final restored = SubscriptionPreferences.safeFromJson(saved.toJson());
        expect(restored.headers, saved.headers);
        expect(restored.client.customUserAgent, 'Custom/1');
      },
    );

    test('drops managed headers from restored preferences', () {
      final restored = SubscriptionPreferences.safeFromJson({
        'headers': {'x-hwid': 'a' * 32, 'x-token': 'kept'},
      });
      expect(restored.headers, isEmpty);
    });

    test('snapshot marks old metadata stale without deleting the payload', () {
      final snapshot = SubscriptionSnapshot(
        metadata: const SubscriptionMetadata({'provider.name': 'Example'}),
        receivedAt: DateTime.utc(2026),
        stale: true,
        staleFields: const ['subscription.total'],
      );
      final restored = SubscriptionSnapshot.safeFromJson(snapshot.toJson());
      expect(restored?.metadata.name, 'Example');
      expect(restored?.usageStale, isTrue);
    });
  });
}
