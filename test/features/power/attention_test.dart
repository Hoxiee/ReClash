import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/power/attention.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';

final _now = DateTime.utc(2026, 11, 9, 12);

int _expireIn(Duration offset) =>
    _now.add(offset).millisecondsSinceEpoch ~/ 1000;

AccountAttention? _attention({
  SubscriptionMetadata metadata = const SubscriptionMetadata(),
  int used = 0,
  int total = 0,
  int expire = 0,
}) => accountAttention(
  metadata: metadata,
  used: used,
  total: total,
  expire: expire,
  now: _now,
);

void main() {
  group('days', () {
    test('within the default three-day window reports the days left', () {
      for (final days in [1, 2, 3]) {
        expect(
          _attention(expire: _expireIn(Duration(days: days))),
          AccountAttention.days(days),
          reason: '$days days',
        );
      }
    });

    test('beyond the default window reports nothing', () {
      expect(_attention(expire: _expireIn(const Duration(days: 4))), isNull);
    });

    test('a plan already past its end is not an attention', () {
      expect(_attention(expire: _expireIn(const Duration(days: -1))), isNull);
    });

    test('a perpetual plan has no days attention', () {
      expect(
        _attention(
          metadata: const SubscriptionMetadata({
            'subscription.perpetual': true,
          }),
          expire: _expireIn(const Duration(days: 2)),
        ),
        isNull,
      );
    });

    test('a custom expiry threshold replaces the default window', () {
      const metadata = SubscriptionMetadata({
        'reminder.expireDays': [7],
      });
      expect(
        _attention(
          metadata: metadata,
          expire: _expireIn(const Duration(days: 5)),
        ),
        const AccountAttention.days(5),
      );
      expect(
        _attention(
          metadata: metadata,
          expire: _expireIn(const Duration(days: 8)),
        ),
        isNull,
      );
    });

    test('several expiry thresholds warn at the widest one', () {
      const metadata = SubscriptionMetadata({
        'reminder.expireDays': [2, 10],
      });
      expect(
        _attention(
          metadata: metadata,
          expire: _expireIn(const Duration(days: 5)),
        ),
        const AccountAttention.days(5),
      );
    });

    test('days are checked before traffic', () {
      expect(
        _attention(
          used: 950,
          total: 1000,
          expire: _expireIn(const Duration(days: 2)),
        ),
        const AccountAttention.days(2),
      );
    });
  });

  group('traffic', () {
    test('at 90 percent used reports the bytes left', () {
      expect(
        _attention(used: 900, total: 1000),
        const AccountAttention.traffic(100),
      );
    });

    test('below 90 percent reports nothing', () {
      expect(_attention(used: 899, total: 1000), isNull);
    });

    test('fully used reports nothing', () {
      expect(_attention(used: 1000, total: 1000), isNull);
      expect(_attention(used: 1200, total: 1000), isNull);
    });

    test('an unlimited or zero total reports nothing', () {
      expect(
        _attention(
          metadata: const SubscriptionMetadata({
            'subscription.unlimited': true,
          }),
          used: 950,
          total: 1000,
        ),
        isNull,
      );
      expect(_attention(used: 950), isNull);
    });

    test('a custom traffic threshold replaces the default', () {
      const metadata = SubscriptionMetadata({
        'reminder.trafficPercent': [50],
      });
      expect(
        _attention(metadata: metadata, used: 600, total: 1000),
        const AccountAttention.traffic(400),
      );
      expect(_attention(used: 600, total: 1000), isNull);
    });

    test('several traffic thresholds warn at the lowest one', () {
      const metadata = SubscriptionMetadata({
        'reminder.trafficPercent': [50, 95],
      });
      expect(
        _attention(metadata: metadata, used: 600, total: 1000),
        const AccountAttention.traffic(400),
      );
    });
  });

  group('accountLinks', () {
    test('a safe https buy-plan link offers renewal', () {
      const metadata = SubscriptionMetadata({
        'provider.buyPlanUrl': 'https://example.com/plans',
      });
      expect(accountLinks(metadata).renew, isTrue);
      expect(
        accountLinkUrl(metadata, PowerAction.renew),
        Uri.parse('https://example.com/plans'),
      );
    });

    test('an unsafe buy-plan scheme offers nothing', () {
      const metadata = SubscriptionMetadata({
        'provider.buyPlanUrl': 'javascript:alert(1)',
      });
      expect(accountLinks(metadata).renew, isFalse);
    });

    test('a buy-traffic link offers top-up', () {
      const metadata = SubscriptionMetadata({
        'provider.buyTrafficUrl': 'https://example.com/traffic',
      });
      expect(accountLinks(metadata).topUp, isTrue);
    });

    test('a support link offers support', () {
      const metadata = SubscriptionMetadata({
        'provider.supportUrl': 'https://example.com/support',
      });
      expect(accountLinks(metadata).support, isTrue);
    });

    test('an unsafe support scheme offers nothing', () {
      const metadata = SubscriptionMetadata({
        'provider.supportUrl': 'javascript:alert(1)',
      });
      expect(accountLinks(metadata).support, isFalse);
    });

    test('metadata without links offers nothing', () {
      final links = accountLinks(const SubscriptionMetadata());
      expect(links, const AccountLinks());
    });

    test('a non-account action has no link', () {
      const metadata = SubscriptionMetadata({
        'provider.buyPlanUrl': 'https://example.com/plans',
      });
      expect(accountLinkUrl(metadata, PowerAction.start), isNull);
    });
  });
}
