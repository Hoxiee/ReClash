part of '../application_notification.dart';

typedef NotificationStatusLoader = Future<AndroidNotificationStatus> Function();
typedef NotificationSettingsOpener =
    Future<bool?> Function({String? channelId});
typedef NotificationPermissionRequester = Future<bool?> Function();

const _serviceChannelId = 'ReClash';
const _quietChannelId = 'ReClash.quiet';
const _hiddenChannelId = 'ReClash.off';
const _subscriptionChannelId = 'reclash_subscription_reminders';

/// A channel keeps the importance it was created with, so every level needs a
/// channel of its own.
String _serviceChannelFor(NotificationVisibility visibility) =>
    switch (visibility) {
      NotificationVisibility.detailed => _serviceChannelId,
      NotificationVisibility.minimal => _quietChannelId,
      NotificationVisibility.off => _hiddenChannelId,
    };

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

class _NotificationMasterCard extends StatelessWidget {
  const _NotificationMasterCard({required this.value, required this.onChanged});

  final NotificationVisibility value;
  final ValueChanged<NotificationVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final active = value != NotificationVisibility.off;
    return CommonCard(
      type: CommonCardType.filled,
      radius: AppCorner.lg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: active
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    shape: AppShape.all(AppCorner.md),
                  ),
                  child: Icon(
                    _visibilityIcon(value),
                    color: active
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.notificationVisibility,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _visibilityDesc(l, value),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final level in NotificationVisibility.values)
                  ChoiceChip(
                    label: Text(_visibilityLabel(l, level)),
                    selected: value == level,
                    onSelected: (_) => onChanged(level),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    labelStyle: context.textTheme.bodyMedium,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _visibilityIcon(NotificationVisibility visibility) =>
    switch (visibility) {
      NotificationVisibility.detailed => Icons.notifications_active_rounded,
      NotificationVisibility.minimal => Icons.notifications_none_rounded,
      NotificationVisibility.off => Icons.notifications_off_rounded,
    };

String _visibilityLabel(
  AppLocalizations l,
  NotificationVisibility visibility,
) => switch (visibility) {
  NotificationVisibility.detailed => l.notificationVisibilityDetailed,
  NotificationVisibility.minimal => l.notificationVisibilityMinimal,
  NotificationVisibility.off => l.notificationVisibilityOff,
};

String _visibilityDesc(AppLocalizations l, NotificationVisibility visibility) =>
    switch (visibility) {
      NotificationVisibility.detailed => l.notificationDetailedDesc,
      NotificationVisibility.minimal => l.notificationMinimalDesc,
      NotificationVisibility.off => l.notificationOffDesc,
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
