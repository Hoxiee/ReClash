import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/advanced.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_doctor_path.dart';

String connectionDoctorTitle(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot,
) {
  if (!snapshot.supported) return appLocalizations.doctorUnsupportedTitle;
  if (!snapshot.isFresh) return appLocalizations.doctorObservingTitle;
  if (_expectedCaptureInactive(snapshot)) {
    return appLocalizations.doctorVpnInactiveTitle;
  }
  if (_markerOnlyReachable(snapshot)) {
    return appLocalizations.doctorEndpointReachableTitle;
  }
  return switch (snapshot.state) {
    DoctorExamState.examining => appLocalizations.doctorExaminingTitle,
    DoctorExamState.inconclusive => appLocalizations.doctorInconclusiveTitle,
    DoctorExamState.superseded => appLocalizations.doctorSupersededTitle,
    DoctorExamState.cancelled => appLocalizations.doctorCancelledTitle,
    _ => switch (snapshot.health) {
      DoctorHealth.healthy => appLocalizations.doctorHealthyTitle,
      DoctorHealth.degraded => appLocalizations.doctorDegradedTitle,
      DoctorHealth.broken => appLocalizations.doctorBrokenTitle,
      _ => appLocalizations.doctorObservingTitle,
    },
  };
}

String connectionDoctorDescription(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot, {
  int? easterEggRoll,
}) {
  if (!snapshot.supported) return appLocalizations.doctorUnsupportedDesc;
  if (!snapshot.isFresh) return appLocalizations.doctorObservingDesc;
  if (_expectedCaptureInactive(snapshot)) {
    return appLocalizations.doctorVpnInactiveDesc;
  }
  if (_markerOnlyReachable(snapshot)) {
    return appLocalizations.doctorEndpointReachableDesc;
  }
  if (_showsDoctorEasterEgg(snapshot, easterEggRoll)) {
    return appLocalizations.doctorHealthyEasterEgg;
  }
  return switch (snapshot.state) {
    DoctorExamState.examining => appLocalizations.doctorExaminingDesc,
    DoctorExamState.inconclusive => appLocalizations.doctorInconclusiveDesc,
    DoctorExamState.superseded => appLocalizations.doctorSupersededDesc,
    DoctorExamState.cancelled => appLocalizations.doctorCancelledDesc,
    _ => switch (snapshot.health) {
      DoctorHealth.healthy => appLocalizations.doctorHealthyDesc,
      DoctorHealth.degraded => appLocalizations.doctorDegradedDesc,
      DoctorHealth.broken => appLocalizations.doctorBrokenDesc,
      _ => appLocalizations.doctorObservingDesc,
    },
  };
}

bool _showsDoctorEasterEgg(DoctorSnapshot snapshot, int? roll) {
  const requiredStages = {'app', 'ingress', 'route', 'internet', 'response'};
  final passedStages = snapshot.stages
      .where((stage) => stage.state == DoctorStageState.passed)
      .map((stage) => stage.id)
      .toSet();
  return snapshot.isFresh &&
      snapshot.state == DoctorExamState.complete &&
      snapshot.health == DoctorHealth.healthy &&
      snapshot.confidence == DoctorConfidence.confirmed &&
      snapshot.captureState == DoctorCaptureState.active &&
      passedStages.containsAll(requiredStages) &&
      (roll ?? _stableEasterEggRoll(snapshot.examId, 32)) == 0;
}

int _stableEasterEggRoll(String seed, int buckets) {
  if (seed.isEmpty) return -1;
  var hash = 0x811c9dc5;
  for (final unit in seed.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return hash % buckets;
}

bool _expectedCaptureInactive(DoctorSnapshot snapshot) =>
    snapshot.causeCode == 'vpnNotActive' &&
    snapshot.layer == DoctorLayer.capture &&
    snapshot.health == DoctorHealth.broken;

bool _markerOnlyReachable(DoctorSnapshot snapshot) {
  final responsePassed = snapshot.stages.any(
    (stage) => stage.id == 'response' && stage.state == DoctorStageState.passed,
  );
  final protectedPathProven = snapshot.stages.any(
    (stage) => stage.id == 'ingress' && stage.state == DoctorStageState.passed,
  );
  final captureNotApplicable =
      snapshot.captureState == DoctorCaptureState.notApplicable;
  return responsePassed && !protectedPathProven && captureNotApplicable;
}

String connectionDoctorLayerLabel(
  AppLocalizations appLocalizations,
  DoctorLayer layer,
) => switch (layer) {
  DoctorLayer.capture => appLocalizations.doctorLayerCapture,
  DoctorLayer.ingress => appLocalizations.doctorLayerIngress,
  DoctorLayer.dns => appLocalizations.doctorLayerDns,
  DoctorLayer.route => appLocalizations.doctorLayerRoute,
  DoctorLayer.dial => appLocalizations.doctorLayerDial,
  DoctorLayer.transport => appLocalizations.doctorLayerTransport,
  DoctorLayer.marker => appLocalizations.doctorLayerMarker,
  DoctorLayer.unknown => appLocalizations.unknown,
};

bool connectionDoctorTakesHero(DoctorSnapshot snapshot) {
  if (!snapshot.supported || !snapshot.isFresh) return false;
  return snapshot.state == DoctorExamState.examining ||
      _expectedCaptureInactive(snapshot) ||
      snapshot.health == DoctorHealth.degraded ||
      snapshot.health == DoctorHealth.broken;
}

String connectionDoctorHeroText(
  AppLocalizations appLocalizations,
  DoctorSnapshot snapshot,
) {
  if (snapshot.state == DoctorExamState.examining) {
    return appLocalizations.doctorHeroExamining(
      snapshot.progress.completed,
      snapshot.progress.total,
    );
  }
  if (_expectedCaptureInactive(snapshot)) {
    return appLocalizations.doctorVpnInactiveTitle;
  }
  return appLocalizations.doctorHeroIssue(
    connectionDoctorLayerLabel(appLocalizations, snapshot.layer),
  );
}

class ConnectionDoctorView extends ConsumerStatefulWidget {
  const ConnectionDoctorView({super.key});

  @override
  ConsumerState<ConnectionDoctorView> createState() =>
      _ConnectionDoctorViewState();
}

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
    final answer = doctorAnswerOf(snapshot, doctorAnswerText(appLocalizations));
    return CommonScaffold(
      title: appLocalizations.connectionDoctor,
      isLoading: _initializing,
      actions: [
        IconButton(
          tooltip: appLocalizations.doctorRefresh,
          onPressed: _busyAction == null
              ? () => unawaited(_refresh(showError: true))
              : null,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: ListView(
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
                  padding: const EdgeInsets.all(16),
                  child: ConnectionDoctorPathMap(snapshot: snapshot),
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

(String, IconData) _remedyLabel(
  AppLocalizations appLocalizations,
  DoctorRemedy remedy,
) => switch (remedy) {
  DoctorRemedy.startVpn => (
    appLocalizations.doctorRemedyStartVpn,
    Icons.vpn_key_rounded,
  ),
  DoctorRemedy.recheck => (
    appLocalizations.doctorStandardExam,
    Icons.refresh_rounded,
  ),
  DoctorRemedy.deepCheck => (
    appLocalizations.doctorDeepExam,
    Icons.manage_search_rounded,
  ),
  DoctorRemedy.flushDns => (
    appLocalizations.doctorFlushDns,
    Icons.cached_rounded,
  ),
  DoctorRemedy.pickNode => (
    appLocalizations.changeServer,
    Icons.swap_horiz_rounded,
  ),
  DoctorRemedy.openProfiles => (
    appLocalizations.profiles,
    Icons.folder_open_rounded,
  ),
  DoctorRemedy.openDns => (
    appLocalizations.doctorRemedyOpenDns,
    Icons.dns_rounded,
  ),
  DoctorRemedy.openAdvanced => (
    appLocalizations.advancedConfig,
    Icons.tune_rounded,
  ),
  DoctorRemedy.exportReport => (
    appLocalizations.doctorExportReport,
    Icons.ios_share_rounded,
  ),
};

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

Color _answerColor(BuildContext context, DoctorAnswerTone tone) {
  final colors = context.colorScheme;
  return switch (tone) {
    DoctorAnswerTone.good => Colors.green.harmonizeWith(colors.primary),
    DoctorAnswerTone.working => colors.primary,
    DoctorAnswerTone.warning => Colors.orange.harmonizeWith(colors.primary),
    DoctorAnswerTone.bad => colors.error,
    DoctorAnswerTone.neutral => colors.onSurfaceVariant,
  };
}

IconData _answerIcon(DoctorAnswerTone tone) => switch (tone) {
  DoctorAnswerTone.good => Icons.check_circle_outline,
  DoctorAnswerTone.working => Icons.radar_rounded,
  DoctorAnswerTone.warning => Icons.warning_amber_rounded,
  DoctorAnswerTone.bad => Icons.error_outline_rounded,
  DoctorAnswerTone.neutral => Icons.monitor_heart_outlined,
};

String _captureStateLabel(
  AppLocalizations appLocalizations,
  DoctorCaptureState state,
) => switch (state) {
  DoctorCaptureState.active => appLocalizations.doctorCaptureActive,
  DoctorCaptureState.inactive => appLocalizations.doctorCaptureInactive,
  DoctorCaptureState.notApplicable =>
    appLocalizations.doctorCaptureNotApplicable,
  DoctorCaptureState.unknown => appLocalizations.unknown,
};

String _scopeLabel(AppLocalizations appLocalizations, DoctorScope scope) =>
    switch (scope) {
      DoctorScope.app => appLocalizations.doctorScopeApp,
      DoctorScope.inbound => appLocalizations.doctorScopeInbound,
      DoctorScope.unknown => appLocalizations.unknown,
    };

String _confidenceLabel(
  AppLocalizations appLocalizations,
  DoctorConfidence confidence,
) => switch (confidence) {
  DoctorConfidence.confirmed => appLocalizations.doctorConfidenceConfirmed,
  DoctorConfidence.probable => appLocalizations.doctorConfidenceProbable,
  DoctorConfidence.insufficient =>
    appLocalizations.doctorConfidenceInsufficient,
  DoctorConfidence.unknown => appLocalizations.unknown,
};

String _outcomeLabel(
  AppLocalizations appLocalizations,
  DoctorEvidenceOutcome outcome,
) => switch (outcome) {
  DoctorEvidenceOutcome.seen => appLocalizations.doctorOutcomeSeen,
  DoctorEvidenceOutcome.succeeded => appLocalizations.doctorOutcomeSucceeded,
  DoctorEvidenceOutcome.failed => appLocalizations.doctorOutcomeFailed,
  DoctorEvidenceOutcome.dropped => appLocalizations.doctorOutcomeDropped,
  DoctorEvidenceOutcome.notApplicable =>
    appLocalizations.doctorOutcomeNotApplicable,
  DoctorEvidenceOutcome.unknown => appLocalizations.unknown,
};

String _evidenceDescription(
  AppLocalizations appLocalizations,
  DoctorEvidence fact,
) {
  final outcome = _outcomeLabel(appLocalizations, fact.outcome);
  final confidence = _confidenceLabel(appLocalizations, fact.confidence);
  final values = <String>[
    '$outcome · $confidence',
    if (fact.code.isNotEmpty) fact.code,
    if (fact.durationBucketMs > 0) '${fact.durationBucketMs} ms',
  ];
  return values.join(' · ');
}

IconData _evidenceIcon(DoctorEvidenceOutcome outcome) => switch (outcome) {
  DoctorEvidenceOutcome.succeeded => Icons.check_circle_outline,
  DoctorEvidenceOutcome.failed => Icons.error_outline_rounded,
  DoctorEvidenceOutcome.dropped => Icons.remove_circle_outline,
  DoctorEvidenceOutcome.notApplicable => Icons.not_interested_rounded,
  _ => Icons.radio_button_checked_rounded,
};

String _modeLabel(AppLocalizations appLocalizations, DoctorExamMode mode) =>
    switch (mode) {
      DoctorExamMode.standard => appLocalizations.doctorModeStandard,
      DoctorExamMode.deep => appLocalizations.doctorModeDeep,
      DoctorExamMode.unknown => appLocalizations.unknown,
    };

String _incidentTitle(
  AppLocalizations appLocalizations,
  DoctorIncident incident,
) {
  return switch (incident.state) {
    DoctorExamState.inconclusive => appLocalizations.doctorInconclusiveTitle,
    DoctorExamState.superseded => appLocalizations.doctorSupersededTitle,
    DoctorExamState.cancelled => appLocalizations.doctorCancelledTitle,
    _ => switch (incident.health) {
      DoctorHealth.healthy => appLocalizations.doctorHealthyTitle,
      DoctorHealth.degraded => appLocalizations.doctorDegradedTitle,
      DoctorHealth.broken => appLocalizations.doctorBrokenTitle,
      _ => appLocalizations.doctorObservingTitle,
    },
  };
}

IconData _incidentIcon(DoctorIncident incident) => switch (incident.health) {
  DoctorHealth.healthy => Icons.check_circle_outline,
  DoctorHealth.degraded => Icons.warning_amber_rounded,
  DoctorHealth.broken => Icons.error_outline_rounded,
  _ => Icons.help_outline_rounded,
};
