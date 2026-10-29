import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/doctor.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import 'finding.dart';
import 'journal.dart';
import 'kernel.dart';
import 'path.dart';
import 'probes/clock.dart';
import 'probes/path.dart';
import 'probes/scheduler.dart';
import 'remedies/catalog.dart';
import 'remedies/remedy.dart';
import 'rules/rules.dart';
import 'sensors/sensors.dart';

class PreferencesIncidentStore implements IncidentStore {
  const PreferencesIncidentStore();

  @override
  Future<List<String>> load() => preferences.getDoctorIncidents();

  @override
  Future<void> save(List<String> incidents) =>
      preferences.saveDoctorIncidents(incidents);
}

class _RefConfigAccess implements ConfigAccess {
  const _RefConfigAccess(this._ref);

  final Ref _ref;

  @override
  Config read() => _ref.read(configProvider);

  @override
  void write(Config config) => writeConfig(_ref, config);
}

final incidentStoreProvider = Provider<IncidentStore>(
  (ref) => const PreferencesIncidentStore(),
);

final diagnosticRemediesProvider = Provider<List<Remedy>>((ref) {
  return [
    RuleModeRemedy(ref.read(setupActionProvider.notifier).changeMode),
    BatteryExemptionRemedy(
      ref.read(batteryOptimizationIgnoredProvider.notifier).request,
    ),
    UpdateSubscriptionRemedy((profileId) async {
      final profile = ref.read(profilesProvider).getProfile(profileId);
      if (profile == null) return false;
      final updated = await ref
          .read(profilesActionProvider.notifier)
          .updateProfile(profile);
      return updated != null;
    }),
    if (doctorPlugin case final plugin?) ...[
      VpnPermissionRemedy(plugin.requestVpnPermission),
      for (final (id, target) in const [
        ('device.openVpnSettings', DoctorSettings.vpn),
        ('device.openPrivateDnsSettings', DoctorSettings.privateDns),
        ('device.openDateSettings', DoctorSettings.dateTime),
        ('network.openCaptivePortal', DoctorSettings.captivePortal),
      ])
        SystemScreenRemedy(id, () => plugin.openSettings(target)),
    ],
  ];
});

/// The kind of every remedy this platform has; a finding's remedy missing
/// here has no button.
final remedyKindsProvider = Provider<Map<String, FixKind>>(
  (ref) => {
    for (final remedy in ref.watch(diagnosticRemediesProvider))
      remedy.id: remedy.kind,
  },
);

final diagnosticKernelProvider = Provider<DiagnosticKernel>((ref) {
  late final DoctorKernel kernel;
  kernel = DoctorKernel(
    engine: const RuleEngine(defaultRules),
    scheduler: ProbeScheduler(),
    journal: DiagnosticJournal(ref.read(incidentStoreProvider)),
    config: _RefConfigAccess(ref),
    remedies: ref.read(diagnosticRemediesProvider),
    pathChecks: (step) => pathCheck(ref, kernel, step),
    pathIntent: () => pathIntent(ref),
  );
  for (final sensor in defaultSensors) {
    sensor(ref, kernel);
  }
  ref.onDispose(kernel.dispose);
  return kernel;
});

final findingsProvider = StreamProvider<List<Finding>>((ref) async* {
  final kernel = ref.watch(diagnosticKernelProvider);
  yield kernel.findings;
  yield* kernel.findingUpdates;
});

/// The latest connection path of any scope, updated step by step.
final pathProvider = StreamProvider<PathResult?>((ref) async* {
  final kernel = ref.watch(diagnosticKernelProvider);
  yield kernel.path;
  yield* kernel.pathUpdates;
});

final diagnosticEventsProvider = StreamProvider<DiagnosticEvent>(
  (ref) => ref.watch(diagnosticKernelProvider).events,
);

final incidentHistoryProvider = FutureProvider<List<DiagnosticEvent>>((ref) {
  ref.watch(diagnosticEventsProvider);
  return ref.watch(diagnosticKernelProvider).history();
});

/// Measures the clock through the Core; the result lands in the snapshot.
Future<Duration> probeClockSkew(Ref ref, {bool force = false}) {
  final request = clockSkewProbe(
    ref.read(coreHandlerProvider).clockSkew,
    url: defaultTestUrl,
  );
  return ref
      .read(diagnosticKernelProvider)
      .probe(force ? request.forced() : request);
}
