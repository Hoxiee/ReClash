import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

const androidResRoot = 'android/app/src/main/res';

const launcherVariants = <String>[
  'default',
  'pulse',
  'glacier',
  'obsidian',
  'velvet',
  'solar',
  'circuit',
  'echo',
  'shift',
];

const launcherDensities = <String, double>{
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

const adaptiveCanvasDp = 108.0;
const adaptiveSafeRadiusDp = 33.0;
const legacyIconDp = 48.0;

String launcherSuffix(String variant) =>
    variant == 'default' ? '' : '_$variant';

class IconPixels {
  const IconPixels._(this.width, this.height, this._rgba);

  final int width;
  final int height;
  final Uint8List _rgba;

  static Future<IconPixels> read(File file) async {
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = IconPixels._(
      image.width,
      image.height,
      data!.buffer.asUint8List(),
    );
    image.dispose();
    codec.dispose();
    return pixels;
  }

  int alphaAt(int x, int y) => _rgba[(y * width + x) * 4 + 3];

  int get minAlpha {
    var minimum = 255;
    for (var i = 3; i < _rgba.length; i += 4) {
      if (_rgba[i] < minimum) minimum = _rgba[i];
    }
    return minimum;
  }

  ui.Rect get alphaBounds {
    var left = width;
    var top = height;
    var right = 0;
    var bottom = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (alphaAt(x, y) == 0) continue;
        left = math.min(left, x);
        top = math.min(top, y);
        right = math.max(right, x + 1);
        bottom = math.max(bottom, y + 1);
      }
    }
    return ui.Rect.fromLTRB(
      left.toDouble(),
      top.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }

  /// Farthest painted pixel from the canvas centre, as a fraction of the width.
  double get alphaRadius {
    final centerX = (width - 1) / 2;
    final centerY = (height - 1) / 2;
    var radius = 0.0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (alphaAt(x, y) == 0) continue;
        radius = math.max(radius, math.sqrt(
          math.pow(x - centerX, 2) + math.pow(y - centerY, 2),
        ));
      }
    }
    return radius / width;
  }
}

String androidAttribute(String source, String element, String attribute) {
  final tag = RegExp('<$element\\b[^>]*>').firstMatch(source)!.group(0)!;
  return RegExp('android:$attribute="([^"]+)"').firstMatch(tag)!.group(1)!;
}

double? _androidNumber(String tag, String attribute) {
  final match = RegExp('android:$attribute="([^"]+)"').firstMatch(tag);
  return match == null
      ? null
      : double.parse(match.group(1)!.replaceAll('dp', ''));
}

class AndroidVectorIcon {
  const AndroidVectorIcon._(this.sizeDp, this.markRadiusDp, this.markBoundsDp);

  final double sizeDp;

  /// Distance from the icon centre to the farthest stroked point, in dp.
  final double markRadiusDp;

  /// Stroke extents of the mark, round caps included, in dp.
  final ui.Rect markBoundsDp;

  factory AndroidVectorIcon.parse(String source) {
    final header = RegExp(r'<vector\b[^>]*>').firstMatch(source)!.group(0)!;
    final sizeDp = _androidNumber(header, 'width')!;
    final viewportWidth = _androidNumber(header, 'viewportWidth')!;
    final viewportHeight = _androidNumber(header, 'viewportHeight')!;
    var radius = 0.0;
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;
    for (final chunk in source.split('<group').skip(1)) {
      final group = chunk.substring(0, chunk.indexOf('>'));
      final body = chunk.substring(0, chunk.indexOf('</group>'));
      final pivotX = _androidNumber(group, 'pivotX') ?? 0;
      final pivotY = _androidNumber(group, 'pivotY') ?? 0;
      final translateX = (_androidNumber(group, 'translateX') ?? 0) + pivotX;
      final translateY = (_androidNumber(group, 'translateY') ?? 0) + pivotY;
      final scale = _androidNumber(group, 'scaleX') ?? 1;
      final rotation = (_androidNumber(group, 'rotation') ?? 0) * math.pi / 180;
      for (final match in RegExp(r'<path\b[^>]*>').allMatches(body)) {
        final path = match.group(0)!;
        final strokeWidth = _androidNumber(path, 'strokeWidth') ?? 0;
        final data = androidAttribute(path, 'path', 'pathData');
        for (final point in RegExp(
          r'(-?[\d.]+),(-?[\d.]+)',
        ).allMatches(data)) {
          final x = (double.parse(point.group(1)!) - pivotX) * scale;
          final y = (double.parse(point.group(2)!) - pivotY) * scale;
          final dx =
              translateX +
              x * math.cos(rotation) -
              y * math.sin(rotation) -
              viewportWidth / 2;
          final dy =
              translateY +
              x * math.sin(rotation) +
              y * math.cos(rotation) -
              viewportHeight / 2;
          final cap = scale * strokeWidth / 2;
          radius = math.max(radius, math.sqrt(dx * dx + dy * dy) + cap);
          left = math.min(left, viewportWidth / 2 + dx - cap);
          top = math.min(top, viewportHeight / 2 + dy - cap);
          right = math.max(right, viewportWidth / 2 + dx + cap);
          bottom = math.max(bottom, viewportHeight / 2 + dy + cap);
        }
      }
    }
    final toDp = sizeDp / viewportWidth;
    return AndroidVectorIcon._(
      sizeDp,
      radius * toDp,
      ui.Rect.fromLTRB(left * toDp, top * toDp, right * toDp, bottom * toDp),
    );
  }
}
