import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/ui.dart';

const _contentMaxWidth = 520.0;
const _badgeSize = 96.0;
const _ringWidth = 6.0;
const _badgeCentre = 0.3;
const _secondaryHeight = 48.0;
const _fadeHeight = 32.0;
const _ctaHeight = 52.0;

/// One step of the report. The badge centre rests at a fixed share of the
/// height and the foot keeps both slots even when empty, so neither the
/// badge nor the main button moves between steps.
class ReportStageLayout extends StatefulWidget {
  const ReportStageLayout({
    super.key,
    required this.hero,
    this.body = const [],
    this.primary,
    this.secondary,
  });

  final Widget hero;
  final List<Widget> body;
  final Widget? primary;
  final Widget? secondary;

  @override
  State<ReportStageLayout> createState() => _ReportStageLayoutState();
}

class _ReportStageLayoutState extends State<ReportStageLayout> {
  final _underFoot = ValueNotifier(false);

  @override
  void dispose() {
    _underFoot.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetrics metrics) {
    _underFoot.value = metrics.extentAfter > 0.5;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scroll = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          math.max(
            context.contentTopPadding,
            constraints.maxHeight * _badgeCentre - _badgeSize / 2,
          ),
          16,
          16,
        ),
        child: _Limit(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [widget.hero, ...widget.body],
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) => _onMetrics(notification.metrics),
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) =>
                  _onMetrics(notification.metrics),
              child: ValueListenableBuilder(
                valueListenable: _underFoot,
                builder: (context, underFoot, child) => ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      underFoot ? Colors.transparent : Colors.white,
                    ],
                    stops: [
                      (1 - _fadeHeight / bounds.height).clamp(0.0, 1.0),
                      1,
                    ],
                  ).createShader(bounds),
                  child: child,
                ),
                child: scroll,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12 + context.bottomInset),
          child: _Limit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: _ctaHeight, child: widget.primary),
                SizedBox(
                  height: _secondaryHeight,
                  child: Center(child: widget.secondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Limit extends StatelessWidget {
  const _Limit({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: child,
      ),
    );
  }
}

/// The badge, a title and an optional line under it, centered.
class ReportHero extends StatelessWidget {
  const ReportHero({
    super.key,
    required this.badge,
    required this.title,
    this.subtitle,
  });

  final Widget badge;
  final String title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          badge,
          const SizedBox(height: 16),
          Text(
            title,
            key: const ValueKey('report-title'),
            textAlign: TextAlign.center,
            style: AppTextStyle.title2.of(context, emphasized: true),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: AppTextStyle.subheadline
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
              child: subtitle,
            ),
          ],
        ],
      ),
    );
  }
}

/// The error tone for a ring: the dark scheme's error is a pale pastel that
/// reads as salmon on a thick stroke.
Color reportAlertColor(BuildContext context) {
  final error = context.colorScheme.error;
  if (context.colorScheme.brightness == Brightness.light) return error;
  return HSLColor.fromColor(error).withLightness(0.64).toColor();
}

/// A round well with a ring along its edge filled to [value], which eases
/// to each new value.
class ReportBadge extends StatelessWidget {
  const ReportBadge({
    super.key,
    required this.color,
    this.value = 0,
    this.motion = const Duration(milliseconds: 450),
    this.curve = Curves.easeOutCubic,
    required this.child,
  });

  final Color color;
  final double value;
  final Duration motion;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final level = context.raisedSurfaceLevel;
    final well = level.colorOf(colorScheme);
    final track = SurfaceLevel.inset.colorOf(colorScheme);
    final content = SurfaceScope(
      level: level,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(color: color, size: 40),
          child: child,
        ),
      ),
    );
    return SizedBox.square(
      dimension: _badgeSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: context.motionDuration(motion),
        curve: curve,
        builder: (context, shown, child) => CustomPaint(
          painter: _RingPainter(
            well: well,
            track: track,
            color: color,
            value: shown,
          ),
          child: child,
        ),
        child: content,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.well,
    required this.track,
    required this.color,
    this.value = 0,
  });

  final Color well;
  final Color track;
  final Color color;
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = well);
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - _ringWidth / 2 - 2,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, stroke..color = track);
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      stroke..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.well != well ||
      oldDelegate.track != track;
}

/// A step's text as a tabular figure, so a counting number holds its width.
TextStyle reportFigureStyle(BuildContext context, AppTextStyle style) => style
    .of(context, emphasized: true)
    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
