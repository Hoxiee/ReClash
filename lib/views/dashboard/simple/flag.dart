import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

final _flagEmoji = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true);

const _regionalIndicatorA = 0x1F1E6;

String? countryCodeOfName(String name) {
  final flag = _flagEmoji.firstMatch(name)?.group(0);
  if (flag == null) return null;
  return String.fromCharCodes([
    for (final rune in flag.runes) rune - _regionalIndicatorA + 0x61,
  ]);
}

/// [name] without its flag emoji, unless nothing else is left.
String nameWithoutFlag(String name) {
  final plain = name.replaceAll(_flagEmoji, '').trim();
  return plain.isEmpty ? name : plain;
}

final _pictographs = RegExp(
  r'[\u{1F000}-\u{1FAFF}\u{2190}-\u{2BFF}\u{FE0F}\u{200D}\u{20E3}]+',
  unicode: true,
);

final _edgeSeparators = RegExp(r'^[\s|·•,:_-]+|[\s|·•,:_-]+$');

/// [name] as words alone, without its flag and the emoji tags providers put
/// around it, unless nothing else is left.
String serverTitle(String name) {
  final title = name
      .replaceAll(_flagEmoji, ' ')
      .replaceAll(_pictographs, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(_edgeSeparators, '');
  return title.isEmpty ? nameWithoutFlag(name) : title;
}

class ShapeFlag extends StatelessWidget {
  const ShapeFlag({
    super.key,
    required this.code,
    required this.size,
    this.shape,
    this.dimmed = false,
  });

  final String? code;
  final double size;
  final RoundedPolygon? shape;

  /// Reads as where traffic would go, not where it goes.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final code = this.code?.toLowerCase();
    final shape = this.shape ?? MaterialShapes.circle;
    final fallback = ShapeBadge(
      shape: shape,
      color: DashboardColors.of(context).tone2,
      size: size,
      child: GlyphIcon(AppGlyphs.language, size: size * 0.46),
    );
    if (code == null || !RegExp(r'^[a-z]{2}$').hasMatch(code)) return fallback;
    final flag = ClipPath(
      clipper: _UnitShapeClipper(shapePathOf(shape)),
      child: SvgPicture.asset(
        'assets/images/flags/$code.svg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => fallback,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: dimmed
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix(_halfGrey),
              child: flag,
            )
          : flag,
    );
  }
}

/// Halfway between the flag's colors and their luminance.
const _halfGrey = <double>[
  0.6063,
  0.3576,
  0.0361,
  0,
  0,
  0.1063,
  0.8576,
  0.0361,
  0,
  0,
  0.1063,
  0.3576,
  0.5361,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

class _UnitShapeClipper extends CustomClipper<Path> {
  const _UnitShapeClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path.transform(
    Matrix4.diagonal3Values(size.width, size.height, 1).storage,
  );

  @override
  bool shouldReclip(_UnitShapeClipper oldClipper) => oldClipper.path != path;
}
