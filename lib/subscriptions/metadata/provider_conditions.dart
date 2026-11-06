import 'dart:math' as math;

import 'package:reclash/common/package.dart';
import 'package:reclash/subscriptions/notification/record.dart';

const providerPlatforms = {'android', 'windows', 'macos', 'linux'};

/// Year 9999, well inside what [DateTime] can hold.
const _lastUnixSecond = 253402300799;

bool validProviderUnixSeconds(int value) =>
    value >= 0 && value <= _lastUnixSecond;

/// Whole days until [expire], never below zero; zero without a real expiry.
int remainingDays({required int expire, required DateTime now}) =>
    math.max(0, subscriptionDaysLeft(expire: expire, now: now));

double usedPercent({required int used, required int total}) =>
    used * 100 / total;

/// What a `when` clause is judged against; a stale usage figure never holds
/// a usage condition.
class ProviderConditionSnapshot {
  const ProviderConditionSnapshot({
    required this.now,
    required this.platform,
    required this.appVersion,
    this.expire = 0,
    this.total = 0,
    this.used = 0,
    this.usageStale = false,
  });

  final DateTime now;
  final int expire;
  final int total;
  final int used;
  final bool usageStale;
  final String platform;
  final String appVersion;
}

class ProviderWhen {
  const ProviderWhen({
    this.from,
    this.until,
    this.daysLeftBelow,
    this.trafficAbove,
    this.platforms,
    this.clientBelow,
  });

  static const always = ProviderWhen();

  static const knownKeys = {
    'from',
    'until',
    'days-left-below',
    'traffic-above',
    'platforms',
    'client-below',
  };

  /// Null when [json] is not an object or a key has the wrong type.
  static ProviderWhen? parse(Object? json) {
    if (json == null) return always;
    if (json is! Map) return null;
    int? number(String key) => json[key] is int ? json[key] as int : null;
    for (final key in const [
      'from',
      'until',
      'days-left-below',
      'traffic-above',
    ]) {
      if (json.containsKey(key) && number(key) == null) return null;
    }
    for (final key in const ['from', 'until']) {
      if (number(key) case final value? when !validProviderUnixSeconds(value)) {
        return null;
      }
    }
    final platforms = json['platforms'];
    if (json.containsKey('platforms') &&
        (platforms is! List ||
            platforms.any(
              (v) => v is! String || !providerPlatforms.contains(v),
            ))) {
      return null;
    }
    final client = json['client-below'];
    if (json.containsKey('client-below') &&
        (client is! String || tryParseAppVersion(client) == null)) {
      return null;
    }
    return ProviderWhen(
      from: number('from'),
      until: number('until'),
      daysLeftBelow: number('days-left-below'),
      trafficAbove: number('traffic-above'),
      platforms: platforms is List ? platforms.cast<String>().toSet() : null,
      clientBelow: client as String?,
    );
  }

  final int? from;
  final int? until;
  final int? daysLeftBelow;
  final int? trafficAbove;
  final Set<String>? platforms;
  final String? clientBelow;

  Iterable<int> get boundaries => [?from, ?until];

  bool holds(ProviderConditionSnapshot snapshot) {
    final seconds = snapshot.now.millisecondsSinceEpoch ~/ 1000;
    if (from case final from? when seconds < from) return false;
    if (until case final until? when seconds >= until) return false;
    if (daysLeftBelow case final limit?) {
      final hasExpiry = subscriptionExpireDate(snapshot.expire) != null;
      if (!hasExpiry || snapshot.usageStale) return false;
      final days = remainingDays(expire: snapshot.expire, now: snapshot.now);
      if (days >= limit) return false;
    }
    if (trafficAbove case final limit?) {
      if (snapshot.total <= 0 || snapshot.usageStale) return false;
      final percent = usedPercent(used: snapshot.used, total: snapshot.total);
      if (percent < limit) return false;
    }
    if (platforms case final platforms?
        when !platforms.contains(snapshot.platform)) {
      return false;
    }
    if (clientBelow case final limit?) {
      final installed = tryParseAppVersion(snapshot.appVersion);
      if (installed == null ||
          compareVersions(snapshot.appVersion, limit) >= 0) {
        return false;
      }
    }
    return true;
  }
}

/// The soonest moment after [now] at which a clause or countdown flips, for
/// one timer that re-evaluates the cards.
DateTime? nearestFutureBoundary(DateTime now, Iterable<int> unixSeconds) {
  final seconds = now.millisecondsSinceEpoch ~/ 1000;
  final future = unixSeconds.where((value) => value > seconds);
  if (future.isEmpty) return null;
  return DateTime.fromMillisecondsSinceEpoch(future.reduce(math.min) * 1000);
}
