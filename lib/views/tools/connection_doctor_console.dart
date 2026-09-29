part of 'connection_doctor.dart';

/// The expert console: the real diagnostic levers and the raw evidence behind
/// the answer, pushed off the main screen so the verdict stays uncluttered.
/// Its centrepiece is a latency waterfall — every probe placed by when it
/// started and how long it took.
class DoctorConsoleView extends ConsumerStatefulWidget {
  const DoctorConsoleView({super.key});

  @override
  ConsumerState<DoctorConsoleView> createState() => _DoctorConsoleViewState();
}

class _DoctorConsoleViewState extends ConsumerState<DoctorConsoleView>
    with _DoctorActionsMixin {
  DoctorExamMode _mode = DoctorExamMode.standard;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    final examining = snapshot.state == DoctorExamState.examining;
    final canStart = snapshot.action('startStandard')?.eligible == true;
    final canCancel = snapshot.action('cancel')?.eligible == true;
    final drift =
        snapshot.supported &&
        snapshot.isFresh &&
        snapshot.startGenerations != snapshot.generations;
    return CommonScaffold(
      title: appLocalizations.doctorTechnicalDetails,
      floatBody: true,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.refresh,
          tooltip: appLocalizations.doctorRefresh,
          isLoading: _busy,
          onPressed: () => unawaited(_refresh(showError: true)),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          if (drift) const _DoctorDriftBanner(),
          _DoctorRunPanel(
            mode: _mode,
            busy: _busy,
            examining: examining,
            canStart: canStart,
            canCancel: canCancel,
            progress: snapshot.progress,
            onMode: (mode) => setState(() => _mode = mode),
            onRun: () => unawaited(_start(_mode)),
            onCancel: () => unawaited(_cancel()),
          ),
          if (snapshot.supported)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _DoctorWaterfallCard(snapshot: snapshot),
            ),
          _DoctorCapabilitiesSection(snapshot: snapshot),
          _DoctorDetails(snapshot: snapshot),
          _DoctorHealSection(snapshot: snapshot),
          _DoctorHistorySection(snapshot: snapshot),
          _DoctorEvidenceSection(snapshot: snapshot),
          if (snapshot.supported)
            SettingSection(
              items: [
                DecorationListItem(
                  leading: const GlyphIcon(AppGlyphs.share),
                  title: Text(appLocalizations.doctorExportReport),
                  onPressed: _busy ? null : () => unawaited(_exportReport()),
                ),
              ],
            ),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

/// The evidence on screen was gathered before the network or config changed, so
/// it may no longer describe the live connection.
class _DoctorDriftBanner extends StatelessWidget {
  const _DoctorDriftBanner();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: CommonCard(
        type: CommonCardType.filled,
        radius: AppCorner.xl,
        child: Padding(
          padding: AppInsets.lg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppMedallion(
                icon: AppGlyphs.warning,
                tone: context.colorScheme.warning,
                size: 36,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  appLocalizations.doctorGenerationDrift,
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard/deep selector plus the run or cancel button. The eligibility of
/// `startStandard` gates both modes, matching the answer card.
class _DoctorRunPanel extends StatelessWidget {
  const _DoctorRunPanel({
    required this.mode,
    required this.busy,
    required this.examining,
    required this.canStart,
    required this.canCancel,
    required this.progress,
    required this.onMode,
    required this.onRun,
    required this.onCancel,
  });

  final DoctorExamMode mode;
  final bool busy;
  final bool examining;
  final bool canStart;
  final bool canCancel;
  final DoctorProgress progress;
  final ValueChanged<DoctorExamMode> onMode;
  final VoidCallback onRun;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final progressValue = progress.total > 0
        ? (progress.completed / progress.total).clamp(0.0, 1.0)
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: CommonCard(
        radius: AppCorner.xl,
        child: Padding(
          padding: AppInsets.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlyphIcon(AppGlyphs.healthMonitor, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    appLocalizations.doctorRun,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<DoctorExamMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: DoctorExamMode.standard,
                    icon: const GlyphIcon(AppGlyphs.play, size: 20),
                    label: Text(appLocalizations.doctorModeStandard),
                  ),
                  ButtonSegment(
                    value: DoctorExamMode.deep,
                    icon: const GlyphIcon(AppGlyphs.search, size: 20),
                    label: Text(appLocalizations.doctorModeDeep),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: busy || examining
                    ? null
                    : (selection) => onMode(selection.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (examining) ...[
                LinearProgressIndicator(value: progressValue, minHeight: 4),
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
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(
                width: double.infinity,
                child: examining
                    ? OutlinedButton.icon(
                        onPressed: busy || !canCancel ? null : onCancel,
                        icon: const GlyphIcon(AppGlyphs.stop),
                        label: Text(appLocalizations.doctorCancelExam),
                      )
                    : FilledButton.icon(
                        onPressed: busy || !canStart ? null : onRun,
                        icon: const GlyphIcon(AppGlyphs.play),
                        label: Text(appLocalizations.doctorRun),
                      ),
              ),
              if (!examining && !canStart) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  appLocalizations.doctorActionUnavailable,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The console centrepiece: each probe drawn as a bar on a shared time axis,
/// placed by its start offset and sized by how long it took.
class _DoctorWaterfallCard extends StatelessWidget {
  const _DoctorWaterfallCard({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    return CommonCard(
      radius: AppCorner.xl,
      child: Padding(
        padding: AppInsets.xl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlyphIcon(AppGlyphs.signalChart, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    appLocalizations.doctorWaterfall,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              appLocalizations.doctorWaterfallDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DoctorWaterfall(snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class _DoctorWaterfall extends StatelessWidget {
  const _DoctorWaterfall({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final evidence = snapshot.evidence.take(14).toList();
    if (evidence.isEmpty) {
      return Row(
        children: [
          GlyphIcon(AppGlyphs.hourglass, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            appLocalizations.doctorNoEvidence,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    var maxEnd = 1;
    for (final fact in evidence) {
      final end = fact.offsetMillis + fact.durationBucketMs;
      if (end > maxEnd) maxEnd = end;
    }
    return Column(
      children: [
        for (final fact in evidence)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _WaterfallRow(fact: fact, maxEnd: maxEnd),
          ),
      ],
    );
  }
}

class _WaterfallRow extends StatelessWidget {
  const _WaterfallRow({required this.fact, required this.maxEnd});

  final DoctorEvidence fact;
  final int maxEnd;

  static const _labelWidth = 84.0;
  static const _timeWidth = 56.0;
  static const _trackHeight = 16.0;
  static const _minBar = 6.0;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final color = _waterfallColor(context, fact.outcome);
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            connectionDoctorLayerLabel(appLocalizations, fact.layer),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final scale = width / maxEnd;
              final left = (fact.offsetMillis * scale).clamp(0.0, width);
              var barWidth = fact.durationBucketMs * scale;
              if (barWidth < _minBar) barWidth = _minBar;
              if (left + barWidth > width) {
                barWidth = (width - left).clamp(_minBar, width);
              }
              return SizedBox(
                height: _trackHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: colors.surfaceContainerHighest,
                          shape: AppShape.full,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: left,
                      child: Opacity(
                        opacity: fact.consequence ? 0.5 : 1,
                        child: Container(
                          width: barWidth,
                          decoration: ShapeDecoration(
                            color: color,
                            shape: AppShape.full,
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
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: _timeWidth,
          // A zero bucket is an unmeasured probe, not a 0 ms one, so it stays
          // blank rather than claiming a duration it never had.
          child: fact.durationBucketMs > 0
              ? Text(
                  '${fact.durationBucketMs} ms',
                  textAlign: TextAlign.right,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant)
                      .toJetBrainsMono,
                )
              : null,
        ),
      ],
    );
  }
}

Color _waterfallColor(BuildContext context, DoctorEvidenceOutcome outcome) {
  final colors = context.colorScheme;
  return switch (outcome) {
    DoctorEvidenceOutcome.succeeded => colors.success,
    DoctorEvidenceOutcome.failed => colors.error,
    DoctorEvidenceOutcome.dropped => colors.warning,
    DoctorEvidenceOutcome.seen => colors.primary,
    DoctorEvidenceOutcome.notApplicable ||
    DoctorEvidenceOutcome.unknown => colors.outlineVariant,
  };
}

/// What the current build/platform can actually probe, so the reader knows
/// which absent evidence is a real gap and which is simply out of scope here.
class _DoctorCapabilitiesSection extends StatelessWidget {
  const _DoctorCapabilitiesSection({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final caps = snapshot.capabilities;
    final entries = <(String, bool)>[
      (appLocalizations.doctorCapabilityPassiveWitness, caps.passiveWitness),
      (appLocalizations.doctorCapabilityExplicitExam, caps.explicitExam),
      (appLocalizations.doctorCapabilityCancel, caps.cancel),
      (appLocalizations.doctorCapabilityDnsFlush, caps.dnsFlush),
      (
        appLocalizations.doctorCapabilityAppIngressProbe,
        caps.androidAppIngressProbe,
      ),
      (appLocalizations.doctorCapabilityTunIngressProof, caps.tunIngressProof),
      (appLocalizations.doctorCapabilityByedpiStatus, caps.byedpiStatus),
      (appLocalizations.doctorCapabilityRedactedExport, caps.redactedExport),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: CommonCard(
        radius: AppCorner.xl,
        child: Padding(
          padding: AppInsets.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlyphIcon(AppGlyphs.checklist, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      appLocalizations.doctorCapabilities,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (label, covered) in entries)
                    AppTag(
                      label,
                      foreground: covered
                          ? colors.success
                          : colors.onSurfaceVariant,
                      background: covered
                          ? colors.success.withValues(alpha: 0.14)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every auto-repair the core attempted, newest first, with its outcome. DNS
/// flush is the only heal today, but the audit trail is generic.
class _DoctorHealSection extends StatelessWidget {
  const _DoctorHealSection({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final audits = snapshot.healAudit.reversed.take(5).toList();
    return SettingSection(
      title: appLocalizations.doctorHealAttempts,
      items: audits.isEmpty
          ? [
              DecorationListItem(
                leading: const GlyphIcon(AppGlyphs.wrench),
                title: Text(appLocalizations.doctorNoHealAttempts),
              ),
            ]
          : [
              for (final audit in audits)
                DecorationListItem(
                  leading: const GlyphIcon(AppGlyphs.wrench),
                  title: Text(_healTitle(appLocalizations, audit)),
                  trailing: audit.outcome.isEmpty
                      ? null
                      : AppTag(audit.outcome, mono: true),
                ),
            ],
    );
  }
}

String _healTitle(AppLocalizations appLocalizations, DoctorHealAudit audit) =>
    switch (audit.actionId) {
      'flushDns' => appLocalizations.doctorFlushDns,
      _ => audit.actionId,
    };


