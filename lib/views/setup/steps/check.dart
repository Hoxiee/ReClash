import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/app/permission.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/tools/doctor_path.dart';
import 'package:reclash/widgets/widgets.dart';

import '../coverage_choice.dart';
import '../layout.dart';
import '../widgets.dart';

/// The system calls the check step makes outside the provider tree, kept behind
/// an interface so a test can watch the wizard without a device.
abstract interface class SetupCheckGateway {
  bool get isAndroid;

  Future<void> checkBatteryOptimizationDisable(ProviderReader read);

  Future<void> openBatteryOptimizationSettings();
}

class SystemSetupCheckGateway implements SetupCheckGateway {
  const SystemSetupCheckGateway();

  @override
  bool get isAndroid => system.isAndroid;

  @override
  Future<void> checkBatteryOptimizationDisable(ProviderReader read) =>
      permissions.checkBatteryOptimizationDisable(read);

  @override
  Future<void> openBatteryOptimizationSettings() async {
    permissions.needWaitingBatteryOptimizationSettings = true;
    try {
      await app?.openBatteryOptimizationSettings();
    } catch (_) {
      permissions.needWaitingBatteryOptimizationSettings = false;
      rethrow;
    }
  }
}

enum _Phase { idle, starting, examining, settled, saved }

/// Closes the wizard by connecting for real and reporting what the Connection
/// Doctor saw, so the last thing the user reads is a measured result and not a
/// digest of the settings they just chose.
class SetupCheckStep extends ConsumerStatefulWidget {
  const SetupCheckStep({
    super.key,
    required this.onDone,
    required this.onBack,
    required this.onOutcome,
    this.revisit = false,
    this.gateway = const SystemSetupCheckGateway(),
  });

  final VoidCallback onDone;
  final VoidCallback onBack;

  /// Reports the stage result up to the shell, which owns the receipt.
  final void Function(SetupCheckOutcome outcome, String? detail) onOutcome;

  final bool revisit;
  final SetupCheckGateway gateway;

  @override
  ConsumerState<SetupCheckStep> createState() => _SetupCheckStepState();
}

class _SetupCheckStepState extends ConsumerState<SetupCheckStep> {
  static const _startAttempts = 60;
  static const _startInterval = Duration(milliseconds: 200);
  static const _examAttempts = 40;
  static const _examInterval = Duration(milliseconds: 700);

  _Phase _phase = _Phase.idle;
  String? _failure;
  bool _batteryPending = false;
  int _run = 0;

  @override
  void dispose() {
    _run++;
    super.dispose();
  }

  void _report(SetupCheckOutcome outcome, String? detail) =>
      widget.onOutcome(outcome, detail);

  bool _isCurrent(int run) => mounted && run == _run;

  Future<void> _connectAndCheck() async {
    final l = context.appLocalizations;
    final run = ++_run;
    setState(() {
      _phase = _Phase.starting;
      _failure = null;
    });
    _report(SetupCheckOutcome.running, l.setupCheckPreparing);
    final setup = ref.read(setupActionProvider.notifier);
    setup.beginTunAuthorization();
    var started = false;
    try {
      started = await setup.setRunning(
        true,
        initialize: !ref.read(initProvider),
      );
    } catch (_) {
      started = false;
    }
    if (!_isCurrent(run)) return;
    if (!started || !await _waitForRunning(run)) {
      _fail(l.setupCheckStartFailed);
      return;
    }
    if (!ref.read(connectionDoctorProvider).supported) {
      _unverified(l.doctorUnsupportedTitle, l.doctorUnsupportedDesc);
      return;
    }
    await _examine(DoctorExamMode.standard, run: run);
  }

  Future<bool> _waitForRunning(int run) async {
    for (var attempt = 0; attempt < _startAttempts; attempt++) {
      if (!_isCurrent(run)) return false;
      if (ref.read(isStartProvider)) return true;
      await Future<void>.delayed(_startInterval);
    }
    return false;
  }

  Future<void> _examine(DoctorExamMode mode, {int? run}) async {
    final l = context.appLocalizations;
    final current = run ?? ++_run;
    setState(() {
      _phase = _Phase.examining;
      _failure = null;
    });
    final doctor = ref.read(connectionDoctorProvider.notifier);
    try {
      await doctor.start(mode);
    } catch (_) {
      if (_isCurrent(current)) _fail(l.setupCheckStartFailed);
      return;
    }
    for (var attempt = 0; attempt < _examAttempts; attempt++) {
      if (!_isCurrent(current)) return;
      final snapshot = ref.read(connectionDoctorProvider);
      if (_settled(snapshot)) {
        _finish(snapshot);
        return;
      }
      _report(
        SetupCheckOutcome.running,
        snapshot.progress.total > 0
            ? l.doctorHeroExamining(
                snapshot.progress.completed,
                snapshot.progress.total,
              )
            : l.setupCheckPreparing,
      );
      await Future<void>.delayed(_examInterval);
      if (!_isCurrent(current)) return;
      try {
        await doctor.refresh();
      } catch (_) {}
    }
    if (_isCurrent(current)) _fail(l.setupCheckTimeout);
  }

  bool _settled(DoctorSnapshot snapshot) =>
      snapshot.state == DoctorExamState.complete ||
      snapshot.state == DoctorExamState.inconclusive ||
      snapshot.state == DoctorExamState.cancelled;

  void _finish(DoctorSnapshot snapshot) {
    final l = context.appLocalizations;
    final answer = connectionDoctorAnswer(l, snapshot);
    final healthy = snapshot.health == DoctorHealth.healthy;
    setState(() {
      _phase = _Phase.settled;
      _failure = null;
    });
    _report(
      healthy ? SetupCheckOutcome.passed : SetupCheckOutcome.failed,
      healthy
          ? answer.meaning
          : connectionDoctorLayerLabel(l, snapshot.layer),
    );
  }

  void _fail(String message) {
    setState(() {
      _phase = _Phase.settled;
      _failure = message;
    });
    _report(SetupCheckOutcome.failed, message);
  }

  /// The tunnel is up but this core cannot examine it, which is a saved setup
  /// rather than a failed one — the wizard says so instead of timing out.
  void _unverified(String title, String detail) {
    setState(() {
      _phase = _Phase.saved;
      _failure = title;
    });
    _report(SetupCheckOutcome.saved, detail);
  }

  Future<void> _cancel() async {
    _run++;
    try {
      await ref.read(connectionDoctorProvider.notifier).cancel();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _phase = _Phase.idle);
    _report(SetupCheckOutcome.pending, null);
  }

  Future<void> _flushDnsAndRecheck() async {
    try {
      await ref.read(connectionDoctorProvider.notifier).flushDns();
    } catch (_) {}
    if (!mounted) return;
    await _examine(DoctorExamMode.standard);
  }

  void _saveWithoutConnecting() {
    final l = context.appLocalizations;
    _run++;
    setState(() {
      _phase = _Phase.saved;
      _failure = null;
    });
    _report(SetupCheckOutcome.saved, l.setupSavedDesc);
  }

  Future<void> _handleBattery() async {
    if (_batteryPending) return;
    setState(() => _batteryPending = true);
    try {
      await widget.gateway.openBatteryOptimizationSettings();
      await widget.gateway.checkBatteryOptimizationDisable(ref.read);
    } catch (_) {
      return;
    } finally {
      if (mounted) setState(() => _batteryPending = false);
    }
  }

  /// Remedies the wizard can honour itself. Everything else the doctor may
  /// suggest lives in the app behind setup, so offering it here would hand the
  /// user a dead end.
  bool _canHonour(DoctorRemedy remedy) => switch (remedy) {
    DoctorRemedy.startVpn ||
    DoctorRemedy.recheck ||
    DoctorRemedy.deepCheck ||
    DoctorRemedy.flushDns ||
    DoctorRemedy.openProfiles => true,
    _ => false,
  };

  String _remedyText(AppLocalizations l, DoctorRemedy remedy) =>
      switch (remedy) {
        DoctorRemedy.startVpn => l.doctorRemedyStartVpn,
        DoctorRemedy.recheck => l.doctorStandardExam,
        DoctorRemedy.deepCheck => l.doctorDeepExam,
        DoctorRemedy.flushDns => l.doctorFlushDns,
        DoctorRemedy.openProfiles => l.setupReplaceProfile,
        _ => l.redo,
      };

  void _runRemedy(DoctorRemedy remedy) {
    switch (remedy) {
      case DoctorRemedy.startVpn:
        unawaited(_connectAndCheck());
      case DoctorRemedy.recheck:
        unawaited(_examine(DoctorExamMode.standard));
      case DoctorRemedy.deepCheck:
        unawaited(_examine(DoctorExamMode.deep));
      case DoctorRemedy.flushDns:
        unawaited(_flushDnsAndRecheck());
      case DoctorRemedy.openProfiles:
        widget.onBack();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final snapshot = ref.watch(connectionDoctorProvider);
    final answer = connectionDoctorAnswer(l, snapshot);
    final profiles = ref.watch(profilesProvider);
    final profile = ref.watch(currentProfileProvider) ?? profiles.firstOrNull;
    final byeDpi = ref.watch(byeDpiSupportedProvider);
    final connectable = profile != null || byeDpi;
    final alreadyRunning = ref.watch(isStartProvider);
    final running = _phase == _Phase.starting || _phase == _Phase.examining;
    final failed = _failure != null || answer.isProblem;
    final remedies = _phase == _Phase.settled && _failure == null
        ? answer.remedies.where(_canHonour).toList()
        : const <DoctorRemedy>[];
    return SetupStepScaffold(
      title: switch (_phase) {
        _Phase.idle => l.setupCheckTitle,
        _Phase.starting || _Phase.examining => l.setupCheckRunningTitle,
        _Phase.settled => _failure ?? answer.headline,
        _Phase.saved => _failure ?? l.setupSavedTitle,
      },
      subtitle: switch (_phase) {
        _Phase.idle => connectable
            ? l.setupConnectNowDesc
            : (byeDpi
                  ? l.setupSummaryNoProfile
                  : l.setupSummaryNoProfilePlain),
        _Phase.starting => l.setupCheckPreparing,
        _Phase.examining => l.setupCheckScope,
        _Phase.settled => _failure == null ? answer.meaning : l.setupCheckScope,
        _Phase.saved => l.setupSavedDesc,
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          if (_phase == _Phase.idle) _PlanCard(profile: profile),
          if (running && snapshot.stages.isEmpty)
            SetupCard(
              child: ListItem(
                leading: const SizedBox.square(
                  dimension: 20,
                  child: CommonCircleLoading(),
                ),
                title: Text(l.setupCheckPreparing),
              ),
            ),
          if (snapshot.stages.isNotEmpty &&
              (running || _phase == _Phase.settled))
            _StationList(snapshot: snapshot, blame: answer.blame),
          if (_phase == _Phase.settled && _failure == null)
            ...[
              if (answer.steps.isNotEmpty) _StepsCard(steps: answer.steps),
              if (remedies.length > 1)
                _RemedyRow(
                  remedies: remedies.skip(1).toList(),
                  label: _remedyText,
                  onPressed: _runRemedy,
                ),
            ],
          if (_phase == _Phase.settled || _phase == _Phase.saved)
            _BehaviourCard(
              batteryPending: _batteryPending,
              onBattery: widget.gateway.isAndroid ? _handleBattery : null,
            ),
          if (_phase == _Phase.idle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                l.setupCheckScope,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (running)
          OutlinedButton(onPressed: _cancel, child: Text(l.cancel))
        else if (_phase == _Phase.idle && connectable)
          SetupPrimaryButton(
            key: const ValueKey('setup-connect-check'),
            label: alreadyRunning ? l.doctorStandardExam : l.setupConnectNow,
            onPressed: alreadyRunning
                ? () => unawaited(_examine(DoctorExamMode.standard))
                : _connectAndCheck,
          )
        else if (_phase == _Phase.settled && failed && remedies.isNotEmpty)
          SetupPrimaryButton(
            label: _remedyText(l, remedies.first),
            onPressed: () => _runRemedy(remedies.first),
          )
        else if (_phase == _Phase.settled && failed)
          SetupPrimaryButton(
            label: l.redo,
            onPressed: () => unawaited(_examine(DoctorExamMode.standard)),
          )
        else
          SetupPrimaryButton(
            key: const ValueKey('setup-done'),
            label: l.setupDone,
            onPressed: widget.onDone,
          ),
        if (_phase == _Phase.idle && connectable)
          TextButton(
            onPressed: _saveWithoutConnecting,
            child: Text(l.setupSaveWithoutConnecting),
          )
        else if (_phase == _Phase.settled && !failed)
          TextButton(
            onPressed: () => unawaited(_examine(DoctorExamMode.standard)),
            child: Text(l.redo),
          )
        else if (_phase == _Phase.settled && failed)
          TextButton(
            onPressed: widget.onDone,
            child: Text(l.setupSaveWithoutConnecting),
          ),
        if (!running)
          OutlinedButton(onPressed: widget.onBack, child: Text(l.setupBack)),
      ],
    );
  }
}

/// What pressing connect is about to do, so the step states its own subject
/// instead of leaning on the receipt beside it.
class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    return SetupCard(
      child: Column(
        children: [
          ListItem(
            leading: const GlyphIcon(AppGlyphs.profiles),
            title: Text(l.profile),
            subtitle: Text(
              profile?.label.takeFirstValid([l.profile]) ??
                  l.setupReceiptNoProfile,
            ),
          ),
          ListItem(
            leading: const GlyphIcon(AppGlyphs.vpn),
            title: Text(l.setupStageCoverage),
            subtitle: Text(setupCoverageLabel(context, setupCoverageOf(ref))),
          ),
        ],
      ),
    );
  }
}

class _StationList extends StatelessWidget {
  const _StationList({required this.snapshot, required this.blame});

  final DoctorSnapshot snapshot;
  final String? blame;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SetupCard(
      child: Column(
        children: [
          for (final stage in resolveDoctorPathStages(context, snapshot, blame))
            ListItem(
              leading: GlyphIcon(
                stage.icon,
                color: switch (stage.state) {
                  DoctorStageState.passed => colorScheme.success,
                  DoctorStageState.failed => colorScheme.error,
                  DoctorStageState.checking => colorScheme.primary,
                  _ => colorScheme.onSurfaceVariant,
                },
              ),
              title: Text(stage.label),
              subtitle: stage.description.isEmpty
                  ? null
                  : Text(stage.description),
              trailing: switch (stage.state) {
                DoctorStageState.checking => const SizedBox.square(
                  dimension: 18,
                  child: CommonCircleLoading(),
                ),
                DoctorStageState.passed => GlyphIcon(
                  AppGlyphs.check,
                  size: 18,
                  color: colorScheme.success,
                ),
                DoctorStageState.failed => GlyphIcon(
                  AppGlyphs.error,
                  size: 18,
                  color: colorScheme.error,
                ),
                _ => null,
              },
            ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) => SetupCard(
    child: Padding(
      padding: AppInsets.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          for (final step in steps)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: GlyphIcon(
                    AppGlyphs.chevronForward,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(child: Text(step)),
              ],
            ),
        ],
      ),
    ),
  );
}

class _RemedyRow extends StatelessWidget {
  const _RemedyRow({
    required this.remedies,
    required this.label,
    required this.onPressed,
  });

  final List<DoctorRemedy> remedies;
  final String Function(AppLocalizations l, DoctorRemedy remedy) label;
  final ValueChanged<DoctorRemedy> onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final remedy in remedies)
          OutlinedButton(
            onPressed: () => onPressed(remedy),
            child: Text(label(l, remedy)),
          ),
      ],
    );
  }
}

/// The one behaviour question worth asking, asked after the connection has been
/// proven rather than before it.
class _BehaviourCard extends ConsumerWidget {
  const _BehaviourCard({required this.batteryPending, this.onBattery});

  final bool batteryPending;
  final VoidCallback? onBattery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final setting = ref.watch(appSettingProvider);
    final hasProfile = ref.watch(profilesProvider).isNotEmpty;
    final autoRun = hasProfile && setting.autoRun;
    final battery = ref.watch(batteryOptimizationDisableProvider);
    return SetupCard(
      child: Column(
        children: [
          ListItem.toggle(
            key: const ValueKey('setup-auto-run'),
            title: Text(l.setupAutoRun),
            subtitle: Text(
              hasProfile ? l.setupAutoRunDesc : l.setupAutoRunUnavailable,
            ),
            value: autoRun,
            onChanged: hasProfile
                ? (value) => ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(autoRun: value))
                : null,
          ),
          if (autoRun && onBattery != null && !battery)
            SetupPermissionRow(
              title: l.setupPermissionBattery,
              desc: l.setupPermissionBatteryDesc,
              status: batteryPending
                  ? l.setupPermissionChecking
                  : l.setupPermissionRequest,
              pending: batteryPending,
              onPressed: onBattery,
            ),
        ],
      ),
    );
  }
}
