import 'package:reclash/common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Telegram-style QR: connected corner-rounded modules over a theme gradient.
/// Always encoded at level H so the blanked region under [logo] stays decodable.
class StyledQrCode extends StatelessWidget {
  const StyledQrCode({
    required this.data,
    this.size = 220,
    this.gradient,
    this.backgroundColor = Colors.white,
    this.logo,
    this.logoSizeRatio = 0.22,
    this.padding = 16,
    super.key,
  });

  final String data;
  final double size;
  final Gradient? gradient;
  final Color backgroundColor;
  final Widget? logo;
  final double logoSizeRatio;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final QrImage image;
    try {
      image = QrImage(
        QrCode.fromData(
          data: data,
          errorCorrectLevel: QrErrorCorrectLevel.H,
        ),
      );
    } on Object {
      // The only expected failure is data that overflows the largest symbol.
      return SizedBox.square(dimension: size);
    }
    final resolved = gradient ?? _themeGradient(context.colorScheme);
    final ratio = logo == null ? 0.0 : logoSizeRatio;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StyledQrPainter(
                image: image,
                gradient: resolved,
                background: backgroundColor,
                padding: padding,
                logoRatio: ratio,
              ),
            ),
          ),
          if (logo != null)
            SizedBox.square(
              dimension: size * logoSizeRatio,
              child: FittedBox(child: logo),
            ),
        ],
      ),
    );
  }
}

Gradient _themeGradient(ColorScheme scheme) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkenForContrast(scheme.primary), _darkenForContrast(scheme.tertiary)],
  );
}

// Darkens an endpoint until it reads on the light background; hue stays.
Color _darkenForContrast(Color color) {
  var out = color;
  for (var guard = 0; guard < 8 && out.computeLuminance() > 0.4; guard++) {
    out = Color.lerp(out, Colors.black, 0.2)!;
  }
  return out;
}

class _StyledQrPainter extends CustomPainter {
  _StyledQrPainter({
    required this.image,
    required this.gradient,
    required this.background,
    required this.padding,
    required this.logoRatio,
  });

  final QrImage image;
  final Gradient gradient;
  final Color background;
  final double padding;
  final double logoRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final content = size.shortestSide - padding * 2;
    if (content <= 0 || count == 0) {
      return;
    }
    final cell = content / count;
    final origin = padding;
    final contentRect = Rect.fromLTWH(origin, origin, content, content);
    final center = size.center(Offset.zero);
    final logoSide = logoRatio <= 0 ? 0.0 : size.width * logoRatio * 1.25;
    final logoRect = Rect.fromCenter(
      center: center,
      width: logoSide,
      height: logoSide,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppCorner.lg),
      ),
      Paint()
        ..color = background
        ..isAntiAlias = true,
    );

    bool solid(int r, int c) {
      if (r < 0 || c < 0 || r >= count || c >= count) {
        return false;
      }
      if (_isFinder(r, c, count) || !image.isDark(r, c)) {
        return false;
      }
      final cx = origin + c * cell + cell / 2;
      final cy = origin + r * cell + cell / 2;
      return !logoRect.contains(Offset(cx, cy));
    }

    final radius = cell / 2;
    final modules = Path();
    for (var r = 0; r < count; r++) {
      for (var c = 0; c < count; c++) {
        if (!solid(r, c)) {
          continue;
        }
        final rect = Rect.fromLTWH(origin + c * cell, origin + r * cell, cell, cell);
        modules.addRRect(
          RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(!solid(r, c - 1) && !solid(r - 1, c) ? radius : 0.0),
            topRight: Radius.circular(!solid(r, c + 1) && !solid(r - 1, c) ? radius : 0.0),
            bottomLeft: Radius.circular(!solid(r, c - 1) && !solid(r + 1, c) ? radius : 0.0),
            bottomRight: Radius.circular(!solid(r, c + 1) && !solid(r + 1, c) ? radius : 0.0),
          ),
        );
      }
    }

    final frames = Path()..fillType = PathFillType.evenOdd;
    final dots = Path();
    for (final anchor in [
      [0, 0],
      [0, -7],
      [-7, 0],
    ]) {
      final fr = anchor[0] < 0 ? count + anchor[0] : anchor[0];
      final fc = anchor[1] < 0 ? count + anchor[1] : anchor[1];
      frames
        ..addRRect(_cellRRect(origin, cell, fr, fc, 7, cell * 2))
        ..addRRect(_cellRRect(origin, cell, fr + 1, fc + 1, 5, cell * 1.4));
      dots.addRRect(_cellRRect(origin, cell, fr + 2, fc + 2, 3, cell * 0.9));
    }

    final fill = Paint()
      ..isAntiAlias = true
      ..shader = gradient.createShader(contentRect);
    canvas
      ..drawPath(modules, fill)
      ..drawPath(frames, fill)
      ..drawPath(dots, fill);

    if (logoSide > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(logoRect, Radius.circular(cell * 1.5)),
        Paint()
          ..color = background
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_StyledQrPainter old) {
    return old.image != image ||
        old.gradient != gradient ||
        old.background != background ||
        old.padding != padding ||
        old.logoRatio != logoRatio;
  }
}

bool _isFinder(int r, int c, int count) {
  return (r < 7 && c < 7) ||
      (r < 7 && c >= count - 7) ||
      (r >= count - 7 && c < 7);
}

RRect _cellRRect(double origin, double cell, int r, int c, int span, double radius) {
  return RRect.fromRectAndRadius(
    Rect.fromLTWH(origin + c * cell, origin + r * cell, span * cell, span * cell),
    Radius.circular(radius),
  );
}

