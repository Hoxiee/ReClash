import 'package:reclash/common/subscription/subscription_notice.dart';
import 'package:flutter_test/flutter_test.dart';

int _epochSeconds(DateTime date) => date.millisecondsSinceEpoch ~/ 1000;

void main() {
  final now = DateTime(2026, 5, 10, 12);

  test('a plan further out than the lead window raises no reminder', () {
    final expire = _epochSeconds(now.add(const Duration(days: 4)));

    expect(subscriptionNoticeDay(expire: expire, now: now), isNull);
  });

  test('each of the lead days maps to its own reminder', () {
    for (final days in [3, 2, 1]) {
      final expire = _epochSeconds(now.add(Duration(days: days, minutes: 1)));

      expect(subscriptionNoticeDay(expire: expire, now: now), days);
    }
  });

  test('the last hours of the plan are the day-zero reminder', () {
    final expire = _epochSeconds(now.add(const Duration(hours: 5)));

    expect(subscriptionNoticeDay(expire: expire, now: now), 0);
  });

  test('a plan already over is the expired reminder', () {
    final expire = _epochSeconds(now.subtract(const Duration(days: 9)));

    expect(
      subscriptionNoticeDay(expire: expire, now: now),
      subscriptionExpiredDay,
    );
  });

  test('a perpetual plan and a missing date both stay silent', () {
    final perpetual = _epochSeconds(DateTime(perpetualExpireYear, 1, 1));

    expect(subscriptionNoticeDay(expire: perpetual, now: now), isNull);
    expect(subscriptionNoticeDay(expire: 0, now: now), isNull);
    expect(subscriptionNoticeDay(expire: -1, now: now), isNull);
    expect(subscriptionExpireDate(perpetual), isNull);
  });

  test('the expiration helper separates an over plan from missing dates', () {
    final expired = _epochSeconds(now.subtract(const Duration(seconds: 1)));
    final active = _epochSeconds(now.add(const Duration(seconds: 1)));

    expect(subscriptionIsExpired(expire: expired, now: now), isTrue);
    expect(subscriptionIsExpired(expire: active, now: now), isFalse);
    expect(subscriptionIsExpired(expire: 0, now: now), isFalse);
  });

  test('a reminder is pending until it fires for that very expire', () {
    const record = SubscriptionNoticeRecord();

    expect(record.isPending(profileId: 1, day: 3, expire: 100), isTrue);

    final marked = record.mark(profileId: 1, day: 3, expire: 100);

    expect(marked.isPending(profileId: 1, day: 3, expire: 100), isFalse);
    expect(marked.isPending(profileId: 1, day: 2, expire: 100), isTrue);
    expect(marked.isPending(profileId: 11, day: 3, expire: 100), isTrue);
  });

  test('a renewed plan drops what the old one had already fired', () {
    final marked = const SubscriptionNoticeRecord()
        .mark(profileId: 1, day: 3, expire: 100)
        .mark(profileId: 1, day: 2, expire: 100)
        .mark(profileId: 2, day: 0, expire: 400);

    final renewed = marked.mark(profileId: 1, day: 3, expire: 500);

    expect(renewed.isPending(profileId: 1, day: 2, expire: 500), isTrue);
    expect(renewed.isPending(profileId: 1, day: 3, expire: 500), isFalse);
    expect(renewed.isPending(profileId: 2, day: 0, expire: 400), isFalse);
  });

  test('forgetting one profile leaves the others armed as they were', () {
    final marked = const SubscriptionNoticeRecord()
        .mark(profileId: 1, day: 3, expire: 100)
        .mark(profileId: 11, day: 3, expire: 200);

    final remaining = marked.forget(1);

    expect(remaining.isPending(profileId: 1, day: 3, expire: 100), isTrue);
    expect(remaining.isPending(profileId: 11, day: 3, expire: 200), isFalse);
  });

  test('a record survives a round trip through its stored form', () {
    final marked = const SubscriptionNoticeRecord().mark(
      profileId: 7,
      day: subscriptionExpiredDay,
      expire: 900,
    );

    final restored = SubscriptionNoticeRecord.fromJson(marked.toJson());

    expect(
      restored.isPending(
        profileId: 7,
        day: subscriptionExpiredDay,
        expire: 900,
      ),
      isFalse,
    );
    expect(SubscriptionNoticeRecord.fromJson('nonsense').notified, isEmpty);
    expect(
      SubscriptionNoticeRecord.fromJson({'7:0': 'nonsense'}).notified,
      isEmpty,
    );
  });
}
