import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/account/guard.dart';
import 'package:reclash/features/doctor/account/standing.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/doctor/journal.dart';
import 'package:reclash/features/doctor/kernel.dart';
import 'package:reclash/features/doctor/probes/scheduler.dart';
import 'package:reclash/features/doctor/remedies/connection.dart';
import 'package:reclash/features/doctor/rules/rules.dart';
import 'package:reclash/features/doctor/snapshot.dart';
import 'package:reclash/features/doctor/supervisor/health.dart';
import 'package:reclash/models/models.dart';

final _start = DateTime(2026, 11, 9, 12);

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

class _Store implements AccountStore {
  String? memo;

  @override
  Future<String?> load() async => memo;

  @override
  Future<void> save(String next) async => memo = next;
}

class _Rig {
  _Rig(this.async, {String? memo}) {
    store.memo = memo;
    kernel = DoctorKernel(
      engine: const RuleEngine(defaultRules),
      scheduler: ProbeScheduler(clock: now),
      journal: DiagnosticJournal(MemoryIncidentStore()),
      config: _Config(),
      remedies: [
        for (final id in [
          'profile.update',
          ConnectionRemedy.stopForAccount,
          ConnectionRemedy.resumeAfterRenewal,
        ])
          ConnectionRemedy(id, () async {
            applied.add(id);
            final gate = this.gate;
            if (id == 'profile.update' && gate != null) await gate.future;
            onRemedy[id]?.call();
          }),
      ],
      clock: now,
    );
    guard = AccountGuard(
      kernel: kernel,
      health: health.stream,
      store: store,
      reevaluate: () async => reevaluations++,
      clock: now,
    );
    guard.notices.listen(notices.add);
    unawaited(guard.start());
    async.flushMicrotasks();
  }

  final FakeAsync async;
  final store = _Store();
  final health = StreamController<ConnectionHealth>.broadcast(sync: true);
  late final DoctorKernel kernel;
  late final AccountGuard guard;
  final applied = <String>[];
  final onRemedy = <String, void Function()>{};
  Completer<void>? gate;
  final notices = <AccountNotice>[];
  int reevaluations = 0;

  DateTime now() => _start.add(async.elapsed);

  AccountStanding get standing => guard.standing;

  void plan({
    int profileId = 1,
    Duration expiresIn = const Duration(days: -1),
    Duration fetchedAgo = Duration.zero,
    int used = 0,
    int total = 0,
  }) => kernel.put(
    Facts.subscription,
    SubscriptionFact(
      profileId: profileId,
      expiresAt: now().add(expiresIn),
      used: used,
      total: total,
      fetchedAt: now().subtract(fetchedAgo),
    ),
  );

  void broken([FailureCause cause = FailureCause.authRejected]) =>
      health.add(ConnectionHealth(phase: ConnectionPhase.broken, cause: cause));

  void verified() =>
      health.add(const ConnectionHealth(phase: ConnectionPhase.verified));

  void settle() => async.flushMicrotasks();

  void dispose() {
    unawaited(guard.dispose());
    unawaited(kernel.dispose());
    unawaited(health.close());
    async.flushMicrotasks();
  }
}

void _test(String name, void Function(_Rig rig) body, {String? memo}) {
  test(name, () {
    fakeAsync((async) {
      final rig = _Rig(async, memo: memo);
      body(rig);
      rig.dispose();
    });
  });
}

void main() {
  group('lock', () {
    _test('a fresh ended plan and a failed connection stop the tunnel', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken()
        ..settle();
      expect(rig.applied, [ConnectionRemedy.stopForAccount]);
      expect(rig.standing.lock, AccountLock.expired);
      expect(rig.standing.stoppedByUs, isTrue);
      expect(rig.notices.single.kind, AccountNoticeKind.stopped);
      expect(AccountMemo.decode(rig.store.memo).lock, AccountLock.expired);
    });

    _test('used traffic past the total locks as exhausted', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan(expiresIn: const Duration(days: 3), used: 10, total: 10)
        ..broken(FailureCause.timeout)
        ..settle();
      expect(rig.standing.lock, AccountLock.exhausted);
    });

    _test('a missing network is no evidence against the account', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken(FailureCause.noNetwork)
        ..settle();
      expect(rig.applied, isEmpty);
      expect(rig.standing, AccountStanding.clear);
    });

    _test('a working connection never locks an ended plan', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..verified()
        ..settle();
      expect(rig.applied, isEmpty);
      expect(rig.standing.lock, AccountLock.none);
    });

    _test('a stale ended plan is refreshed first, at most every 10 min', (rig) {
      rig
        ..guard.setRunning(true)
        ..broken()
        ..plan(
          expiresIn: const Duration(minutes: -30),
          fetchedAgo: const Duration(hours: 1),
        )
        ..settle();
      expect(rig.applied, ['profile.update']);
      expect(rig.standing.checking, isFalse);
      expect(rig.standing.lock, AccountLock.none);
      rig
        ..plan(
          expiresIn: const Duration(minutes: -30),
          fetchedAgo: const Duration(hours: 2),
        )
        ..settle();
      expect(rig.applied, ['profile.update']);
      rig.async.elapse(const Duration(minutes: 10));
      rig
        ..plan(
          expiresIn: const Duration(minutes: -30),
          fetchedAgo: const Duration(hours: 3),
        )
        ..settle();
      expect(rig.applied, ['profile.update', 'profile.update']);
    });

    _test('checking is published while the refresh runs', (rig) {
      rig
        ..gate = Completer<void>()
        ..plan(
          expiresIn: const Duration(minutes: -30),
          fetchedAgo: const Duration(hours: 1),
        )
        ..settle();
      expect(rig.standing.checking, isTrue);
      rig.onRemedy['profile.update'] = () =>
          rig.plan(expiresIn: const Duration(days: 30));
      rig
        ..gate!.complete()
        ..settle();
      expect(rig.standing.checking, isFalse);
      expect(rig.standing.lock, AccountLock.none);
    });

    _test('recheck refreshes a locked plan regardless of the gap', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken()
        ..settle();
      bool? clear;
      unawaited(rig.guard.recheck().then((value) => clear = value));
      rig.settle();
      expect(rig.applied.last, 'profile.update');
      expect(clear, isFalse);
      rig.onRemedy['profile.update'] = () =>
          rig.plan(expiresIn: const Duration(days: 30));
      unawaited(rig.guard.recheck().then((value) => clear = value));
      rig.settle();
      expect(clear, isTrue);
    });
  });

  group('resume', () {
    _test('a renewed plan starts the tunnel the guard stopped', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken()
        ..settle()
        ..guard.setRunning(false)
        ..plan(expiresIn: const Duration(days: 30))
        ..settle();
      expect(rig.applied.last, ConnectionRemedy.resumeAfterRenewal);
      expect(rig.notices.last.kind, AccountNoticeKind.resumed);
      expect(rig.notices.last.lock, AccountLock.expired);
      expect(rig.standing, AccountStanding.clear);
      rig.guard.setRunning(true);
      expect(rig.standing.stoppedByUs, isFalse);
    });

    _test('a start by the user drops the pending resume', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken()
        ..settle()
        ..guard.setRunning(false)
        ..guard.setRunning(true);
      expect(rig.standing.stoppedByUs, isFalse);
      rig
        ..guard.setRunning(false)
        ..plan(expiresIn: const Duration(days: 30))
        ..settle();
      expect(rig.applied, isNot(contains(ConnectionRemedy.resumeAfterRenewal)));
    });

    _test(
      'a stop restored from the store resumes after the process died',
      (rig) {
        rig
          ..plan(expiresIn: const Duration(days: 30))
          ..settle();
        expect(rig.applied, [ConnectionRemedy.resumeAfterRenewal]);
      },
      memo: const AccountMemo(
        stoppedProfile: 1,
        lockFingerprint: '1|0|0',
        lock: AccountLock.expired,
      ).encode(),
    );

    _test('a restored lock without an ended plan is cleared', (rig) {
      expect(rig.standing.lock, AccountLock.none);
    }, memo: const AccountMemo(lock: AccountLock.expired).encode());
  });

  group('connect anyway', () {
    _test('an override holds for the same figures only', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..broken()
        ..settle();
      unawaited(rig.guard.connectAnyway());
      rig
        ..guard.setRunning(false)
        ..guard.setRunning(true)
        ..broken()
        ..settle();
      expect(rig.standing.overridden, isTrue);
      expect(rig.standing.lock, AccountLock.none);
      expect(
        rig.applied.where((id) => id == ConnectionRemedy.stopForAccount),
        hasLength(1),
      );
      rig
        ..plan(expiresIn: const Duration(days: -2))
        ..broken()
        ..settle();
      expect(rig.standing.overridden, isFalse);
      expect(rig.standing.lock, AccountLock.expired);
    });

    _test('an override ends after 24 hours', (rig) {
      rig
        ..guard.setRunning(true)
        ..plan()
        ..settle();
      unawaited(rig.guard.connectAnyway());
      rig.settle();
      expect(rig.standing.overridden, isTrue);
      rig.async.elapse(const Duration(hours: 24));
      rig.verified();
      expect(rig.standing.overridden, isFalse);
    });
  });

  _test('the expiry moment re-evaluates without a fetch', (rig) {
    rig
      ..plan(expiresIn: const Duration(hours: 1))
      ..settle();
    expect(rig.reevaluations, 0);
    rig.async.elapse(const Duration(hours: 1));
    expect(rig.reevaluations, 1);
  });

  test('the memo survives an encode round trip', () {
    final memo = AccountMemo(
      overrideFingerprint: '1|2|3',
      overrideUntil: _start,
      stoppedProfile: 4,
      lockFingerprint: '4|5|6',
      lock: AccountLock.exhausted,
    );
    expect(AccountMemo.decode(memo.encode()), memo);
    expect(AccountMemo.decode('not json'), const AccountMemo());
    expect(AccountMemo.decode(null), const AccountMemo());
  });

  test('the fingerprint ignores used traffic', () {
    final fact = SubscriptionFact(profileId: 1, expiresAt: _start, total: 9);
    expect(
      accountFingerprint(fact),
      accountFingerprint(
        SubscriptionFact(profileId: 1, expiresAt: _start, used: 5, total: 9),
      ),
    );
  });
}
