import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'notice.dart';
import 'record.dart';

class SubscriptionReminder {
  SubscriptionReminder({
    Future<SubscriptionNoticeRecord> Function()? readRecord,
    Future<void> Function(SubscriptionNoticeRecord)? writeRecord,
    Future<bool> Function(NoticeRequest)? show,
    DateTime Function()? now,
  }) : _read = readRecord ?? preferences.getSubscriptionNoticeRecord,
       _write = writeRecord ?? preferences.saveSubscriptionNoticeRecord,
       _show = show ?? showSubscriptionNotice,
       _now = now ?? DateTime.now;

  final Future<SubscriptionNoticeRecord> Function() _read;
  final Future<void> Function(SubscriptionNoticeRecord) _write;
  final Future<bool> Function(NoticeRequest) _show;
  final DateTime Function() _now;
  Future<void> _queue = Future.value();

  Future<void> _serial(Future<void> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.catchError((Object _) {});
    return result;
  }

  Future<void> check(Profile profile, {Profile? Function()? currentProfile}) =>
      _serial(() async {
        final latest = currentProfile == null ? profile : currentProfile();
        if (latest != null) await _check(latest);
      });

  Future<void> _check(Profile profile) async {
    final info = profile.subscriptionInfo;
    final snapshot = profile.subscriptionSnapshot;
    if (profile.type != ProfileType.url ||
        info == null ||
        snapshot?.usageStale == true) {
      return;
    }
    final l = currentAppLocalizations;
    final now = _now();
    var record = await _read();
    var changed = false;
    final day = subscriptionNoticeDay(expire: info.expire, now: now);
    if (snapshot?.metadata.perpetual != true &&
        day != null &&
        record.isPending(
          profileId: profile.id,
          day: day,
          expire: info.expire,
        )) {
      final days = subscriptionDaysLeft(expire: info.expire, now: now);
      final message = day == subscriptionExpiredDay
          ? l.subscriptionExpired
          : days <= 0
          ? l.subscriptionExpiresToday
          : l.subscriptionExpiresInDays(days);
      if (await _show(
        _request(profile, 'subscription', message, traffic: false),
      )) {
        record = record.mark(
          profileId: profile.id,
          day: day,
          expire: info.expire,
        );
        changed = true;
      }
    }
    if (info.total > 0 && snapshot?.metadata.unlimited != true) {
      final percent = (info.upload + info.download) * 100 / info.total;
      if (percent < 90 &&
          !record.isTrafficPending(profileId: profile.id, percent: 90)) {
        record = record.rearmTraffic(profileId: profile.id, percent: 90);
        changed = true;
      } else if (percent >= 90 &&
          record.isTrafficPending(profileId: profile.id, percent: 90) &&
          await _show(
            _request(
              profile,
              'subscription-traffic',
              l.subscriptionTrafficLow(percent.floor()),
              traffic: true,
            ),
          )) {
        record = record.markTraffic(profileId: profile.id, percent: 90);
        changed = true;
      }
    }
    if (changed) {
      await _write(record);
    }
  }

  NoticeRequest _request(
    Profile profile,
    String kind,
    String message, {
    required bool traffic,
  }) {
    final metadata =
        profile.subscriptionSnapshot?.metadata ?? const SubscriptionMetadata();
    final topUp = traffic ? metadata.text('provider.buyTrafficUrl') : null;
    final renew = metadata.text('provider.buyPlanUrl');
    final raw = topUp ?? renew ?? metadata.text('provider.supportUrl');
    final url = raw == null ? null : safeSubscriptionLink(raw)?.toString();
    final l = currentAppLocalizations;
    return NoticeRequest(
      key: '$kind:${profile.id}',
      title: sanitizeNoticeText(profile.realLabel),
      message: sanitizeNoticeText(message),
      actionUrl: url,
      actionLabel: url == null
          ? null
          : topUp != null
          ? l.topUpTraffic
          : renew != null
          ? l.renewSubscription
          : l.subscriptionProviderSupport,
    );
  }

  Future<void> forget(int id) => _serial(() async {
    final record = await _read();
    await _write(record.forget(id));
  });
}

final subscriptionReminder = SubscriptionReminder();
