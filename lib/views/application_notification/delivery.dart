part of '../application_notification.dart';

typedef NotificationStatusLoader = Future<AndroidNotificationStatus> Function();
typedef NotificationSettingsOpener =
    Future<bool?> Function({String? channelId});
typedef NotificationPermissionRequester = Future<bool?> Function();

const _serviceChannelId = 'ReClash';
const _subscriptionChannelId = 'reclash_subscription_reminders';

/// One channel carries every level; detailed and minimal differ only in the
/// content posted to it, and turning it off is a system-settings toggle.
String _serviceChannelFor(NotificationVisibility visibility) => _serviceChannelId;

/// What stands between the settings and the shade, and the way to clear it.
typedef _Delivery = ({String text, VoidCallback? fix});

class _AndroidOnly extends StatelessWidget {
  const _AndroidOnly({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    primary: false,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        sliver: SliverToBoxAdapter(
          child: CommonCard(
            radius: AppCorner.xl,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 12,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 32,
                    color: context.colorScheme.primary,
                  ),
                  Text(
                    l.notificationAndroidOnly,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    l.notificationAndroidOnlyDesc,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SettingBottomInset.sliver(),
    ],
  );
}

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
      leading: Icon(
        fix == null ? Icons.info_outline_rounded : Icons.error_outline_rounded,
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
