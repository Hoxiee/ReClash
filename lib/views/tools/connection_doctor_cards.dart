part of 'connection_doctor.dart';

// Start, cancel, DNS flush, and export are the same real levers on the answer
// screen and inside the expert console, so both states drive them through one
// mixin instead of keeping two copies of the busy-guard plumbing.
mixin _DoctorActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String? _busyAction;

  bool get _busy => _busyAction != null;

  Future<void> _refresh({required bool showError}) async {
    try {
      await ref.read(connectionDoctorProvider.notifier).refresh();
    } catch (error) {
      if (showError) {
        dialogs.showNotifier(compactError(error), level: MessageLevel.error);
      }
    }
  }

  Future<void> _runAction(
    String action,
    Future<void> Function() callback, {
    bool showError = true,
  }) async {
    if (_busyAction != null) return;
    setState(() => _busyAction = action);
    try {
      await callback();
    } catch (error) {
      if (showError) {
        dialogs.showNotifier(compactError(error), level: MessageLevel.error);
      }
    } finally {
      if (mounted) setState(() => _busyAction = null);
    }
  }

  Future<void> _start(DoctorExamMode mode, {bool showError = true}) {
    return _runAction(mode.name, () async {
      await ref.read(connectionDoctorProvider.notifier).start(mode);
    }, showError: showError);
  }

  Future<void> _cancel() {
    return _runAction('cancel', () async {
      await ref.read(connectionDoctorProvider.notifier).cancel();
    });
  }

  Future<void> _flushDns() {
    return _runAction('flushDns', () async {
      await ref.read(connectionDoctorProvider.notifier).flushDns();
    });
  }

  Future<void> _exportReport() async {
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.confirm(
      appLocalizations.doctorExportConfirm,
      context: context,
      title: appLocalizations.doctorExportReport,
      confirmText: appLocalizations.doctorExportReport,
    );
    if (!confirmed || !mounted) return;
    await _runAction('exportRedacted', () async {
      final report = await ref
          .read(connectionDoctorProvider.notifier)
          .exportRedacted();
      final text = const JsonEncoder.withIndent('  ').convert(report.toJson());
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final uri = await picker.saveFile(
        'reclash-connection-doctor-$stamp.json',
        Uint8List.fromList(utf8.encode(text)),
      );
      if (uri != null) {
        dialogs.showNotifier(
          appLocalizations.exportSuccess,
          level: MessageLevel.success,
        );
      }
    });
  }
}

class _ConnectionDoctorViewState extends ConsumerState<ConnectionDoctorView>
    with _DoctorActionsMixin {
  bool _initializing = true;
  DoctorExamMode _mode = DoctorExamMode.standard;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  // Opening the screen is a deliberate visit, so it answers with a live check
  // instead of the passive idle state that made the old screen look empty.
  Future<void> _bootstrap() async {
    try {
      await _refresh(showError: false);
      if (!mounted) return;
      final snapshot = ref.read(connectionDoctorProvider);
      final idle =
          snapshot.state != DoctorExamState.examining &&
          (!snapshot.isFresh || snapshot.state == DoctorExamState.observing);
      if (idle && snapshot.action('startStandard')?.eligible == true) {
        await _start(DoctorExamMode.standard, showError: false);
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _applyRemedy(DoctorRemedy remedy) async {
    switch (remedy) {
      case DoctorRemedy.startVpn:
        await _runAction('startVpn', () async {
          await ref.read(setupActionProvider.notifier).setRunning(true);
        });
      case DoctorRemedy.recheck:
        await _start(DoctorExamMode.standard);
      case DoctorRemedy.deepCheck:
        await _start(DoctorExamMode.deep);
      case DoctorRemedy.flushDns:
        await _flushDns();
      case DoctorRemedy.pickNode:
        _leaveTo(PageLabel.proxies);
      case DoctorRemedy.openProfiles:
        _leaveTo(PageLabel.profiles);
      case DoctorRemedy.openDns:
        _openConfig(
          const SettingsPaneSelection(
            id: 'dns',
            detail: DnsView(),
            title: Text('DNS'),
          ),
        );
      case DoctorRemedy.openAdvanced:
        _openConfig(
          SettingsPaneSelection(
            id: 'advanced',
            detail: const AdvancedConfigView(),
            title: Text(context.appLocalizations.advancedConfig),
          ),
        );
      case DoctorRemedy.exportReport:
        await _exportReport();
    }
  }

  // The Doctor is opened as a sheet or a pushed route; leaving for a main tab
  // means closing it first so the tab is what the user lands on.
  void _leaveTo(PageLabel page) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    ref.read(currentPageLabelProvider.notifier).toPage(page, returnable: true);
  }

  // A pushing host pane drills in place. The Doctor opened as a desktop overlay
  // sheet has none, so it closes and hands the drill-in to the Tools tab for a
  // real path with a back-step; a phone keeps the full-page push.
  void _openConfig(SettingsPaneSelection drill) {
    final pane = SettingsPaneScope.of(context);
    if (pane != null && pane.active && pane.pushes) {
      pane.onSelect(drill);
      return;
    }
    if (!context.isMobileView) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
      ref.read(toolsPaneRequestProvider.notifier).request([
        doctorRootPane(context),
        drill,
      ]);
      ref
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.tools, returnable: true);
      return;
    }
    unawaited(showExtend(context, builder: (_) => drill.detail));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    final answer = connectionDoctorAnswer(appLocalizations, snapshot);
    final reduceMotion = ref.watch(
      appSettingProvider.select((state) => state.reduceMotion),
    );
    return CommonScaffold(
      title: appLocalizations.connectionDoctor,
      isLoading: _initializing,
      floatBody: true,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: appLocalizations.doctorRefresh,
          isLoading: _busy,
          onPressed: () => unawaited(_start(DoctorExamMode.standard)),
        ),
      ],
      // The verdict leads on its own tab; the expert levers and raw evidence
      // live behind the "Technical details" tab so the answer screen stays a
      // single uncluttered glance. Builds without the Core diagnosis contract
      // have no technical content, so they skip the tabs and show the lone
      // unavailable verdict.
      body: snapshot.supported
          ? AppBarClearance(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    SettingsTabs(
                      labels: [
                        appLocalizations.doctorTabOverview,
                        appLocalizations.doctorTechnicalDetails,
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _overviewTab(
                            snapshot,
                            answer,
                            inset: false,
                            reduceMotion: reduceMotion,
                          ),
                          _technicalTab(snapshot),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _overviewTab(
              snapshot,
              answer,
              inset: true,
              reduceMotion: reduceMotion,
            ),
    );
  }

  Widget _overviewTab(
    DoctorSnapshot snapshot,
    DoctorAnswer answer, {
    required bool inset,
    required bool reduceMotion,
  }) {
    return ListView(
      key: const PageStorageKey('doctor-overview'),
      padding: EdgeInsets.only(
        top: inset ? context.contentTopPadding : AppSpacing.md,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: FadeSlideEnterBox(
            key: const ValueKey('doctor-diagnosis-enter'),
            axis: Axis.vertical,
            distance: _cardEnterDistance,
            child: _DoctorSmoothResize(
              child: _DoctorDiagnosisCard(
                snapshot: snapshot,
                answer: answer,
                busy: _busy,
                reduceMotion: reduceMotion,
                canStart: snapshot.action('startStandard')?.eligible == true,
                canFlushDns: snapshot.action('flushDns')?.eligible == true,
                canCancel: snapshot.action('cancel')?.eligible == true,
                onRemedy: (remedy) => unawaited(_applyRemedy(remedy)),
                onCancel: () => unawaited(_cancel()),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: _DoctorSmoothResize(child: _DoctorStepsCard(answer: answer)),
        ),
        const SettingBottomInset(),
      ],
    );
  }

  Widget _technicalTab(DoctorSnapshot snapshot) {
    final examining = snapshot.state == DoctorExamState.examining;
    final flushAction = snapshot.action('flushDns');
    final drift =
        snapshot.isFresh && snapshot.startGenerations != snapshot.generations;
    return ListView(
      key: const PageStorageKey('doctor-technical'),
      padding: const EdgeInsets.only(top: AppSpacing.md),
      children: [
        if (drift)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: _DoctorDriftBanner(),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: _DoctorRunPanel(
            mode: _mode,
            busy: _busy,
            examining: examining,
            canStart: snapshot.action('startStandard')?.eligible == true,
            canCancel: snapshot.action('cancel')?.eligible == true,
            canFlushDns: flushAction?.eligible == true,
            flushReasonCode: flushAction?.eligibilityReasonCode ?? '',
            progress: snapshot.progress,
            onMode: (mode) => setState(() => _mode = mode),
            onRun: () => unawaited(_start(_mode)),
            onCancel: () => unawaited(_cancel()),
            onFlushDns: () => unawaited(_flushDns()),
            onExport: () => unawaited(_exportReport()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _DoctorWaterfallCard(snapshot: snapshot),
        ),
        _DoctorCapabilitiesSection(snapshot: snapshot),
        _DoctorDetails(snapshot: snapshot),
        _DoctorHealSection(snapshot: snapshot),
        _DoctorHistoryPanel(snapshot: snapshot),
        _DoctorEvidenceDisclosure(snapshot: snapshot),
        const SettingBottomInset(),
      ],
    );
  }
}

/// Travel for the cards' one-shot entry, small enough that the screen settles
/// into place rather than sliding in from off-card.
const _cardEnterDistance = 14.0;

/// Animates a child's height changes instead of snapping, so the verdict and
/// steps cards glide as an exam moves between checking, result, and idle —
/// the jumps the old screen showed on every check.
class _DoctorSmoothResize extends StatelessWidget {
  const _DoctorSmoothResize({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: context.resizeDuration(commonDuration),
      alignment: Alignment.topCenter,
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

/// A progress bar whose fill eases to each new value instead of snapping, so a
/// completed step glides the bar forward; a null value falls back to the
/// indeterminate sweep while the total is still unknown.
class _DoctorProgressBar extends StatelessWidget {
  const _DoctorProgressBar({required this.value, this.minHeight = 6});

  final double? value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return LinearProgressIndicator(
        minHeight: minHeight,
        borderRadius: AppRadius.full,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value!.clamp(0.0, 1.0)),
      duration: context.motionDuration(const Duration(milliseconds: 350)),
      curve: Curves.easeOut,
      builder: (context, animated, _) => LinearProgressIndicator(
        value: animated,
        minHeight: minHeight,
        borderRadius: AppRadius.full,
      ),
    );
  }
}

/// The single hero the screen leads with: the plain-language verdict on top,
/// the live progress while a check runs, the connection path as visual proof,
/// and the fixes at the foot — one tone-accented surface instead of the three
/// disjoint cards the old screen stacked.
class _DoctorDiagnosisCard extends StatelessWidget {
  const _DoctorDiagnosisCard({
    required this.snapshot,
    required this.answer,
    required this.busy,
    required this.reduceMotion,
    required this.canStart,
    required this.canFlushDns,
    required this.canCancel,
    required this.onRemedy,
    required this.onCancel,
  });

  final DoctorSnapshot snapshot;
  final DoctorAnswer answer;
  final bool busy;
  final bool reduceMotion;
  final bool canStart;
  final bool canFlushDns;
  final bool canCancel;
  final ValueChanged<DoctorRemedy> onRemedy;
  final VoidCallback onCancel;

  bool _remedyActive(DoctorRemedy remedy) => switch (remedy) {
    DoctorRemedy.flushDns => canFlushDns,
    DoctorRemedy.recheck || DoctorRemedy.deepCheck => canStart,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final tone = _answerColor(context, answer.tone);
    final examining = snapshot.state == DoctorExamState.examining;
    final progress = snapshot.progress;
    final progressValue = progress.total > 0
        ? (progress.completed / progress.total).clamp(0.0, 1.0)
        : null;
    final remedies = answer.remedies.where(_remedyActive).toList();
    final showActions = remedies.isNotEmpty || (examining && canCancel);
    return CommonCard(
      radius: AppCorner.xl,
      accent: tone,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: _DoctorAura(
                tone: tone,
                examining: examining,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
          Padding(
            padding: AppInsets.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _verdict(context, appLocalizations, colors, tone, examining),
                if (snapshot.supported &&
                    snapshot.isFresh &&
                    !examining &&
                    snapshot.evidence.isNotEmpty)
                  FadeSlideEnterBox(
                    key: const ValueKey('doctor-glance-enter'),
                    axis: Axis.vertical,
                    distance: AppSpacing.sm,
                    child: _DoctorGlance(snapshot: snapshot),
                  ),
                if (examining)
                  FadeSlideEnterBox(
                    key: const ValueKey('doctor-progress-enter'),
                    axis: Axis.vertical,
                    distance: AppSpacing.sm,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DoctorProgressBar(value: progressValue),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            appLocalizations.doctorProgress(
                              progress.completed,
                              progress.total,
                            ),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (snapshot.supported) ...[
                  const _DoctorSeam(),
                  ConnectionDoctorPathMap(
                    snapshot: snapshot,
                    blame: answer.blame,
                    reduceMotion: reduceMotion,
                  ),
                ],
                if (showActions) ...[
                  const _DoctorSeam(),
                  FadeSlideEnterBox(
                    key: const ValueKey('doctor-actions-enter'),
                    axis: Axis.vertical,
                    distance: AppSpacing.sm,
                    child: _actions(
                      context,
                      appLocalizations,
                      remedies: remedies,
                      examining: examining,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verdict(
    BuildContext context,
    AppLocalizations appLocalizations,
    ColorScheme colors,
    Color tone,
    bool examining,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorVerdictMark(
          icon: _answerIcon(answer.tone),
          tone: tone,
          examining: examining,
          reduceMotion: reduceMotion,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer.headline,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                answer.meaning,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (answer.isProblem &&
                  answer.confidence == DoctorConfidence.probable) ...[
                const SizedBox(height: 6),
                Text(
                  _confidenceLabel(appLocalizations, answer.confidence),
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _actions(
    BuildContext context,
    AppLocalizations appLocalizations, {
    required List<DoctorRemedy> remedies,
    required bool examining,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in remedies.asMap().entries)
          _RemedyButton(
            remedy: entry.value,
            primary: entry.key == 0,
            onPressed: busy ? null : () => onRemedy(entry.value),
          ),
        if (examining && canCancel)
          OutlinedButton.icon(
            onPressed: busy ? null : onCancel,
            icon: const GlyphIcon(AppGlyphs.stop),
            label: Text(appLocalizations.doctorCancelExam),
          ),
      ],
    );
  }
}

/// The verdict glyph as a living mark, wearing the hero orb's vocabulary at
/// medallion size: while a check runs a comet sweeps the ring, and when the
/// answer lands the ring settles into an even contour and swells once, so a
/// result arrives with weight instead of appearing flat. The sweep is the only
/// loop on the screen and parks itself whenever motion is reduced.
class _DoctorVerdictMark extends StatefulWidget {
  const _DoctorVerdictMark({
    required this.icon,
    required this.tone,
    required this.examining,
    required this.reduceMotion,
  });

  final Glyph icon;
  final Color tone;
  final bool examining;
  final bool reduceMotion;

  @override
  State<_DoctorVerdictMark> createState() => _DoctorVerdictMarkState();
}

class _DoctorVerdictMarkState extends State<_DoctorVerdictMark>
    with TickerProviderStateMixin {
  static const _medallion = 48.0;
  static const _ringGap = 5.0;

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late final AnimationController _swell = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void initState() {
    super.initState();
    _swell.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) _swell.value = 1;
  }

  @override
  void didUpdateWidget(covariant _DoctorVerdictMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    final landed = oldWidget.examining && !widget.examining;
    if (oldWidget.tone == widget.tone && !landed) return;
    if (_still) {
      _swell.value = 1;
    } else {
      _swell.forward(from: 0);
    }
    // The orb answers a landing the same way; the doctor's landing is the
    // moment the user was waiting for, so it gets the same one tap of feedback.
    if (landed && defaultTargetPlatform == TargetPlatform.android) {
      HapticFeedback.lightImpact();
    }
  }

  bool get _still => context.disableAnimations || widget.reduceMotion;

  @override
  void dispose() {
    _swell.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.examining && !_still;
    if (live) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else if (_sweep.isAnimating) {
      _sweep.stop();
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.examining ? 1 : 0),
      duration: context.motionDuration(const Duration(milliseconds: 420)),
      curve: Curves.easeOut,
      builder: (context, examining, child) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_sweep, _swell]),
          builder: (context, medallion) {
            final swell = Curves.easeOutBack.transform(_swell.value);
            return CustomPaint(
              painter: _VerdictRingPainter(
                tone: widget.tone,
                spin: _sweep.value,
                swell: swell,
                live: examining,
              ),
              child: Padding(
                padding: const EdgeInsets.all(_ringGap),
                child: Transform.scale(
                  scale: 0.78 + 0.22 * swell,
                  child: medallion,
                ),
              ),
            );
          },
          child: child,
        ),
      ),
      child: AppMedallion(
        icon: widget.icon,
        tone: widget.tone,
        size: _medallion,
      ),
    );
  }
}

class _VerdictRingPainter extends CustomPainter {
  const _VerdictRingPainter({
    required this.tone,
    required this.spin,
    required this.swell,
    required this.live,
  });

  final Color tone;
  final double spin;
  final double swell;
  final double live;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.shortestSide * 0.055;
    final radius = (size.shortestSide - stroke) / 2;
    final reveal = swell.clamp(0.0, 1.0);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2.2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.8)
        ..color = tone.withValues(alpha: (0.18 + 0.16 * live) * reveal),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = tone.withValues(alpha: 0.42 * reveal * (1 - live)),
    );
    if (live <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = SweepGradient(
          colors: [
            tone.withValues(alpha: 0),
            tone.withValues(alpha: 0.95 * live),
            tone.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
          transform: GradientRotation(-math.pi / 2 + spin * 2 * math.pi),
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_VerdictRingPainter oldDelegate) =>
      oldDelegate.tone != tone ||
      oldDelegate.spin != spin ||
      oldDelegate.swell != swell ||
      oldDelegate.live != live;
}

/// A barely-there wash of the verdict tone drifting behind the diagnosis card,
/// so the hero reads as lit from within by its own answer. Pure decoration: it
/// holds a single still frame whenever motion is reduced or the page is away.
class _DoctorAura extends StatefulWidget {
  const _DoctorAura({
    required this.tone,
    required this.examining,
    required this.reduceMotion,
  });

  final Color tone;
  final bool examining;
  final bool reduceMotion;

  @override
  State<_DoctorAura> createState() => _DoctorAuraState();
}

class _DoctorAuraState extends State<_DoctorAura>
    with SingleTickerProviderStateMixin {
  static const _stillFrame = 0.18;

  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  );

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still =
        widget.reduceMotion ||
        context.disableAnimations ||
        !PageActivityScope.isActiveOf(context);
    if (still) {
      if (_drift.isAnimating) _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _drift,
        builder: (context, _) => CustomPaint(
          painter: _DoctorAuraPainter(
            tone: widget.tone,
            progress: still ? _stillFrame : _drift.value,
            strength: widget.examining ? 1.35 : 1,
          ),
        ),
      ),
    );
  }
}

class _DoctorAuraPainter extends CustomPainter {
  const _DoctorAuraPainter({
    required this.tone,
    required this.progress,
    required this.strength,
  });

  final Color tone;
  final double progress;
  final double strength;

  /// Per-blob `(centre x, centre y, radius, alpha, speed)` in canvas fractions.
  static const _blobs = <(double, double, double, double, double)>[
    (0.16, 0.10, 0.62, 0.11, 1),
    (0.88, 0.04, 0.44, 0.07, -0.64),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, y, extent, alpha, speed) in _blobs) {
      final angle = progress * 2 * math.pi * speed;
      final center = Offset(
        size.width * (x + 0.03 * math.cos(angle)),
        size.height * (y + 0.12 * math.sin(angle)),
      );
      final radius = size.width * extent * 0.5;
      final bounds = Rect.fromCircle(center: center, radius: radius);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              tone.withValues(alpha: (alpha * strength).clamp(0.0, 1.0)),
              tone.withValues(alpha: 0),
            ],
          ).createShader(bounds),
      );
    }
  }

  @override
  bool shouldRepaint(_DoctorAuraPainter oldDelegate) =>
      oldDelegate.tone != tone ||
      oldDelegate.progress != progress ||
      oldDelegate.strength != strength;
}

/// A quiet at-a-glance readout under the verdict: the machine facts a reader
/// wants without opening the console — protection and confidence — each a glyph
/// with its value, dropped when the fact is still unknown.
class _DoctorGlance extends StatelessWidget {
  const _DoctorGlance({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final items = <(Glyph, String)>[
      if (snapshot.captureState != DoctorCaptureState.unknown)
        (
          AppGlyphs.shield,
          _captureStateLabel(appLocalizations, snapshot.captureState),
        ),
      if (snapshot.confidence != DoctorConfidence.unknown)
        (
          AppGlyphs.checklist,
          _confidenceLabel(appLocalizations, snapshot.confidence),
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        children: [
          for (final (icon, value) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlyphIcon(icon, size: 18, color: colors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  value,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A hairline that separates the verdict, the path proof, and the fixes inside
/// the diagnosis hero, so the three regions read as one card with structure
/// rather than three stacked panels.
class _DoctorSeam extends StatelessWidget {
  const _DoctorSeam();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Divider(
        height: 1,
        thickness: 1,
        color: context.colorScheme.outlineVariant,
      ),
    );
  }
}

class _RemedyButton extends StatelessWidget {
  const _RemedyButton({
    required this.remedy,
    required this.primary,
    required this.onPressed,
  });

  final DoctorRemedy remedy;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final (label, icon) = _remedyLabel(appLocalizations, remedy);
    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: GlyphIcon(icon),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: GlyphIcon(icon),
      label: Text(label),
    );
  }
}

/// The "what to try" steps, split out of the verdict card so the verdict keeps
/// a fixed shape and only this block grows when a problem has advice attached.
class _DoctorStepsCard extends StatelessWidget {
  const _DoctorStepsCard({required this.answer});

  final DoctorAnswer answer;

  @override
  Widget build(BuildContext context) {
    if (answer.steps.isEmpty) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    return FadeSlideEnterBox(
      axis: Axis.vertical,
      distance: _cardEnterDistance,
      delay: const Duration(milliseconds: 90),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CommonCard(
          radius: AppCorner.xl,
          child: Padding(
            padding: AppInsets.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.doctorWhatToTry,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final step in answer.steps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 8),
                          child: GlyphIcon(
                            AppGlyphs.chevronForward,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The console's diagnosis readout: the machine-level facts the verdict was
/// built from — protection, layer, scope, confidence, freshness — laid out as
/// a panel so it shares one card language with every other console section
/// instead of dropping into a list style of its own.
class _DoctorDetails extends StatelessWidget {
  const _DoctorDetails({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final rows = <(Glyph, String, String)>[
      (
        AppGlyphs.shield,
        appLocalizations.doctorProtection,
        _captureStateLabel(appLocalizations, snapshot.captureState),
      ),
      (
        AppGlyphs.layers,
        appLocalizations.doctorLayer,
        connectionDoctorLayerLabel(appLocalizations, snapshot.layer),
      ),
      (
        AppGlyphs.target,
        appLocalizations.doctorScope,
        _scopeLabel(appLocalizations, snapshot.scope),
      ),
      (
        AppGlyphs.checklist,
        appLocalizations.doctorConfidence,
        _confidenceLabel(appLocalizations, snapshot.confidence),
      ),
      (
        AppGlyphs.sync,
        appLocalizations.status,
        snapshot.isFresh
            ? appLocalizations.doctorFresh
            : appLocalizations.doctorStale,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _DoctorPanel(
        title: appLocalizations.doctorDetails,
        icon: AppGlyphs.info,
        body: Column(
          children: [
            for (final (index, (icon, label, value)) in rows.indexed) ...[
              if (index != 0) const SizedBox(height: AppSpacing.md),
              _DoctorFactRow(icon: icon, label: label, value: value),
            ],
          ],
        ),
      ),
    );
  }
}

/// One label/value fact line inside the console diagnosis panel: a quiet
/// leading glyph, the field name, and its reading pushed to the right edge.
class _DoctorFactRow extends StatelessWidget {
  const _DoctorFactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Glyph icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      children: [
        GlyphIcon(icon, size: 20, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class DoctorTimingPreview extends StatelessWidget {
  const DoctorTimingPreview({super.key});

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: context.appLocalizations.developerFindings,
    floatBody: true,
    body: SingleChildScrollView(
      padding: EdgeInsets.only(top: context.appBarInset),
      child: Column(
        children: [
          Padding(
            padding: AppInsets.lg,
            child: Text(context.appLocalizations.developerFindingsDesc),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _DoctorWaterfallCard(
              snapshot: DoctorSnapshot(
                supported: true,
                evidence: [
                  for (final (index, layer) in [
                    DoctorLayer.dns,
                    DoctorLayer.route,
                    DoctorLayer.dial,
                    DoctorLayer.transport,
                    DoctorLayer.marker,
                  ].indexed)
                    DoctorEvidence(
                      layer: layer,
                      outcome: DoctorEvidenceOutcome.succeeded,
                      durationBucketMs: (index + 1) * 25,
                      offsetMillis: index * 100,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
