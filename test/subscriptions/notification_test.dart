import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/notification/notice.dart';
import 'package:reclash/subscriptions/notification/record.dart';
import 'package:reclash/subscriptions/notification/reminder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 22, 12);
  final expiry =
      now.add(const Duration(days: 2, hours: 1)).millisecondsSinceEpoch ~/ 1000;
  late SubscriptionNoticeRecord record;
  late List<NoticeRequest> notices;
  late SubscriptionReminder reminder;
  Profile profile(int id, {int? expire, int used = 0}) =>
      Profile.normal(url: 'https://example.test/sub').copyWith(
        id: id,
        label: 'Account $id',
        subscriptionInfo: SubscriptionInfo(
          expire: expire ?? expiry,
          total: 100,
          download: used,
        ),
      );
  setUp(() async {
    await AppLocalizations.load(const Locale('en'));
    record = const SubscriptionNoticeRecord();
    notices = [];
    reminder = SubscriptionReminder(
      readRecord: () async => record,
      writeRecord: (next) async => record = next,
      show: (notice) async {
        notices.add(notice);
        return true;
      },
      now: () => now,
    );
  });

  test(
    'concurrent checks deliver once and preserve every profile marker',
    () async {
      await Future.wait([
        reminder.check(profile(1)),
        reminder.check(profile(1)),
        reminder.check(profile(2)),
      ]);
      expect(notices.map((n) => n.key), ['subscription:1', 'subscription:2']);
      expect(record.isPending(profileId: 1, day: 2, expire: expiry), isFalse);
      expect(record.isPending(profileId: 2, day: 2, expire: expiry), isFalse);
    },
  );

  test('denied delivery retries and never marks a notice as sent', () async {
    var enabled = false;
    reminder = SubscriptionReminder(
      readRecord: () async => record,
      writeRecord: (next) async => record = next,
      show: (notice) async {
        notices.add(notice);
        return enabled;
      },
      now: () => now,
    );
    await reminder.check(profile(1));
    expect(record.notified, isEmpty);
    enabled = true;
    await reminder.check(profile(1));
    await reminder.check(profile(1));
    expect(notices, hasLength(2));
    expect(record.notified, isNotEmpty);
  });

  test(
    'renewal and a new traffic threshold crossing rearm reminders',
    () async {
      await reminder.check(profile(1, used: 95));
      await reminder.check(profile(1, used: 96));
      await reminder.check(profile(1, used: 40));
      await reminder.check(profile(1, expire: expiry + 3600, used: 91));
      expect(notices.map((n) => n.key), [
        'subscription:1',
        'subscription-traffic:1',
        'subscription:1',
        'subscription-traffic:1',
      ]);
    },
  );

  test(
    'stale usage and perpetual unlimited subscriptions stay silent',
    () async {
      final snapshot = SubscriptionSnapshot(
        metadata: const SubscriptionMetadata(),
        receivedAt: now,
        stale: true,
      );
      await reminder.check(
        profile(1, used: 95).copyWith(subscriptionSnapshot: snapshot),
      );
      await reminder.check(
        profile(2, used: 95).copyWith(
          subscriptionSnapshot: SubscriptionSnapshot(
            metadata: const SubscriptionMetadata({
              'subscription.perpetual': true,
              'subscription.unlimited': true,
            }),
            receivedAt: now,
          ),
        ),
      );
      await reminder.check(profile(3, expire: 0));
      expect(notices, isEmpty);
    },
  );

  test('expiry handles today, expired, absent and huge epoch values', () {
    expect(
      subscriptionNoticeDay(
        expire:
            now.add(const Duration(hours: 3)).millisecondsSinceEpoch ~/ 1000,
        now: now,
      ),
      0,
    );
    expect(
      subscriptionNoticeDay(
        expire: now.millisecondsSinceEpoch ~/ 1000,
        now: now,
      ),
      subscriptionExpiredDay,
    );
    for (final value in [0, -1, 8640000000000, 9223372036854775807]) {
      expect(subscriptionExpireDate(value), isNull);
    }
  });

  test(
    'queued checks resolve fresh profiles and skip deleted profiles',
    () async {
      final gate = Completer<bool>();
      reminder = SubscriptionReminder(
        readRecord: () async => record,
        writeRecord: (next) async => record = next,
        show: (notice) async {
          notices.add(notice);
          return gate.future;
        },
        now: () => now,
      );
      final first = reminder.check(profile(1));
      Profile? current = profile(2);
      final second = reminder.check(profile(2), currentProfile: () => current);
      current = null;
      gate.complete(true);
      await Future.wait([first, second]);
      expect(notices.map((n) => n.key), ['subscription:1']);
      await reminder.forget(1);
      expect(record.notified, isEmpty);
    },
  );

  test('one persistence failure does not poison the reminder queue', () async {
    var attempts = 0;
    reminder = SubscriptionReminder(
      readRecord: () async => record,
      writeRecord: (next) async {
        if (attempts++ == 0) throw StateError('storage');
        record = next;
      },
      show: (notice) async {
        notices.add(notice);
        return true;
      },
      now: () => now,
    );
    await expectLater(reminder.check(profile(1)), throwsStateError);
    await reminder.check(profile(2));
    expect(record.isPending(profileId: 2, day: 2, expire: expiry), isFalse);
  });

  test('notice text collapses lines and truncates on Unicode boundaries', () {
    expect(sanitizeNoticeText('  Account\n name\t '), 'Account name');
    expect(
      sanitizeNoticeText(List.filled(200, '😀').join()).runes,
      hasLength(160),
    );
  });
}
