import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import 'helpers/android_launcher_icons.dart';

File _adaptiveLayer(String density, String variant, String layer) => File(
  '$androidResRoot/drawable-$density/ic_launcher_${variant}_$layer.webp',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('phone legacy launchers keep the shared square grid', () async {
    for (final MapEntry(key: density, value: scale)
        in launcherDensities.entries) {
      final size = (legacyIconDp * scale).round();
      final square = (size * 38 / 48).roundToDouble();
      final inset = ((size - square) / 2).floorToDouble();
      for (final variant in launcherVariants) {
        final file = File(
          '$androidResRoot/mipmap-$density/'
          'ic_launcher${launcherSuffix(variant)}.webp',
        );
        final pixels = await IconPixels.read(file);
        expect((pixels.width, pixels.height), (size, size), reason: file.path);
        expect(
          pixels.alphaBounds,
          ui.Rect.fromLTWH(inset, inset, square, square),
          reason: file.path,
        );
      }
    }
  });

  test('adaptive backgrounds paint the whole canvas', () async {
    for (final MapEntry(key: density, value: scale)
        in launcherDensities.entries) {
      final size = (adaptiveCanvasDp * scale).round();
      for (final variant in launcherVariants) {
        final file = _adaptiveLayer(density, variant, 'background');
        final pixels = await IconPixels.read(file);
        expect((pixels.width, pixels.height), (size, size), reason: file.path);
        expect(pixels.minAlpha, 255, reason: file.path);
      }
    }
  });

  test('adaptive foregrounds hold the mark inside the safe zone', () async {
    for (final density in launcherDensities.keys) {
      for (final variant in launcherVariants) {
        final file = _adaptiveLayer(density, variant, 'foreground');
        final pixels = await IconPixels.read(file);
        expect(pixels.alphaAt(0, 0), 0, reason: file.path);
        expect(
          pixels.alphaRadius * adaptiveCanvasDp,
          lessThanOrEqualTo(adaptiveSafeRadiusDp),
          reason: file.path,
        );
      }
    }
  });

  test('adaptive XML wires all three layers of every variant', () {
    for (final variant in launcherVariants) {
      final file = File(
        '$androidResRoot/mipmap-anydpi-v26/'
        'ic_launcher${launcherSuffix(variant)}.xml',
      );
      final xml = file.readAsStringSync();
      for (final layer in ['background', 'foreground', 'monochrome']) {
        expect(
          androidAttribute(xml, layer, 'drawable'),
          '@drawable/ic_launcher_${variant}_$layer',
          reason: file.path,
        );
      }
    }
  });

  test('monochrome vectors hold the mark inside the safe zone', () {
    for (final variant in launcherVariants) {
      final file = File(
        '$androidResRoot/drawable/ic_launcher_${variant}_monochrome.xml',
      );
      final vector = AndroidVectorIcon.parse(file.readAsStringSync());
      expect(vector.sizeDp, adaptiveCanvasDp, reason: file.path);
      expect(
        vector.markRadiusDp,
        lessThanOrEqualTo(adaptiveSafeRadiusDp),
        reason: file.path,
      );
    }
  });

  test('splash mark stays inside the Android 12 icon circle', () {
    final file = File('$androidResRoot/drawable/ic_launcher_foreground.xml');
    final vector = AndroidVectorIcon.parse(file.readAsStringSync());
    // A splash icon without its own background is drawn on a 288dp canvas and
    // masked to the inner 192dp circle.
    expect(vector.sizeDp, 288);
    expect(vector.markRadiusDp, lessThanOrEqualTo(96));
  });

  test('store icon ships opaque at the required 512 px', () async {
    final pixels = await IconPixels.read(
      File('android/app/src/main/ic_launcher-playstore.png'),
    );
    expect((pixels.width, pixels.height), (512, 512));
    expect(pixels.minAlpha, 255);
  });
}
