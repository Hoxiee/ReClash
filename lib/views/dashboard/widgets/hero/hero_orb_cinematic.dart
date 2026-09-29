part of 'hero_orb.dart';

// The hold easter egg: the charge → nova → collapse → singularity → regrow
// cinematic, its overlay, and the body-transform getters the orb reads while it
// runs. Split off so the base orb file carries only the ambient orb; the base
// State owns the shared controllers below and exposes them through these hooks.
mixin _HeroCinematic on ConsumerState<HeroOrb>, TickerProvider {
  AnimationController get _press;
  AnimationController get _ripple;
  AnimationController get _tint;
  HeroPalette get _currentPalette;
  HeroStatus get _status;
  bool get _still;
  bool get _multiTouch;
  Set<int> get _pointers;
  void _refreshStill();

  late final AnimationController _charge;
  late final AnimationController _nova;
  late final AnimationController _collapse;
  late final AnimationController _singularity;
  late final AnimationController _regrow;

  /// Drawn once per detonation so the spray is stable across its frames and
  /// different every time.
  List<_NovaSpark> _sparks = const [];
  List<_NovaSpark> _singularitySparks = const [];

  /// Set once the big bang has fired so a finger still down after it never
  /// re-arms the charge or the collapse.
  bool _spent = false;
  final List<Timer> _pulseTimers = [];

  OverlayEntry? _cinematicEntry;
  Rect _cinematicOrbRect = Rect.zero;
  Size _cinematicOverlaySize = Size.zero;
  double _cinematicScreenShort = 0;

  Offset? _chargeOrigin;
  bool _swallowTap = false;
  Timer? _swallowTimer;
  Timer? _landingTimer;

  void _initCinematic() {
    _charge = AnimationController(
      vsync: this,
      duration: _novaCharge,
      reverseDuration: const Duration(milliseconds: 260),
    )
      ..addStatusListener(_handleCharge)
      ..addStatusListener(_handleCinematicSettle);
    _nova = AnimationController(vsync: this, duration: _novaDuration)
      ..addStatusListener(_handleCinematicSettle);
    _collapse =
        AnimationController(
            vsync: this,
            duration: _collapseCharge,
            reverseDuration: const Duration(milliseconds: 620),
          )
          ..addStatusListener(_handleCollapse)
          ..addStatusListener(_handleCinematicSettle)
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed && !_spent) {
              _hideCinematic();
            }
          });
    _singularity = AnimationController(
      vsync: this,
      duration: _singularityDuration,
    )
      ..addListener(_driveImpact)
      ..addStatusListener(_handleCinematicSettle);
    _regrow = AnimationController(
      vsync: this,
      value: 1,
      duration: _regrowDuration,
    )..addStatusListener(_handleCinematicSettle);
  }

  void _disposeCinematic() {
    _hideCinematic();
    _swallowTimer?.cancel();
    _landingTimer?.cancel();
    for (final timer in _pulseTimers) {
      timer.cancel();
    }
    _charge.dispose();
    _nova.dispose();
    _collapse.dispose();
    _singularity.dispose();
    _regrow.dispose();
  }

  // The hold cinematic (charge → nova → collapse → singularity → regrow) owns
  // the orb until it settles; an idle freeze landing mid-flight would reset it
  // with a snap, so stillness waits while any stage runs or a finger holds it.
  bool get _cinematicActive =>
      _chargeOrigin != null ||
      _charge.isAnimating ||
      _nova.isAnimating ||
      _collapse.isAnimating ||
      _singularity.isAnimating ||
      !_regrow.isCompleted;

  void _reevaluateStill() {
    if (!mounted || _cinematicActive) return;
    _refreshStill();
  }

  void _handleCinematicSettle(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _reevaluateStill();
    }
  }

  void _beginCharge(Offset position) {
    if (_still ||
        !widget.enabled ||
        _nova.isAnimating ||
        _collapse.isAnimating ||
        _singularity.isAnimating ||
        _spent ||
        _multiTouch) {
      return;
    }
    _chargeOrigin = position;
    _charge.forward(from: 0);
  }

  void _clearPulses() {
    for (final timer in _pulseTimers) {
      timer.cancel();
    }
    _pulseTimers.clear();
  }

  void _cancelCharge() {
    _chargeOrigin = null;
    _spent = false;
    _clearPulses();
    if (_collapse.value > 0 && !_singularity.isAnimating) {
      _collapse.reverse();
      if (!_still) _ripple.forward(from: 0);
    }
    if (_charge.isDismissed) return;
    if (_charge.isCompleted) {
      _charge.value = 0;
      return;
    }
    _charge.reverse();
  }

  void _handleCharge(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _detonate();
  }

  void _detonate() {
    _sparks = _novaSparks(math.Random(DateTime.now().microsecondsSinceEpoch));
    _press.reverse();
    _ripple.forward(from: 0);
    _showCinematic();
    final android = defaultTargetPlatform == TargetPlatform.android;
    if (android) HapticFeedback.heavyImpact();
    _landingTimer?.cancel();
    _landingTimer = android
        ? Timer(_novaDuration * _novaLanding, () {
            _landingTimer = null;
            if (mounted) HapticFeedback.heavyImpact();
          })
        : null;
    _nova.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _nova.value = 0;
      _maybeCollapse();
      // A finger that never made it to the collapse leaves the overlay empty.
      if (!_collapse.isAnimating && !_singularity.isAnimating) {
        _hideCinematic();
      }
    });
  }

  // The nova is done and the finger never left: the orb caves into the collapse
  // that arms the big bang.
  void _maybeCollapse() {
    if (_still ||
        _spent ||
        _multiTouch ||
        _chargeOrigin == null ||
        _pointers.isEmpty ||
        !_charge.isCompleted) {
      return;
    }
    _collapse.forward(from: 0);
    _showCinematic();
    if (defaultTargetPlatform != TargetPlatform.android) return;
    for (final at in const [0.45, 0.7, 0.88]) {
      _pulseTimers.add(
        Timer(_collapseCharge * at, () {
          if (mounted && _collapse.isAnimating) HapticFeedback.lightImpact();
        }),
      );
    }
  }

  void _handleCollapse(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    _evaporate();
  }

  void _evaporate() {
    _spent = true;
    _clearPulses();
    _singularitySparks = _novaSparks(
      math.Random(DateTime.now().microsecondsSinceEpoch),
      count: _singularitySparkCount,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.mediumImpact();
      for (final at in const [0.16, 0.28]) {
        _pulseTimers.add(
          Timer(_singularityDuration * at, () {
            if (mounted) HapticFeedback.lightImpact();
          }),
        );
      }
      // A salvo of heavy hits at the detonation, tapering off, so the blast is
      // a felt rumble on the fingertips rather than a single knock.
      final peak = _singularityDuration * _evaporatePeak;
      for (final ms in const [0, 45, 95, 155]) {
        _pulseTimers.add(
          Timer(peak + Duration(milliseconds: ms), () {
            if (mounted) HapticFeedback.heavyImpact();
          }),
        );
      }
      for (final ms in const [235, 340]) {
        _pulseTimers.add(
          Timer(peak + Duration(milliseconds: ms), () {
            if (mounted) HapticFeedback.mediumImpact();
          }),
        );
      }
    }
    _maybeDiscoverSingularity();
    _singularity.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _singularity.value = 0;
      _collapse.value = 0;
      _charge.value = 0;
      _hideCinematic();
      _regrowOrb();
    });
  }

  void _regrowOrb() {
    _spent = true;
    if (_still) {
      _regrow.value = 1;
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      _pulseTimers.add(
        Timer(_regrowDuration ~/ 2, () {
          if (mounted) HapticFeedback.selectionClick();
        }),
      );
    }
    _ripple.forward(from: 0);
    _regrow.forward(from: 0);
  }

  void _maybeDiscoverSingularity() {
    if (_status != HeroStatus.secured ||
        !PageActivityScope.isActiveOf(context) ||
        !ref.read(milestoneSettingProvider).findingsEnabled ||
        ref.read(findingPreviewProvider).enabled) {
      return;
    }
    ref.read(milestonesProvider.notifier).discover('singularity');
  }

  void _showCinematic() {
    if (_cinematicEntry != null) return;
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    if (box == null || !box.hasSize || overlay == null) return;
    // Anchor against the overlay we insert into, not the render root: on the
    // desktop panes that overlay is offset, so a bare global rect drifts.
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    _cinematicOrbRect =
        box.localToGlobal(Offset.zero, ancestor: overlayBox) & box.size;
    _cinematicOverlaySize = (overlayBox != null && overlayBox.hasSize)
        ? overlayBox.size
        : MediaQuery.sizeOf(context);
    _cinematicScreenShort = _cinematicOverlaySize.shortestSide;
    _cinematicEntry = OverlayEntry(builder: _buildCinematic);
    overlay.insert(_cinematicEntry!);
  }

  void _hideCinematic() {
    _cinematicEntry?.remove();
    _cinematicEntry = null;
    screenImpactOffset.value = Offset.zero;
  }

  void _driveImpact() {
    final s = _singularity.value;
    screenImpactOffset.value = (s > 0 && s < 1)
        ? _screenShake(s, _cinematicScreenShort)
        : Offset.zero;
  }

  Offset _cinematicShake() {
    final s = _singularity.value;
    if (s > 0) {
      if (s < 0.42) {
        final b = s / 0.42;
        final amp = b * b * 3.0;
        return Offset(math.sin(s * 23) * amp * 0.4, math.sin(s * 19) * amp);
      }
      if (s < _evaporatePeak) {
        final b = (s - 0.42) / (_evaporatePeak - 0.42);
        final amp = 4 + b * b * 22;
        return Offset(math.sin(s * 57) * amp * 0.7, math.sin(s * 63) * amp);
      }
      // The screen carries the slam now; the field only keeps a fine judder
      // on top so the collapsing point trembles inside the moving frame.
      final k = ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(0.0, 1.0);
      final decay = math.pow(1 - k, 1.8).toDouble();
      final tremble = math.sin(s * 96) * 9 * decay;
      return Offset(tremble * 0.6, tremble);
    }
    final c = _collapse.value;
    if (c <= _collapseTell) return Offset.zero;
    final local = (c - _collapseTell) / (1 - _collapseTell);
    final tremor = local * local * 1.6;
    return Offset(math.sin(c * 15) * tremor * 0.4, math.sin(c * 12) * tremor);
  }

  /// The big-bang kick, thrown at the whole overlay so the screen itself
  /// recoils. A hard low-frequency lurch that is already at full throw on the
  /// first frame, stacked with a high-frequency buzz, both ringing down fast
  /// under a steep decay so it hits like an impact rather than a wobble.
  Offset _screenShake(double s, double screenShort) {
    if (s < _evaporatePeak) return Offset.zero;
    final k = ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(0.0, 1.0);
    final decay = math.pow(1 - k, 2.3).toDouble();
    final amp = (screenShort <= 0 ? 720.0 : screenShort) * 0.055;
    final lurch = math.cos(k * 8 * math.pi) * amp * decay;
    final swing = math.sin(k * 6 * math.pi + 0.7) * amp * 0.9 * decay;
    final buzz = math.sin(s * 130) * amp * 0.5 * decay;
    return Offset(swing + buzz, lurch + buzz * 0.7);
  }

  Widget _buildCinematic(BuildContext overlayContext) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_nova, _collapse, _singularity, _tint]),
        builder: (context, _) {
          // The nova blast overflows the orb far past its neighbours, so it
          // rides the overlay above the cards instead of under them.
          if (_nova.value > 0 && _nova.value < 1) {
            return Stack(children: [_overlayNova()]);
          }
          final s = _singularity.value;
          final sWarp = s < _evaporatePeak
              ? _evaporatePeak *
                    Curves.easeInOutCubic.transform(s / _evaporatePeak)
              : _evaporatePeak +
                    (1 - _evaporatePeak) *
                        Curves.easeOutQuart.transform(
                          (s - _evaporatePeak) / (1 - _evaporatePeak),
                        );
          final collapseLocal =
              ((_collapse.value - _collapseTell) / (1 - _collapseTell)).clamp(
                0.0,
                1.0,
              );
          final showSingularity = s > 0 && s < 1;
          // Only before the singularity fires: once it has, the s == 1 frame
          // must fall through to nothing, not flash the reborn hole for a beat.
          final showCollapse = s == 0 && collapseLocal > 0;
          if (!showSingularity && !showCollapse) {
            return const SizedBox.shrink();
          }

          const sHandoff = 0.36;
          final windup = Curves.easeInCubic.transform(
            (s / sHandoff).clamp(0.0, 1.0),
          );
          final singularitySpin = 3.0 + s * 4 + s * s * 6;

          final screen = _cinematicOverlaySize.isEmpty
              ? MediaQuery.sizeOf(context)
              : _cinematicOverlaySize;
          final screenShort = math.min(screen.width, screen.height);
          final grow = Curves.easeInOutCubic.transform(
            ((collapseLocal - 0.12) / 0.78).clamp(0.0, 1.0),
          );
          final riseScale = showSingularity ? 1.0 : grow;
          // The hole grows in place over the orb; drifting it to the viewport
          // centre threw it off to the side on the wide desktop panes.
          final focal = _cinematicOrbRect.center;
          final bodyDia = lerpDouble(
            _cinematicOrbRect.shortestSide * 0.92,
            screenShort * 0.5,
            riseScale,
          )!;
          final cine = bodyDia / heroOrbBaseSize;
          final coreRadius = bodyDia / 2 - _coreInset * cine;
          final ringRadius = bodyDia / 2 - (_ringStroke / 2 + 1.5) * cine;
          final field =
              math.sqrt(
                screen.width * screen.width + screen.height * screen.height,
              ) *
              1.3;
          final shake = _cinematicShake();
          final scrimEnvelope = showSingularity
              ? (1 -
                    Curves.easeInCubic.transform(
                      ((s - _evaporatePeak) / (1 - _evaporatePeak)).clamp(
                        0.0,
                        1.0,
                      ),
                    ))
              : Curves.easeInCubic.transform(collapseLocal);
          // Lighter than a black-out so the recoiling app stays visible.
          final scrim = 0.62 * scrimEnvelope;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        (focal.dx / screen.width) * 2 - 1,
                        (focal.dy / screen.height) * 2 - 1,
                      ),
                      radius: 0.95,
                      colors: [
                        Colors.black.withValues(alpha: scrim * 0.4),
                        Colors.black.withValues(alpha: scrim),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: focal.dx - field / 2 + shake.dx,
                top: focal.dy - field / 2 + shake.dy,
                width: field,
                height: field,
                child: showSingularity
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          if (s < sHandoff)
                            CustomPaint(
                              key: HeroOrb.collapseKey,
                              isComplex: true,
                              willChange: true,
                              painter: _HeroCollapsePainter(
                                progress: 1,
                                palette: _currentPalette,
                                scale: cine,
                                coreRadius: coreRadius,
                                fade: 1 - windup,
                                windup: windup,
                              ),
                            ),
                          CustomPaint(
                            key: HeroOrb.singularityKey,
                            isComplex: true,
                            willChange: true,
                            painter: _HeroSingularityPainter(
                              progress: sWarp,
                              palette: _currentPalette,
                              scale: cine,
                              ringRadius: ringRadius,
                              coreRadius: coreRadius,
                              sparks: _singularitySparks,
                              spinPhase: singularitySpin,
                            ),
                          ),
                        ],
                      )
                    : CustomPaint(
                        key: HeroOrb.collapseKey,
                        isComplex: true,
                        willChange: true,
                        painter: _HeroCollapsePainter(
                          progress: _collapse.value,
                          palette: _currentPalette,
                          scale: cine,
                          coreRadius: coreRadius,
                        ),
                      ),
              ),
              if (showSingularity && s >= _evaporatePeak)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(
                      alpha:
                          (0.55 *
                                      math.pow(
                                        1 -
                                            ((s - _evaporatePeak) /
                                                    (1 - _evaporatePeak))
                                                .clamp(0.0, 1.0),
                                        6,
                                      ) +
                                  0.16 *
                                      math.pow(
                                        1 -
                                            ((s - _evaporatePeak) /
                                                    (1 - _evaporatePeak))
                                                .clamp(0.0, 1.0),
                                        1.4,
                                      ))
                              .toDouble(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // The overlay twin of the in-tree nova: anchored on the orb's screen rect and
  // carrying the same kick, tilt and scale so the blast tracks the orb body
  // while painting above the surrounding cards.
  Widget _overlayNova() {
    final rect = _cinematicOrbRect;
    final cine = rect.width / heroOrbBaseSize;
    final spread = _novaSpread * cine;
    return Positioned.fromRect(
      rect: Rect.fromLTWH(
        rect.left - spread,
        rect.top - spread,
        rect.width + spread * 2,
        rect.height + spread * 2,
      ),
      child: Transform.translate(
        offset: _orbKick * cine,
        child: Transform.rotate(
          angle: _orbTilt,
          child: Transform.scale(
            scale: _orbScale,
            child: CustomPaint(
              key: HeroOrb.novaKey,
              painter: _HeroNovaPainter(
                progress: _nova.value,
                palette: _currentPalette,
                scale: cine,
                ringRadius: rect.width / 2 - (_ringStroke / 2 + 1.5) * cine,
                coreRadius: rect.width / 2 - _coreInset * cine,
                sparks: _sparks,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _releaseCharge() {
    if (_charge.isCompleted) {
      _swallowTap = true;
      _swallowTimer?.cancel();
      _swallowTimer = Timer(const Duration(milliseconds: 300), () {
        _swallowTap = false;
        _swallowTimer = null;
      });
    }
    _cancelCharge();
  }

  /// Four beats, the way a thrown punch reads: wind up, hit, ride the recoil,
  /// come down. `easeInCubic` keeps the first second of the hold visually
  /// silent, so only someone already committed sees the wind-up at all.
  double get _novaScale {
    final nova = _nova.value;
    if (nova > 0) {
      if (nova < 0.07) {
        return lerpDouble(
          0.94,
          0.78,
          Curves.easeInCubic.transform(nova / 0.07),
        )!;
      }
      if (nova < _novaLanding) {
        final rebound = ((nova - 0.07) / 0.34).clamp(0.0, 1.0);
        return lerpDouble(0.78, 1.05, Curves.elasticOut.transform(rebound))!;
      }
      // The drop: it overshoots into a squash and springs out of it, which is
      // the beat the finger feels through the second haptic.
      final landing = ((nova - _novaLanding) / (1 - _novaLanding)).clamp(
        0.0,
        1.0,
      );
      if (landing < 0.24) {
        return lerpDouble(
          1.05,
          0.90,
          Curves.easeInCubic.transform(landing / 0.24),
        )!;
      }
      final settle = ((landing - 0.24) / 0.76).clamp(0.0, 1.0);
      return lerpDouble(0.90, 1, Curves.elasticOut.transform(settle))!;
    }
    if (_charge.isCompleted) return 1;
    return 1 - 0.06 * Curves.easeInCubic.transform(_charge.value);
  }

  double get _novaGlow {
    if (_nova.value <= 0) return 0;
    final local = ((_nova.value - 0.04) / 0.34).clamp(0.0, 1.0);
    if (local <= 0 || local >= 1) return 0;
    return math.sin(math.pi * local);
  }

  /// Two impulses, never a wobble: the blast throws the orb, the landing
  /// drives it into the board. Both decay hard, so each reads as a single hit.
  Offset get _novaKick {
    final nova = _nova.value;
    if (nova > 0.04 && nova < 0.34) {
      final local = (nova - 0.04) / 0.30;
      final decay = math.pow(1 - local, 1.9).toDouble();
      final phase = local * 7 * 2 * math.pi;
      return Offset(
        math.sin(phase) * 11 * decay,
        math.cos(phase * 0.82) * 8.5 * decay,
      );
    }
    if (nova > _novaLanding && nova < _novaLanding + 0.16) {
      final local = (nova - _novaLanding) / 0.16;
      final decay = math.pow(1 - local, 2.6).toDouble();
      final phase = local * 6 * 2 * math.pi;
      return Offset(
        math.sin(phase * 1.1) * 6 * decay,
        math.cos(phase) * 7.5 * decay,
      );
    }
    return Offset.zero;
  }

  /// A few degrees of tilt is the difference between a blast and a bounce.
  double get _novaTilt {
    if (_nova.value <= 0.04 || _nova.value >= 0.40) return 0;
    final local = (_nova.value - 0.04) / 0.36;
    final decay = math.pow(1 - local, 2.0).toDouble();
    return math.sin(local * 4 * 2 * math.pi) * 0.085 * decay;
  }

  double get _orbScale {
    if (_regrow.value < 1) return _regrowScale;
    if (_singularity.value > 0) return _drainScale;
    if (_collapse.value > 0) return _collapseScale;
    return _novaScale;
  }

  Offset get _orbKick {
    if (_regrow.value < 1 || _singularity.value > 0) return Offset.zero;
    if (_collapse.value > 0) return _collapseKick;
    return _novaKick;
  }

  double get _orbTilt =>
      (_regrow.value < 1 || _singularity.value > 0) ? 0 : _novaTilt;

  double get _orbGlow {
    final r = _regrow.value;
    if (r < 1) {
      final local = ((r - 0.14) / 0.5).clamp(0.0, 1.0);
      return local <= 0 || local >= 1 ? 0 : math.sin(math.pi * local);
    }
    if (_singularity.value > 0 || _collapse.value > 0) return 0;
    return _novaGlow;
  }

  double get _orbBodyOpacity {
    final r = _regrow.value;
    if (r < 1) {
      return Curves.easeOutCubic.transform(((r - 0.14) / 0.34).clamp(0.0, 1.0));
    }
    if (_singularity.value > 0) return 0;
    final c = _collapse.value;
    if (c <= 0) return 1;
    final local = ((c - _collapseTell) / (1 - _collapseTell)).clamp(0.0, 1.0);
    return 1 - Curves.easeInCubic.transform((local / 0.18).clamp(0.0, 1.0));
  }

  double get _collapseScale {
    final c = _collapse.value;
    if (c <= 0) return _novaScale;
    final gather = Curves.easeInCubic.transform(c);
    final tremor = math.sin(c * 30) * 0.016 * c;
    return lerpDouble(1, 0.5, gather)! + tremor;
  }

  Offset get _collapseKick {
    final c = _collapse.value;
    if (c <= _collapseTell) return Offset.zero;
    final local = (c - _collapseTell) / (1 - _collapseTell);
    final amp = local * local * 5.5;
    final phase = c * 40;
    return Offset(math.sin(phase) * amp, math.cos(phase * 1.3) * amp);
  }

  double get _drainScale => 0.05;

  double get _regrowScale {
    final r = _regrow.value;
    if (r >= 1) return 1;
    if (r < 0.14) return 0;
    return Curves.elasticOut.transform(((r - 0.14) / 0.86).clamp(0.0, 1.0));
  }
}
