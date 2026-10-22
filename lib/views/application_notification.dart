import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/plugins/notification.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/notification.dart';
import 'package:reclash/widgets/settings/setting_target.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/views/notification_components.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({
    super.key,
    this.loadStatus,
    this.openSettings,
    this.requestPermission,
  });
  final Future<AndroidNotificationStatus> Function()? loadStatus;
  final Future<bool> Function({String? channelId})? openSettings;
  final Future<bool> Function()? requestPermission;

  @override
  ConsumerState<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends ConsumerState<NotificationSettingsView>
    with WidgetsBindingObserver {
  AndroidNotificationStatus? _status;
  bool _failed = false;
  bool _busy = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final status =
          await (widget.loadStatus?.call() ?? app!.getNotificationStatus());
      if (!mounted || generation != _generation) return;
      setState(() {
        _status = status;
        _failed = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _status = null;
        _failed = true;
      });
    }
  }

  Future<void> _open([String? channelId]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final opened =
          await (widget.openSettings?.call(channelId: channelId) ??
              app!.openNotificationSettings(channelId: channelId));
      if (!opened) throw StateError('Notification settings unavailable');
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _permission() async {
    if (_busy) return;
    setState(() => _busy = true);
    var granted = false;
    try {
      granted =
          await (widget.requestPermission?.call() ??
              app!.requestNotificationsPermission());
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    if (!granted) await _open();
    await _load();
  }

  ConfigToggleItem _toggle(
    String Function(AppLocalizations) label,
    bool Function(NotificationSettings) select,
    NotificationSettings Function(NotificationSettings, bool) update,
  ) => ConfigToggleItem(
    title: (l) => label(l),
    selector: appSettingProvider.select((s) => select(s.notificationSettings)),
    onChanged: (ref, value) => ref
        .read(appSettingProvider.notifier)
        .update(
          (s) => s.copyWith(
            notificationSettings: update(s.notificationSettings, value),
          ),
        ),
  );

  ListItem _link(
    String title,
    String? subtitle,
    VoidCallback? action, {
    bool retry = false,
  }) => ListItem(
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    trailing: GlyphIcon(retry ? AppGlyphs.reset : AppGlyphs.openExternal),
    onTap: _busy ? null : action,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final settings = ref.watch(
      appSettingProvider.select((s) => s.notificationSettings),
    );
    final status = _status;
    final group = ref.watch(notificationServerGroupProvider);
    return CommonScaffold(
      title: l.notification,
      body: Builder(
        builder: (context) => SettingsPageScroll(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.contentTopPadding,
              bottom: 24 + BottomInsetScope.of(context),
            ),
            child: Column(
              children: [
                generateSection(
                  items: [
                    ConfigOptionsItem<NotificationVisibility>(
                      title: (l) => l.notificationVisibility,
                      selector: appSettingProvider.select(
                        (s) => s.notificationSettings.visibility,
                      ),
                      options: NotificationVisibility.values,
                      textBuilder: (v) => v == NotificationVisibility.detailed
                          ? l.notificationVisibilityDetailed
                          : l.notificationVisibilityMinimal,
                      onChanged: (ref, v) => ref
                          .read(appSettingProvider.notifier)
                          .update(
                            (s) => s.copyWith(
                              notificationSettings: s.notificationSettings
                                  .copyWith(visibility: v),
                            ),
                          ),
                    ),
                  ],
                  footer: l.notificationLevelDescription,
                ),
                generateSection(
                  title: l.notificationDelivery,
                  items: [
                    _link(
                      l.notification,
                      _failed
                          ? '${l.error} · ${l.retry}'
                          : status == null
                          ? l.notificationDeliveryChecking
                          : !status.permissionGranted
                          ? l.notificationDeliveryPermissionDisabled
                          : l.notificationDeliveryReady,
                      _failed
                          ? () => unawaited(_load())
                          : status?.permissionGranted == false
                          ? () => unawaited(_permission())
                          : () => unawaited(_open()),
                      retry: _failed,
                    ),
                    _link(
                      l.notificationServiceChannel,
                      status == null
                          ? null
                          : status.serviceChannelEnabled
                          ? l.notificationDeliveryReady
                          : l.notificationDeliveryServiceDisabled,
                      () => unawaited(_open(serviceNotificationChannel)),
                    ),
                    _link(
                      l.notificationSubscriptionChannel,
                      status == null
                          ? null
                          : status.subscriptionChannelEnabled
                          ? l.notificationDeliveryReady
                          : l.notificationDeliverySubscriptionDisabled,
                      () => unawaited(_open(subscriptionNotificationChannel)),
                    ),
                  ],
                ),
                if (settings.detailed)
                  generateSection(
                    title: l.notificationContent,
                    items: [
                      ListItem.open(
                        title: Text(l.notificationComponents),
                        subtitle: Text(
                          settings.components.isEmpty
                              ? l.notificationComponentsEmpty
                              : settings.components
                                    .map(
                                      (c) =>
                                          notificationComponentLabel(l, c.type),
                                    )
                                    .join(' · '),
                        ),
                        widget: const NotificationComponentsEditor(),
                      ),
                      _toggle(
                        (l) => l.showNotificationStopAction,
                        (s) => s.showStopAction,
                        (s, v) => s.copyWith(showStopAction: v),
                      ),
                      if (settings.components.any(
                        (c) =>
                            c.type == NotificationComponentType.currentServer,
                      ))
                        ListItem(
                          title: Text(l.notificationCurrentServer),
                          subtitle: Text(
                            group ?? l.notificationBlockedNoServerGroup,
                          ),
                        ),
                    ],
                    footer: l.notificationComponentsDesc,
                  ),
                generateSection(
                  title: l.notificationPrivacy,
                  items: [
                    _toggle(
                      (l) => l.notificationHideSensitive,
                      (s) => s.hideSensitiveOnLockScreen,
                      (s, v) => s.copyWith(hideSensitiveOnLockScreen: v),
                    ),
                  ],
                  footer: l.notificationHideSensitiveDesc,
                ),
                generateSection(
                  title: l.notificationReminders,
                  items: [
                    _toggle(
                      (l) => l.notificationSubscriptionReminders,
                      (s) => s.subscriptionReminders,
                      (s, v) => s.copyWith(subscriptionReminders: v),
                    ),
                  ],
                  footer: l.notificationSubscriptionRemindersDesc,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
