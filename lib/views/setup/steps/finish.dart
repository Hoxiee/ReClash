import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/permission.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

abstract interface class SetupPermissionGateway {
  bool get isAndroid;

  Future<bool> isNotificationsPermissionGranted();

  Future<void> requestNotificationsPermission();

  Future<void> openAppSettings();

  Future<bool> isBatteryOptimizationDisabled();

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
  Future<bool> isBatteryOptimizationDisabled() async =>
      await app?.isBatteryOptimizationDisabled() ?? false;

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
    this.permissionGateway = const SystemSetupPermissionGateway(),
  });

  final VoidCallback onDone;
  final VoidCallback onBack;
  final SetupPermissionGateway permissionGateway;

  @override
  ConsumerState<SetupFinishStep> createState() => _SetupFinishStepState();
}

class _SetupFinishStepState extends ConsumerState<SetupFinishStep> {
  _PermissionState _notifications = _PermissionState.checking;
  bool _notificationRequested = false;
  bool _batteryPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(profilesProvider).isEmpty &&
          ref.read(appSettingProvider).autoRun) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoRun: false));
      }
      unawaited(_checkNotifications());
    });
  }

  void _selectPreset(SmartRoutingPreset value) {
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update(
          (state) => state
              .applyPreset(value)
              .copyWith(enabled: value != SmartRoutingPreset.off),
        );
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
      final granted = await widget.permissionGateway
          .isBatteryOptimizationDisabled();
      if (!mounted) return;
      ref.read(batteryOptimizationDisableProvider.notifier).value = granted;
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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final preset = ref.watch(
      smartRoutingSettingProvider.select((state) => state.preset),
    );
    final appSetting = ref.watch(appSettingProvider);
    final profiles = ref.watch(profilesProvider);
    final profile = ref.watch(currentProfileProvider) ?? profiles.firstOrNull;
    final hasProfile = profile != null;
    final autoRun = hasProfile && appSetting.autoRun;
    final recommendation = smartRoutingPresetForLocale(appSetting.locale);
    final battery = ref.watch(batteryOptimizationDisableProvider);
    return SetupStepScaffold(
      title: appLocalizations.setupFinishTitle,
      subtitle: appLocalizations.setupRegionDesc,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appLocalizations.setupRegionTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SetupCard(
            child: RadioGroup<SmartRoutingPreset>(
              groupValue: preset,
              onChanged: (value) {
                if (value != null) _selectPreset(value);
              },
              child: Column(
                children: [
                  for (final value in SmartRoutingPreset.values)
                    ListItem<SmartRoutingPreset>.radio(
                      title: Text(
                        value == SmartRoutingPreset.off
                            ? appLocalizations.setupRegionNone
                            : value.label,
                      ),
                      subtitle: value == recommendation
                          ? Text(appLocalizations.setupRegionRecommended)
                          : null,
                      value: value,
                      onTap: () => _selectPreset(value),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SetupCard(
            child: ListItem.toggle(
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
          ),
          if (widget.permissionGateway.isAndroid) ...[
            const SizedBox(height: 12),
            SetupCard(
              child: Column(
                children: [
                  _PermissionRow(
                    title: appLocalizations.setupPermissionVpn,
                    desc: appLocalizations.setupPermissionVpnDesc,
                    status: appLocalizations.setupPermissionDeferred,
                    trailing: const Icon(Icons.schedule_rounded, size: 20),
                  ),
                  _PermissionRow(
                    title: appLocalizations.setupPermissionNotifications,
                    desc: appLocalizations.setupPermissionNotificationsDesc,
                    status: _permissionLabel(appLocalizations, _notifications),
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
                    pending: _batteryPending,
                    onPressed: battery ? null : _handleBattery,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SetupCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appLocalizations.setupSummaryTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      preset == SmartRoutingPreset.off
                          ? appLocalizations.setupRegionNone
                          : preset.label,
                    ),
                  ),
                  Text(
                    autoRun
                        ? appLocalizations.setupSummaryAutoRunOn
                        : appLocalizations.setupSummaryAutoRunOff,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        SetupPrimaryButton(
          label: autoRun
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
    this.pending = false,
    this.onPressed,
    this.trailing,
  });

  final String title;
  final String desc;
  final String status;
  final bool pending;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListItem(
    title: Text(title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(desc), Text(status)],
    ),
    onTap: pending ? null : onPressed,
    trailing: pending
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : trailing ??
              (onPressed == null
                  ? const Icon(Icons.check_rounded, size: 20)
                  : const Icon(Icons.chevron_right_rounded, size: 20)),
  );
}
