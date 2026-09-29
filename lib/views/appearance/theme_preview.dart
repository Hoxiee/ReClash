import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/widgets/widgets.dart';

class PreviewChoice<T> {
  const PreviewChoice({
    required this.value,
    required this.label,
    required this.pictogram,
  });

  final T value;
  final String label;
  final Widget pictogram;
}

class PreviewChoiceGroup<T> extends StatelessWidget {
  const PreviewChoiceGroup({
    super.key,
    required this.info,
    required this.choices,
    required this.value,
    required this.onChanged,
  });

  final Info info;
  final List<PreviewChoice<T>> choices;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoHeader(info: info),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in choices)
                _ChoiceButton(
                  label: choice.label,
                  isSelected: choice.value == value,
                  onPressed: () => onChanged(choice.value),
                  pictogram: choice.pictogram,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.pictogram,
  });

  static const double _height = 48;

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget pictogram;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _height),
        child: CommonCard(
          isSelected: isSelected,
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ExcludeSemantics(child: pictogram),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The foot of a [MiniScreen], where the options differ, drawn at the size of
/// an icon.
class MiniScreenThumb extends StatelessWidget {
  const MiniScreenThumb({
    super.key,
    required this.screen,
    this.alignment = Alignment.bottomCenter,
  });

  static const Size _screenSize = Size(96, 128);
  static const double _shownHeight = 66;
  static const double _height = 30;

  final Widget screen;

  /// Which slice of the taller [screen] the fixed-height thumbnail reveals.
  /// The hero layout differs at the top, so its chooser crops from there.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final shape = AppShape.sm.copyWith(
      side: BorderSide(color: context.colorScheme.outlineVariant),
    );
    return SizedBox(
      height: _height,
      width: _height * _screenSize.width / _shownHeight,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(shape: shape),
        child: ClipRSuperellipse(
          borderRadius: AppRadius.sm,
          child: FittedBox(
            child: SizedBox(
              width: _screenSize.width,
              height: _shownHeight,
              child: ClipRect(
                child: OverflowBox(
                  alignment: alignment,
                  minHeight: _screenSize.height,
                  maxHeight: _screenSize.height,
                  child: screen,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A phone-shaped frame around a [MiniScreen], bordered like the device edge.
class MiniScreenFrame extends StatelessWidget {
  const MiniScreenFrame({super.key, required this.screen});

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // fit() picks xxl at these widths, which reads as a soap-bar
        // blob; cap at a phone-like radius.
        final corner = math.min(
          AppCorner.fit(constraints.maxWidth),
          AppCorner.md,
        );
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShapeDecoration(
            shape: AppShape.all(corner).copyWith(
              side: BorderSide(color: context.colorScheme.outlineVariant),
            ),
          ),
          child: ClipRSuperellipse(
            borderRadius: AppRadius.all(corner),
            child: screen,
          ),
        );
      },
    );
  }
}

/// A phone-shaped sketch of the home page, drawn in [colorScheme].
class MiniScreen extends StatelessWidget {
  const MiniScreen({super.key, required this.colorScheme, this.hero = false});

  static const int destinationCount = 4;

  final ColorScheme colorScheme;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final unit = width / 20;
        final margin = unit * 1.4;
        final barHeight = unit * 2.9;
        final fabSize = unit * 2.9;
        final statusTop = unit * 1.1;
        final contentTop = statusTop + unit * 1.9;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(
                  colorScheme.surfaceTint.withValues(alpha: hero ? 0.06 : 0),
                  colorScheme.surface,
                ),
                colorScheme.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: statusTop,
                left: margin,
                right: margin,
                child: _MiniStatusBar(colorScheme: colorScheme, unit: unit),
              ),
              Positioned(
                top: contentTop,
                left: margin,
                right: margin,
                bottom: margin + barHeight + unit * 0.6,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: _MiniPageContent(
                      colorScheme: colorScheme,
                      hero: hero,
                      unit: unit,
                    ),
                  ),
                ),
              ),
              // The hero dashboard has no start FAB; its orb owns the
              // control, so the nav bar spans the full width there.
              Positioned(
                left: margin,
                right: hero ? margin : margin + fabSize + unit * 0.6,
                bottom: margin,
                height: barHeight,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: AppShape.full,
                  ),
                  child: _MiniDestinations(
                    colorScheme: colorScheme,
                    unit: unit,
                  ),
                ),
              ),
              if (!hero)
                Positioned(
                  right: margin,
                  bottom: margin,
                  width: fabSize,
                  height: fabSize,
                  child: _MiniFab(colorScheme: colorScheme, unit: unit),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MiniSplitScreen extends StatelessWidget {
  const MiniSplitScreen({super.key, required this.light, required this.dark});

  final Widget light;
  final Widget dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        light,
        ClipPath(clipper: _DiagonalClipper(), child: dark),
      ],
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

/// The thin top strip: a clock and a couple of indicators, just enough to read
/// as a phone rather than a floating panel.
class _MiniStatusBar extends StatelessWidget {
  const _MiniStatusBar({required this.colorScheme, required this.unit});

  final ColorScheme colorScheme;
  final double unit;

  @override
  Widget build(BuildContext context) {
    final ink = colorScheme.onSurface.withValues(alpha: 0.32);
    return SizedBox(
      height: unit * 1.1,
      child: Row(
        children: [
          _MiniLine(color: ink, width: unit * 2.4, height: unit * 0.7),
          const Spacer(),
          _MiniDot(color: ink, size: unit * 0.7),
          SizedBox(width: unit * 0.45),
          Container(
            width: unit * 1.7,
            height: unit * 0.85,
            decoration: ShapeDecoration(
              color: ink,
              shape: AppShape.all(AppCorner.fit(unit)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPageContent extends StatelessWidget {
  const _MiniPageContent({
    required this.colorScheme,
    required this.hero,
    required this.unit,
  });

  final ColorScheme colorScheme;
  final bool hero;
  final double unit;

  Color get _strong => colorScheme.onSurface.withValues(alpha: 0.78);
  Color get _mid => colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
  Color get _faint => colorScheme.onSurfaceVariant.withValues(alpha: 0.32);

  @override
  Widget build(BuildContext context) {
    return hero ? _heroColumn() : _classicColumn();
  }

  // The classic dashboard: a title, then an arrangeable grid of widget tiles.
  Widget _classicColumn() {
    final tile = colorScheme.surfaceContainer;
    Widget iconTile(Color accent) =>
        _MiniTile(color: tile, accent: accent, unit: unit, lineColor: _mid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _MiniLine(color: _strong, width: unit * 5, height: unit * 1.2),
            const Spacer(),
            _MiniDot(color: colorScheme.surfaceContainerHigh, size: unit * 2),
          ],
        ),
        SizedBox(height: unit * 1.3),
        SizedBox(
          height: unit * 7,
          child: Row(
            spacing: unit,
            children: [
              Expanded(child: iconTile(colorScheme.primaryContainer)),
              Expanded(child: iconTile(colorScheme.tertiaryContainer)),
            ],
          ),
        ),
        SizedBox(height: unit),
        SizedBox(
          height: unit * 5.6,
          child: _MiniTile(
            color: tile,
            accent: colorScheme.secondaryContainer,
            unit: unit,
            lineColor: _mid,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniLine(color: _mid, width: unit * 5, height: unit * 0.9),
                SizedBox(height: unit * 0.8),
                Expanded(
                  child: _MiniBars(color: colorScheme.primary, unit: unit),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: unit),
        SizedBox(
          height: unit * 7,
          child: Row(
            spacing: unit,
            children: [
              Expanded(
                child: iconTile(colorScheme.primary.withValues(alpha: 0.85)),
              ),
              Expanded(
                child: iconTile(colorScheme.tertiary.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // The new dashboard: the connection ring up top, live traffic below it.
  Widget _heroColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: unit * 0.4),
        Center(
          child: _MiniOrb(
            color: colorScheme.primary,
            size: unit * 8.2,
            stroke: unit * 0.7,
          ),
        ),
        SizedBox(height: unit * 1.3),
        Center(
          child: _MiniLine(color: _strong, width: unit * 6, height: unit * 1.1),
        ),
        SizedBox(height: unit * 0.7),
        Center(
          child: _MiniLine(
            color: _faint,
            width: unit * 3.6,
            height: unit * 0.7,
          ),
        ),
        SizedBox(height: unit * 1.2),
        _trafficCard(),
        SizedBox(height: unit * 0.9),
        Row(
          spacing: unit,
          children: [
            Expanded(child: _pillChip()),
            Expanded(child: _pillChip()),
          ],
        ),
      ],
    );
  }

  Widget _trafficCard() {
    return _MiniCard(
      color: colorScheme.surfaceContainer,
      height: unit * 6.6,
      unit: unit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _trafficStat(colorScheme.primary),
              const Spacer(),
              _trafficStat(colorScheme.tertiary),
            ],
          ),
          SizedBox(height: unit * 0.8),
          Expanded(child: _MiniSparkline(color: colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _trafficStat(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniDot(color: color, size: unit * 1),
        SizedBox(width: unit * 0.6),
        _MiniLine(color: _mid, width: unit * 3, height: unit * 0.8),
      ],
    );
  }

  Widget _pillChip() {
    return SizedBox(
      height: unit * 2.6,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerHigh,
          shape: AppShape.full,
        ),
        child: Center(
          child: _MiniLine(color: _mid, width: unit * 3, height: unit * 0.8),
        ),
      ),
    );
  }
}

class _MiniDestinations extends StatelessWidget {
  const _MiniDestinations({required this.colorScheme, required this.unit});

  final ColorScheme colorScheme;
  final double unit;

  Widget _buildDestination(int index) {
    if (index != 0) {
      return _MiniDot(color: colorScheme.onSurfaceVariant, size: unit * 0.9);
    }
    return Container(
      width: unit * 2.8,
      height: unit * 1.6,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: colorScheme.secondaryContainer,
        shape: AppShape.full,
      ),
      child: _MiniDot(
        color: colorScheme.onSecondaryContainer,
        size: unit * 0.9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < MiniScreen.destinationCount; i++)
          Expanded(child: Center(child: _buildDestination(i))),
      ],
    );
  }
}

/// The launch button: a filled disc carrying a small power glyph.
class _MiniFab extends StatelessWidget {
  const _MiniFab({required this.colorScheme, required this.unit});

  final ColorScheme colorScheme;
  final double unit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colorScheme.primaryContainer,
        shape: AppShape.full,
      ),
      child: Center(
        child: SizedBox.square(
          dimension: unit * 1.4,
          child: CustomPaint(
            painter: _PowerGlyphPainter(colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}

class _PowerGlyphPainter extends CustomPainter {
  _PowerGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.16;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.36;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gap = 0.9;
    canvas.drawArc(
      rect,
      -math.pi / 2 + gap / 2,
      math.pi * 2 - gap,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 1.05),
      Offset(center.dx, center.dy - radius * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PowerGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// One card in the classic grid: a tinted icon chip over two text lines, or a
/// caller-supplied [child].
class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.color,
    required this.accent,
    required this.unit,
    required this.lineColor,
    this.child,
  });

  final Color color;
  final Color accent;
  final double unit;
  final Color lineColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(unit * 0.9),
      decoration: ShapeDecoration(
        color: color,
        shape: AppShape.all(AppCorner.fit(unit * 7)),
      ),
      child:
          child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: unit * 2.2,
                height: unit * 2.2,
                decoration: ShapeDecoration(
                  color: accent,
                  shape: AppShape.all(AppCorner.fit(unit * 2.2)),
                ),
              ),
              const Spacer(),
              _MiniLine(
                color: lineColor,
                width: unit * 4.5,
                height: unit * 0.8,
              ),
              SizedBox(height: unit * 0.5),
              _MiniLine(
                color: lineColor,
                width: unit * 2.8,
                height: unit * 0.6,
              ),
            ],
          ),
    );
  }
}

/// A short row of rising bars, standing in for a stat or traffic widget. The
/// bars scale to the height they are given so the tile never overflows.
class _MiniBars extends StatelessWidget {
  const _MiniBars({required this.color, required this.unit});

  final Color color;
  final double unit;

  static const _factors = [0.42, 0.62, 0.5, 0.82, 0.66, 1.0];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = constraints.maxHeight;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _factors.length; i++) ...[
              if (i > 0) SizedBox(width: unit * 0.5),
              Container(
                width: unit * 0.9,
                height: extent * _factors[i],
                decoration: ShapeDecoration(
                  color: color.withValues(alpha: 0.32 + i * 0.11),
                  shape: AppShape.all(AppCorner.fit(unit)),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.color,
    required this.height,
    required this.unit,
    this.child,
  });

  final Color color;
  final double height;
  final double unit;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: _MiniBlock(
        color: color,
        extent: height,
        padding: EdgeInsets.all(unit),
        child: child,
      ),
    );
  }
}

class _MiniBlock extends StatelessWidget {
  const _MiniBlock({
    required this.color,
    required this.extent,
    this.padding,
    this.child,
  });

  final Color color;
  final double extent;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: color,
        shape: AppShape.all(AppCorner.fit(extent)),
      ),
      child: child,
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(color: color, shape: AppShape.circle),
    );
  }
}

/// The connection ring: a glowing halo, a stroked ring, and a solid core.
class _MiniOrb extends StatelessWidget {
  const _MiniOrb({
    required this.color,
    required this.size,
    required this.stroke,
  });

  final Color color;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.32),
                    color.withValues(alpha: 0),
                  ],
                  stops: const [0.35, 1],
                ),
              ),
            ),
          ),
          Container(
            width: size * 0.74,
            height: size * 0.74,
            decoration: ShapeDecoration(
              shape: AppShape.circle.copyWith(
                side: BorderSide(color: color, width: stroke),
              ),
            ),
          ),
          SizedBox(
            width: size * 0.3,
            height: size * 0.3,
            child: DecoratedBox(
              decoration: ShapeDecoration(color: color, shape: AppShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

/// A filled area sparkline standing in for the live traffic trace.
class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(color),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.color);

  final Color color;

  static const _points = [0.3, 0.5, 0.35, 0.62, 0.45, 0.72, 0.55, 0.88, 0.7];

  @override
  void paint(Canvas canvas, Size size) {
    final line = Path();
    for (var i = 0; i < _points.length; i++) {
      final x = size.width * i / (_points.length - 1);
      final y = size.height * (1 - _points[i]);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.16));
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.07
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
