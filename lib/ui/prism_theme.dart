import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:prism_ui/measure.dart' as prism;
import 'package:prism_ui/page_background.dart';
import 'package:prism_ui/surface.dart' as prism;
import 'package:prism_ui/theme_data.dart' as prism;
import 'package:reclash/ui/surface.dart' show ElevatedColorScheme;
import 'package:reclash/ui/tooltip.dart' show appTooltipTheme;

/// The app's resolved font, which Material keeps private inside its text styles.
class PrismFont extends material.ThemeExtension<PrismFont> {
  const PrismFont({this.family, this.fallback = const []});

  final String? family;
  final List<String> fallback;

  @override
  PrismFont copyWith({String? family, List<String>? fallback}) => PrismFont(
    family: family ?? this.family,
    fallback: fallback ?? this.fallback,
  );

  @override
  PrismFont lerp(PrismFont? other, double t) => other ?? this;
}

prism.ColorScheme _prismScheme(material.ColorScheme scheme) =>
    prism.ColorScheme(
      brightness: scheme.brightness,
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      primaryFixed: scheme.primaryFixed,
      primaryFixedDim: scheme.primaryFixedDim,
      onPrimaryFixed: scheme.onPrimaryFixed,
      onPrimaryFixedVariant: scheme.onPrimaryFixedVariant,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      secondaryContainer: scheme.secondaryContainer,
      onSecondaryContainer: scheme.onSecondaryContainer,
      secondaryFixed: scheme.secondaryFixed,
      secondaryFixedDim: scheme.secondaryFixedDim,
      onSecondaryFixed: scheme.onSecondaryFixed,
      onSecondaryFixedVariant: scheme.onSecondaryFixedVariant,
      tertiary: scheme.tertiary,
      onTertiary: scheme.onTertiary,
      tertiaryContainer: scheme.tertiaryContainer,
      onTertiaryContainer: scheme.onTertiaryContainer,
      tertiaryFixed: scheme.tertiaryFixed,
      tertiaryFixedDim: scheme.tertiaryFixedDim,
      onTertiaryFixed: scheme.onTertiaryFixed,
      onTertiaryFixedVariant: scheme.onTertiaryFixedVariant,
      error: scheme.error,
      onError: scheme.onError,
      errorContainer: scheme.errorContainer,
      onErrorContainer: scheme.onErrorContainer,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      surfaceDim: scheme.surfaceDim,
      surfaceBright: scheme.surfaceBright,
      surfaceContainerLowest: scheme.surfaceContainerLowest,
      surfaceContainerLow: scheme.surfaceContainerLow,
      surfaceContainer: scheme.surfaceContainer,
      surfaceContainerHigh: scheme.surfaceContainerHigh,
      surfaceContainerHighest: scheme.surfaceContainerHighest,
      onSurfaceVariant: scheme.onSurfaceVariant,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
      shadow: scheme.shadow,
      scrim: scheme.scrim,
      inverseSurface: scheme.inverseSurface,
      onInverseSurface: scheme.onInverseSurface,
      inversePrimary: scheme.inversePrimary,
      surfaceTint: scheme.surfaceTint,
    );

prism.TooltipThemeData _prismTooltipTheme(material.ThemeData theme) {
  final tooltip = appTooltipTheme(theme);
  return prism.TooltipThemeData(
    constraints: tooltip.constraints,
    padding: tooltip.padding,
    margin: tooltip.margin,
    textStyle: tooltip.textStyle,
    decoration: tooltip.decoration,
  );
}

prism.ThemeData buildPrismTheme(material.ThemeData theme) {
  final scheme = theme.colorScheme;
  final font = theme.extension<PrismFont>();
  return prism.ThemeData(
    brightness: theme.brightness,
    platform: theme.platform,
    colorScheme: _prismScheme(scheme),
    elevatedColorScheme: switch (theme.extension<ElevatedColorScheme>()) {
      final elevated? => _prismScheme(elevated.colorScheme),
      _ => null,
    },
    fontFamily: font?.family,
    fontFamilyFallback: font?.fallback,
    visualDensity: prism.VisualDensity(
      horizontal: theme.visualDensity.horizontal,
      vertical: theme.visualDensity.vertical,
    ),
    tapTargetSize: prism.TapTargetSize.shrinkWrap,
    scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    tooltipTheme: _prismTooltipTheme(theme),
  );
}

class PrismThemeBridge extends StatelessWidget {
  const PrismThemeBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themed = prism.Theme(
      data: buildPrismTheme(material.Theme.of(context)),
      child: prism.CardFillScope(
        transform: PageBackgroundScope.applyCardOpacity,
        child: child,
      ),
    );
    // A nested bridge reuses the outer measure.
    if (prism.MeasureScope.maybeOf(context) != null) return themed;
    return prism.MeasureScope(
      measure: prism.Measure.of(
        context,
        MediaQuery.textScalerOf(context).scale(1),
      ),
      child: themed,
    );
  }
}
