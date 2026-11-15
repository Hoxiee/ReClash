import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show HSVColor;
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/branding/color.dart';
import 'package:reclash/subscriptions/branding/resolver.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

final _resolvedAt = DateTime.utc(2026, 11, 15, 12);
const _brandArgb = 0xFF2255AA;
const _tinyMark = 0x10;
const _bigMark = 0x20;
const _lightLogo = 'https://provider.test/logo.svg';
const _darkLogo = 'https://provider.test/logo-dark.svg';
const _svgLogo =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 8 8">'
    '<rect width="8" height="8" fill="#2255aa"/></svg>';

void main() {
  group('profileMonogram', () {
    test('takes the initials of the first two words', () {
      expect(profileMonogram('Nebula VPN'), 'NV');
      expect(profileMonogram('Привет мир'), 'ПМ');
    });

    test('takes the first two letters of a single word', () {
      expect(profileMonogram('nebula'), 'NE');
    });

    test('treats dashes, underscores and dots as word breaks', () {
      for (final name in ['nebula-vpn', 'nebula_vpn', 'nebula.vpn']) {
        expect(profileMonogram(name), 'NV', reason: name);
      }
    });

    test('falls back to a question mark without any letter', () {
      expect(profileMonogram('  '), '?');
    });
  });

  group('monogramHue', () {
    test('keeps a name on the same hue across calls', () {
      expect(monogramHue('Nebula VPN'), 358.0);
      expect(monogramHue('Nebula VPN'), monogramHue('Nebula VPN'));
    });

    test('ignores case and outer spaces', () {
      expect(monogramHue('Foo'), monogramHue(' foo '));
    });

    test('stays within the hue circle', () {
      for (final name in ['', 'a', 'Nebula VPN', 'Привет мир', 'x' * 200]) {
        expect(
          monogramHue(name),
          allOf(greaterThanOrEqualTo(0), lessThan(360)),
          reason: name,
        );
      }
    });

    test('gives different names different hues', () {
      expect(monogramHue('Nebula VPN'), isNot(monogramHue('Aurora VPN')));
    });
  });

  group('ProviderBrand JSON', () {
    test('survives a round trip with both logos and its color', () {
      final brand = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _resolvedAt,
        logo: ProviderLogo(bytes: Uint8List.fromList([1, 2, 3]), svg: true),
        logoDark: ProviderLogo(bytes: Uint8List.fromList([4, 5])),
        color: _brandArgb,
      );
      final restored = ProviderBrand.fromJson(
        jsonDecode(jsonEncode(brand.toJson())),
      )!;
      expect(restored.source, ProviderBrandSource.manifest);
      expect(restored.resolvedAt, _resolvedAt);
      expect(restored.logo?.bytes, [1, 2, 3]);
      expect(restored.logo?.svg, isTrue);
      expect(restored.logoDark?.bytes, [4, 5]);
      expect(restored.logoDark?.svg, isFalse);
      expect(restored.color, _brandArgb);
    });

    test('rejects an unknown source or a missing resolvedAt', () {
      expect(
        ProviderBrand.fromJson({
          'source': 'cloud',
          'resolvedAt': '2026-11-15T12:00:00Z',
        }),
        isNull,
      );
      expect(ProviderBrand.fromJson({'source': 'manifest'}), isNull);
    });

    test('drops an out-of-range color and keeps the brand', () {
      for (final color in [-1, 0x100000000]) {
        final brand = ProviderBrand.fromJson({
          'source': 'site',
          'resolvedAt': '2026-11-15T12:00:00Z',
          'color': color,
        });
        expect(brand, isNotNull, reason: '$color');
        expect(brand!.color, isNull, reason: '$color');
      }
    });

    test('rejects an empty logo and one over the size limit', () {
      expect(ProviderLogo.fromJson({'data': ''}), isNull);
      final oversized = base64.encode(Uint8List(providerLogoLimit + 1));
      expect(ProviderLogo.fromJson({'data': oversized}), isNull);
      final atLimit = base64.encode(Uint8List(providerLogoLimit));
      expect(ProviderLogo.fromJson({'data': atLimit}), isNotNull);
    });

    test('keeps the manifest logo links through a round trip', () {
      final brand = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _resolvedAt,
        manifestLogos: '$_lightLogo\n$_darkLogo',
      );
      final restored = ProviderBrand.fromJson(
        jsonDecode(jsonEncode(brand.toJson())),
      )!;
      expect(restored.manifestLogos, '$_lightLogo\n$_darkLogo');
    });

    test('reads a non-string manifest logo links value as absent', () {
      for (final links in [
        42,
        true,
        [_lightLogo],
      ]) {
        final brand = ProviderBrand.fromJson({
          'source': 'manifest',
          'resolvedAt': '2026-11-15T12:00:00Z',
          'manifestLogos': links,
        });
        expect(brand, isNotNull, reason: '$links');
        expect(brand!.manifestLogos, isNull, reason: '$links');
      }
    });

    test('omits the manifest logo links key when unset', () {
      final json = ProviderBrand(
        source: ProviderBrandSource.site,
        resolvedAt: _resolvedAt,
      ).toJson();
      expect(json.containsKey('manifestLogos'), isFalse);
    });

    test('logoFor falls back to the other logo when one is missing', () {
      final light = ProviderLogo(bytes: Uint8List.fromList([1]));
      final dark = ProviderLogo(bytes: Uint8List.fromList([2]));
      final lightOnly = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _resolvedAt,
        logo: light,
      );
      expect(lightOnly.logoFor(dark: true), same(light));
      expect(lightOnly.logoFor(dark: false), same(light));

      final darkOnly = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _resolvedAt,
        logoDark: dark,
      );
      expect(darkOnly.logoFor(dark: false), same(dark));
      expect(darkOnly.logoFor(dark: true), same(dark));

      final both = ProviderBrand(
        source: ProviderBrandSource.manifest,
        resolvedAt: _resolvedAt,
        logo: light,
        logoDark: dark,
      );
      expect(both.logoFor(dark: true), same(dark));
      expect(both.logoFor(dark: false), same(light));
    });
  });

  group('manifestLogoLinks', () {
    test('is null without a logo link', () {
      expect(manifestLogoLinks(const SubscriptionMetadata()), isNull);
    });

    test('names only the light logo when no dark one is declared', () {
      expect(
        manifestLogoLinks(
          const SubscriptionMetadata({'provider.logo': _lightLogo}),
        ),
        '$_lightLogo\n',
      );
    });

    test('names only the dark logo when no light one is declared', () {
      expect(
        manifestLogoLinks(
          const SubscriptionMetadata({'provider.logoDark': _darkLogo}),
        ),
        '\n$_darkLogo',
      );
    });

    test('changes when either logo link changes', () {
      final both = manifestLogoLinks(
        const SubscriptionMetadata({
          'provider.logo': _lightLogo,
          'provider.logoDark': _darkLogo,
        }),
      );
      final otherLight = manifestLogoLinks(
        const SubscriptionMetadata({
          'provider.logo': 'https://provider.test/other.svg',
          'provider.logoDark': _darkLogo,
        }),
      );
      final otherDark = manifestLogoLinks(
        const SubscriptionMetadata({
          'provider.logo': _lightLogo,
          'provider.logoDark': 'https://provider.test/other-dark.svg',
        }),
      );
      expect(both, '$_lightLogo\n$_darkLogo');
      expect(otherLight, isNot(both));
      expect(otherDark, isNot(both));
    });
  });

  group('dominant color', () {
    test('a mostly red buffer with gray pixels reads as red', () {
      final color = dominantPixelColor(
        _rgba([(0xFFDC1E1E, 80), (0xFF808080, 20)]),
      );
      expect(color, isNotNull);
      expect(_hueOf(color!), anyOf(lessThan(10), greaterThan(350)));
    });

    test('gray, black and white buffers have no dominant color', () {
      expect(
        dominantPixelColor(
          _rgba([(0xFF808080, 50), (0xFF000000, 30), (0xFFFFFFFF, 20)]),
        ),
        isNull,
      );
    });

    test('a hue on under 4% of opaque pixels is not a brand color', () {
      expect(
        dominantPixelColor(_rgba([(0xFFDC1E1E, 3), (0xFF808080, 97)])),
        isNull,
      );
    });

    test('the most frequent saturated svg hex wins', () {
      expect(
        dominantSvgColor(
          '<svg><rect fill="#ff0000"/><rect fill="#ff0000"/>'
          '<rect fill="#1e88e5"/><rect fill="#1e88e5"/>'
          '<rect fill="#1e88e5"/></svg>',
        ),
        0xFF1E88E5,
      );
    });

    test('svg grays, black and white are ignored', () {
      expect(
        dominantSvgColor(
          '<svg fill="#fff" stroke="#000"><rect fill="#808080"/>'
          '<rect fill="#fff"/><rect fill="#000"/><rect fill="#fff"/>'
          '<rect fill="#3f51b5"/></svg>',
        ),
        0xFF3F51B5,
      );
    });

    test('shorthand svg hex expands to the full color', () {
      expect(dominantSvgColor('<svg><circle fill="#f00"/></svg>'), 0xFFFF0000);
    });

    test('an svg without a saturated hex has no dominant color', () {
      expect(
        dominantSvgColor('<svg fill="#fff"><path fill="#333"/></svg>'),
        isNull,
      );
      expect(dominantSvgColor('<svg></svg>'), isNull);
    });
  });

  group('site and Telegram links', () {
    test('sameProviderSite accepts the host, www and subdomains', () {
      expect(
        sameProviderSite(
          Uri.parse('https://provider.test/i.png'),
          'provider.test',
        ),
        isTrue,
      );
      expect(
        sameProviderSite(
          Uri.parse('https://www.provider.test/i.png'),
          'provider.test',
        ),
        isTrue,
      );
      expect(
        sameProviderSite(
          Uri.parse('https://cdn.provider.test/i.png'),
          'provider.test',
        ),
        isTrue,
      );
    });

    test('sameProviderSite rejects foreign hosts and lookalike suffixes', () {
      for (final host in [
        'evil.test',
        'provider.test.evil.test',
        'notprovider.test',
      ]) {
        expect(
          sameProviderSite(Uri.parse('https://$host/i.png'), 'provider.test'),
          isFalse,
          reason: host,
        );
      }
    });

    test('t.me and tg resolve links map to the public t.me page', () {
      final page = Uri.parse('https://t.me/nebula_support');
      expect(
        telegramPreviewPage(Uri.parse('https://t.me/nebula_support')),
        page,
      );
      expect(
        telegramPreviewPage(Uri.parse('tg://resolve?domain=nebula_support')),
        page,
      );
    });

    test('og:image from Telegram hosts is accepted', () {
      for (final url in [
        'https://t.me/i/userpic/320/nebula.jpg',
        'https://cdn4.telesco.pe/file/avatar.jpg',
        'https://cdn5.cdn-telegram.org/file/avatar.jpg',
      ]) {
        expect(
          telegramPreviewImage(_ogImage(url)),
          Uri.parse(url),
          reason: url,
        );
      }
    });

    test('og:image from other hosts, plain http or the t_logo is rejected', () {
      for (final url in [
        'https://evil.test/avatar.jpg',
        'http://cdn4.telesco.pe/file/avatar.jpg',
        'https://t.me/img/t_logo.png',
      ]) {
        expect(telegramPreviewImage(_ogImage(url)), isNull, reason: url);
      }
      expect(telegramPreviewImage('<html></html>'), isNull);
    });

    test('site icons resolve against the page and touch icons come first', () {
      final candidates = siteIconCandidates(
        '<link rel="icon" href="/favicon-192.png" sizes="192x192">'
        '<link rel="apple-touch-icon" href="touch/apple.png">'
        '<link rel="icon" href="/favicon-16.png" sizes="16x16">',
        Uri.parse('https://provider.test/app/index.html'),
      );
      expect(candidates, [
        Uri.parse('https://provider.test/app/touch/apple.png'),
        Uri.parse('https://provider.test/favicon-192.png'),
      ]);
    });
  });

  group('ProviderBrandResolver', () {
    test('a manifest logo wins and the provider site is never asked', () async {
      const logo = 'https://provider.test/logo.svg';
      final transport = _FakeTransport([
        _reply(logo, utf8.encode(_svgLogo), type: 'image/svg+xml'),
      ]);
      final brand = await _resolve(
        transport,
        fields: {
          'provider.logo': logo,
          'provider.webUrl': 'https://provider.test/home',
        },
      );
      expect(brand.source, ProviderBrandSource.manifest);
      expect(brand.logo?.svg, isTrue);
      expect(brand.color, _brandArgb);
      expect(brand.resolvedAt, _resolvedAt);
      expect(transport.requested, [Uri.parse(logo)]);
    });

    test(
      'a page apple touch icon supplies the logo without a manifest',
      () async {
        final transport = _FakeTransport([
          _reply(
            'https://provider.test/home',
            utf8.encode('<link rel="apple-touch-icon" href="/touch.png">'),
            type: 'text/html; charset=utf-8',
          ),
          _reply('https://provider.test/touch.png', _png(_bigMark)),
        ]);
        final brand = await _resolve(
          transport,
          fields: {'provider.webUrl': 'https://provider.test/home'},
        );
        expect(brand.source, ProviderBrandSource.site);
        expect(brand.logo?.bytes, _png(_bigMark));
        expect(brand.logo?.svg, isFalse);
        expect(brand.color, _brandArgb);
      },
    );

    test('the subscription page logo wins over the site icons', () async {
      const logo = 'https://provider.test/logo.png';
      final transport = _FakeTransport([
        _reply(
          'https://provider.test/sub/token',
          utf8.encode(_ogImage(logo)),
          type: 'text/html; charset=utf-8',
        ),
        _reply(logo, _png(_bigMark)),
      ]);
      final brand = await _resolve(
        transport,
        fields: {'provider.webUrl': 'https://provider.test/home'},
        readSize: _smallIcon,
      );
      expect(brand.source, ProviderBrandSource.site);
      expect(brand.logo?.bytes, _png(_bigMark));
      expect(brand.logo?.svg, isFalse);
      expect(brand.color, _brandArgb);
      expect(transport.requested, [
        Uri.parse('https://provider.test/sub/token'),
        Uri.parse(logo),
      ]);
    });

    test(
      'a non-HTML subscription reply falls back to the site icons',
      () async {
        final transport = _FakeTransport([
          _reply(
            'https://provider.test/sub/token',
            utf8.encode('vless://nebula@provider.test:443#Nebula'),
            type: 'text/plain',
          ),
          _reply('https://provider.test/apple-touch-icon.png', _png(_bigMark)),
        ]);
        final brand = await _resolve(
          transport,
          fields: {'provider.webUrl': 'https://provider.test/home'},
        );
        expect(brand.source, ProviderBrandSource.site);
        expect(brand.logo?.bytes, _png(_bigMark));
        expect(transport.requested, [
          Uri.parse('https://provider.test/sub/token'),
          Uri.parse('https://provider.test/home'),
          Uri.parse('https://provider.test/apple-touch-icon.png'),
        ]);
      },
    );

    test(
      'a subscription page logo the size reader rejects is skipped',
      () async {
        const logo = 'https://provider.test/logo.png';
        final transport = _FakeTransport([
          _reply(
            'https://provider.test/sub/token',
            utf8.encode(_ogImage(logo)),
            type: 'text/html',
          ),
          _reply(logo, _png(_bigMark)),
        ]);
        final brand = await _resolve(transport, readSize: _undecodable);
        expect(brand.source, ProviderBrandSource.monogram);
        expect(brand.logo, isNull);
        expect(transport.requested, contains(Uri.parse(logo)));
      },
    );

    test('an icon measured below the minimum size is skipped', () async {
      final transport = _FakeTransport([
        _reply(
          'https://provider.test/home',
          utf8.encode(
            '<link rel="apple-touch-icon" href="/tiny.png">'
            '<link rel="icon" href="/favicon.png" sizes="16x16">',
          ),
          type: 'text/html',
        ),
        _reply('https://provider.test/tiny.png', _png(_tinyMark)),
        _reply('https://provider.test/apple-touch-icon.png', _png(_bigMark)),
      ]);
      final brand = await _resolve(
        transport,
        fields: {'provider.webUrl': 'https://provider.test/home'},
      );
      expect(brand.source, ProviderBrandSource.site);
      expect(brand.logo?.bytes, _png(_bigMark));
      expect(
        transport.requested,
        isNot(contains(Uri.parse('https://provider.test/favicon.png'))),
      );
    });

    test(
      'a Telegram support account supplies the logo when the site has none',
      () async {
        final transport = _FakeTransport([
          _reply(
            'https://t.me/nebula_support',
            utf8.encode(_ogImage('https://cdn4.telesco.pe/file/avatar.jpg')),
            type: 'text/html',
          ),
          _reply('https://cdn4.telesco.pe/file/avatar.jpg', _png(_bigMark)),
        ]);
        final brand = await _resolve(
          transport,
          fields: {'provider.supportUrl': 'https://t.me/nebula_support'},
        );
        expect(brand.source, ProviderBrandSource.telegram);
        expect(brand.logo?.bytes, _png(_bigMark));
      },
    );

    test('with no logo anywhere the monogram takes the name color', () async {
      final brand = await _resolve(_FakeTransport(const []));
      expect(brand.source, ProviderBrandSource.monogram);
      expect(brand.logo, isNull);
      expect(brand.logoDark, isNull);
      expect(brand.color, isNotNull);
      expect(brand.color, monogramColor(monogramHue('Nebula VPN')));
    });

    test('a manifest brand keeps the manifest logo links', () async {
      final fields = <String, Object?>{
        'provider.logo': _lightLogo,
        'provider.logoDark': _darkLogo,
      };
      final transport = _FakeTransport([
        _reply(_lightLogo, utf8.encode(_svgLogo), type: 'image/svg+xml'),
        _reply(_darkLogo, _png(_bigMark)),
      ]);
      final brand = await _resolve(transport, fields: fields);
      expect(brand.source, ProviderBrandSource.manifest);
      expect(
        brand.manifestLogos,
        manifestLogoLinks(SubscriptionMetadata(fields)),
      );
    });

    test('a site brand has no manifest logo links', () async {
      final transport = _FakeTransport([
        _reply(
          'https://provider.test/home',
          utf8.encode('<link rel="apple-touch-icon" href="/touch.png">'),
          type: 'text/html; charset=utf-8',
        ),
        _reply('https://provider.test/touch.png', _png(_bigMark)),
      ]);
      final brand = await _resolve(
        transport,
        fields: {
          'provider.logo': 'https://provider.test/missing.svg',
          'provider.webUrl': 'https://provider.test/home',
        },
      );
      expect(brand.source, ProviderBrandSource.site);
      expect(brand.manifestLogos, isNull);
    });

    test('a monogram has no manifest logo links', () async {
      final brand = await _resolve(
        _FakeTransport(const []),
        fields: {'provider.logo': 'https://provider.test/missing.svg'},
      );
      expect(brand.source, ProviderBrandSource.monogram);
      expect(brand.manifestLogos, isNull);
    });

    test('every request stays on the provider, Telegram or its CDN', () async {
      final transport = _FakeTransport([
        _reply(
          'https://provider.test/home',
          utf8.encode(
            '<link rel="icon" href="https://tracker.test/icon.png" '
            'sizes="192x192">',
          ),
          type: 'text/html',
        ),
        _reply(
          'https://t.me/nebula_support',
          utf8.encode(_ogImage('https://cdn4.telesco.pe/file/avatar.jpg')),
          type: 'text/html',
        ),
        _reply('https://cdn4.telesco.pe/file/avatar.jpg', _png(_bigMark)),
      ]);
      final brand = await _resolve(
        transport,
        fields: {
          'provider.webUrl': 'https://provider.test/home',
          'provider.supportUrl': 'https://t.me/nebula_support',
        },
      );
      expect(brand.source, ProviderBrandSource.telegram);
      expect(
        transport.requested.map((uri) => uri.host),
        everyElement(isIn({'provider.test', 't.me', 'cdn4.telesco.pe'})),
      );
    });

    test('a plain http logo URL is never fetched', () async {
      const logo = 'http://provider.test/logo.png';
      final transport = _FakeTransport([_reply(logo, _png(_bigMark))]);
      final brand = await _resolve(transport, fields: {'provider.logo': logo});
      expect(brand.source, ProviderBrandSource.monogram);
      expect(
        transport.requested.where((uri) => uri.scheme != 'https'),
        isEmpty,
      );
    });

    test('a cancelled resolve throws before sending any request', () async {
      final transport = _FakeTransport(const []);
      final cancellation = SubscriptionCancellation()..cancel();
      await expectLater(
        _resolve(
          transport,
          fields: {'provider.logo': 'https://provider.test/logo.png'},
          cancellation: cancellation,
        ),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.failure,
            'failure',
            SubscriptionFailure.cancelled,
          ),
        ),
      );
      expect(transport.requested, isEmpty);
    });
  });

  group('ProviderBrandResolver.resolveManifest', () {
    test('returns a manifest brand and requests only the logo links', () async {
      const light = 'https://provider.test/logo.png';
      const dark = 'https://provider.test/logo-dark.png';
      final fields = <String, Object?>{
        'provider.logo': light,
        'provider.logoDark': dark,
        'provider.webUrl': 'https://provider.test/home',
        'provider.supportUrl': 'https://t.me/nebula_support',
      };
      final transport = _FakeTransport([
        _reply(light, _png(_bigMark)),
        _reply(dark, _png(_bigMark)),
      ]);
      final brand = await _resolveManifest(transport, fields: fields);
      expect(brand, isNotNull);
      expect(brand!.source, ProviderBrandSource.manifest);
      expect(brand.logo?.bytes, _png(_bigMark));
      expect(brand.logoDark?.bytes, _png(_bigMark));
      expect(
        brand.manifestLogos,
        manifestLogoLinks(SubscriptionMetadata(fields)),
      );
      expect(
        transport.requested,
        unorderedEquals([Uri.parse(light), Uri.parse(dark)]),
      );
    });

    test('returns null when the manifest logo does not load', () async {
      const logo = 'https://provider.test/logo.png';
      final transport = _FakeTransport(const []);
      final brand = await _resolveManifest(
        transport,
        fields: {
          'provider.logo': logo,
          'provider.webUrl': 'https://provider.test/home',
          'provider.supportUrl': 'https://t.me/nebula_support',
        },
      );
      expect(brand, isNull);
      expect(transport.requested, [Uri.parse(logo)]);
    });

    test('returns null without any request when no logo is declared', () async {
      final transport = _FakeTransport(const []);
      final brand = await _resolveManifest(
        transport,
        fields: {
          'provider.webUrl': 'https://provider.test/home',
          'provider.supportUrl': 'https://t.me/nebula_support',
        },
      );
      expect(brand, isNull);
      expect(transport.requested, isEmpty);
    });
  });
}

double _hueOf(int argb) => HSVColor.fromColor(Color(argb)).hue;

Uint8List _rgba(List<(int argb, int count)> runs) => Uint8List.fromList([
  for (final (argb, count) in runs)
    for (var i = 0; i < count; i++) ...[
      argb >> 16 & 0xFF,
      argb >> 8 & 0xFF,
      argb & 0xFF,
      argb >> 24 & 0xFF,
    ],
]);

String _ogImage(String url) =>
    '<html><head><meta property="og:image" content="$url"></head></html>';

List<int> _png(int mark) => [0x89, 0x50, 0x4e, 0x47, mark];

SubscriptionResponse _reply(
  String url,
  List<int> bytes, {
  String type = 'image/png',
}) => SubscriptionResponse(
  bytes: Uint8List.fromList(bytes),
  headers: {
    'content-type': [type],
  },
  status: 200,
  uri: Uri.parse(url),
);

Future<int?> _readColor(Uint8List bytes, {required bool svg}) async =>
    _brandArgb;

Future<({int width, int height})?> _readSize(Uint8List bytes) async =>
    bytes.last == _tinyMark
    ? (width: 16, height: 16)
    : (width: 180, height: 180);

Future<({int width, int height})?> _smallIcon(Uint8List bytes) async =>
    (width: 32, height: 32);

Future<({int width, int height})?> _undecodable(Uint8List bytes) async => null;

Future<ProviderBrand> _resolve(
  _FakeTransport transport, {
  Map<String, Object?> fields = const {},
  SubscriptionCancellation? cancellation,
  ImageSizeReader? readSize,
}) =>
    ProviderBrandResolver(
      transport: transport,
      readColor: _readColor,
      readSize: readSize ?? _readSize,
      clock: () => _resolvedAt,
    ).resolve(
      name: 'Nebula VPN',
      subscriptionUrl: 'https://provider.test/sub/token',
      metadata: SubscriptionMetadata(fields),
      cancellation: cancellation,
    );

Future<ProviderBrand?> _resolveManifest(
  _FakeTransport transport, {
  Map<String, Object?> fields = const {},
}) => ProviderBrandResolver(
  transport: transport,
  readColor: _readColor,
  readSize: _readSize,
  clock: () => _resolvedAt,
).resolveManifest(SubscriptionMetadata(fields));

class _FakeTransport implements SubscriptionTransport {
  _FakeTransport(Iterable<SubscriptionResponse> replies)
    : _replies = {for (final reply in replies) reply.uri: reply};

  final Map<Uri, SubscriptionResponse> _replies;
  final List<Uri> requested = [];

  @override
  ProtectedSubscriptionFetcher? get protectedFetcher => null;

  @override
  bool Function()? get canUseProtected => null;

  @override
  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => _answer(source);

  @override
  Future<SubscriptionResponse> fetchCapped(
    Uri source, {
    required int limit,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async => _answer(source);

  SubscriptionResponse _answer(Uri source) {
    requested.add(source);
    final reply = _replies[source];
    if (reply == null) {
      throw const SubscriptionException(SubscriptionFailure.http, status: 404);
    }
    return reply;
  }
}
