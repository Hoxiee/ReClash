import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/network_cost.dart';
import 'package:reclash/common/preferences.dart';
import 'package:reclash/features/doctor/account/guard.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/environment/scanner.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/doctor/remedies/connection.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/features/doctor/supervisor/network.dart';
import 'package:reclash/features/doctor/supervisor/supervisor.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/features/power/providers.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_profiles.dart';

class _Config implements ConfigAccess {
  Config config = const Config(
    themeProps: defaultThemeProps,
    patchClashConfig: defaultClashConfig,
  );

  @override
  Config read() => config;

  @override
  void write(Config next) => config = next;
}

class _FakeSupervisor extends Mock implements ConnectionSupervisor {
  // ignore: close_sinks
  final health$ = StreamController<ConnectionHealth>.broadcast(sync: true);

  @override
  Stream<ConnectionHealth> get updates => health$.stream;

  @override
  ConnectionHealth get health => const ConnectionHealth();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> applied;
  late DoctorKernel kernel;
  late _FakeSupervisor supervisor;

  ProviderContainer newContainer({required bool smart}) {
    applied = [];
    supervisor = _FakeSupervisor();
    kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: _Config(),
      remedies: [
        for (final id in [
          ConnectionRemedy.stopForAccount,
          ConnectionRemedy.resumeAfterRenewal,
        ])
          ConnectionRemedy(id, () async => applied.add(id)),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        environmentReaderProvider.overrideWithValue(null),
        networkSnapshotProvider.overrideWithBuild(
          (_, _) => const NetworkCostSnapshot(
            cost: NetworkCost.unmetered,
            identity: 'wifi',
          ),
        ),
        diagnosticKernelProvider.overrideWithValue(kernel),
        connectionSupervisorProvider.overrideWithValue(supervisor),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await supervisor.health$.close();
      await kernel.dispose();
    });
    container.listen(appSettingProvider, (_, _) {});
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(smartPowerButton: smart));
    return container;
  }

  setUp(() => mockPreferences());

  test('smart power button is on by default', () {
    expect(const AppSettingProps().smartPowerButton, isTrue);
  });

  test('the face is the plain run state when the setting is off', () {
    final container = newContainer(smart: true);
    container.listen(accountStandingProvider, (_, _) {});
    container.listen(powerFaceProvider, (_, _) {});
    kernel.put(
      Facts.subscription,
      SubscriptionFact(
        profileId: 1,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        used: 0,
        total: 0,
        fetchedAt: DateTime.now(),
      ),
    );
    final ended = container.read(powerFaceProvider);
    expect(ended.state, isNot(PowerFaceState.off));

    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(smartPowerButton: false));
    expect(
      container.read(powerFaceProvider).state,
      PowerFace.plain(PowerLink.off).state,
    );
  });

  Future<AccountLockSnapshot> lockAfterEvidence({required bool smart}) async {
    final container = newContainer(smart: smart);
    container.read(runTimeProvider.notifier).value = 1;
    container.listen(accountStandingProvider, (_, _) {});
    container.listen(accountNoticesProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    kernel.put(
      Facts.subscription,
      SubscriptionFact(
        profileId: 1,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        used: 0,
        total: 0,
        fetchedAt: DateTime.now(),
      ),
    );
    supervisor.health$.add(
      const ConnectionHealth(
        phase: ConnectionPhase.broken,
        cause: FailureCause.authRejected,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return (container.read(accountStandingProvider), List.of(applied));
  }

  test('the guard locks and stops the tunnel when the setting is on', () async {
    final (standing, applied) = await lockAfterEvidence(smart: true);
    expect(standing.lock, AccountLock.expired);
    expect(applied, [ConnectionRemedy.stopForAccount]);
  });

  test('the guard never locks or stops the tunnel when it is off', () async {
    final (standing, applied) = await lockAfterEvidence(smart: false);
    expect(standing, const AccountStanding());
    expect(applied, isEmpty);
  });

  test('the setting off clears the persisted account memo', () async {
    final memo = const AccountMemo(
      stoppedProfile: 1,
      lockFingerprint: 'fingerprint',
      lock: AccountLock.expired,
    ).encode();
    await mockPreferences({'doctor.account': memo});
    final container = newContainer(smart: false);
    container.read(accountGuardProvider);
    await Future<void>.delayed(Duration.zero);
    expect(
      AccountMemo.decode(await preferences.getDoctorAccount()),
      const AccountMemo(),
    );
  });
}

typedef AccountLockSnapshot = (AccountStanding, List<String>);
