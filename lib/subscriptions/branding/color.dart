import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_color_utilities/material_color_utilities.dart';

const _sampleExtent = 32;
const _hueBuckets = 24;

/// The pixel size of an encoded raster image, read from its header without
/// decoding it; null for anything the engine cannot decode.
Future<({int width, int height})?> encodedImageSize(Uint8List bytes) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    return (width: descriptor.width, height: descriptor.height);
  } on Object {
    return null;
  } finally {
    descriptor?.dispose();
    buffer?.dispose();
  }
}

/// The logo's dominant saturated color as ARGB, or null for a gray, black or
/// white logo, which keeps the profile neutral.
Future<int?> dominantLogoColor(Uint8List bytes, {required bool svg}) async {
  if (svg) return dominantSvgColor(utf8.decode(bytes, allowMalformed: true));
  ui.Codec? codec;
  ui.Image? image;
  try {
    codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _sampleExtent,
      targetHeight: _sampleExtent,
    );
    image = (await codec.getNextFrame()).image;
    final data = await image.toByteData();
    return data == null ? null : dominantPixelColor(data.buffer.asUint8List());
  } on Object {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
  }
}

/// Picks the hue that carries the most chroma over the opaque pixels of an
/// RGBA buffer and averages the pixels of that hue.
int? dominantPixelColor(Uint8List rgba) {
  final weights = List<double>.filled(_hueBuckets, 0);
  final counts = List<int>.filled(_hueBuckets, 0);
  final sums = List.generate(_hueBuckets, (_) => [0.0, 0.0, 0.0]);
  var opaque = 0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    if (rgba[i + 3] < 200) continue;
    opaque++;
    final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
    final weight = _colorfulness(r, g, b);
    if (weight == 0) continue;
    final bucket = (_hue(r, g, b) / 360 * _hueBuckets).floor().clamp(
      0,
      _hueBuckets - 1,
    );
    weights[bucket] += weight;
    counts[bucket]++;
    sums[bucket][0] += r * weight;
    sums[bucket][1] += g * weight;
    sums[bucket][2] += b * weight;
  }
  if (opaque == 0) return null;
  var best = 0;
  for (var i = 1; i < _hueBuckets; i++) {
    if (weights[i] > weights[best]) best = i;
  }
  // A few tinted pixels of anti-aliasing on a monochrome mark are not a brand.
  if (counts[best] < opaque * 0.04) return null;
  final w = weights[best];
  return _argb(
    (sums[best][0] / w).round(),
    (sums[best][1] / w).round(),
    (sums[best][2] / w).round(),
  );
}

final _svgHex = RegExp(r'#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![0-9a-fA-F])');

/// The most frequent saturated hex color in an SVG's source.
int? dominantSvgColor(String source) {
  final counts = <int, double>{};
  for (final match in _svgHex.allMatches(source)) {
    final hex = match.group(1)!;
    final full = hex.length == 3
        ? hex.split('').map((c) => '$c$c').join()
        : hex;
    final value = int.parse(full, radix: 16);
    final r = value >> 16 & 0xFF, g = value >> 8 & 0xFF, b = value & 0xFF;
    final weight = _colorfulness(r, g, b);
    if (weight > 0) counts[value] = (counts[value] ?? 0) + weight;
  }
  if (counts.isEmpty) return null;
  final best = counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  return 0xFF000000 | best;
}

/// Chroma of a saturated, not too dark color; zero for grays, near-black and
/// near-white.
double _colorfulness(int r, int g, int b) {
  final high = math.max(r, math.max(g, b));
  final low = math.min(r, math.min(g, b));
  final chroma = (high - low).toDouble();
  if (high < 40 || chroma / high < 0.25) return 0;
  return chroma;
}

double _hue(int r, int g, int b) {
  final high = math.max(r, math.max(g, b));
  final chroma = (high - math.min(r, math.min(g, b))).toDouble();
  final double sector;
  if (high == r) {
    sector = ((g - b) / chroma) % 6;
  } else if (high == g) {
    sector = (b - r) / chroma + 2;
  } else {
    sector = (r - g) / chroma + 4;
  }
  return sector * 60;
}

int _argb(int r, int g, int b) => 0xFF000000 | r << 16 | g << 8 | b;

/// The tone-50 color of a monogram's hue, stored like a logo's color.
int monogramColor(double hue) => Hct.from(hue, 40, 50).toInt();
