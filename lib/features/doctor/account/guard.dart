import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../cause.dart';
import '../kernel.dart';
import '../remedies/connection.dart';
import '../snapshot.dart';
import '../supervisor/health.dart';
import 'standing.dart';

/// Failures that say the upstream refuses us; a local network problem never
/// proves the plan ended.
const accountEvidence = {
  FailureCause.authRejected,
  FailureCause.timeout,
  FailureCause.reset,
  FailureCause.tlsHandshake,
  FailureCause.refused,
  FailureCause.noUpstream,
};

AccountLock accountEnded(SubscriptionFact? fact, DateTime now) {
  if (fact == null) return AccountLock.none;
  final expiresAt = fact.expiresAt;
  if (expiresAt != null && !expiresAt.isAfter(now)) return AccountLock.expired;
  if (fact.total > 0 && fact.used >= fact.total) return AccountLock.exhausted;
  return AccountLock.none;
}

/// The figures a lock and an override hold for; any change re-evaluates.
String accountFingerprint(SubscriptionFact fact) =>
    '${fact.profileId}|${fact.expiresAt?.millisecondsSinceEpoch}|${fact.total}';

@immutable
final class AccountMemo {
  const AccountMemo({
    this.overrideFingerprint,
    this.overrideUntil,
    this.stoppedProfile,
    this.lockFingerprint,
    this.lock = AccountLock.none,
  });

  factory AccountMemo.decode(String? source) {
    if (source == null || source.isEmpty) return const AccountMemo();
    try {
      final json = jsonDecode(source) as Map<String, Object?>;
      return AccountMemo(
        overrideFingerprint: json['override'] as String?,
        overrideUntil: switch (json['until']) {
          final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
          _ => null,
        },
        stoppedProfile: json['stopped'] as int?,
        lockFingerprint: json['lockFor'] as String?,
        lock: AccountLock.values.asNameMap()[json['lock']] ?? AccountLock.none,
      );
    } on Object {
      return const AccountMemo();
    }
  }

  final String? overrideFingerprint;
  final DateTime? overrideUntil;
  final int? stoppedProfile;
  final String? lockFingerprint;
  final AccountLock lock;

  AccountMemo copyWith({
    Object? overrideFingerprint = _keep,
    Object? overrideUntil = _keep,
    Object? stoppedProfile = _keep,
    Object? lockFingerprint = _keep,
    AccountLock? lock,
  }) => AccountMemo(
    overrideFingerprint: overrideFingerprint == _keep
        ? this.overrideFingerprint
        : overrideFingerprint as String?,
    overrideUntil: overrideUntil == _keep
        ? this.overrideUntil
        : overrideUntil as DateTime?,
    stoppedProfile: stoppedProfile == _keep
        ? this.stoppedProfile
        : stoppedProfile as int?,
    lockFingerprint: lockFingerprint == _keep
        ? this.lockFingerprint
        : lockFingerprint as String?,
    lock: lock ?? this.lock,
  );

  @override
  bool operator ==(Object other) =>
      other is AccountMemo &&
      other.overrideFingerprint == overrideFingerprint &&
      other.overrideUntil == overrideUntil &&
      other.stoppedProfile == stoppedProfile &&
      other.lockFingerprint == lockFingerprint &&
      other.lock == lock;

  @override
  int get hashCode => Object.hash(
    overrideFingerprint,
    overrideUntil,
    stoppedProfile,
    lockFingerprint,
    lock,
  );

  String encode() => jsonEncode({
    'override': ?overrideFingerprint,
    'until': ?overrideUntil?.millisecondsSinceEpoch,
    'stopped': ?stoppedProfile,
    'lockFor': ?lockFingerprint,
    if (lock != AccountLock.none) 'lock': lock.name,
  });
}

abstract interface class AccountStore {
  Future<String?> load();

  Future<void> save(String memo);
}

/// Judges the account from the subscription fact and the supervisor's
/// verdicts. It stops and starts the tunnel only through remedies, which ask
/// the lifecycle owners.
class AccountGuard {
  AccountGuard({
    required DiagnosticKernel kernel,
    required Stream<ConnectionHealth> health,
    required AccountStore store,
    Future<void> Function()? reevaluate,
    DateTime Function()? clock,
    this.freshFor = const Duration(minutes: 10),
    this.staleRefreshGap = const Duration(minutes: 10),
    this.lockedRefreshGap = const Duration(minutes: 1),
    this.overrideLimit = const Duration(hours: 24),
  }) : _kernel = kernel,
       _health = health,
       _store = store,
       _reevaluate = reevaluate,
       _clock = clock ?? DateTime.now;

  /// An expired reading fetched within this long is believed.
  final Duration freshFor;
  final Duration staleRefreshGap;
  final Duration lockedRefreshGap;
  final Duration overrideLimit;

  final DiagnosticKernel _kernel;
  final Stream<ConnectionHealth> _health;
  final AccountStore _store;

  /// Re-runs the rules, so the findings follow the clock at expiry.
  final Future<void> Function()? _reevaluate;
  final DateTime Function() _clock;

  final _updates = StreamController<AccountStanding>.broadcast(sync: true);
  final _notices = StreamController<AccountNotice>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  final _refreshedAt = <int, DateTime>{};

  AccountStanding _standing = AccountStanding.clear;
  AccountMemo _memo = const AccountMemo();
  SubscriptionFact? _fact;
  bool _running = false;
  bool _visible = true;
  bool _checking = false;
  bool _ourStart = false;
  bool _stopping = false;
  FailureCause? _evidence;
  Timer? _expiry;
  DateTime? _expiryAt;
  bool _started = false;
  bool _disposed = false;

  AccountStanding get standing => _standing;

  Stream<AccountStanding> get updates => _updates.stream;

  Stream<AccountNotice> get notices => _notices.stream;

  Future<void> start() async {
    _memo = AccountMemo.decode(await _store.load());
    if (_disposed) return;
    _subscriptions
      ..add(_kernel.snapshots.listen(_onSnapshot))
      ..add(_health.listen(_onHealth));
    _fact = _kernel.snapshot.valueOf(Facts.subscription);
    _started = true;
    _evaluate();
  }

  void setRunning(bool running) {
    if (running == _running) return;
    _running = running;
    if (running) {
      if (!_ourStart && _memo.stoppedProfile != null) {
        _remember(_memo.copyWith(stoppedProfile: null));
      }
      _ourStart = false;
    } else {
      _evidence = null;
    }
    _evaluate();
  }

  void setVisible(bool visible) {
    if (visible == _visible) return;
    _visible = visible;
    final fact = _fact;
    if (!visible || fact == null) return;
    if (_memo.lock != AccountLock.none) {
      unawaited(_refresh(fact.profileId, gap: lockedRefreshGap));
    } else {
      _evaluate();
    }
  }

  /// Stores the user's choice for the current figures; the caller starts the
  /// tunnel itself.
  Future<void> connectAnyway() async {
    final fact = _fact;
    if (fact == null) return;
    _remember(
      _memo.copyWith(
        overrideFingerprint: accountFingerprint(fact),
        overrideUntil: _clock().add(overrideLimit),
        lockFingerprint: null,
        lock: AccountLock.none,
      ),
    );
    _evaluate();
  }

  /// Fetches the subscription now; true when no lock remains.
  Future<bool> recheck() async {
    final fact = _fact;
    if (fact != null) await _refresh(fact.profileId, gap: Duration.zero);
    return _memo.lock == AccountLock.none;
  }

  void _onSnapshot(DiagnosticSnapshot snapshot) {
    final fact = snapshot.valueOf(Facts.subscription);
    if (fact == _fact) return;
    _fact = fact;
    _evaluate();
  }

  void _onHealth(ConnectionHealth health) {
    switch (health.phase) {
      case ConnectionPhase.verified:
        _evidence = null;
      case ConnectionPhase.broken when accountEvidence.contains(health.cause):
        _evidence = health.cause;
      default:
        return;
    }
    _evaluate();
  }

  bool _fresh(SubscriptionFact fact, AccountLock ended, DateTime now) {
    final fetchedAt = fact.fetchedAt;
    if (fetchedAt == null) return false;
    final expiresAt = fact.expiresAt;
    if (ended == AccountLock.expired &&
        expiresAt != null &&
        fetchedAt.isAfter(expiresAt)) {
      return true;
    }
    return now.difference(fetchedAt) < freshFor;
  }

  void _evaluate() {
    if (_disposed || !_started) return;
    final now = _clock();
    final fact = _fact;
    final ended = accountEnded(fact, now);
    final fingerprint = fact == null ? null : accountFingerprint(fact);
    var memo = _memo;
    if (fact != null &&
        memo.stoppedProfile != null &&
        memo.stoppedProfile != fact.profileId) {
      memo = memo.copyWith(stoppedProfile: null);
    }
    final overrideUntil = memo.overrideUntil;
    final overridden =
        memo.overrideFingerprint == fingerprint &&
        overrideUntil != null &&
        now.isBefore(overrideUntil);
    final previousLock = memo.lock;
    if (memo.lock != AccountLock.none &&
        (memo.lockFingerprint != fingerprint ||
            ended == AccountLock.none ||
            overridden)) {
      memo = memo.copyWith(lockFingerprint: null, lock: AccountLock.none);
    }
    if (memo != _memo) _remember(memo);
    _scheduleExpiry(fact?.expiresAt, now);
    if (memo.lock == AccountLock.none &&
        memo.stoppedProfile != null &&
        ended == AccountLock.none &&
        !_running) {
      _resume(previousLock);
    }
    if (fact != null && ended != AccountLock.none) {
      if (!_fresh(fact, ended, now)) {
        unawaited(_refresh(fact.profileId, gap: staleRefreshGap));
      } else if (_evidence != null && _running && !overridden && !_stopping) {
        unawaited(_lockAndStop(ended, fingerprint!, fact.profileId));
      }
    }
    _publish(overridden);
  }

  Future<void> _lockAndStop(
    AccountLock lock,
    String fingerprint,
    int profile,
  ) async {
    _stopping = true;
    _evidence = null;
    _remember(
      _memo.copyWith(
        lockFingerprint: fingerprint,
        lock: lock,
        stoppedProfile: profile,
      ),
    );
    _publish(false);
    try {
      await _kernel.apply(ConnectionRemedy.stopForAccount);
      if (!_disposed) {
        _notices.add(AccountNotice(AccountNoticeKind.stopped, lock));
      }
    } finally {
      _stopping = false;
    }
  }

  void _resume(AccountLock cleared) {
    _remember(_memo.copyWith(stoppedProfile: null));
    _ourStart = true;
    _notices.add(AccountNotice(AccountNoticeKind.resumed, cleared));
    unawaited(_kernel.apply(ConnectionRemedy.resumeAfterRenewal));
  }

  Future<void> _refresh(int profileId, {required Duration gap}) async {
    final now = _clock();
    final last = _refreshedAt[profileId];
    if (_checking || last != null && now.difference(last) < gap) return;
    _refreshedAt[profileId] = now;
    _checking = true;
    _publish(null);
    try {
      await _kernel.apply('profile.update');
    } finally {
      _checking = false;
      if (!_disposed) {
        _fact = _kernel.snapshot.valueOf(Facts.subscription);
        _evaluate();
      }
    }
  }

  /// The findings change at the expiry moment without a fetch.
  void _scheduleExpiry(DateTime? expiresAt, DateTime now) {
    if (expiresAt == _expiryAt) return;
    _expiry?.cancel();
    _expiryAt = expiresAt;
    if (expiresAt == null || !expiresAt.isAfter(now)) return;
    _expiry = Timer(expiresAt.difference(now), () async {
      await _reevaluate?.call();
      _evaluate();
    });
  }

  void _remember(AccountMemo memo) {
    _memo = memo;
    unawaited(_store.save(memo.encode()).catchError((Object _) {}));
  }

  /// A null [overridden] keeps the last published value.
  void _publish(bool? overridden) {
    if (_disposed) return;
    final next = AccountStanding(
      lock: _memo.lock,
      checking: _checking,
      overridden: overridden ?? _standing.overridden,
      stoppedByUs: _memo.stoppedProfile != null,
    );
    if (next == _standing) return;
    _standing = next;
    _updates.add(next);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _expiry?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _updates.close();
    await _notices.close();
  }
}

const _keep = Object();
