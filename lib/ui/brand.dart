import 'dart:math' as math;

import 'dart:ui' show Brightness, Color;
import 'package:material_color_utilities/material_color_utilities.dart'
    show Hct;

/// How strongly a surface takes its provider's hue.
enum BrandSurface {
  /// The active profile's pass.
  pass(dark: 22, light: 12),

  /// A profile card in the stack or the desktop grid.
  card(dark: 10, light: 6);

  const BrandSurface({required this.dark, required this.light});

  final double dark;
  final double light;
}

/// A provider color reduced to its hue, to tint surfaces without moving them
/// off their level: the tone stays the level's, so text contrast is untouched.
/// The one exception to `.agents/surfaces.md` keeping color off whole cards.
class BrandTint {
  BrandTint(Color color) : _source = Hct.fromInt(color.toARGB32());

  final Hct _source;

  double get hue => _source.hue;

  Color surface(Color level, BrandSurface strength, Brightness brightness) {
    final base = Hct.fromInt(level.toARGB32());
    final cap = brightness == Brightness.dark ? strength.dark : strength.light;
    return Color(
      Hct.from(hue, math.min(_source.chroma, cap), base.tone).toInt(),
    ).withAlpha((level.a * 255).round());
  }

  /// Gauge segments, the remaining-traffic ring and the sync trace: status
  /// text tones, 80 in dark and 40 in light.
  Color accent(Brightness brightness) => Color(
    Hct.from(
      hue,
      math.max(_source.chroma, 48),
      brightness == Brightness.dark ? 80 : 40,
    ).toInt(),
  );

  /// The well behind a monogram, and the letters on it.
  Color well(Brightness brightness) =>
      Color(Hct.from(hue, 36, brightness == Brightness.dark ? 30 : 90).toInt());

  Color onWell(Brightness brightness) =>
      Color(Hct.from(hue, 40, brightness == Brightness.dark ? 88 : 30).toInt());
}
