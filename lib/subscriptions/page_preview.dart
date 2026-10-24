import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:reclash/models/profile.dart';

import 'metadata/metadata.dart';
import 'transport/transport.dart';

class SubscriptionPagePreview {
  const SubscriptionPagePreview({
    this.label,
    this.metadata = const SubscriptionMetadata(),
    this.info,
    this.logoBytes,
    this.logoIsSvg = false,
    this.remnawave = false,
    this.apiUri,
  });

  final String? label;
  final SubscriptionMetadata metadata;
  final SubscriptionInfo? info;
  final Uint8List? logoBytes;
  final bool logoIsSvg;
  final bool remnawave;
  final Uri? apiUri;

  SubscriptionPagePreview withMetadata(SubscriptionMetadata value) =>
      SubscriptionPagePreview(
        label: label,
        metadata: metadata.merge(value),
        info: info,
        remnawave: remnawave,
        apiUri: apiUri,
      );
}

Future<SubscriptionPagePreview> previewSubscriptionPage(
  String url, {
  required SubscriptionTransport transport,
  SubscriptionCancellation? cancellation,
}) async {
  final response = await transport.fetch(
    Uri.parse(url),
    headers: _browserHeaders,
    cancellation: cancellation,
  );
  final type = response.headers['content-type']?.firstOrNull
      ?.split(';')
      .first
      .trim()
      .toLowerCase();
  if (type != 'text/html' && type != 'application/xhtml+xml') {
    return const SubscriptionPagePreview();
  }
  var result = await Isolate.run(
    () => parseSubscriptionPage(
      utf8.decode(response.bytes),
      baseUri: response.uri,
    ),
  );
  if (result.remnawave) {
    final cookie = _pageSession(response.headers['set-cookie'] ?? const []);
    if (cookie != null) {
      try {
        final config = await transport.fetch(
          response.uri.resolve('/assets/.app-config-v2.json'),
          headers: {..._browserHeaders, 'Cookie': cookie},
          timeout: const Duration(seconds: 8),
          cancellation: cancellation,
        );
        if (config.uri.origin == response.uri.origin) {
          final branding = await Isolate.run(
            () => _remnawaveBranding(utf8.decode(config.bytes), response.uri),
          );
          result = result.withMetadata(branding);
        }
      } on Object {
        if (cancellation?.cancelled ?? false) {
          throw const SubscriptionException(SubscriptionFailure.cancelled);
        }
      }
    }
  }
  final apiUri = result.apiUri;
  if (apiUri != null) {
    try {
      final api = await transport.fetch(
        apiUri,
        headers: {..._browserHeaders, 'Accept': 'application/json'},
        timeout: const Duration(seconds: 8),
        cancellation: cancellation,
      );
      if (api.uri.origin == response.uri.origin &&
          api.bytes.length <= 64 * 1024 &&
          api.headers['content-type']?.firstOrNull?.split(';').first.trim() ==
              'application/json') {
        final metadata = await Isolate.run(
          () =>
              parseProviderPreviewApi(utf8.decode(api.bytes), baseUri: api.uri),
        );
        result = result.withMetadata(metadata);
      }
    } on Object {
      if (cancellation?.cancelled ?? false) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
    }
  }
  final logoUrl = result.metadata.logo;
  Uint8List? logoBytes;
  var logoIsSvg = false;
  if (logoUrl != null) {
    try {
      final image = await transport.fetch(
        Uri.parse(logoUrl),
        headers: {..._browserHeaders, 'Accept': 'image/*'},
        timeout: const Duration(seconds: 8),
        cancellation: cancellation,
      );
      final type = image.headers['content-type']?.firstOrNull
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      if (image.bytes.isNotEmpty &&
          image.bytes.length <= 512 * 1024 &&
          const {
            'image/png',
            'image/jpeg',
            'image/webp',
            'image/gif',
            'image/svg+xml',
            'image/x-icon',
            'image/vnd.microsoft.icon',
          }.contains(type)) {
        logoBytes = image.bytes;
        logoIsSvg = type == 'image/svg+xml';
      }
    } on Object {
      if (cancellation?.cancelled ?? false) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
    }
  }
  if (cancellation?.cancelled ?? false) {
    throw const SubscriptionException(SubscriptionFailure.cancelled);
  }
  return SubscriptionPagePreview(
    label: result.label,
    metadata: result.metadata,
    info: result.info,
    logoBytes: logoBytes,
    logoIsSvg: logoIsSvg,
  );
}

const _browserHeaders = {
  'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'Accept': 'text/html,application/xhtml+xml',
};

String? _pageSession(List<String> headers) {
  for (final header in headers) {
    try {
      final cookie = Cookie.fromSetCookieValue(header);
      if (cookie.name == 'session' &&
          cookie.value.isNotEmpty &&
          cookie.value.length <= 4096 &&
          RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(cookie.value)) {
        return 'session=${cookie.value}';
      }
    } on FormatException {
      continue;
    }
  }
  return null;
}

SubscriptionMetadata _remnawaveBranding(String source, Uri baseUri) {
  final data = jsonDecode(source);
  final branding = data is Map ? data['brandingSettings'] : null;
  if (branding is! Map) return const SubscriptionMetadata();
  return SubscriptionMetadata({
    'provider.name': ?_text(branding['title']),
    'provider.logo': ?_pageLink(branding['logoUrl'], baseUri),
    'provider.supportUrl': ?_pageLink(
      branding['supportUrl'],
      baseUri,
      support: true,
    ),
  });
}

String? _pageLink(Object? value, Uri? baseUri, {bool support = false}) {
  final text = _text(value);
  if (text == null) return null;
  final uri = Uri.tryParse(text);
  if (uri == null) return null;
  final resolved = uri.hasScheme ? uri : baseUri?.resolveUri(uri);
  if (resolved == null ||
      baseUri?.scheme == 'https' && resolved.scheme == 'http') {
    return null;
  }
  return (support
          ? safeSubscriptionSupportLink(resolved.toString())
          : safeSubscriptionLink(resolved.toString()))
      ?.toString();
}

SubscriptionPagePreview parseSubscriptionPage(String source, {Uri? baseUri}) {
  final document = html.parse(source);
  final apiUri = _providerApiUri(document, baseUri);
  final panel = document
      .querySelector('#sbpg[data-panel]')
      ?.attributes['data-panel'];
  if (panel != null) {
    try {
      final decoded = jsonDecode(utf8.decode(base64.decode(panel)));
      final response = decoded is Map ? decoded['response'] : null;
      final user = response is Map && response['isFound'] == true
          ? response['user']
          : null;
      if (user is Map) {
        final used = _count(user['trafficUsedBytes']);
        final total = _count(user['trafficLimitBytes']);
        final expiry = user['expiresAt'] is String
            ? DateTime.tryParse(user['expiresAt'] as String)
            : null;
        return SubscriptionPagePreview(
          label: _text(user['username']),
          remnawave: true,
          apiUri: apiUri,
          metadata: _pageMetadata(document, baseUri).merge(
            SubscriptionMetadata({'account.title': ?_text(user['username'])}),
          ),
          info: used != null && total != null && expiry != null
              ? SubscriptionInfo(
                  download: used,
                  total: total,
                  expire: expiry.millisecondsSinceEpoch ~/ 1000,
                )
              : null,
        );
      }
    } on FormatException {
      return SubscriptionPagePreview(
        metadata: _pageMetadata(document, baseUri),
        remnawave: true,
        apiUri: apiUri,
      );
    }
  }
  final result =
      _threeXUiPage(document, baseUri) ??
      _marzbanPage(document, baseUri) ??
      SubscriptionPagePreview(metadata: _pageMetadata(document, baseUri));
  return SubscriptionPagePreview(
    label: result.label,
    metadata: result.metadata,
    info: result.info,
    apiUri: apiUri,
  );
}

Uri? _providerApiUri(Document document, Uri? baseUri) {
  if (baseUri == null) return null;
  final links = document.querySelectorAll('link[rel="reclash-preview"][href]');
  if (links.length != 1) return null;
  final link = _pageLink(links.single.attributes['href'], baseUri);
  final uri = link == null ? null : Uri.tryParse(link);
  return uri != null &&
          uri.origin == baseUri.origin &&
          !uri.hasFragment &&
          uri.replace(fragment: '').toString() !=
              baseUri.replace(fragment: '').toString()
      ? uri
      : null;
}

SubscriptionMetadata parseProviderPreviewApi(
  String source, {
  required Uri baseUri,
}) {
  if (utf8.encode(source).length > 64 * 1024) {
    throw const FormatException('Preview API too large');
  }
  final data = jsonDecode(source);
  if (data is! Map || data['version'] is! int || data['version'] != 1) {
    throw const FormatException('Unsupported preview API');
  }
  final provider = data['provider'];
  final account = data['account'];
  final subscription = data['subscription'];
  String? text(Object? value, int limit) {
    final result = _text(value);
    return result != null && result.length <= limit ? result : null;
  }

  return SubscriptionMetadata({
    if (provider is Map) ...{
      'provider.name': ?text(provider['name'], 256),
      'provider.announce': ?text(provider['description'], 4096),
      'provider.logo': ?_pageLink(provider['logoUrl'], baseUri),
      'provider.supportUrl': ?_pageLink(
        provider['supportUrl'],
        baseUri,
        support: true,
      ),
    },
    if (account is Map) 'account.title': ?text(account['name'], 256),
    if (subscription is Map)
      'subscription.type': ?text(subscription['type'], 32),
  });
}

SubscriptionMetadata _pageMetadata(Document document, Uri? baseUri) {
  String? meta(String name) => _text(
    document
        .querySelector('meta[property="$name"], meta[name="$name"]')
        ?.attributes['content'],
  );
  return SubscriptionMetadata({
    'provider.name':
        ?meta('og:site_name') ??
        meta('og:title') ??
        _text(document.querySelector('title')?.text),
    'provider.announce': ?meta('description') ?? meta('og:description'),
    'provider.logo': ?_pageLink(
      meta('og:image') ??
          document
              .querySelector(
                'link[rel="apple-touch-icon"], link[rel="icon"], link[rel="shortcut icon"]',
              )
              ?.attributes['href'],
      baseUri,
    ),
    'provider.supportUrl': ?_supportAnchor(document, baseUri),
  });
}

SubscriptionPagePreview? _threeXUiPage(Document document, Uri? baseUri) {
  for (final script in document.querySelectorAll('script')) {
    final match = RegExp(
      r'window\.__SUB_PAGE_DATA__\s*=\s*(\{[\s\S]*\})\s*;?\s*$',
    ).firstMatch(script.text);
    if (match == null) continue;
    try {
      final data = jsonDecode(match[1]!);
      if (data is! Map) continue;
      final upload = _count(data['uploadByte']);
      final download = _count(data['downloadByte']);
      final total = _count(data['totalByte']);
      final rawExpire = _count(data['expire']);
      final expire = rawExpire != null && rawExpire <= 8640000000000
          ? rawExpire
          : null;
      final title = _text(data['subTitle']);
      return SubscriptionPagePreview(
        label: title,
        metadata: SubscriptionMetadata({
          ..._pageMetadata(document, baseUri).fields,
          'provider.name': ?title,
          'provider.announce': ?_text(data['announce']),
          'provider.supportUrl': ?_pageLink(
            data['subSupportUrl'],
            baseUri,
            support: true,
          ),
          'account.title': ?_accountEmail(data['emails']),
        }),
        info:
            upload != null &&
                download != null &&
                total != null &&
                expire != null
            ? SubscriptionInfo(
                upload: upload,
                download: download,
                total: total,
                expire: expire,
              )
            : null,
      );
    } on FormatException {
      continue;
    }
  }
  return null;
}

SubscriptionPagePreview? _marzbanPage(Document document, Uri? baseUri) {
  final values = <String, String>{};
  for (final element in document.querySelectorAll('p')) {
    final text = element.text.trim();
    final separator = text.indexOf(':');
    if (separator > 0) {
      values[text.substring(0, separator).trim()] = text
          .substring(separator + 1)
          .trim();
    }
  }
  if (!values.keys.toSet().containsAll({
    'Username',
    'Status',
    'Data Limit',
    'Data Used',
    'Expiration Date',
  })) {
    return null;
  }
  final used = _traffic(values['Data Used']!.split(' (').first);
  final total = _traffic(values['Data Limit']!);
  final rawExpiry = values['Expiration Date']!;
  final expiry = rawExpiry == '∞'
      ? 0
      : DateTime.tryParse(
          rawExpiry.split(' (').first.trim(),
        )?.millisecondsSinceEpoch;
  return SubscriptionPagePreview(
    label: _text(values['Username']),
    metadata: _pageMetadata(document, baseUri).merge(
      SubscriptionMetadata({'account.title': ?_text(values['Username'])}),
    ),
    info: used != null && total != null && expiry != null
        ? SubscriptionInfo(download: used, total: total, expire: expiry ~/ 1000)
        : null,
  );
}

String? _accountEmail(Object? emails) {
  if (emails is! List) return null;
  final names = emails.map(_text).whereType<String>().toSet();
  return names.length == 1 ? names.single : null;
}

String? _supportAnchor(Document document, Uri? baseUri) {
  for (final anchor in document.querySelectorAll('a[href]')) {
    final rel = anchor.attributes['rel']?.split(RegExp(r'\s+')) ?? const [];
    final label = _text(anchor.attributes['aria-label']) ?? anchor.text.trim();
    if (!rel.contains('help') &&
        !RegExp(
          r'^(?:support|help|contact(?: us)?|поддержка|техподдержка|помощь|связаться с нами)$',
          caseSensitive: false,
        ).hasMatch(label)) {
      continue;
    }
    final link = _pageLink(anchor.attributes['href'], baseUri, support: true);
    if (link != null) return link;
  }
  return null;
}

int? _count(Object? value) {
  final count = value is int
      ? value
      : value is String
      ? int.tryParse(value)
      : null;
  return count != null && count >= 0 && count <= 9007199254740991
      ? count
      : null;
}

String? _text(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isNotEmpty &&
          text.length <= 4096 &&
          !text.runes.any(
            (rune) => rune < 32 && rune != 10 && rune != 13 && rune != 9,
          )
      ? text
      : null;
}

int? _traffic(String text) {
  if (text.trim() == '∞') return 0;
  final match = RegExp(
    r'^(\d+(?:\.\d+)?)\s*(B|[KMGTPE]i?B)$',
    caseSensitive: false,
  ).firstMatch(text.trim());
  if (match == null) return null;
  final power = const [
    'B',
    'KB',
    'MB',
    'GB',
    'TB',
    'PB',
    'EB',
  ].indexOf(match[2]!.toUpperCase().replaceAll('I', ''));
  var value = double.parse(match[1]!);
  for (var index = 0; index < power; index++) {
    value *= 1024;
  }
  return value.isFinite ? _count(value.round()) : null;
}
