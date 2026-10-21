import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

String _androidAttribute(String source, String element, String attribute) {
  final elementTag = RegExp('<$element\\b[^>]*>').firstMatch(source)!.group(0)!;
  return RegExp(
    'android:$attribute="([^"]+)"',
  ).firstMatch(elementTag)!.group(1)!;
}

double _androidDoubleAttribute(
  String source,
  String element,
  String attribute,
) {
  return double.parse(_androidAttribute(source, element, attribute));
}

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
        'android/app/src/main/res/'
        'mipmap-television-$density/ic_launcher.webp',
      );
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');

      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      expect(
        (frame.image.width, frame.image.height),
        (size, size),
        reason: file.path,
      );
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('TV banner is an opaque 320 by 180 launcher tile', () async {
    final file = File('android/app/src/main/res/mipmap-xhdpi/ic_banner.png');
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    final frame = await codec.getNextFrame();
    try {
      expect((frame.image.width, frame.image.height), (320, 180));
      final data = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      expect(data, isNotNull);
      final pixels = data!.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      expect([
        for (var index = 3; index < pixels.length; index += 4) pixels[index],
      ], everyElement(255));
    } finally {
      frame.image.dispose();
      codec.dispose();
    }
  });

  test(
    'Android adaptive launcher layers stay inside the circular safe zone',
    () {
      for (final (directory, name, foreground) in [
        ('mipmap-anydpi-v26', 'ic_launcher', 'ic_launcher_foreground'),
        ('mipmap-anydpi-v26', 'ic_launcher_round', 'ic_launcher_foreground'),
        (
          'mipmap-television-anydpi-v26',
          'ic_launcher',
          'ic_launcher_foreground_tv',
        ),
      ]) {
        final adaptiveIcon = File(
          'android/app/src/main/res/$directory/$name.xml',
        ).readAsStringSync();
        expect(
          _androidAttribute(adaptiveIcon, 'foreground', 'drawable'),
          '@drawable/$foreground',
        );
        expect(
          _androidAttribute(adaptiveIcon, 'background', 'drawable'),
          '@color/ic_launcher_background',
        );
        expect(
          _androidAttribute(adaptiveIcon, 'monochrome', 'drawable'),
          '@drawable/ic_launcher_monochrome',
        );
      }

      for (final name in [
        'ic_launcher_foreground',
        'ic_launcher_foreground_tv',
        'ic_launcher_monochrome',
      ]) {
        final vector = File(
          'android/app/src/main/res/drawable/$name.xml',
        ).readAsStringSync();
        final scaleX = _androidDoubleAttribute(vector, 'group', 'scaleX');
        final scaleY = _androidDoubleAttribute(vector, 'group', 'scaleY');
        final translateX = _androidDoubleAttribute(
          vector,
          'group',
          'translateX',
        );
        final translateY = _androidDoubleAttribute(
          vector,
          'group',
          'translateY',
        );
        final viewportWidth = _androidDoubleAttribute(
          vector,
          'vector',
          'viewportWidth',
        );
        final viewportHeight = _androidDoubleAttribute(
          vector,
          'vector',
          'viewportHeight',
        );

        const logoBounds = ui.Rect.fromLTRB(-144.31, -161.96, 147.21, 159.52);
        final transformedBounds = ui.Rect.fromLTRB(
          (logoBounds.left * scaleX + translateX) / viewportWidth * 108,
          (logoBounds.top * scaleY + translateY) / viewportHeight * 108,
          (logoBounds.right * scaleX + translateX) / viewportWidth * 108,
          (logoBounds.bottom * scaleY + translateY) / viewportHeight * 108,
        );
        const safeCenter = ui.Offset(54, 54);
        const safeRadius = 33.0;

        expect(scaleX, scaleY, reason: name);
        for (final corner in [
          transformedBounds.topLeft,
          transformedBounds.topRight,
          transformedBounds.bottomLeft,
          transformedBounds.bottomRight,
        ]) {
          expect(
            (corner - safeCenter).distance,
            lessThanOrEqualTo(safeRadius),
            reason: name,
          );
        }
        expect(transformedBounds.center.dx, closeTo(safeCenter.dx, 0.05));
        expect(transformedBounds.center.dy, closeTo(safeCenter.dy, 0.05));
      }
    },
  );
}
