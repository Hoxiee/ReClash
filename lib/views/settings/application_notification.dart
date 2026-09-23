import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

part 'application_notification/components.dart';
part 'application_notification/component_editor.dart';
part 'application_notification/delivery.dart';
part 'application_notification/preview.dart';

class NotificationSettingsTab extends ConsumerStatefulWidget {
  const NotificationSettingsTab({
    super.key,
    this.isAndroid,
    this.loadStatus,
    this.openSettings,
    this.requestPermission,
  });

  final bool? isAndroid;
  final NotificationStatusLoader? loadStatus;
  final NotificationSettingsOpener? openSettings;
  final NotificationPermissionRequester? requestPermission;

  @override
  ConsumerState<NotificationSettingsTab> createState() =>
      _NotificationSettingsTabState();
}

class _NotificationSettingsTabState
    extends ConsumerState<NotificationSettingsTab>
    with WidgetsBindingObserver {
  AndroidNotificationStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Channels and the permission are changed outside the app, so the summary is
  /// stale until the user comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_loadStatus());
  }

  Future<void> _loadStatus() async {
    if (!(widget.isAndroid ?? system.isAndroid)) return;
    try {
      final status = await (widget.loadStatus?.call() ?? _platformStatus());
      if (mounted) setState(() => _status = status);
    } on Object {
      if (mounted) {
        setState(
          () => _status = const AndroidNotificationStatus(
            permissionGranted: false,
            serviceChannelEnabled: false,
            subscriptionChannelEnabled: false,
          ),
        );
      }
    }
  }

  Future<AndroidNotificationStatus> _platformStatus() async =>
      app?.getNotificationStatus(
        serviceChannelId: _serviceChannelFor(
          ref.read(appSettingProvider).notificationSettings.visibility,
        ),
      ) ??
      const AndroidNotificationStatus(
        permissionGranted: true,
        serviceChannelEnabled: true,
        subscriptionChannelEnabled: true,
      );

  void _update(NotificationSettings Function(NotificationSettings) update) {
    ref
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            notificationSettings: update(state.notificationSettings),
          ),
        );
  }

  Future<void> _openSettings(String? channelId) async {
    await (widget.openSettings?.call(channelId: channelId) ??
        app?.openNotificationSettings(channelId: channelId));
  }

  Future<void> _requestPermission() async {
    final granted =
        await (widget.requestPermission?.call() ??
            app?.requestNotificationsPermission());
    // A permanently denied permission never reaches the system dialog again, so
    // the app's own notification screen is the only way left.
    if (granted != true) await _openSettings(null);
    await _loadStatus();
  }

  _Delivery _delivery(AppLocalizations l, NotificationSettings settings) =>
      switch (_status) {
        null => (text: l.notificationDeliveryChecking, fix: null),
        AndroidNotificationStatus(permissionGranted: false) => (
          text: l.notificationDeliveryPermissionDisabled,
          fix: () => unawaited(_requestPermission()),
        ),
        // A disabled service channel is how the user turns the ongoing
        // notification off, so it is the answer rather than a problem to fix.
        AndroidNotificationStatus(serviceChannelEnabled: false) => (
          text: l.notificationDeliveryOff,
          fix: null,
        ),
        AndroidNotificationStatus(subscriptionChannelEnabled: false)
            when settings.subscriptionReminders =>
          (
            text: l.notificationDeliverySubscriptionDisabled,
            fix: () => unawaited(_openSettings(_subscriptionChannelId)),
          ),
        _ => (text: l.notificationDeliveryReady, fix: null),
      };

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    if (!(widget.isAndroid ?? system.isAndroid)) {
      return _AndroidOnly(l: l);
    }
    final settings = ref.watch(
      appSettingProvider.select((state) => state.notificationSettings),
    );
    return CustomScrollView(
      primary: false,
      slivers: [
        SettingSection.sliver(
          top: 12,
          items: [
            DecorationListItem.options(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l.notificationVisibility),
              subtitle: Text(_visibilityDesc(l, settings.visibility)),
              dialogTitle: l.notificationVisibility,
              options: NotificationVisibility.values,
              value: settings.visibility,
              textBuilder: (value) =>
                  _visibilityLabel(l, value as NotificationVisibility),
              subtitleBuilder: (value) =>
                  _visibilityDesc(l, value as NotificationVisibility),
              onChanged: (value) {
                if (value == null) return;
                _update(
                  (state) =>
                      state.copyWith(visibility: value as NotificationVisibility),
                );
                unawaited(_loadStatus());
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          sliver: SliverToBoxAdapter(
            child: NotificationPreview(settings: settings.projected),
          ),
        ),
        SettingSection.sliver(
          title: l.notificationProtectionTitle,
          subTitle: l.notificationProtectionDesc,
          items: [
            _DeliverySummary(delivery: _delivery(l, settings)),
            _settingsLink(
              icon: Icons.notifications_off_outlined,
              title: l.notificationTurnOff,
              subtitle: l.notificationTurnOffDesc,
              onPressed: () =>
                  _openSettings(_serviceChannelFor(settings.visibility)),
            ),
            _settingsLink(
              icon: Icons.update_outlined,
              title: l.notificationSubscriptionChannel,
              subtitle: _subscriptionChannelId,
              onPressed: () => _openSettings(_subscriptionChannelId),
            ),
          ],
        ),
        _dependent(
          settings.detailed,
          SettingSection.sliver(
            title: l.notificationContent,
            subTitle: l.notificationComponentsDesc,
            items: [
              DecorationListItem.open(
                leading: const Icon(Icons.dashboard_customize_outlined),
                title: Text(l.notificationComponents),
                subtitle: Text(
                  settings.components.isEmpty
                      ? l.notificationComponentsEmpty
                      : settings.components
                            .map((item) => _componentLabel(l, item.type))
                            .join(' · '),
                ),
                widget: const NotificationComponentsEditor(),
              ),
            ],
          ),
        ),
        _dependent(
          settings.detailed,
          SettingSection.sliver(
            title: l.notificationControls,
            subTitle: l.notificationControlsDesc,
            items: [
              _toggle(
                icon: Icons.pause_circle_outline_rounded,
                title: l.notificationPauseAction,
                subtitle: l.notificationPauseActionDesc,
                value: settings.showPauseAction,
                onChanged: (value) =>
                    _update((state) => state.copyWith(showPauseAction: value)),
              ),
              _toggle(
                icon: Icons.stop_circle_outlined,
                title: l.showNotificationStopAction,
                subtitle: l.showNotificationStopActionDesc,
                value: settings.showStopAction,
                onChanged: (value) =>
                    _update((state) => state.copyWith(showStopAction: value)),
              ),
            ],
          ),
        ),
        SettingSection.sliver(
          title: l.notificationPrivacy,
          items: [
            _toggle(
              icon: Icons.lock_outline_rounded,
              title: l.notificationHideSensitive,
              subtitle: l.notificationHideSensitiveDesc,
              value: settings.hideSensitiveOnLockScreen,
              onChanged: (value) => _update(
                (state) => state.copyWith(hideSensitiveOnLockScreen: value),
              ),
            ),
          ],
        ),
        SettingSection.sliver(
          title: l.notificationReminders,
          subTitle: l.notificationRemindersDesc,
          items: [
            _toggle(
              icon: Icons.notifications_none_rounded,
              title: l.notificationSubscriptionReminders,
              subtitle: l.notificationSubscriptionRemindersDesc,
              value: settings.subscriptionReminders,
              onChanged: (value) => _update(
                (state) => state.copyWith(subscriptionReminders: value),
              ),
            ),
          ],
        ),
        const SettingBottomInset.sliver(),
      ],
    );
  }

  DecorationListItem _settingsLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return DecorationListItem(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded, size: 20),
      onPressed: onPressed,
    );
  }

  DecorationListItem _toggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return DecorationListItem.toggle(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dependent(bool active, Widget sliver) {
    return SliverIgnorePointer(
      ignoring: !active,
      sliver: SliverOpacity(opacity: active ? 1 : 0.38, sliver: sliver),
    );
  }
}
