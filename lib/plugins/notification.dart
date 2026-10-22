import 'package:reclash/plugins/app.dart';
import 'package:reclash/common/app_localizations.dart';

const serviceNotificationChannel = 'ReClash';
const subscriptionNotificationChannel = 'reclash_subscription_reminders';

class AndroidNotificationStatus {
  const AndroidNotificationStatus({
    required this.permissionGranted,
    required this.serviceChannelEnabled,
    required this.subscriptionChannelEnabled,
  });
  final bool permissionGranted;
  final bool serviceChannelEnabled;
  final bool subscriptionChannelEnabled;
}

extension AppNotifications on App {
  Future<AndroidNotificationStatus> getNotificationStatus() async {
    final result = await methodChannel.invokeMapMethod<String, Object?>(
      'getNotificationStatus',
      {'channelName': currentAppLocalizations.subscriptionNoticeChannel},
    );
    if (result == null) throw StateError('Notification status unavailable');
    return AndroidNotificationStatus(
      permissionGranted: result['permissionGranted'] == true,
      serviceChannelEnabled: result['serviceChannelEnabled'] == true,
      subscriptionChannelEnabled: result['subscriptionChannelEnabled'] == true,
    );
  }

  Future<bool> openNotificationSettings({String? channelId}) async =>
      await methodChannel.invokeMethod<bool>('openNotificationSettings', {
        'channelId': channelId,
      }) ??
      false;

  Future<bool> requestNotificationsPermission() async =>
      await methodChannel.invokeMethod<bool>(
        'requestNotificationsPermission',
      ) ??
      false;

  Future<bool> showNotice({
    required String channelName,
    required String notificationKey,
    required String title,
    required String message,
    required bool hideSensitiveOnLockScreen,
    required String publicMessage,
    String? actionLabel,
    String? actionUrl,
  }) async =>
      await methodChannel.invokeMethod<bool>('showNotice', {
        'channelName': channelName,
        'notificationKey': notificationKey,
        'title': title,
        'message': message,
        'hideSensitiveOnLockScreen': hideSensitiveOnLockScreen,
        'publicMessage': publicMessage,
        'actionLabel': actionLabel,
        'actionUrl': actionUrl,
      }) ??
      false;
}
