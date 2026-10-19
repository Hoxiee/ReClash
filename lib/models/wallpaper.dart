import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/wallpaper.freezed.dart';
part 'generated/wallpaper.g.dart';

enum WallpaperFit { cover, contain, fill }

const maxWallpaperLibrary = 3;

final _wallpaperFileName = RegExp(r'^[a-f0-9]{32}\.png$');

bool isWallpaperFileName(Object? value) =>
    value is String && _wallpaperFileName.hasMatch(value);

List<String> sanitizeWallpaperLibrary(Object? value) {
  if (value is! Iterable) return const [];
  final names = <String>[];
  for (final name in value) {
    if (isWallpaperFileName(name) && !names.contains(name)) {
      names.add(name as String);
      if (names.length == maxWallpaperLibrary) break;
    }
  }
  return names;
}

List<String> wallpaperLibraryOf(Map<String, Object?>? config) {
  final theme = config?['themeProps'];
  final wallpaper = theme is Map ? theme['wallpaper'] : null;
  return wallpaper is Map
      ? sanitizeWallpaperLibrary(wallpaper['library'])
      : const [];
}

@freezed
abstract class WallpaperProps with _$WallpaperProps {
  const factory WallpaperProps({
    @Default(false) bool enabled,
    String? fileName,
    @Default(<String>[]) List<String> library,
    @Default(WallpaperFit.cover) WallpaperFit fit,
    @Default(1.0) double scale,
    @Default(0.0) double positionX,
    @Default(0.0) double positionY,
    @Default(0.35) double opacity,
    @Default(0.0) double dimming,
    @Default(0.0) double blur,
    @Default(0.9) double cardOpacity,
  }) = _WallpaperProps;

  factory WallpaperProps.fromJson(Map<String, Object?> json) =>
      _$WallpaperPropsFromJson(json);

  static WallpaperProps safeFromJson(Object? json) {
    if (json is! Map) return const WallpaperProps();
    double number(String key, double fallback, double min, double max) {
      final value = json[key];
      return value is num && value.isFinite
          ? value.toDouble().clamp(min, max)
          : fallback;
    }

    final library = sanitizeWallpaperLibrary(json['library']);
    final selected = json['fileName'];
    final fileName = isWallpaperFileName(selected) && library.contains(selected)
        ? selected as String
        : null;
    return WallpaperProps(
      enabled: fileName != null && json['enabled'] == true,
      fileName: fileName,
      library: library,
      fit: WallpaperFit.values.firstWhere(
        (value) => value.name == json['fit'],
        orElse: () => WallpaperFit.cover,
      ),
      scale: number('scale', 1, 1, 3),
      positionX: number('positionX', 0, -1, 1),
      positionY: number('positionY', 0, -1, 1),
      opacity: number('opacity', 0.35, 0, 1),
      dimming: number('dimming', 0, 0, 1),
      blur: number('blur', 0, 0, 30),
      cardOpacity: number('cardOpacity', 0.9, 0, 1),
    );
  }
}
