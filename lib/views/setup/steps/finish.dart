import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/permission.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets.dart';

class SetupFinishStep extends ConsumerWidget {
  const SetupFinishStep({super.key, required this.onDone});

  final VoidCallback onDone;

  void _selectPreset(WidgetRef ref, SmartRoutingPreset value) {
    ref
        .read(smartRoutingSettingProvider.notifier)
        .update(
          (state) => state
              .applyPreset(value)
              .copyWith(enabled: value != SmartRoutingPreset.off),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final preset = ref.watch(
      smartRoutingSettingProvider.select((state) => state.preset),
    );
    final autoRun = ref.watch(
      appSettingProvider.select((state) => state.autoRun),
    );
    return SetupStepScaffold(
      title: appLocalizations.setupFinishTitle,
      subtitle: appLocalizations.setupRegionDesc,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SetupCard(
            child: RadioGroup<SmartRoutingPreset>(
              groupValue: preset,
              onChanged: (value) {
                if (value != null) {
                  _selectPreset(ref, value);
                }
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
                      value: value,
                      onTap: () => _selectPreset(ref, value),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SetupCard(
            child: ListItem.toggle(
              title: Text(appLocalizations.setupAutoRun),
              subtitle: Text(appLocalizations.setupAutoRunDesc),
              value: autoRun,
              onChanged: (value) => ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(autoRun: value)),
            ),
          ),
          const SizedBox(height: 12),
          const _Permissions(),
        ],
      ),
      actions: [
        SetupPrimaryButton(
          label: appLocalizations.setupDone,
          onPressed: onDone,
        ),
      ],
    );
  }
}

/// Only the two Android prompts the app can raise on its own. VPN permission and
/// desktop TUN authorization are raised by the first start itself, so asking here
/// would mean two system dialogs for one grant.
class _Permissions extends ConsumerWidget {
  const _Permissions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!system.isAndroid) {
      return const SizedBox.shrink();
    }
    final appLocalizations = context.appLocalizations;
    final battery = ref.watch(batteryOptimizationDisableProvider);
    return SetupCard(
      child: Column(
        children: [
          _PermissionRow(
            title: appLocalizations.setupPermissionVpn,
            desc: appLocalizations.setupPermissionVpnDesc,
          ),
          _PermissionRow(
            title: appLocalizations.setupPermissionNotifications,
            desc: appLocalizations.setupPermissionNotificationsDesc,
            onPressed: () => unawaited(
              app?.requestNotificationsPermission() ?? Future.value(),
            ),
          ),
          if (!battery)
            _PermissionRow(
              title: appLocalizations.ignoreBatteryOptimization,
              desc: appLocalizations.batteryOptimizationDesc,
              onPressed: () {
                permissions.needWaitingBatteryOptimizationSettings = true;
                unawaited(
                  app?.openBatteryOptimizationSettings() ?? Future.value(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.desc,
    this.onPressed,
  });

  final String title;
  final String desc;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ListItem(
    title: Text(title),
    subtitle: Text(desc),
    onTap: onPressed,
    trailing: onPressed == null
        ? null
        : const Icon(Icons.chevron_right_rounded, size: 20),
  );
}
