import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/android_launcher_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TV launcher icons meet density-specific minimum sizes', () async {
    const expectedSizes = {
      'mdpi': 80,
      'hdpi': 120,
      'xhdpi': 160,
      'xxhdpi': 240,
      'xxxhdpi': 320,
    };

    for (final MapEntry(key: density, value: size) in expectedSizes.entries) {
      final file = File(
        '$androidResRoot/mipmap-television-$density/ic_launcher.webp',
      );
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');

      final pixels = await IconPixels.read(file);
      expect((pixels.width, pixels.height), (size, size), reason: file.path);
    }
  });

  test('TV adaptive icon reuses the phone layers and stays centred', () {
    final adaptiveIcon = File(
      '$androidResRoot/mipmap-television-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(
      androidAttribute(adaptiveIcon, 'background', 'drawable'),
      '@drawable/ic_launcher_default_background',
    );
    expect(
      androidAttribute(adaptiveIcon, 'foreground', 'drawable'),
      '@drawable/ic_launcher_foreground_tv',
    );
    expect(
      androidAttribute(adaptiveIcon, 'monochrome', 'drawable'),
      '@drawable/ic_launcher_default_monochrome',
    );

    final vector = AndroidVectorIcon.parse(
      File(
        '$androidResRoot/drawable/ic_launcher_foreground_tv.xml',
      ).readAsStringSync(),
    );
    expect(vector.sizeDp, adaptiveCanvasDp);
    expect(vector.markRadiusDp, lessThanOrEqualTo(adaptiveSafeRadiusDp));
  });

  test('leanback banner ships opaque at 320x180', () async {
    final pixels = await IconPixels.read(
      File('$androidResRoot/mipmap-xhdpi/ic_banner.png'),
    );
    expect((pixels.width, pixels.height), (320, 180));
    expect(pixels.minAlpha, 255);
  });
}
