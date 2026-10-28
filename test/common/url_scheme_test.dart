import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/protocol.dart';
import 'package:reclash/common/url_scheme.dart';

Matcher _issue(UrlSchemeIssue issue) =>
    isA<UrlSchemeException>().having((error) => error.issue, 'issue', issue);

void main() {
  group('parseUrlSchemeLink', () {
    test('parses every application command without parameters', () {
      for (final command in ReClashCommand.values.where(
        (c) => !c.isProfile && c != ReClashCommand.routing,
      )) {
        for (final suffix in ['', '/']) {
          final result = parseUrlSchemeLink(
            'reclash://${command.host}$suffix',
          )!;
          expect(result.command, command);
          expect(result.payload, isNull);
          expect(result.name, isNull);
        }
      }
    });

    test('keeps Clash schemes limited to install-config', () {
      for (final scheme in configProtocolSchemes) {
        final result = parseUrlSchemeLink(
          '$scheme://install-config?url=https%3A%2F%2Fexample.com%2Fsub&name=Home',
        )!;
        expect(result.command, ReClashCommand.installConfig);
        expect(result.payload, 'https://example.com/sub');
        expect(result.name, 'Home');
      }
      for (final scheme in ['clash', 'clashmeta']) {
        expect(
          () => parseUrlSchemeLink('$scheme://connect'),
          throwsA(_issue(UrlSchemeIssue.unknownCommand)),
        );
      }
    });

    test('unrelated schemes do not become application commands', () {
      for (final link in [
        'https://example.com/sub',
        'vmess://AbCdEf',
        'other://open',
      ]) {
        expect(parseUrlSchemeLink(link), isNull);
      }
    });

    test('reads query and path payloads exactly once', () {
      const url =
          'https://user:secret@example.com/a%2Fb?token=a%2Bb&next=%23#part';
      final encoded = Uri.encodeComponent(url);
      for (final input in [
        'reclash://add?url=$encoded',
        'reclash://add/$encoded',
        'reclash://add/$url',
      ]) {
        expect(parseUrlSchemeLink(input)!.payload, url);
      }
    });

    test('profile names support Unicode and reserved URL characters', () {
      const name = 'Дом 🦊 & 工作 # % +';
      final link = Uri(
        scheme: 'reclash',
        host: 'add',
        queryParameters: {'url': 'https://example.com/sub', 'name': name},
      ).toString();
      expect(parseUrlSchemeLink(link)!.name, name);
    });

    test('rejects unknown commands and authority modifiers', () {
      expect(
        () => parseUrlSchemeLink('reclash://launch'),
        throwsA(_issue(UrlSchemeIssue.unknownCommand)),
      );
      for (final link in ['reclash://user@connect', 'reclash://connect:443']) {
        expect(
          () => parseUrlSchemeLink(link),
          throwsA(_issue(UrlSchemeIssue.invalidLink)),
        );
      }
    });

    test('rejects arguments on action commands and ambiguous profile inputs', () {
      for (final link in [
        'reclash://connect?confirm=false',
        'reclash://close#trusted',
        'reclash://open/extra',
        'reclash://add?url=https%3A%2F%2Fexample.com&url=https%3A%2F%2Fother.com',
        'reclash://add?url=https%3A%2F%2Fexample.com&name=a&name=b',
        'reclash://add?url=https%3A%2F%2Fexample.com&trusted=true',
        'reclash://add/https%3A%2F%2Fexample.com?url=https%3A%2F%2Fother.com',
        'reclash://install-config/https%3A%2F%2Fexample.com',
        'reclash://import?data=YQ%3D%3D#part',
      ]) {
        expect(
          () => parseUrlSchemeLink(link),
          throwsA(_issue(UrlSchemeIssue.invalidLink)),
          reason: link,
        );
      }
    });

    test('reports missing payloads', () {
      for (final link in [
        'reclash://add',
        'reclash://add?url=',
        'reclash://import?data=%20',
        'reclash://install-config/',
      ]) {
        expect(
          () => parseUrlSchemeLink(link),
          throwsA(_issue(UrlSchemeIssue.missingPayload)),
        );
      }
    });

    test('rejects malformed percent encoding and invalid UTF-8 parameters', () {
      for (final input in [
        'reclash://add?url=%',
        'reclash://add?url=%ZZ',
        'reclash://add?url=%FF',
        'reclash://import/%FF',
        'reclash://add?url=https%3A%2F%2Fexample.com&name=%C0%AF',
      ]) {
        expect(
          () => parseUrlSchemeLink(input),
          throwsA(_issue(UrlSchemeIssue.invalidLink)),
        );
      }
    });

    test('limits names by Unicode scalars and rejects controls', () {
      expect(
        checkedLinkName('🦊' * urlSchemeMaxNameLength),
        '🦊' * urlSchemeMaxNameLength,
      );
      expect(checkedLinkName('  Home  '), 'Home');
      expect(checkedLinkName('  '), isNull);
      for (final input in [
        'a' * (urlSchemeMaxNameLength + 1),
        'a\u0000b',
        'a\nb',
      ]) {
        expect(
          () => checkedLinkName(input),
          throwsA(_issue(UrlSchemeIssue.invalidName)),
        );
      }
    });

    test('rejects non-HTTP sources and malformed subscription URLs', () {
      for (final url in [
        'file:///etc/config',
        'ftp://example.com/sub',
        'https://',
        'relative/path',
        'https://example.com/a b',
      ]) {
        expect(isSubscriptionUrl(url), isFalse);
        expect(
          () => parseUrlSchemeLink(
            'reclash://add?url=${Uri.encodeComponent(url)}',
          ),
          throwsA(_issue(UrlSchemeIssue.invalidUrl)),
        );
      }
    });

    test('enforces the original input bound before trimming', () {
      expect(
        () => parseUrlSchemeLink(' ' * urlSchemeMaxLength + 'reclash://open'),
        throwsA(_issue(UrlSchemeIssue.tooLarge)),
      );
      expect(
        isProfileLinkInput('reclash://import/${'a' * urlSchemeMaxLength}'),
        isFalse,
      );
    });
  });

  group('routing links', () {
    test('carry a payload or an https url only under reclash', () {
      final inline = parseUrlSchemeLink('reclash://routing?p=abc_-')!;
      expect(inline.command, ReClashCommand.routing);
      expect(inline.payload, 'abc_-');
      expect(inline.command.isProfile, isFalse);
      expect(inline.command.changesConnection, isFalse);
      final remote = parseUrlSchemeLink(
        'reclash://routing?url=${Uri.encodeComponent('https://example.com/r.yaml')}',
      )!;
      expect(remote.payload, 'https://example.com/r.yaml');
      expect(
        () => parseUrlSchemeLink('clash://routing?p=abc'),
        throwsA(_issue(UrlSchemeIssue.unknownCommand)),
      );
    });

    test('reject malformed shapes', () {
      final cases = {
        'reclash://routing': UrlSchemeIssue.invalidLink,
        'reclash://routing?p=a&url=https%3A%2F%2Fa.com':
            UrlSchemeIssue.invalidLink,
        'reclash://routing?p=a&p=b': UrlSchemeIssue.invalidLink,
        'reclash://routing?x=a': UrlSchemeIssue.invalidLink,
        'reclash://routing/extra?p=a': UrlSchemeIssue.invalidLink,
        'reclash://routing?p=a#f': UrlSchemeIssue.invalidLink,
        'reclash://routing?p=': UrlSchemeIssue.missingPayload,
        'reclash://routing?url=http%3A%2F%2Fa.com%2Fr':
            UrlSchemeIssue.invalidUrl,
        'reclash://routing?url=ftp%3A%2F%2Fa.com': UrlSchemeIssue.invalidUrl,
        'reclash://routing?p=${'a' * urlSchemeMaxRoutingPayloadLength}a':
            UrlSchemeIssue.tooLarge,
      };
      for (final MapEntry(:key, :value) in cases.entries) {
        expect(
          () => parseUrlSchemeLink(key),
          throwsA(_issue(value)),
          reason: key,
        );
      }
    });

    test('are built and parsed back', () async {
      final inline = await buildUrlSchemeLink(
        ReClashCommand.routing,
        payload: 'abc',
      );
      expect(inline, 'reclash://routing?p=abc');
      final remote = await buildUrlSchemeLink(
        ReClashCommand.routing,
        payload: 'https://example.com/r.yaml',
      );
      expect(
        (await readUrlSchemeLink(remote))!.payload,
        'https://example.com/r.yaml',
      );
    });
  });

  group('buildUrlSchemeLink', () {
    test('every command round-trips through the same parser', () async {
      const url = 'https://example.com/a%2Fb?token=a+b&part=%23#anchor';
      const config = 'proxies: []\nproxy-groups: []\nrules: [MATCH,DIRECT]\n';
      const name = 'Home 🦊 & 工作 # % +';
      for (final command in ReClashCommand.values.where(
        (c) => c != ReClashCommand.routing,
      )) {
        final link = await buildUrlSchemeLink(
          command,
          payload: command.isProfile
              ? command == ReClashCommand.importProfile
                    ? config
                    : url
              : '',
          name: command.isProfile ? name : '',
        );
        final parsed = (await readUrlSchemeLink(link))!;
        expect(parsed.command, command);
        expect(parsed.name, command.isProfile ? name : isNull);
        if (command == ReClashCommand.importProfile) {
          expect(
            utf8.decode(await decodeUrlSchemeConfig(parsed.payload!)),
            config,
          );
        } else {
          expect(parsed.payload, command.isProfile ? url : isNull);
        }
      }
    });

    test('omits optional names and all arguments on action commands', () async {
      final action = await buildUrlSchemeLink(ReClashCommand.toggle);
      expect(action, 'reclash://toggle');
      final link = await buildUrlSchemeLink(
        ReClashCommand.add,
        payload: 'https://example.com/sub',
        name: '  ',
      );
      expect(Uri.parse(link).queryParameters.containsKey('name'), isFalse);
    });

    test(
      'validates required payload and refuses irrelevant arguments',
      () async {
        for (final command in ReClashCommand.values.where((c) => c.isProfile)) {
          await expectLater(
            buildUrlSchemeLink(command),
            throwsA(_issue(UrlSchemeIssue.missingPayload)),
          );
        }
        await expectLater(
          buildUrlSchemeLink(ReClashCommand.connect, name: 'Home'),
          throwsA(_issue(UrlSchemeIssue.invalidLink)),
        );
        await expectLater(
          buildUrlSchemeLink(ReClashCommand.close, payload: 'true'),
          throwsA(_issue(UrlSchemeIssue.invalidLink)),
        );
        await expectLater(
          buildUrlSchemeLink(ReClashCommand.add, payload: 'not a URL'),
          throwsA(_issue(UrlSchemeIssue.invalidUrl)),
        );
      },
    );

    test(
      'applies the config limit to UTF-8 bytes rather than character count',
      () async {
        await expectLater(
          buildUrlSchemeLink(
            ReClashCommand.importProfile,
            payload: 'я' * (urlSchemeMaxContentBytes ~/ 2 + 1),
          ),
          throwsA(_issue(UrlSchemeIssue.tooLarge)),
        );
        final link = await buildUrlSchemeLink(
          ReClashCommand.importProfile,
          payload: 'a' * urlSchemeMaxContentBytes,
        );
        expect(link.length, lessThanOrEqualTo(urlSchemeMaxLength));
        expect(
          (await decodeUrlSchemeConfig(
            parseUrlSchemeLink(link)!.payload!,
          )).length,
          urlSchemeMaxContentBytes,
        );
      },
    );
  });

  group('decodeUrlSchemeConfig', () {
    test(
      'accepts standard and URL-safe Base64 with optional padding',
      () async {
        const content = '配置 🦊\nproxies: []';
        final bytes = utf8.encode(content);
        for (final payload in [
          base64.encode(bytes),
          base64Url.encode(bytes),
          base64Url.encode(bytes).replaceAll('=', ''),
        ]) {
          expect(utf8.decode(await decodeUrlSchemeConfig(payload)), content);
        }
      },
    );

    test('rejects invalid Base64 and non-UTF-8 decoded bytes', () async {
      for (final payload in [
        '!',
        'a',
        base64.encode([0xff, 0xfe]),
      ]) {
        await expectLater(
          decodeUrlSchemeConfig(payload),
          throwsA(_issue(UrlSchemeIssue.invalidBase64)),
        );
      }
      await expectLater(
        decodeUrlSchemeConfig(''),
        throwsA(_issue(UrlSchemeIssue.missingPayload)),
      );
    });

    test('rejects decoded configs over the byte limit', () async {
      await expectLater(
        decodeUrlSchemeConfig(
          base64.encode(List.filled(urlSchemeMaxContentBytes + 1, 97)),
        ),
        throwsA(_issue(UrlSchemeIssue.tooLarge)),
      );
    });
  });

  group('isProfileLinkInput', () {
    for (final input in [
      '%',
      '%2',
      'text%ZZ',
      'reclash%3A%2F%2Fadd%2Fhttps%3A%2F%2Fexample.com%2Fsub%',
      '%FF',
    ]) {
      test('rejects malformed percent encoding $input', () {
        expect(isProfileLinkInput(input), isFalse);
      });
    }

    test('still accepts a percent-encoded profile link', () {
      expect(
        isProfileLinkInput(
          Uri.encodeComponent('reclash://add/https://example.com/sub'),
        ),
        isTrue,
      );
    });
  });

  test(
    'profile source display redacts credentials, paths and query tokens',
    () {
      expect(
        profileLinkDisplaySource(
          'https://user:password@example.com:8443/private?token=secret#name',
        ),
        'https://example.com:8443',
      );
      expect(profileLinkDisplaySource('vmess://AbCdEfGh=='), 'vmess://');
      expect(
        const UrlSchemeException(UrlSchemeIssue.invalidBase64).toString(),
        'Invalid external link: invalidBase64',
      );
    },
  );
}
