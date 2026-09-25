part of '../application_notification.dart';

typedef NotificationStatusLoader = Future<AndroidNotificationStatus> Function();
typedef NotificationSettingsOpener =
    Future<bool?> Function({String? channelId});
typedef NotificationPermissionRequester = Future<bool?> Function();

const _serviceChannelId = 'ReClash';
const _subscriptionChannelId = 'reclash_subscription_reminders';

/// One channel carries every level; detailed and minimal differ only in the
/// content posted to it, and turning it off is a system-settings toggle.
String _serviceChannelFor(NotificationVisibility visibility) =>
    _serviceChannelId;

/// What stands between the settings and the shade, and the way to clear it.
typedef _Delivery = ({String text, VoidCallback? fix});

String _visibilityLabel(
  AppLocalizations l,
  NotificationVisibility visibility,
) => switch (visibility) {
  NotificationVisibility.detailed => l.notificationVisibilityDetailed,
  NotificationVisibility.minimal => l.notificationVisibilityMinimal,
};

String _visibilityDesc(AppLocalizations l, NotificationVisibility visibility) =>
    switch (visibility) {
      NotificationVisibility.detailed => l.notificationDetailedDesc,
      NotificationVisibility.minimal => l.notificationMinimalDesc,
    };

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({required this.delivery});

  final _Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final fix = delivery.fix;
    final color = fix == null ? null : context.colorScheme.error;
    return DecorationListItem(
      leading: GlyphIcon(
        fix == null ? AppGlyphs.info : AppGlyphs.error,
        color: color,
      ),
      title: Text(l.notificationDelivery),
      subtitle: Text(
        delivery.text,
        style: context.textTheme.bodyMedium?.copyWith(color: color),
      ),
      invalid: fix != null,
      trailing: fix == null
          ? null
          : Text(
              l.notificationDeliveryFix,
              style: context.textTheme.labelLarge?.copyWith(color: color),
            ),
      onPressed: fix,
    );
  }
}
