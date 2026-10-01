import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  final image = MemoryImage(Uint8List.fromList([1, 2, 3]));
  const branded = PanelBackground(
    url: 'https://example.com/background.jpg',
    opacity: 1,
  );

  ProviderContainer container({
    required WallpaperProps wallpaper,
    required MemoryImage? image,
    required PanelBackground? providerBackground,
  }) {
    final container = ProviderContainer(
      overrides: [
        wallpaperImageProvider.overrideWith((_) async => image),
        panelBackgroundProvider.overrideWithValue(providerBackground),
      ],
    );
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(wallpaper: wallpaper));
    return container;
  }

  WallpaperProps wallpaper({required bool providerPriority}) {
    return WallpaperProps(
      enabled: true,
      providerPriority: providerPriority,
      fileName: 'a' * 32 + '.png',
    );
  }

  test('own background wins everywhere when priority is off', () async {
    final c = container(
      wallpaper: wallpaper(providerPriority: false),
      image: image,
      providerBackground: branded,
    );
    addTearDown(c.dispose);
    await c.read(wallpaperImageProvider.future);
    expect(c.read(effectiveWallpaperImageProvider), image);
  });

  test('provider background suppresses the own one when priority is on', () {
    final c = container(
      wallpaper: wallpaper(providerPriority: true),
      image: image,
      providerBackground: branded,
    );
    addTearDown(c.dispose);
    expect(c.read(effectiveWallpaperImageProvider), isNull);
  });

  test('own background is a fallback on profiles without one', () async {
    final c = container(
      wallpaper: wallpaper(providerPriority: true),
      image: image,
      providerBackground: null,
    );
    addTearDown(c.dispose);
    await c.read(wallpaperImageProvider.future);
    expect(c.read(effectiveWallpaperImageProvider), image);
  });

  test('disabled own background stays off regardless of priority', () {
    final c = container(
      wallpaper: const WallpaperProps(providerPriority: true),
      image: image,
      providerBackground: null,
    );
    addTearDown(c.dispose);
    expect(c.read(effectiveWallpaperImageProvider), isNull);
  });

  test('missing image resolves to no background', () {
    final c = container(
      wallpaper: wallpaper(providerPriority: true),
      image: null,
      providerBackground: null,
    );
    addTearDown(c.dispose);
    expect(c.read(effectiveWallpaperImageProvider), isNull);
  });

  test('stored configs without the flag keep the old behavior', () {
    expect(WallpaperProps.safeFromJson({}).providerPriority, isFalse);
    expect(
      WallpaperProps.safeFromJson({
        'enabled': true,
        'providerPriority': true,
      }).providerPriority,
      isTrue,
    );
  });
}
