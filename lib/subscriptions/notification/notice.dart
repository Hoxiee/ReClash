import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/plugins/notification.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';

class NoticeRequest {
  const NoticeRequest({
    required this.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionUrl,
  });
  final String key;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionUrl;
}

String sanitizeNoticeText(String value) {
  final text = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return String.fromCharCodes(text.runes.take(160));
}

Future<bool> showSubscriptionNotice(NoticeRequest notice) async {
  final bridge = app;
  if (bridge == null) return false;
  final container = globalState.container;
  if (container.read(safeModeProvider)) return false;
  final settings = container.read(appSettingProvider).notificationSettings;
  if (!settings.subscriptionReminders) return false;
  final l = currentAppLocalizations;
  try {
    return await bridge.showNotice(
      channelName: l.subscriptionNoticeChannel,
      notificationKey: notice.key,
      title: notice.title,
      message: notice.message,
      hideSensitiveOnLockScreen: settings.hideSensitiveOnLockScreen,
      publicMessage: l.subscriptionNoticeChannel,
      actionLabel: notice.actionLabel,
      actionUrl: notice.actionUrl,
    );
  } on Object catch (error) {
    commonPrint.log(
      'Subscription notification failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
    return false;
  }
}
