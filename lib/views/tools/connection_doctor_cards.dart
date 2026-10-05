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
    final confirmed = await dialogs.showMessage(
      context: context,
      title: appLocalizations.doctorExportReport,
      confirmText: appLocalizations.doctorExportReport,
      message: TextSpan(text: appLocalizations.doctorExportConfirm),
    );
    if (confirmed != true || !mounted) return;
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
        _openConfig(const DnsView(), paneId: 'dns', title: 'DNS');
      case DoctorRemedy.openAdvanced:
        _openConfig(
          const AdvancedConfigView(),
          paneId: 'advanced',
          title: context.appLocalizations.advancedConfig,
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

  // Inside a desktop two-pane tool the remedy drills into the same detail pane;
  // a standalone Doctor (sheet or mobile) has no pane, so it defers to
  // [showExtend] like every other open row: a side sheet on desktop, a full
  // page on mobile, never a full-window route stacked over the Doctor sheet.
  void _openConfig(
    Widget view, {
    required String paneId,
    required String title,
  }) {
    final pane = SettingsPaneScope.of(context);
    if (pane != null && pane.active && pane.pushes) {
      pane.onSelect(
        SettingsPaneSelection(id: paneId, detail: view, title: Text(title)),
      );
      return;
    }
    unawaited(showExtend(context, builder: (_) => view));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    final answer = connectionDoctorAnswer(appLocalizations, snapshot);
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
                      child: _DoctorTabView(
                        children: [
                          _overviewTab(snapshot, answer, inset: false),
                          _technicalTab(snapshot),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _overviewTab(snapshot, answer, inset: true),
    );
  }

  Widget _overviewTab(
    DoctorSnapshot snapshot,
    DoctorAnswer answer, {
    required bool inset,
  }) {
    return ListView(
      key: const PageStorageKey('doctor-overview'),
      padding: EdgeInsets.only(
        top: inset ? context.contentTopPadding : AppSpacing.md,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: _DoctorSmoothResize(
            child: _DoctorDiagnosisCard(
              snapshot: snapshot,
              answer: answer,
              busy: _busy,
              canStart: snapshot.action('startStandard')?.eligible == true,
              canFlushDns: snapshot.action('flushDns')?.eligible == true,
              canCancel: snapshot.action('cancel')?.eligible == true,
              onRemedy: (remedy) => unawaited(_applyRemedy(remedy)),
              onCancel: () => unawaited(_cancel()),
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

/// Animates a child's height changes instead of snapping, so the verdict and
/// steps cards glide as an exam moves between checking, result, and idle —
/// the jumps the old screen showed on every check.
class _DoctorSmoothResize extends StatelessWidget {
  const _DoctorSmoothResize({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: context.motionDuration(commonDuration),
      alignment: Alignment.topCenter,
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

/// Shows only the tab the [DefaultTabController] points at, cross-fading on a
/// switch. A `TabBarView` would add its own paging scrollable and keep the
/// inactive tab's list mounted; keeping a single scroll view here leaves the
/// Doctor one lever per screen and one scroll target for its tests.
class _DoctorTabView extends StatefulWidget {
  const _DoctorTabView({required this.children});

  final List<Widget> children;

  @override
  State<_DoctorTabView> createState() => _DoctorTabViewState();
}

class _DoctorTabViewState extends State<_DoctorTabView> {
  TabController? _controller;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (controller == _controller) return;
    _controller?.removeListener(_handleChange);
    _controller = controller;
    _index = controller.index;
    controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    final controller = _controller;
    if (controller == null || !mounted || controller.index == _index) return;
    setState(() => _index = controller.index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      child: KeyedSubtree(
        key: ValueKey(_index),
        child: widget.children[_index],
      ),
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
      return LinearProgressIndicator(minHeight: minHeight);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value!.clamp(0.0, 1.0)),
      duration: context.motionDuration(const Duration(milliseconds: 350)),
      curve: Curves.easeOut,
      builder: (context, animated, _) =>
          LinearProgressIndicator(value: animated, minHeight: minHeight),
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
    required this.canStart,
    required this.canFlushDns,
    required this.canCancel,
    required this.onRemedy,
    required this.onCancel,
  });

  final DoctorSnapshot snapshot;
  final DoctorAnswer answer;
  final bool busy;
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
      child: Padding(
        padding: AppInsets.lg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _verdict(context, appLocalizations, colors, tone),
            if (snapshot.supported &&
                snapshot.isFresh &&
                !examining &&
                snapshot.evidence.isNotEmpty)
              _DoctorGlance(snapshot: snapshot),
            if (examining) ...[
              const SizedBox(height: AppSpacing.lg),
              _DoctorProgressBar(value: progressValue, minHeight: 6),
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
            if (snapshot.supported) ...[
              const _DoctorSeam(),
              ConnectionDoctorPathMap(snapshot: snapshot, blame: answer.blame),
            ],
            if (showActions) ...[
              const _DoctorSeam(),
              _actions(
                context,
                appLocalizations,
                remedies: remedies,
                examining: examining,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _verdict(
    BuildContext context,
    AppLocalizations appLocalizations,
    ColorScheme colors,
    Color tone,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorVerdictMark(icon: _answerIcon(answer.tone), tone: tone),
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

/// The verdict glyph as a living mark: a tone-tinted halo behind the medallion
/// that swells in as the answer resolves, so a settled result lands with weight
/// instead of appearing flat. One-shot, so it never fights `pumpAndSettle`.
class _DoctorVerdictMark extends StatelessWidget {
  const _DoctorVerdictMark({required this.icon, required this.tone});

  final Glyph icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(tone),
      tween: Tween(begin: 0, end: 1),
      duration: context.motionDuration(commonDuration),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final eased = value.clamp(0.0, 1.0);
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: AppShape.md,
            shadows: [
              BoxShadow(
                color: tone.withValues(alpha: 0.4 * eased),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Transform.scale(scale: 0.72 + 0.28 * value, child: child),
        );
      },
      child: AppMedallion(icon: icon, tone: tone, size: 48),
    );
  }
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
    return Padding(
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
                        child: Text(step, style: context.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
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
        AppGlyphs.update,
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
