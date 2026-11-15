import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' show StringCharacters;

/// Where a profile's logo came from, in the order the resolver tries them.
enum ProviderBrandSource { manifest, site, telegram, monogram }

class ProviderLogo {
  ProviderLogo({required this.bytes, this.svg = false});

  final Uint8List bytes;
  final bool svg;

  /// A data URI that `CommonTargetIcon` decodes in place; the MIME type only
  /// tells SVG apart, raster bytes are sniffed by the codec.
  late final String src =
      'data:${svg ? 'image/svg+xml' : 'image/png'};base64,${base64Encode(bytes)}';

  Map<String, Object?> toJson() => {'data': base64Encode(bytes), 'svg': svg};

  static ProviderLogo? fromJson(Object? value) {
    if (value is! Map || value['data'] is! String) return null;
    try {
      final bytes = base64Decode(value['data'] as String);
      if (bytes.isEmpty || bytes.length > providerLogoLimit) return null;
      return ProviderLogo(bytes: bytes, svg: value['svg'] == true);
    } on FormatException {
      return null;
    }
  }
}

/// The largest logo file the resolver keeps, as the page preview does.
const providerLogoLimit = 512 * 1024;

class ProviderBrand {
  const ProviderBrand({
    required this.source,
    required this.resolvedAt,
    this.logo,
    this.logoDark,
    this.color,
    this.manifestLogos,
  });

  final ProviderBrandSource source;
  final DateTime resolvedAt;
  final ProviderLogo? logo;
  final ProviderLogo? logoDark;

  /// ARGB; null keeps the profile's surfaces neutral.
  final int? color;

  /// The manifest logo links this brand was loaded from, so an update
  /// fetches them again only when the provider changes them.
  final String? manifestLogos;

  ProviderLogo? logoFor({required bool dark}) =>
      dark ? logoDark ?? logo : logo ?? logoDark;

  Map<String, Object?> toJson() => {
    'source': source.name,
    'resolvedAt': resolvedAt.toUtc().toIso8601String(),
    if (logo != null) 'logo': logo!.toJson(),
    if (logoDark != null) 'logoDark': logoDark!.toJson(),
    if (color != null) 'color': color,
    if (manifestLogos != null) 'manifestLogos': manifestLogos,
  };

  static ProviderBrand? fromJson(Object? value) {
    if (value is! Map) return null;
    final source = ProviderBrandSource.values
        .where((s) => s.name == value['source'])
        .firstOrNull;
    final rawResolvedAt = value['resolvedAt'];
    final resolvedAt = rawResolvedAt is String
        ? DateTime.tryParse(rawResolvedAt)
        : null;
    if (source == null || resolvedAt == null) return null;
    final color = value['color'];
    final manifestLogos = value['manifestLogos'];
    return ProviderBrand(
      source: source,
      resolvedAt: resolvedAt,
      logo: ProviderLogo.fromJson(value['logo']),
      logoDark: ProviderLogo.fromJson(value['logoDark']),
      color: color is int && color >= 0 && color <= 0xFFFFFFFF ? color : null,
      manifestLogos: manifestLogos is String ? manifestLogos : null,
    );
  }
}

/// Up to two letters: the initials of the first two words, or the first two
/// letters of a single word.
String profileMonogram(String name) {
  final words = name
      .split(RegExp(r'[\s._\-–—/|·]+'))
      .map((word) => word.characters.where(_isLetterOrDigit).join())
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  final letters = words.length == 1
      ? words.first.characters.take(2).toString()
      : words.take(2).map((word) => word.characters.first).join();
  return letters.toUpperCase();
}

bool _isLetterOrDigit(String grapheme) =>
    RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(grapheme);

/// A hue in degrees that stays the same for a name across launches and
/// platforms, unlike `String.hashCode`.
double monogramHue(String name) {
  var hash = 0x811c9dc5;
  for (final unit in utf8.encode(name.trim().toLowerCase())) {
    hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
  }
  return (hash % 360).toDouble();
}
