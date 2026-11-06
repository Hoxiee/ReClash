import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/preferences.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/subscriptions/transport/header_policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../helpers/provider_presentation.dart';

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
        'manifest',
        'apps',
        'reminder',
        'settings',
        'transport',
        'support',
      });
      expect(
        subscriptionFields.map((field) => field.path).toSet(),
        hasLength(subscriptionFields.length),
      );
      final headers = subscriptionFieldHeaders.toList();
      expect(headers.toSet(), hasLength(headers.length));
      expect(headers.where((header) => header.startsWith('reclash-')), [
        'reclash-config',
      ]);
    });

    test('standard headers decode into their fields', () {
      final result = readSubscriptionMetadata({
        'Support-URL': ['https://support.example.test'],
        'Profile-Web-Page-URL': ['https://web.example.test'],
        'Announce': ['base64:SGVsbG8='],
        'Hide-URL': ['yes'],
        'Profile-Title': ['UHJvdmlkZXI='],
        'Profile-Update-Interval': ['6'],
        'Subscription-Userinfo': ['upload=1; download=2; total=0; expire=0'],
      });
      expect(result.metadata.fields, {
        'provider.supportUrl': 'https://support.example.test',
        'provider.webUrl': 'https://web.example.test',
        'provider.announce': 'Hello',
        'presentation.hideUrl': true,
        'account.title': 'UHJvdmlkZXI=',
        'update.intervalMinutes': 360,
        'subscription.upload': 1,
        'subscription.download': 2,
        'subscription.total': 0,
        'subscription.unlimited': true,
        'subscription.expire': 0,
        'subscription.perpetual': true,
      });
      expect(result.warnings, isEmpty);
      final invalid = readSubscriptionMetadata({
        'profile-update-interval': ['0'],
        'support-url': ['javascript:alert(1)'],
      });
      expect(invalid.metadata.fields, isEmpty);
      expect(
        invalid.warnings,
        containsAll([
          'Invalid provider field: profile-update-interval',
          'Invalid provider field: support-url',
        ]),
      );
    });

    test('removed reclash headers warn and decode nothing', () {
      final result = readSubscriptionMetadata({
        'reclash-servicename': ['Provider'],
        'flclashx-servicename': ['Provider'],
        'reclash-routing': ['https://routing.example.test/bundle.yaml'],
      });
      expect(result.metadata.fields, isEmpty);
      expect(
        result.warnings,
        containsAll([
          'Unsupported provider field: reclash-servicename',
          'Unsupported provider field: reclash-routing',
        ]),
      );
    });

    test('the manifest address needs an HTTPS response', () {
      final headers = {
        'reclash-config': ['https://cdn.example.test/config.yaml'],
      };
      expect(
        readSubscriptionMetadata(
          headers,
          secure: true,
        ).metadata.text('presentation.config'),
        'https://cdn.example.test/config.yaml',
      );
      final plain = readSubscriptionMetadata(headers);
      expect(plain.metadata.fields, isEmpty);
      expect(
        plain.warnings,
        contains('Provider field needs an HTTPS response: reclash-config'),
      );
    });

    test('subscription kind is display only and tolerates unknown tokens', () {
      SubscriptionKind? kindOf(String value) => manifestMetadata({
        'provider': {'type': value},
      }).kind;
      expect(kindOf('test'), SubscriptionKind.test);
      expect(kindOf(' Promo '), SubscriptionKind.promo);
      expect(kindOf('vip'), isNull);
      expect(kindOf('x' * 33), isNull);
    });

    test('provider hosts are kept as validated authorities', () {
      final metadata = manifestMetadata({
        'transport': {
          'new-domain': 'https://Other.example.test/',
          'fallback-hosts': ['one.example.test', 'two.example.test:8443'],
        },
      });
      expect(metadata.strings('transport.newDomain'), ['other.example.test']);
      expect(metadata.strings('transport.fallbackHosts'), [
        'one.example.test',
        'two.example.test:8443',
      ]);
      final invalid = parseProviderConfig(
        jsonEncode({
          'version': 1,
          'transport': {
            'fallback-hosts': ['one.example.test/path'],
          },
        }),
        'en',
      );
      expect(invalid.config!.fields, isEmpty);
      expect(
        invalid.warnings,
        contains('Invalid transport section: transport.fallback-hosts'),
      );
    });

    test('the dark service logo is decoded and rejects non-link values', () {
      final metadata = manifestMetadata({
        'provider': {'logo-dark': 'https://cdn.example.net/dark.png'},
      });
      expect(
        metadata.text('provider.logoDark'),
        'https://cdn.example.net/dark.png',
      );
      expect(metadata.logoFor(dark: true), 'https://cdn.example.net/dark.png');
      final invalid = parseProviderConfig(
        jsonEncode({
          'version': 1,
          'provider': {'logo-dark': 'javascript:alert(1)'},
        }),
        'en',
      );
      expect(invalid.config!.fields, isEmpty);
      expect(
        invalid.warnings,
        contains('Invalid provider section: provider.logo-dark'),
      );
    });

    test('logoFor reads the dark logo only in dark mode', () {
      const light = 'https://cdn.example.net/light.png';
      const dark = 'https://cdn.example.net/dark.png';
      const both = SubscriptionMetadata({
        'provider.logo': light,
        'provider.logoDark': dark,
      });
      const lightOnly = SubscriptionMetadata({'provider.logo': light});
      expect(both.logoFor(dark: true), dark);
      expect(both.logoFor(dark: false), light);
      expect(lightOnly.logoFor(dark: true), light);
      expect(lightOnly.logoFor(dark: false), light);
      expect(const SubscriptionMetadata().logoFor(dark: true), isNull);
    });

    test('valid manifest fields win over header fallbacks independently', () {
      final headers = readSubscriptionMetadata({
        'support-url': ['javascript:invalid'],
        'profile-web-page-url': ['https://header.example.test'],
        'announce': ['Header announcement'],
      });
      final manifest = parseProviderConfig(
        jsonEncode({
          'version': 1,
          'provider': {
            'name': 'Manifest provider',
            'web-url': 'https://manifest.example.test',
          },
        }),
        'en',
      ).config;
      final result = withManifest(
        headers,
        manifest,
        excluded: const [],
        included: const [],
      );
      expect(result.metadata.fields, {
        'provider.name': 'Manifest provider',
        'provider.webUrl': 'https://manifest.example.test',
        'provider.announce': 'Header announcement',
      });
      expect(result.source, SubscriptionDataSource.http);
      expect(result.warnings, contains('Invalid provider field: support-url'));
    });

    test('support keys and upload come from the manifest', () {
      const key = 'ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik';
      const other = 'ed25519:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      final metadata = manifestMetadata({
        'support': {
          'keys': [key, other],
          'upload-url': 'https://support.example.test/upload',
        },
      });
      expect(metadata.supportKeys, [key, other]);
      expect(metadata.supportUploadUrl, 'https://support.example.test/upload');

      final headers = readSubscriptionMetadata({
        'reclash-support-key': [key],
      }, secure: true);
      expect(headers.metadata.supportKeys, isEmpty);
    });

    test('support keys are bounded and well formed', () {
      List<String> keys(List<String> value) => manifestMetadata({
        'support': {'keys': value},
      }).supportKeys;
      const key = 'ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik';
      expect(keys([key, key]), [key]);
      expect(keys([key, key, key]), [key]);
      for (final value in [
        ['ed25519:AA', 'ed25519:AB', 'ed25519:AC'],
        ['rsa:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik'],
        ['ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik='],
        ['ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2iL'],
      ]) {
        expect(keys(value), isEmpty, reason: '$value');
      }
      expect(
        manifestMetadata({
          'support': {'upload-url': 'http://support.example.test/upload'},
        }).supportUploadUrl,
        isNull,
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

        const saved = SubscriptionPreferences(
          headers: {'x-token': 'secret'},
          client: SubscriptionClientSettings(customUserAgent: 'Custom/1'),
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
