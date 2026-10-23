import 'dart:ui' show ImageFilter;

import 'package:reclash/ui/button.dart';
import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/liquid_glass.dart';
import 'package:reclash/ui/shape.dart';
import 'package:reclash/ui/surface.dart';
import 'package:reclash/ui/tooltip.dart';
import 'package:reclash/ui/typography.dart';
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  static const double _height = 44;
  static const double _inset = 4;

  final List<(T, String)> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final count = segments.length;
    final index = segments.indexWhere((segment) => segment.$1 == value);
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_inset),
      decoration: ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(colorScheme),
        shape: AppShape.full,
      ),
      child: Stack(
        children: [
          if (index >= 0)
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional(
                count == 1 ? 0 : index * 2 / (count - 1) - 1,
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.primary,
                    shape: AppShape.full,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              for (final (option, label) in segments)
                Expanded(
                  child: Semantics(
                    selected: option == value,
                    button: true,
                    child: FocusRing(
                      shape: AppShape.full,
                      standsOff: option == value,
                      child: Material(
                        type: MaterialType.transparency,
                        shape: AppShape.full,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: AppShape.full,
                          mouseCursor: option == value
                              ? SystemMouseCursors.basic
                              : null,
                          splashFactory: option == value
                              ? NoSplash.splashFactory
                              : null,
                          // A null onTap would unfocus the selected segment.
                          onTap: option == value
                              ? () {}
                              : () => onChanged(option),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppTextStyle.subheadline
                                  .of(context, emphasized: option == value)
                                  .copyWith(
                                    color: option == value
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlyphSegment<T> {
  const GlyphSegment({
    required this.value,
    required this.glyph,
    required this.label,
  });

  final T value;
  final Glyph glyph;
  final String label;
}

/// Bouncy enough for the indicator to land with a little give, which the
/// pages beside it, travelling touching, cannot afford.
final glyphSegmentSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 420),
  bounce: 0.18,
);

/// Moves [position] to [index] along [glyphSegmentSpring], keeping the speed
/// it had when a new index interrupts it.
void springToSegment(
  AnimationController position,
  int index, {
  bool instant = false,
}) {
  if (instant) {
    position.value = index.toDouble();
    return;
  }
  position.animateWith(
    SpringSimulation(
      glyphSegmentSpring,
      position.value,
      index.toDouble(),
      position.velocity,
    ),
  );
}

/// Segments shown as glyphs under one indicator that slides between them;
/// [position] is the segment index it stands on, fractional while it moves,
/// so a title can travel with it.
class GlyphSegmentedControl<T> extends StatelessWidget {
  const GlyphSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.position,
    required this.onChanged,
  });

  static const double _inset = 4;
  static const double _segment = 44;
  static const _size = TonalButtonSize.section;

  final List<GlyphSegment<T>> segments;
  final T value;
  final AnimationController position;
  final ValueChanged<T> onChanged;

  Widget _glyphs(Color color) => IconTheme.merge(
    data: IconThemeData(size: _size.icon, color: color),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final segment in segments)
          SizedBox(
            width: _segment,
            child: Center(
              child: AnimatedGlyph(
                glyph: segment.glyph,
                filled: segment.value == value,
              ),
            ),
          ),
      ],
    ),
  );

  Rect _indicator(TextDirection direction) {
    final last = segments.length - 1;
    final at = position.value;
    // Past either end it squashes against the edge instead of leaving it.
    final overshoot = at < 0 ? -at : (at > last ? at - last : 0.0);
    final stretch = (position.velocity.abs() * 0.035).clamp(0.0, 0.45);
    final width = _segment * (1 + stretch - overshoot * 1.5);
    final height = _size.button * (1 - stretch * 0.18);
    final center = (at.clamp(0, last) + 0.5) * _segment;
    final start = (center - width / 2).clamp(0.0, segments.length * _segment);
    final end = (center + width / 2).clamp(0.0, segments.length * _segment);
    final left = direction == TextDirection.rtl
        ? segments.length * _segment - end
        : start;
    return Rect.fromLTWH(
      left,
      (_size.button - height) / 2,
      end - start,
      height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final direction = Directionality.of(context);
    final track = SizedBox(
      width: segments.length * _segment,
      height: _size.button,
      child: Stack(
        children: [
          _glyphs(colorScheme.onSurfaceVariant),
          AnimatedBuilder(
            animation: position,
            builder: (context, child) {
              final indicator = _indicator(direction);
              return Stack(
                children: [
                  Positioned.fromRect(
                    rect: indicator,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: colorScheme.primary,
                        shape: AppShape.full,
                      ),
                    ),
                  ),
                  ClipPath(clipper: _IndicatorClipper(indicator), child: child),
                ],
              );
            },
            child: _glyphs(colorScheme.onPrimary),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final segment in segments)
                _GlyphSegmentTarget(
                  label: segment.label,
                  selected: segment.value == value,
                  width: _segment,
                  height: _size.button,
                  onPressed: () => onChanged(segment.value),
                ),
            ],
          ),
        ],
      ),
    );
    final padded = Padding(padding: const EdgeInsets.all(_inset), child: track);
    return TonalButtonTheme.glassOf(context)
        ? LiquidGlass(
            style: LiquidGlassStyle.regular(colorScheme),
            child: padded,
          )
        : DecoratedBox(
            decoration: ShapeDecoration(
              color: context.raisedSurfaceLevel.colorOf(colorScheme),
              shape: AppShape.full,
            ),
            child: padded,
          );
  }
}

class _IndicatorClipper extends CustomClipper<Path> {
  const _IndicatorClipper(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) => AppShape.full.getOuterPath(rect);

  @override
  bool shouldReclip(_IndicatorClipper oldClipper) => rect != oldClipper.rect;
}

class _GlyphSegmentTarget extends StatelessWidget {
  const _GlyphSegmentTarget({
    required this.label,
    required this.selected,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final double width;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppTooltip(
    message: label,
    child: Semantics(
      label: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: FocusRing(
        shape: AppShape.full,
        standsOff: selected,
        child: Material(
          type: MaterialType.transparency,
          shape: AppShape.full,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: AppShape.full,
            mouseCursor: selected ? SystemMouseCursors.basic : null,
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: selected ? Colors.transparent : null,
            // A null onTap would unfocus the selected segment.
            onTap: selected ? () {} : onPressed,
            child: SizedBox(width: width, height: height),
          ),
        ),
      ),
    ),
  );
}

/// Labels stacked like an odometer: each rolls through as [position] passes
/// its index, the next arriving from below while moving forward.
class RollingTitle extends StatelessWidget {
  const RollingTitle({super.key, required this.labels, required this.position});

  final List<String> labels;
  final Animation<double> position;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: position,
    builder: (context, _) {
      final at = position.value;
      final nearest = at.round().clamp(0, labels.length - 1);
      return Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          for (var index = 0; index < labels.length; index++)
            if ((at - index).abs() < 1 || index == nearest)
              _rolling(labels[index], at - index, index == nearest),
        ],
      );
    },
  );

  Widget _rolling(String label, double distance, bool current) {
    final away = distance.abs().clamp(0.0, 1.0);
    return FractionalTranslation(
      translation: Offset(0, -distance * 0.9),
      child: Transform.scale(
        scale: 1 - away * 0.12,
        alignment: AlignmentDirectional.centerStart,
        child: Opacity(
          opacity: (1 - away * 1.4).clamp(0.0, 1.0),
          child: ImageFiltered(
            enabled: away > 0,
            imageFilter: ImageFilter.blur(sigmaY: away * 8),
            child: ExcludeSemantics(
              excluding: !current,
              child: Text(label, maxLines: 1, softWrap: false),
            ),
          ),
        ),
      ),
    );
  }
}
