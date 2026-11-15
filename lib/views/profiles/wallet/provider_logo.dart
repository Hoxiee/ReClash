import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/branding/brand.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/icon.dart';

import 'status.dart';

const _traceStroke = 3.0;
const _traceShare = 0.25;

/// The fill of chips and tiles on a brand surface: a veil of the text color,
/// so the provider's hue shows through where a level's gray would flatten it.
Color walletVeil(ColorScheme scheme) => scheme.onSurface.withValues(
  alpha: scheme.brightness == Brightness.dark ? 0.08 : 0.05,
);

/// The small subscription-kind tag beside a profile's name.
class WalletKindChip extends StatelessWidget {
  const WalletKindChip({super.key, required this.kind});

  final SubscriptionKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: AppShape.sm,
        color: walletVeil(scheme),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          kind.label,
          maxLines: 1,
          style: AppTextStyle.caption2
              .of(context, emphasized: true)
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// A profile's mark: the provider's logo on a neutral well, else its monogram
/// on the brand's well; a file or custom profile gets a glyph.
class WalletLogo extends ConsumerWidget {
  const WalletLogo({super.key, required this.profile, required this.size});

  final Profile profile;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;
    final brightness = scheme.brightness;
    final isUrl = profile.type == ProfileType.url;
    final expired =
        walletFactsOf(profile, DateTime.now()).state == WalletState.expired;
    final updating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final brand = isUrl
        ? ref.watch(profileBrandProvider(profile.id)).value
        : null;
    final color = walletBrandColor(profile, brand);
    final tint = color == null ? null : BrandTint(color);
    final logo = brand?.logoFor(dark: brightness == Brightness.dark);
    final neutralWell = context.surfaceLevel.next.colorOf(scheme);
    final monogram = isUrl && logo == null;
    final well = monogram && tint != null ? tint.well(brightness) : neutralWell;
    final foreground = monogram && tint != null
        ? tint.onWell(brightness)
        : scheme.onSurfaceVariant;
    final radius = size * 0.31;
    final letters = Text(
      profileMonogram(profile.realLabel),
      maxLines: 1,
      style: AppTextStyle.custom(
        context,
        size: size * 0.36,
        leading: size * 0.44,
        weight: FontWeight.w700,
      ).copyWith(color: foreground),
    );
    final Widget mark;
    if (!isUrl) {
      mark = GlyphIcon(
        profile.type == ProfileType.custom
            ? AppGlyphs.layers
            : AppGlyphs.importFile,
        size: size * 0.48,
        color: foreground,
      );
    } else if (logo == null) {
      mark = letters;
    } else {
      // Touch icons are full-bleed squares meant to be masked; SVG marks
      // carry no margin of their own.
      final side = logo.svg ? size * 0.64 : size;
      mark = SizedBox.square(
        dimension: side,
        child: IconTheme.merge(
          data: IconThemeData(size: side),
          child: CommonTargetIcon(
            src: logo.src,
            fallback: Center(child: letters),
          ),
        ),
      );
    }
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: expired ? 0.5 : 1,
              child: Container(
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: AppShape.all(radius),
                  color: well,
                ),
                child: mark,
              ),
            ),
          ),
          if (updating)
            Positioned.fill(
              child: IgnorePointer(
                child: _SyncTrace(
                  radius: radius,
                  color: tint?.accent(brightness) ?? scheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SyncTrace extends StatefulWidget {
  const _SyncTrace({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  State<_SyncTrace> createState() => _SyncTraceState();
}

class _SyncTraceState extends State<_SyncTrace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TracePainter(
        progress: _controller,
        radius: widget.radius,
        color: widget.color,
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.progress,
    required this.radius,
    required this.color,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = AppShape.all(
      radius,
    ).getOuterPath((Offset.zero & size).deflate(_traceStroke / 2));
    final metrics = outline.computeMetrics().toList();
    final length = metrics.fold<double>(0, (sum, m) => sum + m.length);
    if (length == 0) {
      return;
    }
    final start = progress.value * length;
    final end = start + length * _traceShare;
    final path = Path();
    var offset = 0.0;
    for (final PathMetric metric in metrics) {
      for (final wrap in const [0.0, 1.0]) {
        final from = math.max(start - wrap * length, offset);
        final to = math.min(end - wrap * length, offset + metric.length);
        if (to > from) {
          path.addPath(
            metric.extractPath(from - offset, to - offset),
            Offset.zero,
          );
        }
      }
      offset += metric.length;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _traceStroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TracePainter oldDelegate) =>
      radius != oldDelegate.radius || color != oldDelegate.color;
}
