import 'dart:ui';

import 'package:reclash/common/notice.dart';
import 'package:reclash/common/subscription_notice.dart';
import 'package:reclash/common/subscription_reminder.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoticeStore {
  SubscriptionNoticeRecord record = const SubscriptionNoticeRecord();
  final shown = <NoticeRequest>[];
  var writes = 0;
  var delivers = true;

  Future<SubscriptionNoticeRecord> read() async => record;

  Future<void> write(SubscriptionNoticeRecord value) async {
    record = value;
    writes++;
  }

  Future<bool> show(NoticeRequest notice) async {
    shown.add(notice);
    return delivers;
  }
}

final _now = DateTime(2026, 5, 10, 12);

Profile _profile({
  Duration? until,
  PanelMeta? panelMeta,
  String label = 'Plan',
  int id = 42,
}) {
  return Profile(
    id: id,
    label: label,
    autoUpdateDuration: const Duration(hours: 12),
    panelMeta: panelMeta,
    subscriptionInfo: until == null
        ? null
        : SubscriptionInfo(
            expire: _now.add(until).millisecondsSinceEpoch ~/ 1000,
          ),
  );
}

SubscriptionReminder _reminder(_NoticeStore store) => SubscriptionReminder(
  readRecord: store.read,
  writeRecord: store.write,
  show: store.show,
  now: () => _now,
);

void main() {
  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  test('a plan outside the lead window is left alone', () async {
    final store = _NoticeStore();

    await _reminder(store).check(_profile(until: const Duration(days: 9)));

    expect(store.shown, isEmpty);
    expect(store.writes, 0);
  });

  test('a profile without a subscription is left alone', () async {
    final store = _NoticeStore();

    await _reminder(store).check(_profile());

    expect(store.shown, isEmpty);
  });

  test('the reminder fires once per day of the same plan', () async {
    final store = _NoticeStore();
    final reminder = _reminder(store);
    final profile = _profile(until: const Duration(days: 2, minutes: 1));

    await reminder.check(profile);
    await reminder.check(profile);

    expect(store.shown, hasLength(1));
    expect(store.shown.single.message, 'Your subscription expires in 2 days');
    expect(store.writes, 1);
  });

  test('an undelivered reminder keeps its day armed', () async {
    final store = _NoticeStore()..delivers = false;

    await _reminder(store).check(_profile(until: const Duration(hours: 3)));

    expect(store.shown, hasLength(1));
    expect(store.writes, 0);
  });

  test('an expired plan reports the loss, not a countdown', () async {
    final store = _NoticeStore();

    await _reminder(store).check(_profile(until: const Duration(days: -4)));

    expect(store.shown.single.message, 'Your subscription has expired');
  });

  test(
    'the service name titles the notice, the profile label backs it up',
    () async {
      final store = _NoticeStore();
      final reminder = _reminder(store);

      await reminder.check(
        _profile(
          until: const Duration(hours: 3),
          panelMeta: const PanelMeta(serviceName: 'Kiwi  VPN\n'),
        ),
      );
      await reminder.check(
        _profile(until: const Duration(hours: 3), label: 'Fallback', id: 43),
      );

      expect(store.shown.first.title, 'Kiwi VPN');
      expect(store.shown.last.title, 'Fallback');
    },
  );

  test('the account username joins the service name in the title', () async {
    final store = _NoticeStore();

    await _reminder(store).check(
      _profile(
        until: const Duration(hours: 3),
        panelMeta: const PanelMeta(
          serviceName: 'Remnawave',
          accountUsername: '550704498_s07ef90',
        ),
      ),
    );

    expect(store.shown.single.title, 'Remnawave (550704498_s07ef90)');
  });

  test('the renew link outranks support, and its label follows', () async {
    final store = _NoticeStore();
    final reminder = _reminder(store);

    await reminder.check(
      _profile(
        until: const Duration(hours: 3),
        panelMeta: const PanelMeta(
          buyPlanUrl: 'https://panel.test/renew',
          supportUrl: 'https://panel.test/support',
        ),
      ),
    );
    await reminder.check(
      _profile(
        until: const Duration(hours: 3),
        id: 43,
        panelMeta: const PanelMeta(supportUrl: 'https://panel.test/support'),
      ),
    );

    expect(store.shown.first.actionUrl, 'https://panel.test/renew');
    expect(store.shown.first.actionLabel, 'Renew subscription');
    expect(store.shown.last.actionUrl, 'https://panel.test/support');
    expect(store.shown.last.actionLabel, 'Support');
  });

  test('a panel with no links leaves the notice without a button', () async {
    final store = _NoticeStore();

    await _reminder(store).check(_profile(until: const Duration(hours: 3)));

    expect(store.shown.single.actionLabel, isNull);
    expect(store.shown.single.actionUrl, isNull);
  });

  test('deleting a profile forgets only its own reminders', () async {
    final store = _NoticeStore()
      ..record = const SubscriptionNoticeRecord()
          .mark(profileId: 42, day: 0, expire: 100)
          .mark(profileId: 43, day: 0, expire: 200);
    final reminder = _reminder(store);

    await reminder.forget(42);

    expect(store.writes, 1);
    expect(store.record.isPending(profileId: 42, day: 0, expire: 100), isTrue);
    expect(store.record.isPending(profileId: 43, day: 0, expire: 200), isFalse);

    await reminder.forget(42);

    expect(store.writes, 1);
  });
  group('startup sweep', () {
    final profiles = [_profile(id: 1), _profile(id: 2), _profile(id: 3)];

    test('is Android-only', () async {
      final checked = <int>[];

      await runSubscriptionReminderSweep(
        profiles: profiles,
        isAndroid: false,
        check: (profile) async => checked.add(profile.id),
      );

      expect(checked, isEmpty);
    });

    test('visits every profile sequentially and isolates failures', () async {
      final checked = <int>[];
      var active = 0;
      var maxActive = 0;

      await runSubscriptionReminderSweep(
        profiles: profiles,
        isAndroid: true,
        check: (profile) async {
          active++;
          maxActive = active > maxActive ? active : maxActive;
          checked.add(profile.id);
          try {
            if (profile.id == 2) throw StateError('notice failed');
            await Future<void>.delayed(Duration.zero);
          } finally {
            active--;
          }
        },
      );

      expect(checked, [1, 2, 3]);
      expect(maxActive, 1);
    });
  });
}
