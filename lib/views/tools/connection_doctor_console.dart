part of 'connection_doctor.dart';

/// The evidence on screen was gathered before the network or config changed, so
/// it may no longer describe the live connection.
class _DoctorDriftBanner extends StatelessWidget {
  const _DoctorDriftBanner();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonCard(
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
    );
  }
}

/// A titled console panel: an icon-led header with an optional trailing badge
/// over its body, so the waterfall, coverage, and audit lists share one frame.
class _DoctorPanel extends StatelessWidget {
  const _DoctorPanel({
    required this.title,
    required this.icon,
    required this.body,
    this.trailing,
  });

  final String title;
  final Glyph icon;
  final Widget body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
                GlyphIcon(icon, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            body,
          ],
        ),
      ),
    );
  }
}

/// The levers: pick a depth and run or cancel on one prominent button, with the
/// two manual tools demoted to a quiet list beneath a seam so the panel reads as
/// one primary action over its utilities instead of a stack of equal buttons. A
/// disabled DNS flush explains itself in one line so a greyed row is never a
/// dead end the reader has to guess at.
class _DoctorRunPanel extends StatelessWidget {
  const _DoctorRunPanel({
    required this.mode,
    required this.busy,
    required this.examining,
    required this.canStart,
    required this.canCancel,
    required this.canFlushDns,
    required this.flushReasonCode,
    required this.progress,
    required this.onMode,
    required this.onRun,
    required this.onCancel,
    required this.onFlushDns,
    required this.onExport,
  });

  final DoctorExamMode mode;
  final bool busy;
  final bool examining;
  final bool canStart;
  final bool canCancel;
  final bool canFlushDns;
  final String flushReasonCode;
  final DoctorProgress progress;
  final ValueChanged<DoctorExamMode> onMode;
  final VoidCallback onRun;
  final VoidCallback onCancel;
  final VoidCallback onFlushDns;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final progressValue = progress.total > 0
        ? (progress.completed / progress.total).clamp(0.0, 1.0)
        : null;
    final flushReason = canFlushDns
        ? null
        : switch (flushReasonCode) {
            'causeNotEligible' => appLocalizations.doctorFlushDnsUnavailable,
            'examActive' => appLocalizations.doctorActionUnavailable,
            _ => null,
          };
    // A disabled check must say why, so the lever never sits dead and silent.
    final runReason = examining || canStart
        ? null
        : appLocalizations.doctorActionUnavailable;
    // The button names the depth it will run, so it never just echoes the
    // panel title and the reader knows which check the tap starts.
    final runLabel = mode == DoctorExamMode.deep
        ? appLocalizations.doctorDeepExam
        : appLocalizations.doctorStandardExam;
    return _DoctorPanel(
      title: appLocalizations.doctorRun,
      icon: AppGlyphs.healthMonitor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            _DoctorProgressBar(value: progressValue, minHeight: 4),
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
                    label: Text(runLabel),
                  ),
          ),
          if (runReason != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              runReason,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1),
          ),
          _DoctorToolRow(
            icon: AppGlyphs.dns,
            label: appLocalizations.doctorFlushDns,
            reason: flushReason,
            onTap: busy || !canFlushDns ? null : onFlushDns,
          ),
          _DoctorToolRow(
            icon: AppGlyphs.export,
            label: appLocalizations.doctorExportReport,
            onTap: busy ? null : onExport,
          ),
        ],
      ),
    );
  }
}

/// A quiet, full-width manual tool inside the run panel: a tinted glyph, its
/// label, and — when the tool is unavailable — a one-line reason, laid out as a
/// tappable row so flush and export read as even utilities under the primary
/// run button rather than more full-width buttons competing with it.
class _DoctorToolRow extends StatelessWidget {
  const _DoctorToolRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.reason,
  });

  final Glyph icon;
  final String label;
  final VoidCallback? onTap;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final enabled = onTap != null;
    final accent = enabled ? colors.primary : colors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            GlyphIcon(icon, size: 20, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : colors.onSurfaceVariant,
                    ),
                  ),
                  if (reason != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      reason!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The console centrepiece: each probe drawn as a bar on a shared time axis,
/// placed by its start offset and sized by how long it took, with the whole
/// path's duration in the header and a one-line reading beneath.
class _DoctorWaterfallCard extends StatelessWidget {
  const _DoctorWaterfallCard({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final evidence = snapshot.evidence.take(14).toList();
    var maxEnd = 0;
    for (final fact in evidence) {
      final end = fact.offsetMillis + fact.durationBucketMs;
      if (end > maxEnd) maxEnd = end;
    }
    return _DoctorPanel(
      title: appLocalizations.doctorWaterfall,
      icon: AppGlyphs.signalChart,
      trailing: maxEnd > 0 ? MetaChip(label: context.delayText(maxEnd)) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoctorWaterfall(evidence: evidence, maxEnd: maxEnd),
          const SizedBox(height: AppSpacing.md),
          _DoctorWaterfallHint(evidence: evidence),
        ],
      ),
    );
  }
}

/// Reads the waterfall out loud: the break and where it stopped the path, or
/// the slowest measured layer with its time, or an all-clear.
class _DoctorWaterfallHint extends StatelessWidget {
  const _DoctorWaterfallHint({required this.evidence});

  final List<DoctorEvidence> evidence;

  @override
  Widget build(BuildContext context) {
    if (evidence.isEmpty) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    DoctorEvidence? broken;
    for (final fact in evidence) {
      if (fact.outcome == DoctorEvidenceOutcome.failed) {
        broken = fact;
        break;
      }
    }
    DoctorEvidence? slow;
    for (final fact in evidence) {
      if (fact.consequence || fact.durationBucketMs <= 0) continue;
      if (slow == null || fact.durationBucketMs > slow.durationBucketMs) {
        slow = fact;
      }
    }
    late final Color tone;
    late final Glyph icon;
    late final String text;
    var strong = false;
    if (broken != null) {
      tone = colors.error;
      icon = AppGlyphs.error;
      text = appLocalizations.doctorWaterfallHintBreak(
        connectionDoctorLayerLabel(appLocalizations, broken.layer),
      );
      strong = true;
    } else if (slow != null) {
      tone = colors.onSurfaceVariant;
      icon = AppGlyphs.signalChart;
      text = appLocalizations.doctorWaterfallHintSlow(
        connectionDoctorLayerLabel(appLocalizations, slow.layer),
        context.delayText(slow.durationBucketMs),
      );
    } else {
      tone = colors.success;
      icon = AppGlyphs.check;
      text = appLocalizations.doctorWaterfallHintClear;
    }
    return Container(
      width: double.infinity,
      padding: AppInsets.md,
      decoration: ShapeDecoration(
        color: tone.withValues(alpha: 0.12),
        shape: AppShape.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlyphIcon(icon, color: tone, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorWaterfall extends StatelessWidget {
  const _DoctorWaterfall({required this.evidence, required this.maxEnd});

  final List<DoctorEvidence> evidence;
  final int maxEnd;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (evidence.isEmpty) {
      return _DoctorEmptyRow(text: appLocalizations.doctorNoEvidence);
    }
    final scale = maxEnd > 0 ? maxEnd : 1;
    return Column(
      children: [
        for (final fact in evidence)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _WaterfallRow(fact: fact, maxEnd: scale),
          ),
      ],
    );
  }
}

/// One probe as a bar on the shared axis. The reading rides just past the bar
/// end — a trailing zone is reserved on every row so the number always lands
/// beside its own bar instead of in a distant fixed column.
class _WaterfallRow extends StatelessWidget {
  const _WaterfallRow({required this.fact, required this.maxEnd});

  final DoctorEvidence fact;
  final int maxEnd;

  static const _labelWidth = 84.0;
  static const _trackHeight = 18.0;
  static const _minBar = 6.0;
  static const _msZone = 52.0;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final color = _waterfallColor(context, fact.outcome);
    // A zero bucket is an unmeasured probe, not a 0 ms one, so it carries no
    // reading rather than claiming a duration it never had.
    final ms = fact.durationBucketMs > 0
        ? context.delayText(fact.durationBucketMs)
        : '';
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
              final reserve = ms.isEmpty ? 0.0 : _msZone;
              final usable = width - reserve > _minBar
                  ? width - reserve
                  : _minBar;
              final scale = usable / maxEnd;
              var left = (fact.offsetMillis * scale).clamp(0.0, usable);
              var barWidth = fact.durationBucketMs * scale;
              if (barWidth < _minBar) barWidth = _minBar;
              if (left + barWidth > usable) {
                left = (usable - barWidth).clamp(0.0, usable);
              }
              final barEnd = left + barWidth;
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
                      width: barWidth,
                      child: Opacity(
                        opacity: fact.consequence ? 0.45 : 1,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: color,
                            shape: AppShape.full,
                          ),
                        ),
                      ),
                    ),
                    if (ms.isNotEmpty)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: barEnd + 6,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ms,
                            style: context.textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant)
                                .toJetBrainsMono,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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
      child: _DoctorPanel(
        title: appLocalizations.doctorCapabilities,
        icon: AppGlyphs.checklist,
        body: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, covered) in entries)
              AppTag(
                label,
                foreground: covered ? colors.success : colors.onSurfaceVariant,
                background: covered
                    ? colors.success.withValues(alpha: 0.14)
                    : null,
              ),
          ],
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
    final colors = context.colorScheme;
    final audits = snapshot.healAudit.reversed.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _DoctorPanel(
        title: appLocalizations.doctorHealAttempts,
        icon: AppGlyphs.wrench,
        body: audits.isEmpty
            ? _DoctorEmptyRow(text: appLocalizations.doctorNoHealAttempts)
            : Column(
                children: [
                  for (final audit in audits)
                    _DoctorArow(
                      icon: AppGlyphs.wrench,
                      tone: _healTone(colors, audit.outcome),
                      title: _healTitle(appLocalizations, audit),
                      subtitle: audit.outcome,
                      time: _clock(audit.at),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Recent completed checks, newest first, each read as a titled verdict with
/// its depth and the layer it settled on.
class _DoctorHistoryPanel extends StatelessWidget {
  const _DoctorHistoryPanel({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final incidents = snapshot.incidents.reversed.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: _DoctorPanel(
        title: appLocalizations.doctorRecentChecks,
        icon: AppGlyphs.history,
        body: incidents.isEmpty
            ? _DoctorEmptyRow(text: appLocalizations.doctorNoIncidents)
            : Column(
                children: [
                  for (final incident in incidents)
                    _DoctorArow(
                      icon: _incidentIcon(incident),
                      tone: _incidentTone(colors, incident.health),
                      title: _incidentTitle(appLocalizations, incident),
                      subtitle:
                          '${_modeLabel(appLocalizations, incident.mode)} · '
                          '${connectionDoctorLayerLabel(appLocalizations, incident.layer)}',
                      time: _clock(incident.finishedAt),
                    ),
                ],
              ),
      ),
    );
  }
}

/// A medallion-led audit line: title, a quiet subtitle, and the clock time it
/// happened, mirroring the heal and history rows on one shape.
class _DoctorArow extends StatelessWidget {
  const _DoctorArow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final Glyph icon;
  final Color tone;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AppMedallion(icon: icon, tone: tone, size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              time,
              style: context.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant)
                  .toJetBrainsMono,
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorEmptyRow extends StatelessWidget {
  const _DoctorEmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      children: [
        GlyphIcon(AppGlyphs.hourglass, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The raw records, tucked behind a disclosure so the expert can open the full
/// evidence log without it crowding the surface that reads itself.
class _DoctorEvidenceDisclosure extends StatefulWidget {
  const _DoctorEvidenceDisclosure({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  State<_DoctorEvidenceDisclosure> createState() =>
      _DoctorEvidenceDisclosureState();
}

class _DoctorEvidenceDisclosureState extends State<_DoctorEvidenceDisclosure> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final evidence = widget.snapshot.evidence.reversed.take(24).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: CommonCard(
        radius: AppCorner.xl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: AppRadius.xl,
              child: Padding(
                padding: AppInsets.xl,
                child: Row(
                  children: [
                    GlyphIcon(AppGlyphs.layers, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        appLocalizations.doctorRawEvidence,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      appLocalizations.doctorRawEvidenceCount(evidence.length),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: context.motionDuration(commonDuration),
                      child: GlyphIcon(
                        AppGlyphs.chevronDown,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: context.motionDuration(commonDuration),
              alignment: Alignment.topCenter,
              curve: Curves.easeOutCubic,
              child: _open
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: evidence.isEmpty
                          ? _DoctorEmptyRow(
                              text: appLocalizations.doctorNoEvidence,
                            )
                          : Column(
                              children: [
                                for (final fact in evidence)
                                  _DoctorEvidenceRow(fact: fact),
                              ],
                            ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorEvidenceRow extends StatelessWidget {
  const _DoctorEvidenceRow({required this.fact});

  final DoctorEvidence fact;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = context.colorScheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlyphIcon(
            _evidenceIcon(fact.outcome),
            size: 20,
            color: _waterfallColor(context, fact.outcome),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connectionDoctorLayerLabel(appLocalizations, fact.layer),
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _evidenceDescription(appLocalizations, fact),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (fact.consequence) ...[
            const SizedBox(width: AppSpacing.sm),
            AppTooltip(
              message: appLocalizations.doctorEvidenceConsequence,
              child: GlyphIcon(
                AppGlyphs.subItem,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (fact.durationBucketMs > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.delayText(fact.durationBucketMs),
              style: context.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant)
                  .toJetBrainsMono,
            ),
          ],
        ],
      ),
    );
    // A consequence was skipped after an upstream fault, so it reads dimmed
    // just as the waterfall dims it, keeping raw evidence and picture in step.
    return fact.consequence ? Opacity(opacity: 0.6, child: row) : row;
  }
}

String _healTitle(AppLocalizations appLocalizations, DoctorHealAudit audit) =>
    switch (audit.actionId) {
      'flushDns' => appLocalizations.doctorFlushDns,
      _ => audit.actionId,
    };

Color _healTone(ColorScheme colors, String outcome) {
  if (outcome.isEmpty) return colors.outline;
  final lower = outcome.toLowerCase();
  if (lower.contains('fail') || lower.contains('error')) return colors.error;
  return colors.success;
}

Color _incidentTone(ColorScheme colors, DoctorHealth health) =>
    switch (health) {
      DoctorHealth.broken => colors.error,
      DoctorHealth.degraded => colors.warning,
      DoctorHealth.healthy => colors.success,
      DoctorHealth.unknown => colors.outline,
    };

/// Epoch millis as a bare wall-clock HH:mm; empty for an unset timestamp.
String _clock(int epochMs) {
  if (epochMs <= 0) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
