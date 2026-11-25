import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:prism_ui/theme_data.dart' as prism;

/// Mirrors the resolved Material scheme, so both widget systems share a palette.
prism.ThemeData buildPrismTheme(material.ThemeData theme) {
  final scheme = theme.colorScheme;
  return prism.ThemeData(
    brightness: theme.brightness,
    platform: theme.platform,
    colorScheme: prism.ColorScheme(
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
    ),
    fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    fontFamilyFallback: theme.textTheme.bodyMedium?.fontFamilyFallback,
    visualDensity: prism.VisualDensity(
      horizontal: theme.visualDensity.horizontal,
      vertical: theme.visualDensity.vertical,
    ),
    tapTargetSize: prism.TapTargetSize.shrinkWrap,
    scaffoldBackgroundColor: scheme.surface,
  );
}

class PrismThemeBridge extends StatelessWidget {
  const PrismThemeBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return prism.Theme(
      data: buildPrismTheme(material.Theme.of(context)),
      child: child,
    );
  }
}
