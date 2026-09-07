import 'package:reclash/common/common.dart';
import 'package:reclash/common/notice.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';

typedef CheckSubscriptionReminder = Future<void> Function(Profile profile);

Future<void> runSubscriptionReminderSweep({
  required List<Profile> profiles,
  bool? isAndroid,
  CheckSubscriptionReminder? check,
}) async {
  if (!(isAndroid ?? system.isAndroid)) return;
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
    final expire = profile.subscriptionInfo?.expire ?? 0;
    final day = subscriptionNoticeDay(expire: expire, now: _now());
    if (day == null) {
      return;
    }
    final record = await _readRecord();
    if (!record.isPending(profileId: profile.id, day: day, expire: expire)) {
      return;
    }
    if (!await _show(_request(profile, day))) {
      return;
    }
    await _writeRecord(
      record.mark(profileId: profile.id, day: day, expire: expire),
    );
  }

  Future<void> forget(int profileId) async {
    final record = await _readRecord();
    final remaining = record.forget(profileId);
    if (remaining.notified.length == record.notified.length) {
      return;
    }
    await _writeRecord(remaining);
  }

  NoticeRequest _request(Profile profile, int day) {
    final localizations = currentAppLocalizations;
    final panelMeta = profile.panelMeta;
    final renewUrl = panelMeta?.buyPlanUrl;
    final actionUrl = renewUrl ?? panelMeta?.supportUrl;
    final username = panelMeta?.accountUsername;
    final service = (panelMeta?.serviceName ?? '').trim();
    final labelAlreadyCarriesService = profile.realLabel.startsWith(
      '$service (',
    );
    var displayName = profile.realLabel;
    if (service.isNotEmpty && !labelAlreadyCarriesService) {
      displayName = username == null ? service : '$service ($username)';
    }
    return NoticeRequest(
      channelName: localizations.subscriptionNoticeChannel,
      title: sanitizeNoticeText(displayName.takeFirstValid([appName])),
      message: sanitizeNoticeText(switch (day) {
        subscriptionExpiredDay => localizations.subscriptionExpired,
        0 => localizations.subscriptionExpiresToday,
        _ => localizations.subscriptionExpiresInDays(day),
      }),
      actionLabel: actionUrl == null
          ? null
          : renewUrl != null
          ? localizations.renewSubscription
          : localizations.support,
      actionUrl: actionUrl,
    );
  }
}

final subscriptionReminder = SubscriptionReminder();
