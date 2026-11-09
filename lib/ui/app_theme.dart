import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';

const _pageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: commonSharedXPageTransitions,
    TargetPlatform.windows: commonSharedXPageTransitions,
    TargetPlatform.linux: commonSharedXPageTransitions,
    TargetPlatform.macOS: commonSharedXPageTransitions,
  },
);

const _actionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: _backButtonIcon,
  closeButtonIconBuilder: _closeButtonIcon,
);

Widget _backButtonIcon(BuildContext context) =>
    GlyphIcon(AppGlyphs.backFor(Theme.of(context).platform));

Widget _closeButtonIcon(BuildContext context) =>
    const GlyphIcon(AppGlyphs.close);

ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required List<Locale> locales,
  String? fontFamily,
}) => ThemeData(
  useMaterial3: true,
  pageTransitionsTheme: _pageTransitionsTheme,
  actionIconTheme: _actionIconTheme,
  colorScheme: colorScheme,
  fontFamily: fontFamily,
  fontFamilyFallback: appFontFamilyFallback(
    platform: defaultTargetPlatform,
    locales: locales,
    fontFamily: fontFamily,
  ),
  extensions: [
    if (brightness == Brightness.dark)
      ElevatedColorScheme(colorScheme.elevated),
  ],
).withAppShapes.withAppSurfaces.withAppTypography.withAppTooltips;
