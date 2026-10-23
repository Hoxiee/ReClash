import 'dart:convert';
import 'dart:isolate';

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
  });

  final String? label;
  final SubscriptionMetadata metadata;
  final SubscriptionInfo? info;
}

Future<SubscriptionPagePreview> previewSubscriptionPage(
  String url, {
  required SubscriptionTransport transport,
  SubscriptionCancellation? cancellation,
}) async {
  final response = await transport.fetch(
    Uri.parse(url),
    headers: const {
      'User-Agent': 'Mozilla/5.0 (compatible; ReClash-Subscription-Preview)',
      'Accept': 'text/html,application/xhtml+xml',
    },
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
  final result = await Isolate.run(
    () => parseSubscriptionPage(utf8.decode(response.bytes)),
  );
  if (cancellation?.cancelled ?? false) {
    throw const SubscriptionException(SubscriptionFailure.cancelled);
  }
  return result;
}

SubscriptionPagePreview parseSubscriptionPage(String source) {
  final document = html.parse(source);
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
          metadata: _pageMetadata(document),
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
      return SubscriptionPagePreview(metadata: _pageMetadata(document));
    }
  }
  return _threeXUiPage(document) ??
      _marzbanPage(document) ??
      SubscriptionPagePreview(metadata: _pageMetadata(document));
}

SubscriptionMetadata _pageMetadata(Document document) {
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
  });
}

SubscriptionPagePreview? _threeXUiPage(Document document) {
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
          ..._pageMetadata(document).fields,
          'provider.name': ?title,
          'provider.announce': ?_text(data['announce']),
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

SubscriptionPagePreview? _marzbanPage(Document document) {
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
    metadata: _pageMetadata(document),
    info: used != null && total != null && expiry != null
        ? SubscriptionInfo(download: used, total: total, expire: expiry ~/ 1000)
        : null,
  );
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
