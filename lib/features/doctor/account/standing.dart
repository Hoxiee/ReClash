import 'package:flutter/foundation.dart';

enum AccountLock { none, expired, exhausted }

/// The account as the guard judged it: a lock needs fresh data saying the
/// plan ended and a connection that failed under it.
@immutable
final class AccountStanding {
  const AccountStanding({
    this.lock = AccountLock.none,
    this.checking = false,
    this.overridden = false,
    this.stoppedByUs = false,
  });

  static const clear = AccountStanding();

  final AccountLock lock;

  /// A refresh of a stale expired or exhausted reading is in flight.
  final bool checking;

  /// The user chose to connect anyway for the current expiry and totals.
  final bool overridden;

  /// The guard stopped the tunnel for the lock and will start it again once
  /// the plan is renewed, unless the user acts first.
  final bool stoppedByUs;

  @override
  bool operator ==(Object other) =>
      other is AccountStanding &&
      other.lock == lock &&
      other.checking == checking &&
      other.overridden == overridden &&
      other.stoppedByUs == stoppedByUs;

  @override
  int get hashCode => Object.hash(lock, checking, overridden, stoppedByUs);
}

enum AccountNoticeKind { stopped, resumed }

@immutable
final class AccountNotice {
  const AccountNotice(this.kind, this.lock);

  final AccountNoticeKind kind;

  /// The lock that stopped the tunnel, or the one renewal cleared.
  final AccountLock lock;
}
