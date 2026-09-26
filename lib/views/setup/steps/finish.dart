import 'dart:async';
import 'package:reclash/icons/icons.dart';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/app/permission.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/settings/access.dart';
import 'package:reclash/views/settings/resources.dart';
import 'package:reclash/views/config/smart_routing.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

abstract interface class SetupPermissionGateway {
  bool get isAndroid;

  Future<bool> isNotificationsPermissionGranted();

  Future<void> requestNotificationsPermission();

  Future<void> openAppSettings();

  Future<void> checkBatteryOptimizationDisable(ProviderReader read);

  Future<void> openBatteryOptimizationSettings();
}

class SystemSetupPermissionGateway implements SetupPermissionGateway {
  const SystemSetupPermissionGateway();

  @override
  bool get isAndroid => system.isAndroid;

  @override
  Future<bool> isNotificationsPermissionGranted() async =>
      await app?.isNotificationsPermissionGranted() ?? false;

  @override
  Future<void> requestNotificationsPermission() async {
    await app?.requestNotificationsPermission();
  }

  @override
  Future<void> openAppSettings() async {
    await app?.openAppSettings();
  }

  @override
  Future<void> checkBatteryOptimizationDisable(ProviderReader read) =>
      permissions.checkBatteryOptimizationDisable(read);

  @override
  Future<void> openBatteryOptimizationSettings() async {
    permissions.needWaitingBatteryOptimizationSettings = true;
    try {
      await app?.openBatteryOptimizationSettings();
    } catch (_) {
      permissions.needWaitingBatteryOptimizationSettings = false;
      rethrow;
    }
  }
}

enum _PermissionState { checking, pending, granted, denied, unavailable, error }

class SetupFinishStep extends ConsumerStatefulWidget {
  const SetupFinishStep({
    super.key,
    required this.onDone,
    required this.onBack,
    this.revisit = false,
    this.permissionGateway = const SystemSetupPermissionGateway(),
  });

  final VoidCallback onDone;
  final VoidCallback onBack;
  final bool revisit;
  final SetupPermissionGateway permissionGateway;

  @override
  ConsumerState<SetupFinishStep> createState() => _SetupFinishStepState();
}

class _SetupFinishStepState extends ConsumerState<SetupFinishStep>
    with WidgetsBindingObserver {
  _PermissionState _notifications = _PermissionState.checking;
  bool _notificationRequested = false;
  bool _batteryPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.revisit &&
          ref.read(profilesProvider).isEmpty &&
          ref.read(appSettingProvider).autoRun) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoRun: false));
      }
      unawaited(_refreshPermissions());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPermissions());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refreshPermissions() async {
    await _checkNotifications();
    if (!widget.permissionGateway.isAndroid) return;
    try {
      await widget.permissionGateway.checkBatteryOptimizationDisable(ref.read);
    } catch (_) {}
  }

  Future<void> _checkNotifications() async {
    if (!widget.permissionGateway.isAndroid) {
      if (mounted) {
        setState(() => _notifications = _PermissionState.unavailable);
      }
      return;
    }
    if (mounted) {
      setState(() => _notifications = _PermissionState.checking);
    }
    try {
      final granted = await widget.permissionGateway
          .isNotificationsPermissionGranted();
      if (!mounted) return;
      setState(
        () => _notifications = granted
            ? _PermissionState.granted
            : _PermissionState.denied,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _notifications = _PermissionState.error);
      }
    }
  }

  Future<void> _handleNotifications() async {
    if (_notifications == _PermissionState.pending ||
        _notifications == _PermissionState.checking) {
      return;
    }
    if (_notificationRequested || _notifications == _PermissionState.error) {
      await widget.permissionGateway.openAppSettings();
      if (mounted) await _refreshPermissions();
      return;
    }
    setState(() => _notifications = _PermissionState.pending);
    try {
      _notificationRequested = true;
      await widget.permissionGateway.requestNotificationsPermission();
      final granted = await widget.permissionGateway
          .isNotificationsPermissionGranted();
      if (!mounted) return;
      setState(
        () => _notifications = granted
            ? _PermissionState.granted
            : _PermissionState.denied,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _notifications = _PermissionState.error);
      }
    }
  }

  Future<void> _handleBattery() async {
    if (_batteryPending) return;
    setState(() => _batteryPending = true);
    try {
      await widget.permissionGateway.openBatteryOptimizationSettings();
      await widget.permissionGateway.checkBatteryOptimizationDisable(ref.read);
    } catch (_) {
      return;
    } finally {
      if (mounted) setState(() => _batteryPending = false);
    }
  }

  String _permissionLabel(AppLocalizations l10n, _PermissionState state) {
    return switch (state) {
      _PermissionState.checking ||
      _PermissionState.pending => l10n.setupPermissionChecking,
      _PermissionState.granted => l10n.setupPermissionGranted,
      _PermissionState.denied =>
        _notificationRequested
            ? l10n.setupPermissionOpenSettings
            : l10n.setupPermissionRequest,
      _PermissionState.unavailable => l10n.setupPermissionUnavailable,
      _PermissionState.error => l10n.setupPermissionOpenSettings,
    };
  }

  Future<void> _handleSmartRouting(BuildContext context, bool value) async {
    if (value && !await confirmSmartRoutingExperimental(context)) {
      return;
    }
    if (!mounted) {
      return;
    }
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update((state) => state.withEnabled(value));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final routing = ref.watch(smartRoutingSettingProvider);
    final appSetting = ref.watch(appSettingProvider);
    final profiles = ref.watch(profilesProvider);
    final profile = ref.watch(currentProfileProvider) ?? profiles.firstOrNull;
    final hasProfile = profile != null;
    final autoRun = hasProfile && appSetting.autoRun;
    final storedAutoRun = appSetting.autoRun;
    final battery = ref.watch(batteryOptimizationDisableProvider);
    final systemProxy = ref.watch(
      networkSettingProvider.select((state) => state.systemProxy),
    );
    final tun = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );
    return SetupStepScaffold(
      title: appLocalizations.setupFinishTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          SetupSection(
            caption: appLocalizations.setupRegionSettings,
            description: appLocalizations.setupRegionSettingsDesc,
            child: SetupCard(
              child: Column(
                children: [
                  ListItem.toggle(
                    key: const ValueKey('setup-smart-routing'),
                    title: Row(
                      spacing: AppSpacing.sm,
                      children: [
                        Flexible(child: Text(appLocalizations.smartRouting)),
                        const ExperimentalBadge(),
                      ],
                    ),
                    subtitle: Text(appLocalizations.smartRoutingDesc),
                    value: routing.enabled,
                    onChanged: (value) => _handleSmartRouting(context, value),
                  ),
                  ListItem<SmartRoutingStrategy>.options(
                    key: const ValueKey('setup-smart-routing-preset'),
                    leading: const GlyphIcon(AppGlyphs.sliders),
                    title: Text(appLocalizations.smartRoutingPreset),
                    subtitle: Text(
                      routing.matchesStrategy
                          ? routing.strategy.label
                          : appLocalizations.smartRoutingStrategyEdited(
                              routing.strategy.label,
                            ),
                    ),
                    dialogTitle: appLocalizations.smartRoutingPreset,
                    options: SmartRoutingStrategy.values,
                    value: routing.strategy,
                    textBuilder: (value) => value.label,
                    subtitleBuilder: (value) => value.description,
                    onChanged: (value) {
                      if (!mounted || value == null) return;
                      ref
                          .read(smartRoutingSettingProvider.notifier)
                          .update((state) => state.applyStrategy(value));
                    },
                  ),
                  ListItem.next(
                    leading: const GlyphIcon(AppGlyphs.language),
                    title: Text(appLocalizations.geoResources),
                    subtitle: Text(appLocalizations.resourcesDesc),
                    widget: const ResourcesView(),
                  ),
                  if (system.isAndroid)
                    ListItem.next(
                      leading: const GlyphIcon(AppGlyphs.appsList),
                      title: Text(appLocalizations.accessControl),
                      subtitle: Text(appLocalizations.accessControlDesc),
                      widget: const AccessView(),
                    ),
                ],
              ),
            ),
          ),
          SetupSection(
            caption: appLocalizations.connection,
            child: SetupCard(
              child: Column(
                children: [
                  ListItem.toggle(
                    title: Text(appLocalizations.setupAutoRun),
                    subtitle: Text(
                      hasProfile
                          ? appLocalizations.setupAutoRunDesc
                          : appLocalizations.setupAutoRunUnavailable,
                    ),
                    value: autoRun,
                    onChanged: hasProfile
                        ? (value) => ref
                              .read(appSettingProvider.notifier)
                              .update((state) => state.copyWith(autoRun: value))
                        : null,
                  ),
                  if (system.isDesktop) ...[
                    ListItem.toggle(
                      title: Text(appLocalizations.systemProxy),
                      subtitle: Text(appLocalizations.setupSystemProxyDesc),
                      value: systemProxy,
                      onChanged: (value) => ref
                          .read(networkSettingProvider.notifier)
                          .update(
                            (state) => state.copyWith(systemProxy: value),
                          ),
                    ),
                    ListItem.toggle(
                      title: Text(appLocalizations.tun),
                      subtitle: Text(appLocalizations.setupTunDesc),
                      value: tun,
                      onChanged: (value) => ref
                          .read(patchClashConfigProvider.notifier)
                          .update((state) => state.copyWith.tun(enable: value)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.permissionGateway.isAndroid)
            SetupSection(
              caption: appLocalizations.setupPermissionsTitle,
              child: SetupCard(
                child: Column(
                  children: [
                    _PermissionRow(
                      title: appLocalizations.setupPermissionVpn,
                      desc: appLocalizations.setupPermissionVpnDesc,
                      status: appLocalizations.setupPermissionDeferred,
                      trailing: const GlyphIcon(AppGlyphs.clock, size: 20),
                    ),
                    _PermissionRow(
                      title: appLocalizations.setupPermissionNotifications,
                      desc: appLocalizations.setupPermissionNotificationsDesc,
                      status: _permissionLabel(
                        appLocalizations,
                        _notifications,
                      ),
                      granted: _notifications == _PermissionState.granted,
                      failed: _notifications == _PermissionState.error,
                      pending:
                          _notifications == _PermissionState.pending ||
                          _notifications == _PermissionState.checking,
                      onPressed:
                          _notifications == _PermissionState.granted ||
                              _notifications == _PermissionState.unavailable
                          ? null
                          : _handleNotifications,
                    ),
                    _PermissionRow(
                      title: appLocalizations.setupPermissionBattery,
                      desc: appLocalizations.setupPermissionBatteryDesc,
                      status: battery
                          ? appLocalizations.setupPermissionGranted
                          : _batteryPending
                          ? appLocalizations.setupPermissionChecking
                          : appLocalizations.setupPermissionRequest,
                      granted: battery,
                      pending: _batteryPending,
                      onPressed: battery ? null : _handleBattery,
                    ),
                  ],
                ),
              ),
            ),
          SetupSection(
            caption: appLocalizations.setupSummaryTitle,
            child: SetupCard(
              child: Padding(
                padding: AppInsets.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    Text(
                      profile == null
                          ? appLocalizations.setupSummaryNoProfile
                          : appLocalizations.setupSummaryProfile(
                              profile.label.takeFirstValid([
                                appLocalizations.profile,
                              ]),
                            ),
                    ),
                    Text(
                      appLocalizations.setupSummaryRouting(
                        routing.enabled
                            ? routing.preset.label
                            : appLocalizations.off,
                      ),
                    ),
                    if (system.isDesktop) ...[
                      Text(
                        systemProxy
                            ? appLocalizations.setupSummarySystemProxyOn
                            : appLocalizations.setupSummarySystemProxyOff,
                      ),
                      Text(
                        tun
                            ? appLocalizations.setupSummaryTunOn
                            : appLocalizations.setupSummaryTunOff,
                      ),
                    ],
                    Text(
                      widget.revisit && !hasProfile && storedAutoRun
                          ? appLocalizations.setupAutoRunUnavailable
                          : autoRun
                          ? appLocalizations.setupSummaryAutoRunOn
                          : appLocalizations.setupSummaryAutoRunOff,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        SetupPrimaryButton(
          label: autoRun && !widget.revisit
              ? appLocalizations.setupDoneConnect
              : appLocalizations.setupDone,
          onPressed: widget.onDone,
        ),
        OutlinedButton(
          onPressed: widget.onBack,
          child: Text(appLocalizations.setupBack),
        ),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.desc,
    required this.status,
    this.granted = false,
    this.failed = false,
    this.pending = false,
    this.onPressed,
    this.trailing,
  });

  final String title;
  final String desc;
  final String status;
  final bool granted;
  final bool failed;
  final bool pending;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tone = failed
        ? colorScheme.error
        : granted
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return ListItem(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc),
          Text(
            status,
            style: context.textTheme.bodySmall?.copyWith(
              color: tone,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onTap: pending ? null : onPressed,
      trailing: pending
          ? const SizedBox.square(
              dimension: 20,
              child: CommonCircleLoading(),
            )
          : trailing ??
                (onPressed == null
                    ? GlyphIcon(AppGlyphs.check, size: 20, color: tone)
                    : const GlyphIcon(AppGlyphs.chevronForward, size: 20)),
    );
  }
}
