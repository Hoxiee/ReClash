import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/ui/ui.dart';

/// Seven, BAR, cherry, lemon, bell and diamond; index 0 is the seven that
/// pays.
const _symbolCount = 6;
const _reels = 3;
const _jackpot = [0, 0, 0];

const _gold = Color(0xFFFFD54F);
const _amber = Color(0xFFFFB300);
const _chrome = [
  Color(0xFFFAFAFA),
  Color(0xFF9E9E9E),
  Color(0xFFF5F5F5),
  Color(0xFF616161),
  Color(0xFFE0E0E0),
];
const _chromeStops = [0.0, 0.3, 0.5, 0.8, 1.0];

/// Reels stay paper-white in a dark theme too, as on a real machine, only
/// dimmer.
const _paperLight = Color(0xFFFAF7F0);
const _paperDark = Color(0xFFE2DBCB);

/// Picks a spin's stops before the reels move, the way real machines do, and
/// pays out by the [pity]-th spin at the latest so a start is never out of
/// reach.
class SlotDraw {
  SlotDraw([math.Random? random]) : _random = random ?? math.Random();

  static const jackpotChance = 1 / 12;
  static const pity = 30;
  static const _nearMissChance = 0.35;

  final math.Random _random;
  var _misses = 0;

  List<int> next() {
    if (_misses + 1 >= pity || _random.nextDouble() < jackpotChance) {
      _misses = 0;
      return _jackpot;
    }
    _misses++;
    if (_random.nextDouble() < _nearMissChance) {
      return [0, 0, 1 + _random.nextInt(_symbolCount - 1)];
    }
    return losing();
  }

  List<int> losing() {
    while (true) {
      final stops = [
        for (var i = 0; i < _reels; i++) _random.nextInt(_symbolCount),
      ];
      if (!isJackpot(stops)) return stops;
    }
  }
}

bool isJackpot(List<int> stops) => stops.every((stop) => stop == 0);

/// The power button as a one-armed bandit: a start has to be won with 777,
/// every other action the face asks for runs on a plain tap or pull.
class SlotMachine extends StatefulWidget {
  const SlotMachine({
    super.key,
    required this.link,
    required this.size,
    required this.label,
    required this.spinToStart,
    required this.onPressed,
    this.draw,
  });

  final PowerLink link;

  /// The side of the square the machine takes.
  final double size;
  final String label;
  final bool spinToStart;

  /// Null disables the machine.
  final VoidCallback? onPressed;
  final SlotDraw? draw;

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

enum _Lights { dim, idle, chase, wave, steady }

class _SlotMachineState extends State<SlotMachine>
    with TickerProviderStateMixin {
  static const _reelDuration = Duration(milliseconds: 1200);

  /// Symbols per second at full speed, the same on every reel.
  static const _reelSpeed = 24.0;
  static const _reelStagger = Duration(milliseconds: 450);
  static const _teaseDuration = Duration(milliseconds: 1000);
  static const _settleDuration = Duration(milliseconds: 450);
  static const _leverThreshold = 0.75;
  static const _leverSpring = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 14,
  );

  late final SlotDraw _draw = widget.draw ?? SlotDraw();
  final _random = math.Random();
  late final _controllers = [
    for (var i = 0; i < _reels; i++) AnimationController(vsync: this),
  ];
  late final _pull = AnimationController.unbounded(vsync: this);
  late final _lights = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..addStatusListener(_burstChanged);
  late final _from = List<double>.filled(_reels, 0);
  late final _to = List<double>.filled(_reels, 0);
  final _motions = List<_ReelMotion?>.filled(_reels, null);
  late List<int> _stops = widget.link == PowerLink.off
      ? _draw.losing()
      : _jackpot;
  _SymbolArt? _art;
  var _coins = const <_Coin>[];
  var _spinning = false;
  var _nearMiss = false;
  var _spins = 0;
  var _leverClicked = false;

  /// A won start that has not run yet; a tap retries it without a spin.
  var _armed = false;
  var _focused = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _reels; i++) {
      _from[i] = _to[i] = _stops[i].toDouble();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _art?.dispose();
    _art = _SymbolArt(
      AppTextStyle.custom(
        context,
        size: 100,
        leading: 100,
        weight: FontWeight.w900,
      ),
    );
    _syncLights();
  }

  @override
  void didUpdateWidget(SlotMachine oldWidget) {
    super.didUpdateWidget(oldWidget);
    final running = widget.link != PowerLink.off;
    if (widget.link == PowerLink.on) _armed = false;
    if (oldWidget.link == PowerLink.on && !running) _spins = 0;
    _syncLights();
    if (_spinning || running == (oldWidget.link != PowerLink.off)) return;
    if (running && !isJackpot(_stops)) {
      unawaited(_settle(_jackpot));
    } else if (!running && !_armed && isJackpot(_stops)) {
      unawaited(_settle(_draw.losing()));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _pull.dispose();
    _lights.dispose();
    _burst.dispose();
    _art?.dispose();
    super.dispose();
  }

  _Lights get _lightsMode {
    if (widget.onPressed == null) return _Lights.dim;
    if (_burst.isAnimating) return _Lights.wave;
    if (_spinning || widget.link == PowerLink.connecting) return _Lights.chase;
    if (widget.link != PowerLink.off || _armed) return _Lights.steady;
    return _Lights.idle;
  }

  void _syncLights() {
    final mode = _lightsMode;
    final moving =
        !context.disableAnimations &&
        (mode == _Lights.chase || mode == _Lights.wave);
    if (!moving) {
      _lights.stop();
    } else if (!_lights.isAnimating) {
      unawaited(_lights.repeat());
    }
  }

  void _burstChanged(AnimationStatus status) {
    if (status.isCompleted && mounted) setState(_syncLights);
  }

  double _positionOf(int reel) {
    final motion = _motions[reel];
    if (motion == null) return _to[reel];
    return _from[reel] + motion.at(_controllers[reel].value * motion.seconds);
  }

  /// Symbols per second, which the reel turns into motion blur.
  double _velocityOf(int reel) {
    final motion = _motions[reel];
    if (motion == null || !_controllers[reel].isAnimating) return 0;
    const step = 0.008;
    final time = _controllers[reel].value * motion.seconds;
    return (motion.at(time + step) - motion.at(time - step)) / (2 * step);
  }

  Future<void> _settle(List<int> stops) async {
    _stops = stops;
    await Future.wait([
      for (var i = 0; i < _reels; i++)
        _roll(i, stops[i], _settleDuration, turns: 1 + i, click: false),
    ]);
  }

  Future<void> _roll(
    int reel,
    int stop,
    Duration duration, {
    required bool click,
    int turns = 1,
    double? speed,
    double kick = 0,
    double brake = 0.2,
  }) async {
    final start = _positionOf(reel);
    final scaled = context.motionDuration(duration);
    final seconds = scaled.inMicroseconds / Duration.microsecondsPerSecond;
    final nearest = start.ceil() + (stop - start.ceil()) % _symbolCount - start;
    if (speed != null) {
      final reach = _ReelMotion.reach(seconds, kick, brake, speed);
      turns = math.max(1, ((reach - nearest) / _symbolCount).round());
    }
    _from[reel] = start;
    _to[reel] = start + nearest + turns * _symbolCount;
    _motions[reel] = _ReelMotion(
      distance: _to[reel] - start,
      seconds: seconds,
      kick: kick,
      brake: brake,
    );
    final controller = _controllers[reel]..duration = scaled;
    await controller.forward(from: 0);
    if (click && mounted) unawaited(HapticFeedback.selectionClick());
  }

  Future<void> _spin({required bool yank}) async {
    final stops = _draw.next();
    _stops = stops;
    setState(() {
      _spinning = true;
      _nearMiss = false;
      _spins++;
    });
    _syncLights();
    unawaited(HapticFeedback.mediumImpact());
    if (yank) unawaited(_yank());
    final tease = stops[0] == 0 && stops[1] == 0;
    await Future.wait([
      for (var i = 0; i < _reels; i++)
        _roll(
          i,
          stops[i],
          _reelDuration +
              _reelStagger * i +
              (tease && i == _reels - 1 ? _teaseDuration : Duration.zero),
          click: true,
          speed: _reelSpeed,
          kick: 0.3,
          brake: tease && i == _reels - 1 ? 1.1 : 0.45,
        ),
    ]);
    if (!mounted) return;
    final won = isJackpot(stops);
    setState(() {
      _spinning = false;
      _armed = won;
      _nearMiss = tease && !won;
    });
    if (won) {
      unawaited(HapticFeedback.heavyImpact());
      _celebrate();
      widget.onPressed?.call();
    }
    _syncLights();
  }

  void _celebrate() {
    _coins = [
      for (var i = 0; i < 28; i++)
        _Coin(
          angle: -math.pi * (0.15 + 0.7 * _random.nextDouble()),
          speed: 0.9 + 0.8 * _random.nextDouble(),
          spin: 6 + 8 * _random.nextDouble(),
          size: 0.05 + 0.03 * _random.nextDouble(),
          delay: 0.25 * _random.nextDouble(),
        ),
    ];
    if (!context.disableAnimations) unawaited(_burst.forward(from: 0));
  }

  void _trigger({bool fromLever = false}) {
    if (_spinning || widget.onPressed == null) return;
    if (widget.spinToStart && !_armed) {
      unawaited(_spin(yank: !fromLever));
    } else {
      unawaited(HapticFeedback.heavyImpact());
      if (!fromLever) unawaited(_yank());
      widget.onPressed!();
    }
  }

  Future<void> _yank() async {
    if (context.disableAnimations) return;
    await _pull.animateTo(
      1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeIn,
    );
    if (mounted) _springBack(0);
  }

  void _springBack(double velocity) {
    if (context.disableAnimations) {
      _pull.value = 0;
      return;
    }
    unawaited(
      _pull.animateWith(
        SpringSimulation(_leverSpring, _pull.value, 0, velocity),
      ),
    );
  }

  void _dragLever(DragUpdateDetails details, double travel) {
    if (_spinning) return;
    _pull.value = (_pull.value + details.primaryDelta! / travel).clamp(0, 1);
    final past = _pull.value >= _leverThreshold;
    if (past && !_leverClicked) unawaited(HapticFeedback.selectionClick());
    _leverClicked = past;
  }

  void _releaseLever(DragEndDetails details, double travel) {
    if (_pull.value >= _leverThreshold) _trigger(fromLever: true);
    _leverClicked = false;
    _springBack(-(details.primaryVelocity ?? 0) / travel);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = context.colorScheme;
    final side = widget.size;
    final enabled = widget.onPressed != null;
    final running = widget.link != PowerLink.off || _armed;
    final height = side * 0.8;
    final paper = colorScheme.brightness == Brightness.dark
        ? _paperDark
        : _paperLight;
    final banner = running
        ? l.slotMachineJackpot
        : _nearMiss
        ? l.slotMachineAlmost
        : l.slotMachineSpin;
    final cabinet = Container(
      width: side * 0.8,
      height: height,
      padding: EdgeInsets.all(side * 0.022),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _chrome,
          stops: _chromeStops,
        ),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(side * 0.1),
          side: _focused
              ? focusRingSide(colorScheme, standsOff: true)
              : BorderSide.none,
        ),
        shadows: [
          BoxShadow(
            color: running
                ? _amber.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: side * 0.08,
            offset: Offset(0, side * 0.03),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD32F2F), Color(0xFF7F0000)],
          ),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(side * 0.08),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(side * 0.03),
          child: Column(
            spacing: side * 0.025,
            children: [
              SizedBox(height: side * 0.17, child: _marquee(banner, side)),
              Expanded(child: _window(side, paper, enabled)),
              SizedBox(height: side * 0.07, child: _counter(side)),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? _trigger : null,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: side,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: enabled ? 1 : 0.55,
                duration: context.motionDuration(
                  const Duration(milliseconds: 350),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: InkResponse(
                        onTap: enabled ? _trigger : null,
                        onFocusChange: (value) =>
                            setState(() => _focused = value),
                        overlayColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        splashFactory: NoSplash.splashFactory,
                        customBorder: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(side * 0.1),
                        ),
                        child: cabinet,
                      ),
                    ),
                    Positioned(
                      left: side * 0.9,
                      top: (side - height) / 2,
                      child: _lever(side, height, enabled),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CoinPainter(
                    burst: _burst,
                    coins: _coins,
                    origin: Offset(side * 0.5, side * 0.5),
                    unit: side,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marquee(String banner, double side) => DecoratedBox(
    decoration: ShapeDecoration(
      color: const Color(0xFF2A0505),
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(side * 0.035),
        side: BorderSide(color: _amber, width: side * 0.006),
      ),
    ),
    child: CustomPaint(
      painter: _BulbPainter(
        phase: _lights,
        mode: _lightsMode,
        radius: side * 0.011,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: side * 0.06),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              banner.toUpperCase(),
              maxLines: 1,
              style:
                  AppTextStyle.custom(
                    context,
                    size: side * 0.075,
                    leading: side * 0.09,
                    weight: FontWeight.w900,
                  ).copyWith(
                    color: _gold,
                    letterSpacing: side * 0.008,
                    shadows: [
                      Shadow(
                        color: const Color(0xFFFF6F00),
                        blurRadius: side * 0.03,
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _window(double side, Color paper, bool enabled) => ClipRSuperellipse(
    borderRadius: BorderRadius.circular(side * 0.04),
    child: ColoredBox(
      color: const Color(0xFF1B1B1B),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.all(side * 0.015),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: side * 0.012,
              children: [
                for (var i = 0; i < _reels; i++)
                  Expanded(
                    child: ClipRSuperellipse(
                      borderRadius: BorderRadius.circular(side * 0.02),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _ReelPainter(
                            repaint: _controllers[i],
                            position: () => _positionOf(i),
                            velocity: () => _velocityOf(i),
                            art: _art!,
                            paper: paper,
                            faded: !enabled,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IgnorePointer(
            child: CustomPaint(painter: _GlassPainter(side * 0.006)),
          ),
        ],
      ),
    ),
  );

  Widget _counter(double side) => Center(
    child: Container(
      width: side * 0.3,
      decoration: ShapeDecoration(
        color: const Color(0xFF120000),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(side * 0.02),
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Text(
            '$_spins'.padLeft(3, '0'),
            style:
                AppTextStyle.custom(
                  context,
                  size: side * 0.05,
                  leading: side * 0.06,
                  weight: FontWeight.w700,
                ).copyWith(
                  color: const Color(0xFFFF3D00),
                  letterSpacing: side * 0.012,
                  fontFeatures: const [ui.FontFeature.tabularFigures()],
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFF1744),
                      blurRadius: side * 0.02,
                    ),
                  ],
                ),
          ),
        ),
      ),
    ),
  );

  Widget _lever(double side, double height, bool enabled) {
    final travel = height * 0.4 * 1.9;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? _trigger : null,
      onVerticalDragUpdate: enabled
          ? (details) => _dragLever(details, travel)
          : null,
      onVerticalDragEnd: enabled
          ? (details) => _releaseLever(details, travel)
          : null,
      child: SizedBox(
        width: side * 0.1,
        height: height,
        child: CustomPaint(
          painter: _LeverPainter(pull: _pull, unit: side),
        ),
      ),
    );
  }
}

/// A reel's travel in symbols over time, the way a motor-driven reel moves:
/// a short wind back, a run at full speed, a constant brake, and a detent
/// that rocks it back onto the symbol.
class _ReelMotion {
  _ReelMotion({
    required this.distance,
    required this.seconds,
    required this.kick,
    required double brake,
  }) {
    final (wind, clunk, run, accel, slow) = _phases(seconds, kick, brake);
    _wind = wind;
    _clunk = clunk;
    _run = run;
    _accel = accel;
    _brake = slow;
    _length = distance + _overshoot + kick;
    _top = _length / (_run - _accel / 2 - _brake / 2);
  }

  /// How far a reel gets at [speed] in [seconds], to pick its turns.
  static double reach(double seconds, double kick, double brake, double speed) {
    final (_, _, run, accel, slow) = _phases(seconds, kick, brake);
    return speed * (run - accel / 2 - slow / 2) - _overshoot - kick;
  }

  static (double, double, double, double, double) _phases(
    double seconds,
    double kick,
    double brake,
  ) {
    final wind = kick > 0 ? math.min(0.12, seconds * 0.15) : 0.0;
    final clunk = math.min(0.14, seconds * 0.2);
    final run = seconds - wind - clunk;
    return (
      wind,
      clunk,
      run,
      math.min(0.16, run * 0.25),
      math.min(brake, run * 0.6),
    );
  }

  static const _overshoot = 0.08;

  final double distance;
  final double seconds;
  final double kick;
  late final double _wind;
  late final double _clunk;
  late final double _run;
  late final double _accel;
  late final double _brake;
  late final double _length;
  late final double _top;

  double at(double time) {
    if (seconds <= 0 || time >= seconds) return distance;
    if (time <= 0) return 0;
    if (time < _wind) return -kick * (1 - math.cos(math.pi * time / _wind)) / 2;
    final t = time - _wind;
    if (t >= _run) {
      final settled = (t - _run) / _clunk;
      return distance + _overshoot * (1 + math.cos(math.pi * settled)) / 2;
    }
    final travelled = t < _accel
        ? _top * t * t / (2 * _accel)
        : t < _run - _brake
        ? _top * (t - _accel / 2)
        : _length - _top * (_run - t) * (_run - t) / (2 * _brake);
    return travelled - kick;
  }
}

/// One reel seen from the front: symbols on a cylinder, squashed towards its
/// edges and blurred by speed.
class _ReelPainter extends CustomPainter {
  _ReelPainter({
    required Listenable repaint,
    required this.position,
    required this.velocity,
    required this.art,
    required this.paper,
    required this.faded,
  }) : super(repaint: repaint);

  static const _step = 0.7;

  final double Function() position;
  final double Function() velocity;
  final _SymbolArt art;
  final Color paper;
  final bool faded;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = paper);
    final symbol = math.min(size.width * 0.8, size.height * 0.4);
    final radius = size.height * 0.58;
    final at = position();
    final blur = (velocity().abs() * symbol * 0.02).clamp(0.0, symbol * 0.3);
    final blurred = blur > 0.5;
    if (blurred) {
      canvas.saveLayer(
        rect,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaY: blur,
            tileMode: TileMode.decal,
          ),
      );
    }
    final first = at.floor() - 3;
    for (var index = first; index <= first + 6; index++) {
      final angle = (index - at) * _step;
      if (angle.abs() >= math.pi / 2) continue;
      canvas
        ..save()
        ..translate(size.width / 2, size.height / 2 + radius * math.sin(angle))
        ..scale(1, math.cos(angle));
      art.paint(canvas, index % _symbolCount, symbol);
      canvas.restore();
    }
    if (blurred) canvas.restore();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC000000),
            Color(0x00000000),
            Color(0x33FFFFFF),
            Color(0x00000000),
            Color(0xCC000000),
          ],
          stops: [0, 0.3, 0.42, 0.58, 1],
        ).createShader(rect),
    );
    if (faded) {
      canvas.drawRect(rect, Paint()..color = paper.withValues(alpha: 0.55));
    }
  }

  @override
  bool shouldRepaint(_ReelPainter oldDelegate) =>
      oldDelegate.art != art ||
      oldDelegate.paper != paper ||
      oldDelegate.faded != faded;
}

/// The reel symbols, each drawn centred on the origin within a square of
/// the given side.
class _SymbolArt {
  _SymbolArt(TextStyle base)
    : _seven = _text(
        '7',
        base.copyWith(
          foreground: Paint()
            ..shader =
                const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
                ).createShader(
                  Rect.fromCenter(center: Offset.zero, width: 60, height: 80),
                ),
        ),
      ),
      _sevenOutline = _text(
        '7',
        base.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFF4A0000),
        ),
      ),
      _bar = _text('BAR', base.copyWith(color: Colors.white));

  final TextPainter _seven;
  final TextPainter _sevenOutline;
  final TextPainter _bar;

  static TextPainter _text(String text, TextStyle style) => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  void dispose() {
    _seven.dispose();
    _sevenOutline.dispose();
    _bar.dispose();
  }

  void paint(Canvas canvas, int symbol, double side) {
    canvas.save();
    switch (symbol) {
      case 0:
        _paintSeven(canvas, side);
      case 1:
        _paintBar(canvas, side);
      case 2:
        canvas.scale(side);
        _paintCherry(canvas);
      case 3:
        canvas.scale(side);
        _paintLemon(canvas);
      case 4:
        canvas.scale(side);
        _paintBell(canvas);
      default:
        canvas.scale(side);
        _paintDiamond(canvas);
    }
    canvas.restore();
  }

  void _paintSeven(Canvas canvas, double side) {
    canvas.scale(side / 82);
    final offset = _glyphOrigin(_seven);
    _sevenOutline.paint(canvas, offset);
    _seven.paint(canvas, offset);
  }

  void _paintBar(Canvas canvas, double side) {
    canvas.scale(side);
    final plate = Rect.fromCenter(
      center: Offset.zero,
      width: 0.92,
      height: 0.44,
    );
    canvas
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(plate, const Radius.circular(0.1)),
        Paint()..color = const Color(0xFF212121),
      )
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          plate.deflate(0.04),
          const Radius.circular(0.07),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.025
          ..color = _amber,
      );
    final scale = math.min(0.7 / _bar.width, 0.34 / _bar.height);
    canvas.scale(scale);
    _bar.paint(canvas, _glyphOrigin(_bar));
  }

  /// Centres capitals and digits on their own height rather than the line
  /// box, which leaves them visibly low.
  static Offset _glyphOrigin(TextPainter text) => Offset(
    -text.width / 2,
    -text.computeDistanceToActualBaseline(TextBaseline.alphabetic) + 36,
  );

  static void _paintCherry(Canvas canvas) {
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2E7D32);
    canvas
      ..drawPath(
        Path()
          ..moveTo(-0.2, 0.08)
          ..quadraticBezierTo(-0.14, -0.22, 0.06, -0.36),
        stem,
      )
      ..drawPath(
        Path()
          ..moveTo(0.18, 0.12)
          ..quadraticBezierTo(0.14, -0.16, 0.06, -0.36),
        stem,
      )
      ..save()
      ..translate(0.18, -0.36)
      ..rotate(-0.45)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: 0.3, height: 0.13),
        Paint()..color = const Color(0xFF43A047),
      )
      ..restore();
    for (final center in const [Offset(-0.2, 0.2), Offset(0.18, 0.26)]) {
      const r = 0.2;
      canvas
        ..drawCircle(
          center,
          r,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
            ).createShader(Rect.fromCircle(center: center, radius: r)),
        )
        ..drawCircle(
          center + const Offset(-r * 0.35, -r * 0.35),
          r * 0.22,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
    }
  }

  static void _paintLemon(Canvas canvas) {
    final path = Path()
      ..moveTo(-0.44, 0)
      ..cubicTo(-0.3, -0.42, 0.3, -0.42, 0.44, 0)
      ..cubicTo(0.3, 0.42, -0.3, 0.42, -0.44, 0)
      ..close();
    const bounds = Rect.fromLTRB(-0.44, -0.32, 0.44, 0.32);
    canvas
      ..drawPath(
        path,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.4),
            colors: [Color(0xFFFFF59D), Color(0xFFFBC02D)],
          ).createShader(bounds),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.025
          ..color = const Color(0xFFF57F17),
      )
      ..drawOval(
        Rect.fromCenter(
          center: const Offset(-0.12, -0.12),
          width: 0.2,
          height: 0.08,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
  }

  static void _paintBell(Canvas canvas) {
    final body = Path()
      ..moveTo(-0.38, 0.24)
      ..cubicTo(-0.26, 0.16, -0.3, -0.12, -0.22, -0.24)
      ..cubicTo(-0.14, -0.38, 0.14, -0.38, 0.22, -0.24)
      ..cubicTo(0.3, -0.12, 0.26, 0.16, 0.38, 0.24)
      ..close();
    const gold = LinearGradient(
      colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)],
    );
    const bounds = Rect.fromLTRB(-0.42, -0.4, 0.42, 0.4);
    canvas
      ..drawCircle(
        const Offset(0, 0.32),
        0.07,
        Paint()..color = const Color(0xFFE65100),
      )
      ..drawCircle(
        const Offset(0, -0.38),
        0.06,
        Paint()..color = const Color(0xFFFF8F00),
      )
      ..drawPath(body, Paint()..shader = gold.createShader(bounds))
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          const Rect.fromLTRB(-0.42, 0.2, 0.42, 0.3),
          const Radius.circular(0.05),
        ),
        Paint()..shader = gold.createShader(bounds),
      )
      ..drawOval(
        Rect.fromCenter(
          center: const Offset(-0.12, -0.06),
          width: 0.08,
          height: 0.3,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.4),
      );
  }

  static void _paintDiamond(Canvas canvas) {
    const table = [Offset(-0.22, -0.3), Offset(0.22, -0.3)];
    const girdle = [Offset(-0.42, -0.1), Offset(0.42, -0.1)];
    const tip = Offset(0, 0.4);
    final outline = Path()
      ..moveTo(table[0].dx, table[0].dy)
      ..lineTo(table[1].dx, table[1].dy)
      ..lineTo(girdle[1].dx, girdle[1].dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(girdle[0].dx, girdle[0].dy)
      ..close();
    final facets = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.018
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.6);
    canvas
      ..drawPath(
        outline,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB2EBF2), Color(0xFF29B6F6), Color(0xFF01579B)],
          ).createShader(const Rect.fromLTRB(-0.42, -0.3, 0.42, 0.4)),
      )
      ..drawPath(
        Path()
          ..moveTo(table[0].dx, table[0].dy)
          ..lineTo(table[1].dx, table[1].dy)
          ..lineTo(0, -0.1)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      )
      ..drawLine(girdle[0], girdle[1], facets)
      ..drawLine(table[0], const Offset(0, -0.1), facets)
      ..drawLine(table[1], const Offset(0, -0.1), facets)
      ..drawLine(const Offset(-0.14, -0.1), tip, facets)
      ..drawLine(const Offset(0.14, -0.1), tip, facets)
      ..drawPath(outline, facets);
  }
}

/// Bulbs around the marquee, lit by the machine's mood.
class _BulbPainter extends CustomPainter {
  _BulbPainter({required this.phase, required this.mode, required this.radius})
    : super(repaint: phase);

  final Animation<double> phase;
  final _Lights mode;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = (Offset.zero & size).deflate(radius * 1.9);
    final spacing = radius * 4.4;
    final perimeter = 2 * (frame.width + frame.height);
    final count = math.max(4, (perimeter / spacing / 2).round() * 2);
    final points = [
      for (var i = 0; i < count; i++) _along(frame, perimeter * i / count),
    ];
    final t = phase.value;
    for (final (i, point) in points.indexed) {
      final glow = switch (mode) {
        _Lights.dim => 0.12,
        _Lights.steady => 1.0,
        _Lights.idle => i.isEven ? 1.0 : 0.3,
        _Lights.chase => (i + (t * 3).floor()) % 3 == 0 ? 1.0 : 0.25,
        _Lights.wave =>
          0.5 + 0.5 * math.sin(2 * math.pi * (t * 2 - i * 3 / points.length)),
      };
      if (glow > 0.2) {
        final halo = Rect.fromCircle(center: point, radius: radius * 2.4);
        canvas.drawOval(
          halo,
          Paint()
            ..shader = RadialGradient(
              colors: [
                _amber.withValues(alpha: 0.55 * glow),
                _amber.withValues(alpha: 0),
              ],
            ).createShader(halo),
        );
      }
      canvas.drawCircle(
        point,
        radius,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF5D4037),
            const Color(0xFFFFF8E1),
            glow,
          )!,
      );
    }
  }

  @override
  bool shouldRepaint(_BulbPainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.radius != radius;

  static Offset _along(Rect frame, double distance) {
    final Rect(:left, :top, :right, :bottom, :width, :height) = frame;
    if (distance < width) return Offset(left + distance, top);
    if ((distance -= width) < height) return Offset(right, top + distance);
    if ((distance -= height) < width) return Offset(right - distance, bottom);
    return Offset(left, bottom - (distance - width));
  }
}

/// Glare on the reel window and the payline across it.
class _GlassPainter extends CustomPainter {
  const _GlassPainter(this.stroke);

  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final glare = Rect.fromLTWH(0, 0, size.width, size.height * 0.4);
    canvas.drawRect(
      glare,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
        ).createShader(glare),
    );
    final y = size.height / 2;
    final arrow = stroke * 3.2;
    final pointer = Paint()..color = _gold;
    canvas
      ..drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0xDDE53935)
          ..strokeWidth = stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(0, y - arrow)
          ..lineTo(arrow * 1.2, y)
          ..lineTo(0, y + arrow)
          ..close(),
        pointer,
      )
      ..drawPath(
        Path()
          ..moveTo(size.width, y - arrow)
          ..lineTo(size.width - arrow * 1.2, y)
          ..lineTo(size.width, y + arrow)
          ..close(),
        pointer,
      );
  }

  @override
  bool shouldRepaint(_GlassPainter oldDelegate) => oldDelegate.stroke != stroke;
}

/// A side lever seen from the front: as it swings down the rod shortens
/// past its hub and the ball comes closer.
class _LeverPainter extends CustomPainter {
  _LeverPainter({required this.pull, required this.unit})
    : super(repaint: pull);

  final Animation<double> pull;

  /// The machine's side, which every part scales with.
  final double unit;

  @override
  void paint(Canvas canvas, Size size) {
    final hub = Offset(size.width * 0.42, size.height / 2);
    final length = size.height * 0.4;
    final angle = pull.value.clamp(-0.1, 1.0) * math.pi * 0.85;
    final tip = hub + Offset(0, -length * math.cos(angle));
    final ball = unit * 0.045 * (1 + 0.18 * math.max(0, math.sin(angle)));
    final mount = Rect.fromLTRB(
      -unit * 0.02,
      hub.dy - unit * 0.06,
      hub.dx + unit * 0.03,
      hub.dy + unit * 0.06,
    );
    final rod = Rect.fromLTWH(
      hub.dx - unit * 0.011,
      0,
      unit * 0.022,
      size.height,
    );
    canvas
      ..drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(mount, Radius.circular(unit * 0.02)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _chrome,
            stops: _chromeStops,
          ).createShader(mount),
      )
      ..drawLine(
        hub,
        tip,
        Paint()
          ..strokeWidth = unit * 0.022
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(
            colors: _chrome,
            stops: _chromeStops,
          ).createShader(rod),
      )
      ..drawCircle(
        hub,
        unit * 0.028,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [Color(0xFFFAFAFA), Color(0xFF616161)],
          ).createShader(Rect.fromCircle(center: hub, radius: unit * 0.028)),
      )
      ..drawCircle(
        tip,
        ball,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.4),
            colors: [Color(0xFFFF8A80), Color(0xFFD50000), Color(0xFF7F0000)],
            stops: [0, 0.6, 1],
          ).createShader(Rect.fromCircle(center: tip, radius: ball)),
      );
  }

  @override
  bool shouldRepaint(_LeverPainter oldDelegate) => oldDelegate.unit != unit;
}

class _Coin {
  const _Coin({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.delay,
  });

  final double angle;

  /// Machine sides per second.
  final double speed;
  final double spin;
  final double size;
  final double delay;
}

/// The jackpot payout: coins thrown up from the reels, falling and fading.
class _CoinPainter extends CustomPainter {
  _CoinPainter({
    required this.burst,
    required this.coins,
    required this.origin,
    required this.unit,
  }) : super(repaint: burst);

  static const _seconds = 1.8;
  static const _gravity = 2.8;

  final Animation<double> burst;
  final List<_Coin> coins;
  final Offset origin;
  final double unit;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = burst.value;
    if (progress <= 0 || progress >= 1) return;
    final t = progress * _seconds;
    final opacity = ((_seconds - t) / 0.5).clamp(0.0, 1.0);
    for (final coin in coins) {
      final life = t - coin.delay;
      if (life <= 0) continue;
      final center =
          origin +
          Offset(math.cos(coin.angle), math.sin(coin.angle)) *
              (coin.speed * unit * life) +
          Offset(0, 0.5 * _gravity * unit * life * life);
      final side = coin.size * unit;
      final width = side * math.cos(coin.spin * life).abs().clamp(0.15, 1.0);
      canvas
        ..drawOval(
          Rect.fromCenter(center: center, width: width, height: side),
          Paint()..color = const Color(0xFFB8860B).withValues(alpha: opacity),
        )
        ..drawOval(
          Rect.fromCenter(
            center: center,
            width: width * 0.76,
            height: side * 0.76,
          ),
          Paint()..color = _gold.withValues(alpha: opacity),
        );
    }
  }

  @override
  bool shouldRepaint(_CoinPainter oldDelegate) =>
      oldDelegate.coins != coins ||
      oldDelegate.origin != origin ||
      oldDelegate.unit != unit;
}
