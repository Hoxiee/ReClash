/// Panels that never expire answer with a date decades out rather than no date.
const perpetualExpireYear = 2099;

/// One reminder a day from here down to the day itself, then one after it.
const subscriptionNoticeLeadDays = 3;

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

/// Null when the plan is too far out, perpetual, or has no end date at all.
int? subscriptionNoticeDay({required int expire, required DateTime now}) {
  final expireDate = subscriptionExpireDate(expire);
  if (expireDate == null) return null;
  if (subscriptionIsExpired(expire: expire, now: now)) {
    return subscriptionExpiredDay;
  }
  final daysLeft = expireDate.difference(now).inDays;
  return daysLeft <= subscriptionNoticeLeadDays ? daysLeft : null;
}

/// Holds the `expire` each reminder fired for, so a renewal re-arms them.
class SubscriptionNoticeRecord {
  final Map<String, int> notified;

  const SubscriptionNoticeRecord({this.notified = const {}});

  static String _key(int profileId, int day) => '$profileId:$day';

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
          if (!_belongsTo(entry.key, profileId) || entry.value == expire)
            entry.key: entry.value,
        _key(profileId, day): expire,
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

  @override
  String toString() => 'SubscriptionNoticeRecord($notified)';
}
