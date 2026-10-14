import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';

/// What the user let into ReClash, phrased as the one thing they decide instead
/// of the mechanisms that implement it. Desktop picks between whole-device
/// capture and the system proxy; Android only chooses how many apps ride the
/// VPN.
enum SetupCoverage { device, systemProxy, localProxy, selectedApps }

/// The options the running platform can actually offer, in presentation order.
List<SetupCoverage> setupCoverageOptions() => system.isAndroid
    ? const [SetupCoverage.device, SetupCoverage.selectedApps]
    : const [
        SetupCoverage.device,
        SetupCoverage.systemProxy,
        SetupCoverage.localProxy,
      ];

/// Reads the choice back out of the settings that own it, so the wizard never
/// becomes a second source of truth for coverage.
SetupCoverage setupCoverageOf(WidgetRef ref) {
  if (system.isAndroid) {
    final enabled = ref.watch(
      vpnSettingProvider.select((state) => state.accessControlProps.enable),
    );
    return enabled ? SetupCoverage.selectedApps : SetupCoverage.device;
  }
  final tun = ref.watch(
    patchClashConfigProvider.select((state) => state.tun.enable),
  );
  if (tun) return SetupCoverage.device;
  final systemProxy = ref.watch(
    networkSettingProvider.select((state) => state.systemProxy),
  );
  return systemProxy ? SetupCoverage.systemProxy : SetupCoverage.localProxy;
}

void applySetupCoverage(WidgetRef ref, SetupCoverage coverage) {
  if (system.isAndroid) {
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith.accessControlProps(
            enable: coverage == SetupCoverage.selectedApps,
          ),
        );
    return;
  }
  ref
      .read(patchClashConfigProvider.notifier)
      .update(
        (state) =>
            state.copyWith.tun(enable: coverage == SetupCoverage.device),
      );
  ref
      .read(networkSettingProvider.notifier)
      .update(
        (state) =>
            state.copyWith(systemProxy: coverage == SetupCoverage.systemProxy),
      );
}

String setupCoverageLabel(BuildContext context, SetupCoverage coverage) {
  final l = context.appLocalizations;
  return switch (coverage) {
    SetupCoverage.device =>
      system.isAndroid ? l.setupCoverageDevice : l.setupCoverageAll,
    SetupCoverage.systemProxy => l.setupCoverageProxy,
    SetupCoverage.localProxy => l.setupCoverageLocal,
    SetupCoverage.selectedApps => l.setupCoverageSelected,
  };
}

String setupCoverageDescription(BuildContext context, SetupCoverage coverage) {
  final l = context.appLocalizations;
  return switch (coverage) {
    SetupCoverage.device =>
      system.isAndroid ? l.setupCoverageDeviceDesc : l.setupCoverageAllDesc,
    SetupCoverage.systemProxy => l.setupProxyScope,
    SetupCoverage.localProxy => l.setupCoverageLocalDesc,
    SetupCoverage.selectedApps => l.setupCoverageSelectedDesc,
  };
}
