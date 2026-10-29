import 'package:flutter_riverpod/misc.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/finding.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/path.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/remedies/remedy.dart';
import 'package:reclash/features/doctor/snapshot.dart';

const directModeFinding = Finding(
  id: 'config.directMode',
  severity: CheckSeverity.warning,
  evidence: [],
  titleKey: 'doctorDirectModeTitle',
  detailKey: 'doctorDirectModeDetail',
  remedyIds: ['config.ruleMode'],
);

const batteryFinding = Finding(
  id: 'device.batteryOptimization',
  severity: CheckSeverity.warning,
  evidence: [],
  titleKey: 'doctorBatteryOptimizationTitle',
  detailKey: 'doctorBatteryOptimizationDetail',
  remedyIds: ['device.ignoreBatteryOptimization'],
);

const clockSkewFinding = Finding(
  id: 'device.clockSkew',
  severity: CheckSeverity.critical,
  cause: FailureCause.clockSkew,
  evidence: ['device.clockSkew'],
  titleKey: 'doctorCauseClockSkew',
  detailKey: 'doctorClockSkewBehind',
  args: {'seconds': 420},
  remedyIds: ['device.openDateSettings'],
);

const doctorRemedyKinds = {
  'config.ruleMode': FixKind.auto,
  'device.ignoreBatteryOptimization': FixKind.system,
  'device.openDateSettings': FixKind.system,
};

class FakeDoctorKernel implements DiagnosticKernel {
  final applied = <String>[];
  final snoozes = <({String id, DateTime? until})>[];

  @override
  DiagnosticSnapshot get snapshot =>
      DiagnosticSnapshot(takenAt: DateTime.now());

  @override
  Future<RemedyOutcome> apply(String remedyId) async {
    applied.add(remedyId);
    return RemedyOutcome(remedyId: remedyId, status: RemedyStatus.fixed);
  }

  @override
  bool snooze(String findingId, {DateTime? until}) {
    snoozes.add((id: findingId, until: until));
    return true;
  }

  @override
  Future<PathResult> runPath({
    PathScope scope = PathScope.full,
    bool force = false,
  }) async => PathResult.start(scope, DateTime.now());

  @override
  PathResult? get path => null;

  @override
  Stream<PathResult> get pathUpdates => const Stream.empty();

  @override
  Future<List<DiagnosticEvent>> history() async => const [];

  @override
  Stream<DiagnosticEvent> get events => const Stream.empty();

  @override
  Stream<DiagnosticSnapshot> get snapshots => const Stream.empty();

  @override
  List<Finding> get findings => const [];

  @override
  Stream<List<Finding>> get findingUpdates => const Stream.empty();

  @override
  Future<T> probe<T extends Object>(ProbeRequest<T> request) =>
      throw UnimplementedError();

  @override
  Future<RemedyOutcome> undo(String remedyId) => throw UnimplementedError();

  @override
  Future<PlanOutcome> heal(HealPlan plan) => throw UnimplementedError();

  @override
  FailureExplanation explain(Object error) => throw UnimplementedError();
}

List<Override> doctorOverrides({
  required FakeDoctorKernel kernel,
  required List<Finding> findings,
  PathResult? path,
  List<DiagnosticEvent> history = const [],
}) => [
  diagnosticKernelProvider.overrideWithValue(kernel),
  findingsProvider.overrideWith((ref) => Stream.value(findings)),
  pathProvider.overrideWith((ref) => Stream.value(path)),
  incidentHistoryProvider.overrideWith((ref) async => history),
  remedyKindsProvider.overrideWithValue(doctorRemedyKinds),
];
