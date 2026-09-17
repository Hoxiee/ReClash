import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:riverpod/riverpod.dart' show Provider, ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/config.g.dart';

@riverpod
class AppSetting extends _$AppSetting with AutoDisposeNotifierMixin {
  @override
  AppSettingProps build() {
    return const AppSettingProps();
  }
}

final appRegionProvider = Provider<AppRegion>((ref) {
  final region = ref.watch(appSettingProvider.select((state) => state.region));
  return region ??
      AppRegion.fromPreset(
        ref.watch(smartRoutingSettingProvider.select((state) => state.preset)),
      );
});

void selectAppRegion(ProviderReader read, AppRegion region) {
  final settings = read(appSettingProvider);
  if (settings.region == region) return;
  final previous = read(appRegionProvider);
  read(appSettingProvider.notifier).update(
    (state) => state.copyWith(
      region: region,
      sendDeviceIdentity:
          region == AppRegion.russia || state.sendDeviceIdentity,
    ),
  );
  if (previous != region) {
    read(
      smartRoutingSettingProvider.notifier,
    ).update((state) => state.applyPreset(region.preset));
  }
}

@Riverpod(keepAlive: true)
class WindowSetting extends _$WindowSetting with AutoDisposeNotifierMixin {
  @override
  WindowProps build() {
    return const WindowProps();
  }
}

@riverpod
class VpnSetting extends _$VpnSetting with AutoDisposeNotifierMixin {
  @override
  VpnProps build() {
    return const VpnProps();
  }
}

@riverpod
class SmartRoutingSetting extends _$SmartRoutingSetting
    with AutoDisposeNotifierMixin {
  @override
  SmartRoutingProps build() {
    return const SmartRoutingProps();
  }
}

@riverpod
class DesyncSetting extends _$DesyncSetting with AutoDisposeNotifierMixin {
  @override
  DesyncProps build() {
    return const DesyncProps();
  }
}

final byeDpiSupportedProvider = Provider<bool>((_) => system.isAndroid);

final effectiveDesyncSettingProvider = Provider<DesyncProps>((ref) {
  if (!ref.watch(byeDpiSupportedProvider)) return defaultDesyncProps;
  return ref.watch(desyncSettingProvider);
});

@riverpod
class NetworkSetting extends _$NetworkSetting with AutoDisposeNotifierMixin {
  @override
  NetworkProps build() {
    return const NetworkProps();
  }
}

@riverpod
class ThemeSetting extends _$ThemeSetting with AutoDisposeNotifierMixin {
  @override
  ThemeProps build() {
    return const ThemeProps();
  }
}

@riverpod
class CurrentProfileId extends _$CurrentProfileId
    with AutoDisposeNotifierMixin {
  @override
  int? build() {
    return null;
  }
}

@riverpod
class MilestoneSetting extends _$MilestoneSetting
    with AutoDisposeNotifierMixin {
  @override
  MilestoneProps build() => const MilestoneProps();
}

@riverpod
class DavSetting extends _$DavSetting with AutoDisposeNotifierMixin {
  @override
  DAVProps? build() {
    return null;
  }
}

@riverpod
class OverrideDns extends _$OverrideDns with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@riverpod
class HotKeyActions extends _$HotKeyActions with AutoDisposeNotifierMixin {
  @override
  List<HotKeyAction> build() {
    return [];
  }
}

@riverpod
class ProxiesStyleSetting extends _$ProxiesStyleSetting
    with AutoDisposeNotifierMixin {
  @override
  ProxiesStyleProps build() {
    return const ProxiesStyleProps();
  }
}

@Riverpod(name: 'patchClashConfigProvider')
class _PatchClashConfig extends _$PatchClashConfig
    with AutoDisposeNotifierMixin {
  @override
  PatchClashConfig build() {
    return const PatchClashConfig();
  }
}

/// The selector's own vocabulary: smart routing on top of Rule reads as Auto, so
/// the pair can never disagree with what the core was told.
@Riverpod(name: 'uiOutboundModeProvider')
UiOutboundMode _uiOutboundMode(Ref ref) {
  final mode = ref.watch(patchClashConfigProvider).mode;
  final smartRouting = ref.watch(smartRoutingSettingProvider).enabled;
  return mode.uiMode(smartRouting: smartRouting);
}

@Riverpod(name: 'configProvider')
Config _config(Ref ref) {
  final appSettingProps = ref.watch(appSettingProvider);
  final windowProps = ref.watch(windowSettingProvider);
  final vpnProps = ref.watch(vpnSettingProvider);
  final networkProps = ref.watch(networkSettingProvider);
  final smartRoutingProps = ref.watch(smartRoutingSettingProvider);
  final desyncProps = ref.watch(desyncSettingProvider);
  final themeProps = ref.watch(themeSettingProvider);
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final milestoneProps = ref.watch(milestoneSettingProvider);
  final davProps = ref.watch(davSettingProvider);
  final overrideDns = ref.watch(overrideDnsProvider);
  final hotKeyActions = ref.watch(hotKeyActionsProvider);
  final proxiesStyleProps = ref.watch(proxiesStyleSettingProvider);
  final patchClashConfig = ref.watch(patchClashConfigProvider);
  return Config(
    appSettingProps: appSettingProps,
    windowProps: windowProps,
    vpnProps: vpnProps,
    networkProps: networkProps,
    smartRoutingProps: smartRoutingProps,
    desyncProps: desyncProps,
    themeProps: themeProps,
    currentProfileId: currentProfileId,
    milestoneProps: milestoneProps,
    davProps: davProps,
    overrideDns: overrideDns,
    hotKeyActions: hotKeyActions,
    proxiesStyleProps: proxiesStyleProps,
    patchClashConfig: patchClashConfig,
  );
}

List<Override> buildConfigOverrides(Config config) {
  return [
    appSettingProvider.overrideWithBuild((_, _) => config.appSettingProps),
    windowSettingProvider.overrideWithBuild((_, _) => config.windowProps),
    vpnSettingProvider.overrideWithBuild((_, _) => config.vpnProps),
    networkSettingProvider.overrideWithBuild((_, _) => config.networkProps),
    smartRoutingSettingProvider.overrideWithBuild(
      (_, _) => config.smartRoutingProps,
    ),
    desyncSettingProvider.overrideWithBuild((_, _) => config.desyncProps),
    themeSettingProvider.overrideWithBuild((_, _) => config.themeProps),
    currentProfileIdProvider.overrideWithBuild(
      (_, _) => config.currentProfileId,
    ),
    milestoneSettingProvider.overrideWithBuild((_, _) => config.milestoneProps),
    davSettingProvider.overrideWithBuild((_, _) => config.davProps),
    overrideDnsProvider.overrideWithBuild((_, _) => config.overrideDns),
    hotKeyActionsProvider.overrideWithBuild((_, _) => config.hotKeyActions),
    proxiesStyleSettingProvider.overrideWithBuild(
      (_, _) => config.proxiesStyleProps,
    ),
    patchClashConfigProvider.overrideWithBuild(
      (_, _) => config.patchClashConfig,
    ),
  ];
}
