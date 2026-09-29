/// Panels that never expire answer with a date decades out rather than no date.
const perpetualExpireYear = 2099;

/// Days-before-expiry the reminder fires at when the panel names none.
const defaultExpireNotifyDays = <int>[3, 2, 1];

/// Used-traffic percents the reminder fires at when the panel names none.
const defaultTrafficNotifyPercent = <int>[90];

const subscriptionExpiredDay = -1;

DateTime? subscriptionExpireDate(int expire) {
  if (expire <= 0) return null;
  final date = DateTime.fromMillisecondsSinceEpoch(expire * 1000);
  return date.year >= perpetualExpireYear ? null : date;
}

bool subscriptionIsExpired({required int expire, required DateTime now}) {
  final expireDate = subscriptionExpireDate(expire);
  return expireDate != null && !expireDate.isAfter(now);
}

/// Whole days from [now] to expiry, floored; not meaningful once expired.
int subscriptionDaysLeft({required int expire, required DateTime now}) {
  final expireDate = subscriptionExpireDate(expire);
  if (expireDate == null) return 0;
  return expireDate.difference(now).inDays;
}

/// The threshold bucket a reminder should fire under, keyed for dedup: the
/// expired marker, day zero, or the tightest configured threshold the plan has
/// entered. Null when the plan is too far out, perpetual, or has no end date.
int? subscriptionNoticeDay({
  required int expire,
  required DateTime now,
  List<int> thresholds = defaultExpireNotifyDays,
}) {
  final expireDate = subscriptionExpireDate(expire);
  if (expireDate == null) return null;
  if (subscriptionIsExpired(expire: expire, now: now)) {
    return subscriptionExpiredDay;
  }
  final daysLeft = expireDate.difference(now).inDays;
  if (daysLeft <= 0) return 0;
  int? bucket;
  for (final threshold in thresholds) {
    if (threshold > 0 &&
        daysLeft <= threshold &&
        (bucket == null || threshold < bucket)) {
      bucket = threshold;
    }
  }
  return bucket;
}

/// Holds the `expire` each reminder fired for, so a renewal re-arms them.
class SubscriptionNoticeRecord {
  final Map<String, int> notified;

  const SubscriptionNoticeRecord({this.notified = const {}});

  /// Sentinel value stored for a fired traffic notice; the crossing itself
  /// re-arms it, so it needs no `expire` to key against.
  static const _trafficFired = 1;

  static String _key(int profileId, int day) => '$profileId:$day';

  static String _trafficKey(int profileId, int percent) =>
      '$profileId:t$percent';

  static SubscriptionNoticeRecord fromJson(Object? json) {
    if (json is! Map) {
      return const SubscriptionNoticeRecord();
    }
    final notified = <String, int>{};
    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is String && value is int) {
        notified[key] = value;
      }
    }
    return SubscriptionNoticeRecord(notified: notified);
  }

  Map<String, Object?> toJson() => notified;

  bool isPending({
    required int profileId,
    required int day,
    required int expire,
  }) => notified[_key(profileId, day)] != expire;

  SubscriptionNoticeRecord mark({
    required int profileId,
    required int day,
    required int expire,
  }) {
    return SubscriptionNoticeRecord(
      notified: {
        for (final entry in notified.entries)
          if (!_isExpireEntry(entry.key, profileId) || entry.value == expire)
            entry.key: entry.value,
        _key(profileId, day): expire,
      },
    );
  }

  bool isTrafficPending({required int profileId, required int percent}) =>
      notified[_trafficKey(profileId, percent)] != _trafficFired;

  SubscriptionNoticeRecord markTraffic({
    required int profileId,
    required int percent,
  }) {
    return SubscriptionNoticeRecord(
      notified: {...notified, _trafficKey(profileId, percent): _trafficFired},
    );
  }

  SubscriptionNoticeRecord rearmTraffic({
    required int profileId,
    required int percent,
  }) {
    final key = _trafficKey(profileId, percent);
    if (!notified.containsKey(key)) return this;
    return SubscriptionNoticeRecord(
      notified: {
        for (final entry in notified.entries)
          if (entry.key != key) entry.key: entry.value,
      },
    );
  }

  SubscriptionNoticeRecord forget(int profileId) {
    return SubscriptionNoticeRecord(
      notified: {
        for (final entry in notified.entries)
          if (!_belongsTo(entry.key, profileId)) entry.key: entry.value,
      },
    );
  }

  static bool _belongsTo(String key, int profileId) =>
      key.startsWith('$profileId:');

  static bool _isExpireEntry(String key, int profileId) {
    if (!_belongsTo(key, profileId)) return false;
    return int.tryParse(key.substring('$profileId:'.length)) != null;
  }

  @override
  String toString() => 'SubscriptionNoticeRecord($notified)';
}
