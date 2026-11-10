import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/doctor.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import 'account/guard.dart';
import 'account/standing.dart';
import 'environment/healer.dart';
import 'environment/scanner.dart';
import 'finding.dart';
import 'fixlink/overrides.dart';
import 'journal.dart';
import 'kernel.dart';
import 'path.dart';
import 'probes/clock.dart';
import 'probes/path.dart';
import 'probes/scheduler.dart';
import 'probes/verify.dart';
import 'remedies/best_node.dart';
import 'remedies/catalog.dart';
import 'remedies/connection.dart';
import 'remedies/environment.dart';
import 'remedies/remedy.dart';
import 'rules/rules.dart';
import 'sensors/sensors.dart';
import 'supervisor/health.dart';
import 'supervisor/network.dart';
import 'supervisor/supervisor.dart';

export 'account/standing.dart';
export 'supervisor/health.dart';
export 'supervisor/network.dart' show networkOnlineProvider;

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

class PreferencesAccountStore implements AccountStore {
  const PreferencesAccountStore();

  @override
  Future<String?> load() => preferences.getDoctorAccount();

  @override
  Future<void> save(String memo) => preferences.saveDoctorAccount(memo);
}

final incidentStoreProvider = Provider<IncidentStore>(
  (ref) => const PreferencesIncidentStore(),
);

List<Remedy> _environmentRemedies(Ref ref) {
  final config = PatchConfigAccess(
    read: () => ref.read(patchClashConfigProvider),
    write: (change) =>
        ref.read(patchClashConfigProvider.notifier).update(change),
  );
  final queue = systemProxyQueue;
  Future<bool> rescanAfter(Future<bool> change) async {
    final result = await change;
    await ref.read(environmentScannerProvider).rescan();
    return result;
  }

  return [
    IgnoreSystemHostsRemedy(config),
    ResetOverridesRemedy(config),
    FreePortRemedy(config),
    FreeTunDeviceRemedy(config),
    if (system.isDesktop) ...[
      OpenHostsRemedy(() => ref.read(environmentScannerProvider).openHosts()),
      RestartTunnelRemedy(
        () => ref.read(coreActionProvider.notifier).restartCore(silence: true),
      ),
    ],
    if (queue != null) ...[
      ClearOwnProxyRemedy((port) => rescanAfter(queue.clear(ownPort: port))),
      ClearProxyRemedy(() => rescanAfter(queue.clear())),
      ReapplyProxyRemedy(
        () => rescanAfter(queue.apply(ref.read(proxyStateProvider))),
      ),
    ],
  ];
}

List<Remedy> _connectionRemedies(Ref ref) {
  Future<void> setRunning(bool running) =>
      ref.read(commonActionProvider.notifier).setRunning(running);
  return [
    ConnectionRemedy(ConnectionRemedy.bestNode, () => selectBestNode(ref)),
    ConnectionRemedy(ConnectionRemedy.resetConnections, () async {
      final core = ref.read(coreHandlerProvider);
      if (!await core.clearDnsCache()) throw StateError('DNS flush failed');
      await core.closeConnections();
    }),
    ConnectionRemedy(ConnectionRemedy.restartCore, () async {
      final restarted = await ref
          .read(coreActionProvider.notifier)
          .restartCore(silence: true);
      if (!restarted) throw StateError('the Core did not restart');
    }),
    ConnectionRemedy(
      ConnectionRemedy.reconnect,
      () => ref.read(setupActionProvider.notifier).restartVpn(),
    ),
    ConnectionRemedy(ConnectionRemedy.stopForAccount, () => setRunning(false)),
    ConnectionRemedy(
      ConnectionRemedy.resumeAfterRenewal,
      () => setRunning(true),
    ),
  ];
}

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
    }, current: () => ref.read(currentProfileIdProvider)),
    ..._connectionRemedies(ref),
    ..._environmentRemedies(ref),
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

final Provider<DiagnosticKernel> diagnosticKernelProvider = Provider((ref) {
  late final DoctorKernel kernel;
  kernel = DoctorKernel(
    engine: const RuleEngine(defaultRules),
    scheduler: ProbeScheduler(),
    journal: DiagnosticJournal(ref.read(incidentStoreProvider)),
    config: _RefConfigAccess(ref),
    remedies: ref.read(diagnosticRemediesProvider),
    pathChecks: (step) => pathCheck(ref, kernel, step),
    verifyChecks: (step) => verifyCheck(ref, kernel, step),
    pathIntent: () => pathIntent(ref),
  );
  for (final sensor in defaultSensors) {
    sensor(ref, kernel);
  }
  ref.listen(appVisibleProvider, (previous, visible) {
    if (previous != false || !visible) return;
    if (kernel.findings.any((f) => f.id == 'device.clockSkew')) {
      unawaited(probeClockSkew(ref, force: true).then((_) {}, onError: (_) {}));
    }
  });
  ref.onDispose(kernel.dispose);
  return kernel;
});

final environmentHealerProvider = Provider<EnvironmentHealer>((ref) {
  final healer = EnvironmentHealer(
    kernel: ref.watch(diagnosticKernelProvider),
    remedies: ref.read(diagnosticRemediesProvider),
    enabled: () => ref.read(appSettingProvider).autoHeal,
  )..start();
  ref.onDispose(healer.dispose);
  return healer;
});

final environmentHealNoticesProvider = StreamProvider<HealNotice>(
  (ref) => ref.watch(environmentHealerProvider).notices,
);

bool _tunnelRunning(Ref ref) =>
    ref.read(isStartProvider) &&
    ref.read(coreStatusProvider) == CoreStatus.connected &&
    !ref.read(suspendProvider);

/// The main group and the node it points at; either moving means what was
/// verified no longer describes the path.
final _mainSelectionProvider = Provider<(String?, String?)>((ref) {
  final group = ref.watch(mainGroupProvider);
  if (group == null) return (null, null);
  final node =
      ref.watch(selectedMapProvider)[group] ??
      ref.watch(groupsProvider).getGroup(group)?.now;
  return (group, node);
});

final connectionSupervisorProvider = Provider<ConnectionSupervisor>((ref) {
  final supervisor = ConnectionSupervisor(
    kernel: ref.watch(diagnosticKernelProvider),
    autoHeal: () {
      final setting = ref.read(appSettingProvider);
      return setting.autoHeal && setting.smartPowerButton;
    },
    selectedNode: () => ref.read(_mainSelectionProvider).$2,
  )..start();
  void sync() => supervisor.setRunning(_tunnelRunning(ref));
  ref
    ..listen(appVisibleProvider, (_, visible) {
      supervisor.setVisible(visible);
    }, fireImmediately: true)
    ..listen(networkSnapshotProvider, (previous, next) {
      if (next == null) return;
      supervisor.setNetwork(
        online: next.cost != NetworkCost.offline,
        changed: previous != null && previous.identity != next.identity,
      );
    }, fireImmediately: true)
    ..listen(isStartProvider, (_, _) => sync())
    ..listen(coreStatusProvider, (_, _) => sync())
    ..listen(suspendProvider, (_, _) => sync())
    ..listen(_mainSelectionProvider, (_, _) => supervisor.selectionChanged())
    ..onDispose(supervisor.dispose);
  sync();
  return supervisor;
});

final connectionHealthProvider =
    NotifierProvider<ConnectionHealthState, ConnectionHealth>(
      ConnectionHealthState.new,
    );

class ConnectionHealthState extends Notifier<ConnectionHealth> {
  @override
  ConnectionHealth build() {
    final supervisor = ref.watch(connectionSupervisorProvider);
    final subscription = supervisor.updates.listen((health) => state = health);
    ref.onDispose(subscription.cancel);
    return supervisor.health;
  }
}

final accountGuardProvider = Provider<AccountGuard>((ref) {
  final kernel = ref.watch(diagnosticKernelProvider);
  final enabled = ref.watch(
    appSettingProvider.select((setting) => setting.smartPowerButton),
  );
  const store = PreferencesAccountStore();
  final guard = AccountGuard(
    kernel: kernel,
    health: ref.watch(connectionSupervisorProvider).updates,
    store: store,
    reevaluate: kernel is DoctorKernel ? kernel.refresh : null,
  );
  ref
    ..listen(isStartProvider, (_, running) {
      guard.setRunning(running);
    }, fireImmediately: true)
    ..listen(appVisibleProvider, (_, visible) {
      guard.setVisible(visible);
    }, fireImmediately: true)
    ..onDispose(guard.dispose);
  if (enabled) {
    unawaited(guard.start());
  } else {
    unawaited(store.save(const AccountMemo().encode()));
  }
  return guard;
});

final accountStandingProvider =
    NotifierProvider<AccountStandingState, AccountStanding>(
      AccountStandingState.new,
    );

class AccountStandingState extends Notifier<AccountStanding> {
  @override
  AccountStanding build() {
    final guard = ref.watch(accountGuardProvider);
    final subscription = guard.updates.listen((standing) => state = standing);
    ref.onDispose(subscription.cancel);
    return guard.standing;
  }
}

final accountNoticesProvider = StreamProvider<AccountNotice>(
  (ref) => ref.watch(accountGuardProvider).notices,
);

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
