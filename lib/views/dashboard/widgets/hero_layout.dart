import 'dart:math' as math;

import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:flutter/widgets.dart';

const double heroOrbMinSize = 120;
const double heroOrbMaxSize = 280;

const double heroOrbSizeStep = 8;

const double _splitMinWidth = 540;
const double _splitAlwaysWidth = 1100;
const double _splitRatio = 1.35;

bool heroSplitFor(BoxConstraints box) {
  if (!box.hasBoundedWidth || !box.hasBoundedHeight) return false;
  if (box.maxWidth < _splitMinWidth) return false;
  return box.maxWidth >= _splitAlwaysWidth ||
      box.maxWidth >= box.maxHeight * _splitRatio;
}

double heroOrbSizeFor(
  double available, {
  double min = heroOrbMinSize,
  double max = heroOrbMaxSize,
}) {
  final ceiling = math.max(min, max);
  final band = available.clamp(min, ceiling);
  final stepped = (band / heroOrbSizeStep).floorToDouble() * heroOrbSizeStep;
  return stepped.clamp(min, ceiling).toDouble();
}

enum HeroDensity { compact, regular, comfortable }

class HeroMetrics {
  const HeroMetrics({
    required this.density,
    required this.orbMin,
    required this.orbMax,
  });

  factory HeroMetrics.of(
    BoxConstraints box,
    TextScaler textScaler, {
    bool split = false,
    bool portrait = false,
  }) {
    final height = box.hasBoundedHeight ? box.maxHeight : heroOrbMaxSize * 3;
    final effective = height / math.max(1, textScaler.scale(14) / 14);
    final density = effective < 520
        ? HeroDensity.compact
        : effective < 760
        ? HeroDensity.regular
        : HeroDensity.comfortable;
    if (portrait) {
      return HeroMetrics(
        density: density,
        orbMin: heroOrbMinSize,
        orbMax: heroOrbBaseSize,
      );
    }
    final orbMax = split
        ? (height * 0.42).clamp(heroOrbMinSize, heroOrbMaxSize).toDouble()
        : heroOrbMaxSize;
    return HeroMetrics(
      density: density,
      orbMin: heroOrbMinSize,
      orbMax: orbMax,
    );
  }

  final HeroDensity density;
  final double orbMin;
  final double orbMax;

  double get gapEdge => switch (density) {
    HeroDensity.compact => 4,
    HeroDensity.regular => 8,
    HeroDensity.comfortable => 8,
  };

  double get gapCaption => switch (density) {
    HeroDensity.compact => 10,
    HeroDensity.regular => 14,
    HeroDensity.comfortable => 18,
  };

  double get gapCard => switch (density) {
    HeroDensity.compact => 8,
    HeroDensity.regular => 12,
    HeroDensity.comfortable => 16,
  };

  double get captionMinHeight => switch (density) {
    HeroDensity.compact => 46,
    HeroDensity.regular => 54,
    HeroDensity.comfortable => 58,
  };
}
