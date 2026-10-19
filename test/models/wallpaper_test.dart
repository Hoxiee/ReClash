import 'dart:convert';

import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallpaper defaults preserve the existing theme configuration', () {
    final theme = ThemeProps.fromJson(const {}).wallpaper;
    expect(theme, const WallpaperProps());
    expect(ThemeProps.fromJson(const {}).toJson()['wallpaper'], isNotNull);
  });

  test('wallpaper settings survive a config JSON round trip', () {
    const wallpaper = WallpaperProps(
      enabled: true,
      fileName: '0123456789abcdef0123456789abcdef.png',
      library: ['0123456789abcdef0123456789abcdef.png'],
      fit: WallpaperFit.contain,
      scale: 1.75,
      positionX: -0.4,
      opacity: 0.7,
      dimming: 0.2,
      blur: 4,
      cardOpacity: 0.6,
    );
    final config = Config(themeProps: ThemeProps(wallpaper: wallpaper));
    final decoded =
        jsonDecode(jsonEncode(config.toJson())) as Map<String, Object?>;
    expect(Config.fromJson(decoded).themeProps.wallpaper, wallpaper);
  });

  test('malformed and out-of-range wallpaper values are sanitized', () {
    final wallpaper = WallpaperProps.safeFromJson({
      'enabled': true,
      'fileName': '../outside.png',
      'library': [
        '0123456789abcdef0123456789abcdef.png',
        '0123456789abcdef0123456789abcdef.png',
        '../outside.png',
      ],
      'scale': 80,
      'positionX': double.nan,
      'positionY': -80,
      'opacity': 2,
      'dimming': -1,
      'blur': 100,
      'cardOpacity': 2,
      'fit': 'unsupported',
    });
    expect(wallpaper.enabled, isFalse);
    expect(wallpaper.fileName, isNull);
    expect(wallpaper.library, ['0123456789abcdef0123456789abcdef.png']);
    expect(wallpaper.scale, 3);
    expect(wallpaper.positionX, 0);
    expect(wallpaper.positionY, -1);
    expect(wallpaper.opacity, 1);
    expect(wallpaper.dimming, 0);
    expect(wallpaper.blur, 30);
    expect(wallpaper.cardOpacity, 1);
    expect(wallpaper.fit, WallpaperFit.cover);
  });

  test('backup config exposes only safe wallpaper file names', () {
    expect(
      wallpaperLibraryOf({
        'themeProps': {
          'wallpaper': {
            'library': [
              '0123456789abcdef0123456789abcdef.png',
              '../escape.png',
              'fedcba9876543210fedcba9876543210.png',
              '0123456789abcdef0123456789abcdef.png',
            ],
          },
        },
      }),
      [
        '0123456789abcdef0123456789abcdef.png',
        'fedcba9876543210fedcba9876543210.png',
      ],
    );
  });
}
