import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:html/parser.dart' as html;
import 'package:reclash/common/telegram_link.dart';

import '../metadata/metadata.dart';
import '../page_preview.dart';
import '../transport/transport.dart';
import 'brand.dart';
import 'color.dart';

typedef LogoColorReader =
    Future<int?> Function(Uint8List bytes, {required bool svg});

typedef ImageSizeReader =
    Future<({int width, int height})?> Function(Uint8List bytes);

const _pageLimit = 512 * 1024;
const _fetchTimeout = Duration(seconds: 8);

/// Favicons below this are 16 and 32 pixel marks that blur at the pass size.
const minSiteIconExtent = 48;
const _siteIconAttempts = 3;

const _pageHeaders = {
  'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'Accept': 'text/html,application/xhtml+xml',
};

/// Finds a profile's logo without third-party icon services: it asks only the
/// provider's own hosts and Telegram, and falls back to a monogram.
class ProviderBrandResolver {
  ProviderBrandResolver({
    required this.transport,
    LogoColorReader? readColor,
    ImageSizeReader? readSize,
    DateTime Function()? clock,
  }) : _readColor = readColor ?? dominantLogoColor,
       _readSize = readSize ?? encodedImageSize,
       _clock = clock ?? DateTime.now;

  final SubscriptionTransport transport;
  final LogoColorReader _readColor;
  final ImageSizeReader _readSize;
  final DateTime Function() _clock;

  Future<ProviderBrand> resolve({
    required String name,
    required String subscriptionUrl,
    required SubscriptionMetadata metadata,
    SubscriptionCancellation? cancellation,
  }) async {
    final steps = <ProviderBrandSource, Future<_Logos?> Function()>{
      ProviderBrandSource.manifest: () => _manifest(metadata, cancellation),
      ProviderBrandSource.site: () =>
          _site(metadata, subscriptionUrl, cancellation),
      ProviderBrandSource.telegram: () => _telegram(metadata, cancellation),
    };
    for (final MapEntry(key: source, value: step) in steps.entries) {
      final logos = await step();
      _checkCancelled(cancellation);
      if (logos != null) return _brand(source, logos, metadata);
    }
    return ProviderBrand(
      source: ProviderBrandSource.monogram,
      resolvedAt: _clock(),
      color: monogramColor(monogramHue(name)),
    );
  }

  /// Only the manifest's logos; null when it declares none that loads.
  Future<ProviderBrand?> resolveManifest(
    SubscriptionMetadata metadata, {
    SubscriptionCancellation? cancellation,
  }) async {
    final logos = await _manifest(metadata, cancellation);
    _checkCancelled(cancellation);
    return logos == null
        ? null
        : _brand(ProviderBrandSource.manifest, logos, metadata);
  }

  Future<ProviderBrand> _brand(
    ProviderBrandSource source,
    _Logos logos,
    SubscriptionMetadata metadata,
  ) async {
    final primary = logos.light ?? logos.dark!;
    return ProviderBrand(
      source: source,
      resolvedAt: _clock(),
      logo: logos.light,
      logoDark: logos.dark,
      color: await _readColor(primary.bytes, svg: primary.svg),
      manifestLogos: source == ProviderBrandSource.manifest
          ? manifestLogoLinks(metadata)
          : null,
    );
  }

  Future<_Logos?> _manifest(
    SubscriptionMetadata metadata,
    SubscriptionCancellation? cancellation,
  ) async {
    Future<ProviderLogo?> load(String? value) async {
      final uri = value == null ? null : safeSubscriptionLink(value);
      return uri == null ? null : _image(uri, cancellation: cancellation);
    }

    final [light, dark] = await Future.wait([
      load(metadata.logo),
      load(metadata.text('provider.logoDark')),
    ]);
    return light == null && dark == null ? null : _Logos(light, dark);
  }

  Future<_Logos?> _site(
    SubscriptionMetadata metadata,
    String subscriptionUrl,
    SubscriptionCancellation? cancellation,
  ) async {
    final declared = await _subscriptionPage(subscriptionUrl, cancellation);
    if (declared != null) return declared;
    final site = switch (metadata.text('provider.webUrl')) {
      final value? => safeSubscriptionLink(value, httpsOnly: true),
      null => null,
    };
    final source = site ?? Uri.tryParse(subscriptionUrl);
    if (source == null || source.scheme != 'https' || source.host.isEmpty) {
      return null;
    }
    final page =
        site ?? Uri(scheme: 'https', host: source.host, port: source.port);
    final candidates = <Uri>[];
    final body = await _page(page, cancellation);
    if (body != null) {
      candidates.addAll(
        await Isolate.run(() => siteIconCandidates(body.html, body.uri)),
      );
    }
    candidates.add(page.resolve('/apple-touch-icon.png'));
    final tried = <String>{};
    for (final candidate in candidates) {
      if (tried.length == _siteIconAttempts) break;
      if (!sameProviderSite(candidate, page.host) ||
          !tried.add(candidate.toString())) {
        continue;
      }
      final logo = await _image(
        candidate,
        cancellation: cancellation,
        minExtent: minSiteIconExtent,
      );
      if (logo != null) return _Logos(logo, null);
    }
    return null;
  }

  /// The logo the subscription page itself declares, read the way the add
  /// dialog previews it: `og:image`, its icon links, or a panel's branding.
  Future<_Logos?> _subscriptionPage(
    String subscriptionUrl,
    SubscriptionCancellation? cancellation,
  ) async {
    if (Uri.tryParse(subscriptionUrl)?.scheme != 'https') return null;
    try {
      final preview = await previewSubscriptionPage(
        subscriptionUrl,
        transport: transport,
        cancellation: cancellation,
      );
      final bytes = preview.logoBytes;
      if (bytes == null || bytes.length > providerLogoLimit) return null;
      final svg = _looksLikeSvg(bytes);
      if (preview.logoIsSvg && !svg) return null;
      if (!svg && await _readSize(bytes) == null) return null;
      return _Logos(ProviderLogo(bytes: bytes, svg: svg), null);
    } on Object {
      _checkCancelled(cancellation);
      return null;
    }
  }

  Future<_Logos?> _telegram(
    SubscriptionMetadata metadata,
    SubscriptionCancellation? cancellation,
  ) async {
    final link = switch (metadata.text('provider.supportUrl')) {
      final value? => TelegramLink.tryParse(value),
      null => null,
    };
    final page = link == null ? null : telegramPreviewPage(link.uri);
    if (page == null) return null;
    final body = await _page(page, cancellation);
    if (body == null) return null;
    final image = await Isolate.run(() => telegramPreviewImage(body.html));
    if (image == null) return null;
    final logo = await _image(
      image,
      cancellation: cancellation,
      minExtent: minSiteIconExtent,
    );
    return logo == null ? null : _Logos(logo, null);
  }

  Future<({String html, Uri uri})?> _page(
    Uri uri,
    SubscriptionCancellation? cancellation,
  ) async {
    final response = await _fetch(uri, _pageHeaders, _pageLimit, cancellation);
    if (response == null) return null;
    final type = _contentType(response);
    if (type != 'text/html' && type != 'application/xhtml+xml') return null;
    return (
      html: utf8.decode(response.bytes, allowMalformed: true),
      uri: response.uri,
    );
  }

  Future<ProviderLogo?> _image(
    Uri uri, {
    SubscriptionCancellation? cancellation,
    int minExtent = 1,
  }) async {
    if (uri.scheme != 'https') return null;
    final response = await _fetch(
      uri,
      const {'Accept': 'image/*'},
      providerLogoLimit,
      cancellation,
    );
    if (response == null ||
        response.bytes.isEmpty ||
        response.uri.scheme != 'https') {
      return null;
    }
    final bytes = response.bytes;
    if (_contentType(response) == 'image/svg+xml' || _looksLikeSvg(bytes)) {
      return _looksLikeSvg(bytes)
          ? ProviderLogo(bytes: bytes, svg: true)
          : null;
    }
    final size = await _readSize(bytes);
    if (size == null || size.width < minExtent || size.height < minExtent) {
      return null;
    }
    return ProviderLogo(bytes: bytes);
  }

  Future<SubscriptionResponse?> _fetch(
    Uri uri,
    Map<String, String> headers,
    int limit,
    SubscriptionCancellation? cancellation,
  ) async {
    _checkCancelled(cancellation);
    try {
      return await transport.fetchCapped(
        uri,
        limit: limit,
        headers: headers,
        timeout: _fetchTimeout,
        cancellation: cancellation,
      );
    } on Object {
      _checkCancelled(cancellation);
      return null;
    }
  }
}

class _Logos {
  const _Logos(this.light, this.dark);

  final ProviderLogo? light;
  final ProviderLogo? dark;
}

void _checkCancelled(SubscriptionCancellation? cancellation) {
  if (cancellation?.cancelled ?? false) {
    throw const SubscriptionException(SubscriptionFailure.cancelled);
  }
}

String? _contentType(SubscriptionResponse response) => response
    .headers['content-type']
    ?.firstOrNull
    ?.split(';')
    .first
    .trim()
    .toLowerCase();

bool _looksLikeSvg(Uint8List bytes) {
  final head = utf8
      .decode(bytes.take(1024).toList(), allowMalformed: true)
      .trimLeft()
      .toLowerCase();
  return head.startsWith('<svg') ||
      (head.startsWith('<?xml') || head.startsWith('<!--')) &&
          head.contains('<svg');
}

/// The manifest's logo links as one comparable value; null without any.
String? manifestLogoLinks(SubscriptionMetadata metadata) {
  final links = [metadata.logo, metadata.text('provider.logoDark')];
  return links.every((link) => link == null)
      ? null
      : links.map((link) => link ?? '').join('\n');
}

/// A page's declared icons, best first: touch icons, then the largest other
/// icons; icons declared smaller than [minSiteIconExtent] are left out.
List<Uri> siteIconCandidates(String source, Uri base) {
  final document = html.parse(source);
  final found = <({Uri uri, int rank, int extent})>[];
  for (final link in document.querySelectorAll('link[rel][href]')) {
    final rel = link.attributes['rel']!.toLowerCase().split(RegExp(r'\s+'));
    final touch =
        rel.contains('apple-touch-icon') ||
        rel.contains('apple-touch-icon-precomposed');
    if (!touch && !rel.contains('icon')) continue;
    final href = link.attributes['href']!.trim();
    final uri = Uri.tryParse(href);
    if (uri == null || href.isEmpty) continue;
    final resolved = base.resolveUri(uri);
    final scalable =
        link.attributes['type']?.toLowerCase() == 'image/svg+xml' ||
        resolved.path.toLowerCase().endsWith('.svg');
    final extent = scalable
        ? 1 << 16
        : _declaredExtent(link.attributes['sizes']) ?? (touch ? 180 : 0);
    if (extent > 0 && extent < minSiteIconExtent) continue;
    found.add((uri: resolved, rank: touch ? 0 : 1, extent: extent));
  }
  found.sort(
    (a, b) => a.rank != b.rank
        ? a.rank.compareTo(b.rank)
        : b.extent.compareTo(a.extent),
  );
  return [for (final icon in found) icon.uri];
}

int? _declaredExtent(String? sizes) {
  if (sizes == null) return null;
  if (sizes.toLowerCase().split(RegExp(r'\s+')).contains('any')) return 1 << 16;
  return RegExp(
    r'(\d+)[xX](\d+)',
  ).allMatches(sizes).map((m) => int.parse(m.group(1)!)).maxOrNull;
}

/// Whether an icon lives on the provider's own site: the page's host, one
/// of its subdomains, or the parent domain it belongs to.
bool sameProviderSite(Uri icon, String pageHost) {
  String bare(String host) =>
      host.toLowerCase().startsWith('www.') ? host.substring(4) : host;
  final a = bare(icon.host.toLowerCase());
  final b = bare(pageHost.toLowerCase());
  if (a.isEmpty || b.isEmpty) return false;
  if (a == b) return true;
  final (shorter, longer) = a.length < b.length ? (a, b) : (b, a);
  return shorter.contains('.') && longer.endsWith('.$shorter');
}

/// The public `t.me` page of a support link, whose preview carries the
/// account's avatar.
Uri? telegramPreviewPage(Uri link) {
  if (link.scheme == 'https' &&
      const {'t.me', 'telegram.me'}.contains(link.host.toLowerCase())) {
    final segments = link.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    return Uri(scheme: 'https', host: 't.me', path: '/${segments.first}');
  }
  if (link.scheme == 'tg' && link.host == 'resolve') {
    final domain = link.queryParameters['domain'];
    return domain == null
        ? null
        : Uri(scheme: 'https', host: 't.me', path: '/$domain');
  }
  return null;
}

/// Telegram's own CDN serves the avatars `t.me` previews point at.
bool _telegramHost(String host) =>
    host == 't.me' ||
    host == 'telegram.org' ||
    host.endsWith('.telegram.org') ||
    host.endsWith('.telesco.pe') ||
    host.endsWith('.cdn-telegram.org');

Uri? telegramPreviewImage(String source) {
  final content = html
      .parse(source)
      .querySelector('meta[property="og:image"]')
      ?.attributes['content']
      ?.trim();
  final uri = content == null ? null : Uri.tryParse(content);
  if (uri == null || uri.scheme != 'https' || !_telegramHost(uri.host)) {
    return null;
  }
  // Accounts without an avatar preview Telegram's own logo.
  if (uri.path.contains('/img/t_logo')) return null;
  return uri;
}
