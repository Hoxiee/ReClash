import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/sheet.dart';
import 'package:reclash/ui/surface.dart';
import 'package:reclash/ui/typography.dart';

const _contentMaxWidth = 520.0;
const _badgeSize = 96.0;
const _ringWidth = 6.0;
const _ringInset = 2.0;
const _badgeCentre = 0.3;
const _secondaryHeight = 48.0;
const _fadeHeight = 32.0;
const _ctaHeight = 52.0;
const _textMotion = Duration(milliseconds: 240);
const _spinTurn = Duration(milliseconds: 1000);
const _spinArc = 0.25;

/// One detent, so the layout's height stays put while the sheet is open.
const stageSheetProps = SheetProps(
  backgroundColor: Colors.transparent,
  detents: [0.9],
);

/// One step of a sheet that walks through a process. The badge centre rests at
/// a fixed share of the height and the foot keeps both slots even when empty,
/// so neither the badge nor the main button moves between steps.
class StageSheetLayout extends StatefulWidget {
  const StageSheetLayout({
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
  State<StageSheetLayout> createState() => _StageSheetLayoutState();
}

class _StageSheetLayoutState extends State<StageSheetLayout> {
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
class StageSheetHero extends StatelessWidget {
  const StageSheetHero({
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
          AnimatedSwitcher(
            duration: context.motionDuration(_textMotion),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(title),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.title2.of(context, emphasized: true),
                  ),
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
          ),
        ],
      ),
    );
  }
}

/// The error tone for a ring: the dark scheme's error is a pale pastel that
/// reads as salmon on a thick stroke.
Color stageAlertColor(BuildContext context) {
  final error = context.colorScheme.error;
  if (context.colorScheme.brightness == Brightness.light) return error;
  return HSLColor.fromColor(error).withLightness(0.64).toColor();
}

/// A round well with a ring along its edge filled to [value], which eases
/// to each new value, or spinning while [value] is null.
class StageSheetBadge extends StatelessWidget {
  const StageSheetBadge({
    super.key,
    required this.color,
    this.value = 0,
    this.motion = const Duration(milliseconds: 450),
    this.curve = Curves.easeOutCubic,
    required this.child,
  });

  final Color color;
  final double? value;
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
    final value = this.value;
    return SizedBox.square(
      dimension: _badgeSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: (value ?? 0).clamp(0, 1)),
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
        child: value != null
            ? content
            : Stack(
                fit: StackFit.expand,
                children: [
                  _RingSpinner(color: color),
                  content,
                ],
              ),
      ),
    );
  }
}

class _RingSpinner extends StatefulWidget {
  const _RingSpinner({required this.color});

  final Color color;

  @override
  State<_RingSpinner> createState() => _RingSpinnerState();
}

class _RingSpinnerState extends State<_RingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns;

  @override
  void initState() {
    super.initState();
    _turns = AnimationController(vsync: this, duration: _spinTurn)..repeat();
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _turns,
    child: CustomPaint(
      painter: _RingPainter(
        well: Colors.transparent,
        track: Colors.transparent,
        color: widget.color,
        value: _spinArc,
      ),
    ),
  );
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
      radius: radius - _ringWidth / 2 - _ringInset,
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
TextStyle stageFigureStyle(BuildContext context, AppTextStyle style) => style
    .of(context, emphasized: true)
    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
