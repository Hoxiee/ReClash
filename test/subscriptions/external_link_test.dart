import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';

const _crypt1 =
    'incy://crypt1/AAECAwQFBgcICQoLNyILfyzDr1Fxn34D88TTDqLf-oNELzHPSWrfIN3ASn0soKcNUVYYzdAANve-SW7JDPuJ-GGTPfEfbvjoEyKSsaSQ3JCaY_oxLvPAJlQ1Q3coiTWpUzouWimxoDCBYcDphGTtc6h4CtDKVWhFaTYiPvE';
const _vectorUrl =
    'https://duckvpn.tech/sub/3404b41d-2ed2-4754-95d4-3d7745ff5f2e';

Matcher _issue(UrlSchemeIssue issue) =>
    isA<UrlSchemeException>().having((error) => error.issue, 'issue', issue);

void main() {
  test(
    'decrypts the reference crypt1 vector locally with its name and preset',
    () async {
      final result = await resolveProfileLink(_crypt1);
      expect(result.url, _vectorUrl);
      expect(result.name, 'Test provider');
      expect(result.preset, SubscriptionClientPreset.incy);
      expect(result.bytes, isNull);
      expect(result.shareLink, isNull);
    },
  );

  test('tampered ciphertext is never treated as a subscription URL', () async {
    await expectLater(
      resolveProfileLink(_crypt1.replaceRange(30, 31, 'X')),
      throwsA(_issue(UrlSchemeIssue.authenticationFailed)),
    );
  });

  test(
    'crypt1 accepts trailing path separators without changing the payload',
    () async {
      expect((await resolveProfileLink('$_crypt1/')).url, _vectorUrl);
    },
  );

  test(
    'malformed or unsupported encrypted links fail with typed safe errors',
    () async {
      for (final entry in {
        'incy://crypt1/': UrlSchemeIssue.missingPayload,
        'incy://crypt1/AAAA': UrlSchemeIssue.invalidBase64,
        'incy://crypt2/AAAA': UrlSchemeIssue.unsupportedEncryption,
        'happ://crypt2/AAAA': UrlSchemeIssue.unsupportedEncryption,
        'incy://crypt1/AAAA?trusted=true': UrlSchemeIssue.invalidLink,
      }.entries) {
        await expectLater(
          resolveProfileLink(entry.key),
          throwsA(_issue(entry.value)),
        );
      }
    },
  );

  test(
    'plain URLs are unchanged and contain no implied client preset',
    () async {
      const url = 'https://example.com/a%2Fb?token=a+b&next=%23#label';
      final result = await resolveProfileLink(' $url\n');
      expect(result.url, url);
      expect(result.preset, isNull);
      expect(result.displaySource, 'https://example.com');
    },
  );

  test('fully percent-encoded Happ links are accepted and resolved', () async {
    const encoded = 'happ%3A%2F%2Fadd%2Fhttps%3A%2F%2Fexample.test%2Fsub';
    const url = 'https://example.test/sub';
    expect(isProfileLinkInput(encoded), isTrue);
    final result = await resolveProfileLink(encoded);
    expect(result.url, url);
    expect(result.preset, SubscriptionClientPreset.happ);
  });

  test('raw and encoded wrapper URLs are decoded only once', () async {
    const url = 'https://example.com/a%2Fb?token=a%2Bb&name=source#anchor';
    for (final scheme in ['incy', 'happ']) {
      for (final payload in [url, Uri.encodeComponent(url)]) {
        final result = await resolveProfileLink('$scheme://add/$payload');
        expect(result.url, url);
        expect(
          result.preset,
          scheme == 'incy'
              ? SubscriptionClientPreset.incy
              : SubscriptionClientPreset.happ,
        );
        expect(result.name, isNull);
      }
    }
  });

  test('wrapper names are optional, decoded and validated', () async {
    final result = await resolveProfileLink(
      'happ://add/'
      '${Uri.encodeComponent('https://example.com/sub')}'
      '?name=${Uri.encodeComponent('Дом 🦊 & % +')}',
    );
    expect(result.name, 'Дом 🦊 & % +');
    for (final query in ['name=a&name=b', 'name=%FF', 'trusted=true']) {
      await expectLater(
        resolveProfileLink('happ://add/https%3A%2F%2Fexample.com?$query'),
        throwsA(_issue(UrlSchemeIssue.invalidLink)),
      );
    }
  });

  test('raw and Base64 wrapper configs preserve UTF-8 data', () async {
    const content = 'proxies: []\nrules:\n  - MATCH,DIRECT\n';
    for (final path in [
      Uri.encodeComponent(content),
      base64Url.encode(utf8.encode(content)),
    ]) {
      final result = await resolveProfileLink('incy://import/$path');
      expect(utf8.decode(result.bytes!), content);
      expect(result.url, isNull);
      expect(result.preset, SubscriptionClientPreset.incy);
    }
  });

  test(
    'Base64 wrapper URLs are resolved rather than imported as config',
    () async {
      const url = 'https://example.com/sub?token=a%2Bb';
      final result = await resolveProfileLink(
        'happ://add/${base64Url.encode(utf8.encode(url))}',
      );
      expect(result.url, url);
      expect(result.bytes, isNull);
      expect(result.preset, SubscriptionClientPreset.happ);
    },
  );

  test(
    'wrapped proxy lists stay content rather than one malformed share link',
    () async {
      const content =
          'vless://id@first.test:443#One\nvless://id@second.test:443#Two';
      final result = await resolveProfileLink(
        'incy://import/${Uri.encodeComponent(content)}',
      );
      expect(utf8.decode(result.bytes!), content);
      expect(result.shareLink, isNull);
    },
  );

  test(
    'nested wrappers preserve the inner preset and explicit outer name',
    () async {
      final result = await resolveProfileLink(
        'happ://add/${Uri.encodeComponent(_crypt1)}?name=Home',
      );
      expect(result.url, _vectorUrl);
      expect(result.name, 'Home');
      expect(result.preset, SubscriptionClientPreset.incy);
    },
  );

  test(
    'HTTP share envelopes unwrap query values, text and encoded paths',
    () async {
      for (final input in [
        'https://example.com/share?url=${Uri.encodeComponent(_crypt1)}&text=hello',
        'https://example.com/share?text=${Uri.encodeComponent('Open ($_crypt1)')}',
        'https://example.com/share/${Uri.encodeComponent(_crypt1)}',
      ]) {
        final result = await resolveProfileLink(input);
        expect(result.url, _vectorUrl);
        expect(result.name, 'Test provider');
      }
    },
  );

  test(
    'install-config unwraps HTTP envelopes and retains its explicit name',
    () async {
      final envelope =
          'https://example.com/share?url=${Uri.encodeComponent(_crypt1)}';
      final link = await buildUrlSchemeLink(
        ReClashCommand.installConfig,
        payload: envelope,
        name: 'Home',
      );
      final result = await resolveProfileLink(link);
      expect(result.url, _vectorUrl);
      expect(result.name, 'Home');
      expect(result.preset, SubscriptionClientPreset.incy);
    },
  );

  test(
    'ambiguous embedded links are rejected rather than arbitrarily selected',
    () async {
      final input = Uri.https('example.com', '/share', {
        'url': _crypt1,
        'config': 'happ://add/https%3A%2F%2Fother.test',
      }).toString();
      await expectLater(
        resolveProfileLink(input),
        throwsA(_issue(UrlSchemeIssue.invalidLink)),
      );
    },
  );

  test(
    'all app profile commands preserve their name and payload type',
    () async {
      for (final command in [
        ReClashCommand.add,
        ReClashCommand.installConfig,
        ReClashCommand.importProfile,
      ]) {
        final link = await buildUrlSchemeLink(
          command,
          name: 'Home',
          payload: command == ReClashCommand.importProfile
              ? 'proxies: []'
              : 'https://example.com/sub',
        );
        final result = await resolveProfileLink(link);
        expect(result.name, 'Home');
        if (command == ReClashCommand.importProfile) {
          expect(utf8.decode(result.bytes!), 'proxies: []');
        } else {
          expect(result.url, 'https://example.com/sub');
        }
      }
    },
  );

  test('share-link payloads retain their original case', () async {
    const link = 'vmess://AbCdEfGh+/==';
    final result = await resolveProfileLink(link);
    expect(result.shareLink, link);
    expect(result.url, isNull);
    expect(result.displaySource, 'vmess://');
  });

  test('bounds nested wrappers and decoded config bytes', () async {
    var link = 'https://example.com/sub';
    for (var i = 0; i <= urlSchemeMaxDepth; i++) {
      link = 'incy://add/${Uri.encodeComponent(link)}';
    }
    await expectLater(
      resolveProfileLink(link),
      throwsA(_issue(UrlSchemeIssue.tooDeep)),
    );
    await expectLater(
      resolveProfileLink(
        'incy://import/'
        '${base64Url.encode(List.filled(urlSchemeMaxContentBytes + 1, 97))}',
      ),
      throwsA(_issue(UrlSchemeIssue.tooLarge)),
    );
  });

  test('invalid links never execute or resolve a source', () async {
    for (final input in [
      '',
      'not a link',
      '%',
      '%2',
      '%ZZ',
      'happ%3A%2F%2Fadd%2Fhttps%3A%2F%2Fexample.com%2Fsub%',
      'other://add/data',
      'reclash://connect',
      'happ://add',
      'incy://unknown/data',
      'incy://add/https%ZZ',
    ]) {
      await expectLater(
        resolveProfileLink(input),
        throwsA(isA<UrlSchemeException>()),
      );
    }
  });
}
