part of 'connection_doctor.dart';

class _ConnectionDoctorViewState extends ConsumerState<ConnectionDoctorView> {
  String? _busyAction;
  bool _initializing = true;
  bool _showTechnicalDetails = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  // Opening the screen is a deliberate visit, so it answers with a live check
  // instead of the passive idle state that made the old screen look empty.
  Future<void> _bootstrap() async {
    await _refresh(showError: false);
    if (!mounted) return;
    final snapshot = ref.read(connectionDoctorProvider);
    final idle =
        snapshot.state != DoctorExamState.examining &&
        (!snapshot.isFresh || snapshot.state == DoctorExamState.observing);
    if (idle && snapshot.action('startStandard')?.eligible == true) {
      await _start(DoctorExamMode.standard, showError: false);
    }
  }

  Future<void> _refresh({required bool showError}) async {
    try {
      await ref.read(connectionDoctorProvider.notifier).refresh();
    } catch (error) {
      if (showError) {
        dialogs.showNotifier(compactError(error), level: MessageLevel.error);
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
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
        await _runAction('flushDns', () async {
          await ref.read(connectionDoctorProvider.notifier).flushDns();
        });
      case DoctorRemedy.pickNode:
        _leaveTo(PageLabel.proxies);
      case DoctorRemedy.openProfiles:
        _leaveTo(PageLabel.profiles);
      case DoctorRemedy.openDns:
        await _openConfig(
          const BaseScaffold(title: 'DNS', body: DnsListView()),
        );
      case DoctorRemedy.openAdvanced:
        await _openConfig(const AdvancedConfigView());
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

  Future<void> _openConfig(Widget view) => BaseNavigator.push(context, view);

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
          isLoading: _busyAction != null,
          onPressed: () => unawaited(_refresh(showError: true)),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.only(top: context.appBarInset),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _DoctorAnswerCard(
              snapshot: snapshot,
              answer: answer,
              busy: _busyAction != null,
              canStart: snapshot.action('startStandard')?.eligible == true,
              canFlushDns: snapshot.action('flushDns')?.eligible == true,
              canCancel: snapshot.action('cancel')?.eligible == true,
              onRemedy: (remedy) => unawaited(_applyRemedy(remedy)),
              onStart: () => unawaited(_start(DoctorExamMode.standard)),
              onCancel: () => unawaited(
                _runAction('cancel', () async {
                  await ref.read(connectionDoctorProvider.notifier).cancel();
                }),
              ),
            ),
          ),
          if (snapshot.supported)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CommonCard(
                radius: AppCorner.xl,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConnectionDoctorPathMap(
                    snapshot: snapshot,
                    blame: answer.blame,
                  ),
                ),
              ),
            ),
          if (snapshot.supported)
            SettingSection(
              items: [
                DecorationListItem(
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(appLocalizations.doctorTechnicalDetails),
                  trailing: Icon(
                    _showTechnicalDetails
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  onPressed: () => setState(
                    () => _showTechnicalDetails = !_showTechnicalDetails,
                  ),
                ),
              ],
            ),
          if (_showTechnicalDetails) ...[
            _DoctorExpertActions(
              snapshot: snapshot,
              busy: _busyAction != null,
              onDeepCheck: () => unawaited(_start(DoctorExamMode.deep)),
              onExport: () => unawaited(_exportReport()),
            ),
            _DoctorDetails(snapshot: snapshot),
            _DoctorEvidenceSection(snapshot: snapshot),
            _DoctorHistorySection(snapshot: snapshot),
          ],
          _DoctorLimitationsSection(snapshot: snapshot),
          const SettingBottomInset(),
        ],
      ),
    );
  }
}

/// The single answer the screen leads with: what happened, what it means, what
/// to try, and buttons that carry each fix out.
class _DoctorAnswerCard extends StatelessWidget {
  const _DoctorAnswerCard({
    required this.snapshot,
    required this.answer,
    required this.busy,
    required this.canStart,
    required this.canFlushDns,
    required this.canCancel,
    required this.onRemedy,
    required this.onStart,
    required this.onCancel,
  });

  final DoctorSnapshot snapshot;
  final DoctorAnswer answer;
  final bool busy;
  final bool canStart;
  final bool canFlushDns;
  final bool canCancel;
  final ValueChanged<DoctorRemedy> onRemedy;
  final VoidCallback onStart;
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
    final showStart =
        !answer.storm &&
        snapshot.supported &&
        canStart &&
        !examining &&
        !remedies.contains(DoctorRemedy.recheck);
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.xl,
      isError: answer.tone == DoctorAnswerTone.bad,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnswerBadge(icon: _answerIcon(answer.tone), tone: tone),
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
                      const SizedBox(height: 4),
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
            ),
            if (examining) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progressValue, minHeight: 4),
              const SizedBox(height: 8),
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
            if (answer.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                appLocalizations.doctorWhatToTry,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              for (final step in answer.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Icon(
                          Icons.arrow_right_rounded,
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
            if (remedies.isNotEmpty ||
                showStart ||
                (examining && canCancel)) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in remedies.asMap().entries)
                    _RemedyButton(
                      remedy: entry.value,
                      primary: entry.key == 0,
                      onPressed: busy ? null : () => onRemedy(entry.value),
                    ),
                  if (showStart)
                    FilledButton.tonalIcon(
                      onPressed: busy ? null : onStart,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(appLocalizations.doctorStandardExam),
                    ),
                  if (examining && canCancel)
                    OutlinedButton.icon(
                      onPressed: busy ? null : onCancel,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: Text(appLocalizations.doctorCancelExam),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  const _AnswerBadge({required this.icon, required this.tone});

  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: AppShape.all(AppCorner.md),
        color: tone.withValues(alpha: 0.14),
      ),
      child: Icon(icon, size: 24, color: tone),
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
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

/// Deep check and report export live here: real controls, but for the curious,
/// not the answer everyone needs.
class _DoctorExpertActions extends StatelessWidget {
  const _DoctorExpertActions({
    required this.snapshot,
    required this.busy,
    required this.onDeepCheck,
    required this.onExport,
  });

  final DoctorSnapshot snapshot;
  final bool busy;
  final VoidCallback onDeepCheck;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final canStart = snapshot.action('startStandard')?.eligible == true;
    return SettingSection(
      items: [
        DecorationListItem(
          leading: const Icon(Icons.manage_search_rounded),
          title: Text(appLocalizations.doctorDeepExam),
          onPressed: busy || !canStart ? null : onDeepCheck,
        ),
        DecorationListItem(
          leading: const Icon(Icons.ios_share_rounded),
          title: Text(appLocalizations.doctorExportReport),
          onPressed: busy ? null : onExport,
        ),
      ],
    );
  }
}

class _DoctorDetails extends StatelessWidget {
  const _DoctorDetails({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    return SettingSection(
      title: appLocalizations.doctorDetails,
      items: [
        DecorationListItem(
          leading: const Icon(Icons.shield_outlined),
          title: Text(appLocalizations.doctorProtection),
          trailing: Text(
            _captureStateLabel(appLocalizations, snapshot.captureState),
          ),
        ),
        DecorationListItem(
          leading: const Icon(Icons.layers_outlined),
          title: Text(appLocalizations.doctorLayer),
          trailing: Text(
            connectionDoctorLayerLabel(appLocalizations, snapshot.layer),
          ),
        ),
        DecorationListItem(
          leading: const Icon(Icons.filter_center_focus_rounded),
          title: Text(appLocalizations.doctorScope),
          trailing: Text(_scopeLabel(appLocalizations, snapshot.scope)),
        ),
        DecorationListItem(
          leading: const Icon(Icons.fact_check_outlined),
          title: Text(appLocalizations.doctorConfidence),
          trailing: Text(
            _confidenceLabel(appLocalizations, snapshot.confidence),
          ),
        ),
        DecorationListItem(
          leading: const Icon(Icons.update_rounded),
          title: Text(appLocalizations.status),
          trailing: Text(
            snapshot.isFresh
                ? appLocalizations.doctorFresh
                : appLocalizations.doctorStale,
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
            padding: const EdgeInsets.all(16),
            child: Text(context.appLocalizations.developerFindingsDesc),
          ),
          _DoctorEvidenceSection(
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
                    durationBucketMs: (index + 1) * 25,
                    offsetMillis: index * 100,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DoctorEvidenceSection extends StatelessWidget {
  const _DoctorEvidenceSection({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final evidence = snapshot.evidence.reversed.take(12).toList();
    return SettingSection(
      title: appLocalizations.doctorEvidence,
      items: evidence.isEmpty
          ? [
              DecorationListItem(
                leading: const Icon(Icons.hourglass_empty_rounded),
                title: Text(appLocalizations.doctorNoEvidence),
              ),
            ]
          : [
              for (final fact in evidence)
                DecorationListItem(
                  leading: Icon(_evidenceIcon(fact.outcome)),
                  title: Text(
                    connectionDoctorLayerLabel(appLocalizations, fact.layer),
                  ),
                  subtitle: Text(_evidenceDescription(appLocalizations, fact)),
                  trailing: fact.consequence
                      ? Tooltip(
                          message: appLocalizations.doctorEvidenceConsequence,
                          child: const Icon(Icons.subdirectory_arrow_right),
                        )
                      : null,
                ),
            ],
    );
  }
}

class _DoctorHistorySection extends StatelessWidget {
  const _DoctorHistorySection({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.supported) return const SizedBox.shrink();
    final appLocalizations = context.appLocalizations;
    final incidents = snapshot.incidents.reversed.take(5).toList();
    return SettingSection(
      title: appLocalizations.doctorRecentChecks,
      items: incidents.isEmpty
          ? [
              DecorationListItem(
                leading: const Icon(Icons.history_rounded),
                title: Text(appLocalizations.doctorNoIncidents),
              ),
            ]
          : [
              for (final incident in incidents)
                DecorationListItem(
                  leading: Icon(_incidentIcon(incident)),
                  title: Text(_incidentTitle(appLocalizations, incident)),
                  subtitle: Text(
                    '${_modeLabel(appLocalizations, incident.mode)} · '
                    '${connectionDoctorLayerLabel(appLocalizations, incident.layer)}',
                  ),
                ),
            ],
    );
  }
}

class _DoctorLimitationsSection extends StatelessWidget {
  const _DoctorLimitationsSection({required this.snapshot});

  final DoctorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = <Widget>[];
    if (!snapshot.supported) {
      items.add(
        DecorationListItem(
          leading: const Icon(Icons.extension_off_outlined),
          title: Text(appLocalizations.doctorUnsupportedHint),
        ),
      );
    } else {
      items.add(
        DecorationListItem(
          leading: const Icon(Icons.visibility_outlined),
          title: Text(appLocalizations.doctorPassiveHint),
        ),
      );
      if (!snapshot.isFresh) {
        items.add(
          DecorationListItem(
            leading: const Icon(Icons.schedule_rounded),
            title: Text(appLocalizations.doctorStaleHint),
          ),
        );
      }
      if (snapshot.evidenceDropped > 0) {
        items.add(
          DecorationListItem(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text(
              appLocalizations.doctorEvidenceDropped(snapshot.evidenceDropped),
            ),
          ),
        );
      }
    }
    return SettingSection(
      title: appLocalizations.doctorLimitations,
      items: items,
    );
  }
}
