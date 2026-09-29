import 'package:reclash/common/common.dart';
import 'package:reclash/common/ui/notice.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

typedef CheckSubscriptionReminder = Future<void> Function(Profile profile);

Future<void> runSubscriptionReminderSweep({
  required List<Profile> profiles,
  bool enabled = true,
  bool? isAndroid,
  CheckSubscriptionReminder? check,
}) async {
  if (!enabled || !(isAndroid ?? system.isAndroid)) return;
  final checkProfile = check ?? subscriptionReminder.check;
  for (final profile in profiles) {
    try {
      await checkProfile(profile);
    } catch (error) {
      commonPrint.log(
        'subscription reminder failed for ${profile.id}: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
    }
  }
}

class SubscriptionReminder {
  final Future<SubscriptionNoticeRecord> Function() _readRecord;
  final Future<void> Function(SubscriptionNoticeRecord record) _writeRecord;
  final Future<bool> Function(NoticeRequest notice) _show;
  final DateTime Function() _now;

  SubscriptionReminder({
    Future<SubscriptionNoticeRecord> Function()? readRecord,
    Future<void> Function(SubscriptionNoticeRecord record)? writeRecord,
    Future<bool> Function(NoticeRequest notice)? show,
    DateTime Function()? now,
  }) : _readRecord = readRecord ?? preferences.getSubscriptionNoticeRecord,
       _writeRecord = writeRecord ?? preferences.saveSubscriptionNoticeRecord,
       _show = show ?? systemNotice.show,
       _now = now ?? DateTime.now;

  Future<void> check(Profile profile) async {
    final info = profile.subscriptionInfo;
    if (info == null) return;
    final now = _now();
    var record = await _readRecord();
    var changed = false;

    if (await _checkExpire(profile, info, now, record) case final marked?) {
      record = marked;
      changed = true;
    }
    if (await _checkTraffic(profile, info, record) case final touched?) {
      record = touched;
      changed = true;
    }
    if (changed) await _writeRecord(record);
  }

  Future<SubscriptionNoticeRecord?> _checkExpire(
    Profile profile,
    SubscriptionInfo info,
    DateTime now,
    SubscriptionNoticeRecord record,
  ) async {
    final expire = info.expire;
    final thresholds =
        profile.panelMeta?.expireNotifyDays ?? defaultExpireNotifyDays;
    final day = subscriptionNoticeDay(
      expire: expire,
      now: now,
      thresholds: thresholds,
    );
    if (day == null ||
        !record.isPending(profileId: profile.id, day: day, expire: expire)) {
      return null;
    }
    final daysLeft = subscriptionDaysLeft(expire: expire, now: now);
    if (!await _show(_expireRequest(profile, day, daysLeft))) return null;
    return record.mark(profileId: profile.id, day: day, expire: expire);
  }

  Future<SubscriptionNoticeRecord?> _checkTraffic(
    Profile profile,
    SubscriptionInfo info,
    SubscriptionNoticeRecord record,
  ) async {
    final total = info.total;
    final thresholds =
        profile.panelMeta?.trafficNotifyPercent ?? defaultTrafficNotifyPercent;
    if (total <= 0 || thresholds.isEmpty) return null;
    final usedPercent = info.used * 100 / total;
    var next = record;
    var changed = false;
    for (final percent in thresholds) {
      if (usedPercent < percent &&
          !record.isTrafficPending(profileId: profile.id, percent: percent)) {
        next = next.rearmTraffic(profileId: profile.id, percent: percent);
        changed = true;
      }
    }
    final crossed = thresholds.where((percent) => usedPercent >= percent);
    if (crossed.isNotEmpty) {
      final top = crossed.reduce((a, b) => a > b ? a : b);
      if (next.isTrafficPending(profileId: profile.id, percent: top) &&
          await _show(_trafficRequest(profile, usedPercent.floor()))) {
        next = next.markTraffic(profileId: profile.id, percent: top);
        changed = true;
      }
    }
    return changed ? next : null;
  }

  Future<void> forget(int profileId) async {
    final record = await _readRecord();
    final remaining = record.forget(profileId);
    if (remaining.notified.length == record.notified.length) {
      return;
    }
    await _writeRecord(remaining);
  }

  NoticeRequest _expireRequest(Profile profile, int day, int daysLeft) {
    final localizations = currentAppLocalizations;
    final panelMeta = profile.panelMeta;
    final renewUrl = panelMeta?.buyPlanUrl;
    final actionUrl = renewUrl ?? panelMeta?.supportUrl;
    return NoticeRequest(
      channelName: localizations.subscriptionNoticeChannel,
      notificationKey: 'subscription:${profile.id}',
      title: sanitizeNoticeText(_displayName(profile)),
      message: sanitizeNoticeText(switch (day) {
        subscriptionExpiredDay => localizations.subscriptionExpired,
        _ when daysLeft <= 0 => localizations.subscriptionExpiresToday,
        _ => localizations.subscriptionExpiresInDays(daysLeft),
      }),
      actionLabel: actionUrl == null
          ? null
          : renewUrl != null
          ? localizations.renewSubscription
          : localizations.support,
      actionUrl: actionUrl,
    );
  }

  NoticeRequest _trafficRequest(Profile profile, int percent) {
    final localizations = currentAppLocalizations;
    final panelMeta = profile.panelMeta;
    final topUpUrl = panelMeta?.buyTrafficUrl;
    final actionUrl = topUpUrl ?? panelMeta?.buyPlanUrl ?? panelMeta?.supportUrl;
    return NoticeRequest(
      channelName: localizations.subscriptionNoticeChannel,
      notificationKey: 'subscription-traffic:${profile.id}',
      title: sanitizeNoticeText(_displayName(profile)),
      message: sanitizeNoticeText(localizations.subscriptionTrafficLow(percent)),
      actionLabel: actionUrl == null
          ? null
          : topUpUrl != null
          ? localizations.topUpTraffic
          : panelMeta?.buyPlanUrl != null
          ? localizations.renewSubscription
          : localizations.support,
      actionUrl: actionUrl,
    );
  }

  String _displayName(Profile profile) {
    final panelMeta = profile.panelMeta;
    final username = panelMeta?.accountUsername;
    final service = (panelMeta?.serviceName ?? '').trim();
    final labelAlreadyCarriesService = profile.realLabel.startsWith(
      '$service (',
    );
    var displayName = profile.realLabel;
    if (service.isNotEmpty && !labelAlreadyCarriesService) {
      displayName = username == null ? service : '$service ($username)';
    }
    return displayName.takeFirstValid([appName]);
  }
}

final subscriptionReminder = SubscriptionReminder();
