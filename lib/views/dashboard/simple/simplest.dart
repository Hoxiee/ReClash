import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/core_status_button.dart';

import 'home.dart';
import 'power_button.dart';

const _revealChance = bool.fromEnvironment('SIMPLEST_DASHBOARD') ? 1.0 : 0.01;

/// Whether this session found the simplest dashboard; only a pin carries it
/// past a restart.
class SimplestDashboardReveal extends Notifier<bool> {
  SimplestDashboardReveal([math.Random? random])
    : _random = random ?? math.Random();

  final math.Random _random;

  @override
  bool build() => false;

  /// Call before the style changes: the joke needs someone retreating from
  /// the detailed dashboard, and a profile for the button to run.
  void roll() {
    final retreating =
        ref.read(appSettingProvider).dashboardStyle == DashboardStyle.detailed;
    if (!retreating || ref.read(profilesProvider).isEmpty) return;
    if (_random.nextDouble() < _revealChance) state = true;
  }
}

final simplestDashboardRevealProvider =
    NotifierProvider<SimplestDashboardReveal, bool>(
      SimplestDashboardReveal.new,
    );

const _maxWidth = 440.0;
const _height = 112.0;
const _hintHeight = 48.0;

/// The app a subscription provider dreams of: one button, and it asks for
/// money. It only says so; it runs the same toggle as the power button.
class SimplestDashboardView extends StatelessWidget {
  const SimplestDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      backgroundColor: DashboardColors.of(context).page,
      titleWidget: const SizedBox.shrink(),
      actions: [if (coreLib == null) const CoreStatusButton()],
      body: PowerRequest(
        builder: (context, link, toggle) => LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth - 48, _maxWidth);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PayButton(link: link, width: width, onPressed: toggle),
                  if (toggle == null)
                    SizedBox(
                      height: _hintHeight,
                      child: Center(
                        child: Text(
                          context.appLocalizations.simpleStatusNoProfileHint,
                          style: AppTextStyle.subheadline
                              .of(context)
                              .copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A paywall's call to action, fine print included.
class _PayButton extends StatefulWidget {
  const _PayButton({
    required this.link,
    required this.width,
    required this.onPressed,
  });

  final PowerLink link;
  final double width;
  final VoidCallback? onPressed;

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton>
    with SingleTickerProviderStateMixin {
  static const _colorDuration = Duration(milliseconds: 350);

  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  var _focused = false;

  bool get _begging =>
      widget.onPressed != null &&
      (widget.link == PowerLink.off || widget.link == PowerLink.connecting);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSheen();
  }

  @override
  void didUpdateWidget(_PayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSheen();
  }

  void _syncSheen() {
    if (_begging && !context.disableAnimations) {
      if (!_sheen.isAnimating) unawaited(_sheen.repeat());
    } else {
      _sheen
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  void _onTap() {
    unawaited(HapticFeedback.heavyImpact());
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final link = widget.link;
    final enabled = widget.onPressed != null;
    final (fill, ink) = switch (link) {
      _ when !enabled => (colors.tone, colorScheme.onSurfaceVariant),
      PowerLink.off => (dashboardMoneyGreen, Colors.white),
      PowerLink.connecting ||
      PowerLink.on => (colors.okContainer, colors.onOkContainer),
      PowerLink.paused => (colors.tone, colorScheme.onSurface),
    };
    final (label, note) = switch (link) {
      PowerLink.off => (
        appLocalizations.simplestOff,
        appLocalizations.simplestOffNote,
      ),
      PowerLink.connecting => (
        appLocalizations.simplestConnecting,
        appLocalizations.simplestConnectingNote,
      ),
      PowerLink.on => (
        appLocalizations.simplestOn,
        appLocalizations.simplestOnNote,
      ),
      PowerLink.paused => (
        appLocalizations.simplestPaused,
        appLocalizations.simplestPausedNote,
      ),
    };
    final tooltip = powerTooltip(context, link);
    final duration = context.motionDuration(_colorDuration);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        excludeSemantics: true,
        child: InkResponse(
          onTap: enabled ? _onTap : null,
          onFocusChange: (value) => setState(() => _focused = value),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          customBorder: AppShape.full,
          child: ElasticPress(
            enabled: enabled,
            child: AnimatedContainer(
              duration: duration,
              width: widget.width,
              height: _height,
              decoration: ShapeDecoration(
                color: fill,
                shape: AppShape.full.copyWith(
                  side: _focused
                      ? focusRingSide(colorScheme, standsOff: true)
                      : BorderSide.none,
                ),
                shadows: [
                  BoxShadow(
                    color: _begging
                        ? dashboardMoneyGreen.withValues(alpha: 0.35)
                        : Colors.transparent,
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRSuperellipse(
                    borderRadius: AppRadius.full,
                    child: CustomPaint(painter: _SheenPainter(_sheen)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: AnimatedSwitcher(
                      duration: duration,
                      child: Column(
                        key: ValueKey(link),
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 2,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                softWrap: false,
                                style: AppTextStyle.title1
                                    .of(context, emphasized: true)
                                    .copyWith(color: ink),
                              ),
                            ),
                          ),
                          Text(
                            note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.footnote
                                .of(context)
                                .copyWith(color: ink.withValues(alpha: 0.88)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A band of light crossing the button early in each period, then a pause.
class _SheenPainter extends CustomPainter {
  _SheenPainter(this.sweep) : super(repaint: sweep);

  static const _sweepShare = 0.4;

  final Animation<double> sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = sweep.value / _sweepShare;
    if (progress <= 0 || progress >= 1) return;
    final band = size.height * 1.6;
    final left = lerpDouble(-band, size.width, progress)!;
    final rect = Rect.fromLTWH(left, 0, band, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) => oldDelegate.sweep != sweep;
}
