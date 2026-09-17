part of '../state.dart';

typedef DynamicColorSeeds = ({
  Color? lightSeed,
  Color? darkSeed,
  Color accentColor,
});

@riverpod
ThemeProps effectiveThemeProps(Ref ref) {
  final user = ref.watch(themeSettingProvider);
  final themeHex = ref.watch(
    currentProfileProvider.select((state) => state?.panelMeta?.themeHex),
  );
  return applyPanelTheme(user, parsePanelTheme(themeHex));
}

@Riverpod(keepAlive: true)
class DynamicColor extends _$DynamicColor {
  @override
  DynamicColorSeeds build() {
    return (
      lightSeed: null,
      darkSeed: null,
      accentColor: const Color(defaultPrimaryColor),
    );
  }

  void seed({Color? lightSeed, Color? darkSeed, required Color accentColor}) {
    state = (
      lightSeed: lightSeed,
      darkSeed: darkSeed,
      accentColor: accentColor,
    );
  }
}

@riverpod
ColorScheme genColorScheme(
  Ref ref,
  Brightness brightness, {
  Color? color,
  bool ignoreConfig = false,
}) {
  final themeSetting = ref.watch(
    effectiveThemePropsProvider.select(
      (state) => (
        primaryColor: state.primaryColor,
        schemeVariant: state.schemeVariant,
        contrastLevel: state.contrastLevel,
      ),
    ),
  );
  final dynamicColor = ref.watch(dynamicColorProvider);
  if (color == null &&
      (ignoreConfig == true || themeSetting.primaryColor == null)) {
    final seed = switch (brightness) {
      Brightness.light => dynamicColor.lightSeed,
      Brightness.dark => dynamicColor.darkSeed,
    };
    return ColorScheme.fromSeed(
      seedColor: seed ?? dynamicColor.accentColor,
      brightness: brightness,
      dynamicSchemeVariant: themeSetting.schemeVariant,
      contrastLevel: themeSetting.contrastLevel,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: color ?? Color(themeSetting.primaryColor!),
    brightness: brightness,
    dynamicSchemeVariant: themeSetting.schemeVariant,
    contrastLevel: themeSetting.contrastLevel,
  );
}

@Riverpod(keepAlive: true)
class EffectiveThemeMode extends _$EffectiveThemeMode {
  @override
  ThemeMode build() {
    final themeSetting = ref.watch(themeSettingProvider);
    final now = DateTime.now();
    final flip = themeSetting.nextScheduleFlip(now);
    if (flip != null) {
      // One-shot timer past the window edge: the extra second makes the
      // recompute land after the boundary, not exactly on it.
      final timer = Timer(
        flip + const Duration(seconds: 1),
        ref.invalidateSelf,
      );
      ref.onDispose(timer.cancel);
    }
    return themeSetting.themeModeAt(now);
  }
}

@riverpod
Brightness currentBrightness(Ref ref) {
  final themeMode = ref.watch(effectiveThemeModeProvider);
  final systemBrightness = ref.watch(systemBrightnessProvider);
  return switch (themeMode) {
    ThemeMode.system => systemBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}
