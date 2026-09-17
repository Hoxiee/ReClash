import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/wallpaper.freezed.dart';
part 'generated/wallpaper.g.dart';

enum WallpaperFit { cover, contain, fill }

bool isWallpaperFileName(Object? value) =>
    value is String && RegExp(r'^[a-f0-9]{32}\.png$').hasMatch(value);

String? wallpaperFileNameOf(Map? configMap) {
  final theme = configMap?['themeProps'];
  if (theme is! Map) return null;
  final wallpaper = theme['wallpaper'];
  if (wallpaper is! Map) return null;
  final fileName = wallpaper['fileName'];
  return isWallpaperFileName(fileName) ? fileName as String : null;
}

@freezed
abstract class WallpaperProps with _$WallpaperProps {
  const factory WallpaperProps({
    @Default(false) bool enabled,
    String? fileName,
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

    final fileName = json['fileName'];
    final validFile = isWallpaperFileName(fileName);
    return WallpaperProps(
      enabled: validFile && json['enabled'] == true,
      fileName: validFile ? fileName as String : null,
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
