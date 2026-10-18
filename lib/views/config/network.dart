import 'package:reclash/models/tool_route.dart';
import 'package:reclash/widgets/settings/setting_spec.dart';
import 'package:reclash/widgets/settings/setting_target.dart';

import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/regional/regional_network.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/config/override.dart';
import 'package:reclash/views/config/tun.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show dirname, join;

typedef _VpnUpdate<T> = VpnProps Function(VpnProps state, T value);

typedef _NetworkUpdate<T> = NetworkProps Function(NetworkProps state, T value);

typedef _TunUpdate<T> =
    PatchClashConfig Function(PatchClashConfig state, T value);

ConfigWriter<T> _vpnWriter<T>(_VpnUpdate<T> update) {
  return (ref, value) => ref
      .read(vpnSettingProvider.notifier)
      .update((state) => update(state, value));
}

ConfigWriter<T> _networkWriter<T>(_NetworkUpdate<T> update) {
  return (ref, value) => ref
      .read(networkSettingProvider.notifier)
      .update((state) => update(state, value));
}

ConfigWriter<T> _tunWriter<T>(_TunUpdate<T> update) {
  return (ref, value) => ref
      .read(patchClashConfigProvider.notifier)
      .update((state) => update(state, value));
}

ConfigToggleItem _vpnToggle({
  required ConfigLabel title,
  required bool Function(VpnProps state) select,
  required _VpnUpdate<bool> update,
}) {
  return ConfigToggleItem(
    title: title,
    selector: vpnSettingProvider.select(select),
    onChanged: _vpnWriter(update),
  );
}

ConfigToggleItem _networkToggle({
  required ConfigLabel title,
  required bool Function(NetworkProps state) select,
  required _NetworkUpdate<bool> update,
}) {
  return ConfigToggleItem(
    title: title,
    selector: networkSettingProvider.select(select),
    onChanged: _networkWriter(update),
  );
}

class VPNItem extends ConsumerWidget {
  const VPNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[0],
      child: _vpnToggle(
        title: networkToolSettings[0].title,
        select: (state) => state.enable,
        update: (state, value) => state.copyWith(enable: value),
      ),
    );
  }
}

class TUNItem extends ConsumerWidget {
  const TUNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      setting: networkToolSettings[1],
      title: networkToolSettings[1].title,
      selector: patchClashConfigProvider.select((state) => state.tun.enable),
      onChanged: (ref, value) =>
          ref.read(setupActionProvider.notifier).setTunEnabled(value),
    );
  }
}

class AllowBypassItem extends ConsumerWidget {
  const AllowBypassItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[2],
      child: _vpnToggle(
        title: networkToolSettings[2].title,
        select: (state) => state.allowBypass,
        update: (state, value) => state.copyWith(allowBypass: value),
      ),
    );
  }
}

class VpnSystemProxyItem extends ConsumerWidget {
  const VpnSystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[3],
      child: _vpnToggle(
        title: networkToolSettings[3].title,
        select: (state) => state.systemProxy,
        update: (state, value) => state.copyWith(systemProxy: value),
      ),
    );
  }
}

class SystemProxyItem extends ConsumerWidget {
  const SystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[3],
      child: _networkToggle(
        title: networkToolSettings[3].title,
        select: (state) => state.systemProxy,
        update: (state, value) => state.copyWith(systemProxy: value),
      ),
    );
  }
}

class Ipv6Item extends ConsumerWidget {
  const Ipv6Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[4],
      child: _vpnToggle(
        title: networkToolSettings[4].title,
        select: (state) => state.ipv6,
        update: (state, value) => state.copyWith(ipv6: value),
      ),
    );
  }
}

class AutoSetSystemDnsItem extends ConsumerWidget {
  const AutoSetSystemDnsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[5],
      child: _networkToggle(
        title: networkToolSettings[5].title,
        select: (state) => state.autoSetSystemDns,
        update: (state, value) => state.copyWith(autoSetSystemDns: value),
      ),
    );
  }
}

class DNSHijackingItem extends ConsumerWidget {
  const DNSHijackingItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[6],
      child: _vpnToggle(
        title: networkToolSettings[6].title,
        select: (state) => state.dnsHijacking,
        update: (state, value) => state.copyWith(dnsHijacking: value),
      ),
    );
  }
}

class TunStackItem extends ConsumerWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<TunStack>(
      setting: networkToolSettings[7],
      title: networkToolSettings[7].title,
      options: TunStack.values,
      textBuilder: (stack) => stack.name,
      selector: patchClashConfigProvider.select((state) => state.tun.stack),
      onChanged: _tunWriter((state, value) => state.copyWith.tun(stack: value)),
    );
  }
}

class InterfaceNameModeItem extends ConsumerWidget {
  const InterfaceNameModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    return ConfigOptionsItem<InterfaceNameMode>(
      setting: networkToolSettings[8],
      title: networkToolSettings[8].title,
      options: InterfaceNameMode.values,
      textBuilder: (mode) => switch (mode) {
        InterfaceNameMode.clear => appLocalizations.interfaceNameModeClear,
        InterfaceNameMode.follow => appLocalizations.interfaceNameModeFollow,
        InterfaceNameMode.custom => appLocalizations.interfaceNameModeCustom,
      },
      selector: patchClashConfigProvider.select(
        (state) => state.interfaceNameMode,
      ),
      onChanged: _tunWriter(
        (state, value) => state.copyWith(interfaceNameMode: value),
      ),
    );
  }
}

class InterfaceNameItem extends ConsumerWidget {
  const InterfaceNameItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      setting: networkToolSettings[9],
      title: networkToolSettings[9].title,
      maxLength: TextInputLimits.name,
      selector: patchClashConfigProvider.select((state) => state.interfaceName),
      onChanged: _tunWriter(
        (state, value) => state.copyWith(interfaceName: value.trim()),
      ),
    );
  }
}

class BypassPrivateRouteItem extends ConsumerWidget {
  const BypassPrivateRouteItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SettingTarget(
      spec: networkToolSettings[10],
      child: _networkToggle(
        title: networkToolSettings[10].title,
        select: (state) => state.bypassPrivateRoute,
        update: (state, value) => state.copyWith(bypassPrivateRoute: value),
      ),
    );
  }
}

class BypassDomainItem extends ConsumerWidget {
  const BypassDomainItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigListEditItem(
      setting: networkToolSettings[11],
      title: networkToolSettings[11].title,
      itemMaxLength: TextInputLimits.domain,
      selector: networkSettingProvider.select((state) => state.bypassDomain),
      onChanged: _networkWriter(
        (state, value) => state.copyWith(bypassDomain: value),
      ),
    );
  }
}

class RouteAddressItem extends ConsumerWidget {
  const RouteAddressItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigListEditItem(
      setting: networkToolSettings[12],
      title: networkToolSettings[12].title,
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateCidr,
      selector: patchClashConfigProvider.select(
        (state) => state.tun.routeAddress,
      ),
      onChanged: _tunWriter(
        (state, value) => state.copyWith.tun(routeAddress: value),
      ),
    );
  }
}

class LoopbackItem extends StatelessWidget {
  const LoopbackItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: Text(context.appLocalizations.loopback),
      onTap: () {
        windows?.runas(
          '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
          '',
        );
      },
    );
  }
}

class _MtuItem extends ConsumerWidget {
  const _MtuItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final value = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.mtu),
    );
    final regionMtu = regionTunMtu(
      ref.watch(appSettingProvider.select((state) => state.regionCode)),
    );
    return ListItem.input(
      title: Text(networkToolSettings[13].title(l)),
      subtitle: Text('$value'),
      dialogTitle: networkToolSettings[13].title(l),
      value: '$value',
      resetValue: '$regionMtu',
      maxLength: TextInputLimits.number,
      keyboardType: TextInputType.number,
      validator: (value) {
        final mtu = int.tryParse(value?.trim() ?? '');
        if (mtu == null) return l.numberTip('MTU');
        return mtu < minTunMtu || mtu > maxTunMtu
            ? l.numberRangeTip('MTU', '$minTunMtu', '$maxTunMtu')
            : null;
      },
      onChanged: (value) {
        if (value == null) return;
        final mtu = int.parse(value.trim());
        ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                tun: state.tun.copyWith(mtu: mtu),
                tunOverride: state.tunOverride.copyWith(mtu: mtu),
                tunOverrideKeys: {...state.tunOverrideKeys, TunOverrideKey.mtu},
              ),
            );
      },
    );
  }
}

const _maxUint32 = 0xFFFFFFFF;

class _NumberItem extends ConsumerWidget {
  const _NumberItem({
    required this.title,
    required this.select,
    required this.update,
    this.isSeconds = false,
  });

  final ConfigLabel title;
  final int Function(PatchClashConfig state) select;
  final _TunUpdate<int> update;
  final bool isSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final label = title(appLocalizations);
    final value = ref.watch(patchClashConfigProvider.select(select));
    return ListItem.input(
      title: Text(label),
      subtitle: Text(
        isSeconds ? appLocalizations.secondsCount(value) : '$value',
      ),
      dialogTitle: label,
      value: '$value',
      resetValue: '${select(defaultClashConfig)}',
      suffixText: isSeconds ? appLocalizations.seconds : null,
      maxLength: TextInputLimits.number,
      keyboardType: TextInputType.number,
      validator: (value) {
        final number = int.tryParse(value?.trim() ?? '');
        if (number == null) {
          return appLocalizations.numberTip(label);
        }
        return number < 0 || number > _maxUint32
            ? appLocalizations.numberRangeTip(label, '0', '$_maxUint32')
            : null;
      },
      onChanged: (value) {
        if (value == null) {
          return;
        }
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => update(state, int.parse(value.trim())));
      },
    );
  }
}

// Android's VPN service starts from these rows; the desktop TUN takes the
// same keys as overrides, so a profile's own values apply unless picked.
List<Widget> tunItems({required bool isMipsStack}) {
  return [
    SettingTarget(spec: networkToolSettings[13], child: const _MtuItem()),
    if (isMipsStack)
      ConfigOptionsItem<String>(
        setting: networkToolSettings[14],
        title: networkToolSettings[14].title,
        options: congestionControllers,
        textBuilder: (value) => value,
        selector: patchClashConfigProvider.select(
          (state) => state.tun.congestionController,
        ),
        onChanged: _tunWriter(
          (state, value) => state.copyWith.tun(congestionController: value),
        ),
      ),
    const BypassPrivateRouteItem(),
    const RouteAddressItem(),
    ConfigListEditItem(
      setting: networkToolSettings[15],
      title: networkToolSettings[15].title,
      itemMaxLength: TextInputLimits.cidr,
      itemValidator: validateCidr,
      selector: patchClashConfigProvider.select(
        (state) => state.tun.routeExcludeAddress,
      ),
      onChanged: _tunWriter(
        (state, value) => state.copyWith.tun(routeExcludeAddress: value),
      ),
    ),
  ];
}

class TunSection extends ConsumerWidget {
  const TunSection({
    super.key,
    required this.isDesktop,
    required this.isLinux,
    required this.isWindows,
  });

  final bool isDesktop;
  final bool isLinux;
  final bool isWindows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    if (!isDesktop) {
      final isMipsStack = ref.watch(
        patchClashConfigProvider.select(
          (state) => state.tun.stack == TunStack.mips,
        ),
      );
      return generateSection(
        title: appLocalizations.tun,
        items: tunItems(isMipsStack: isMipsStack),
        footer: appLocalizations.bypassPrivateRouteDesc,
      );
    }
    return OverrideSection(
      title: appLocalizations.tun,
      spec: appTunOverrideSpec(isLinux: isLinux, isWindows: isWindows),
      items: const [BypassPrivateRouteItem(key: ValueKey(#bypassPrivateRoute))],
      footer: [appLocalizations.bypassPrivateRouteDesc],
    );
  }
}

// mihomo keeps TCP keep-alive off on Android whatever the config says
// (component/keepalive), and only Linux honours a routing mark.
List<Widget> outboundItems({required bool isDesktop, required bool isLinux}) {
  return [
    if (isDesktop) ...[
      ConfigToggleItem(
        setting: networkToolSettings[16],
        title: networkToolSettings[16].title,
        selector: patchClashConfigProvider.select(
          (state) => state.disableKeepAlive,
        ),
        onChanged: _tunWriter(
          (state, value) => state.copyWith(disableKeepAlive: value),
        ),
      ),
      SettingTarget(
        spec: networkToolSettings[17],
        child: _NumberItem(
          title: networkToolSettings[17].title,
          isSeconds: true,
          select: (state) => state.keepAliveIdle,
          update: (state, value) => state.copyWith(keepAliveIdle: value),
        ),
      ),
      SettingTarget(
        spec: networkToolSettings[18],
        child: _NumberItem(
          title: networkToolSettings[18].title,
          isSeconds: true,
          select: (state) => state.keepAliveInterval,
          update: (state, value) => state.copyWith(keepAliveInterval: value),
        ),
      ),
    ],
    if (isLinux)
      SettingTarget(
        spec: networkToolSettings[19],
        child: _NumberItem(
          title: networkToolSettings[19].title,
          select: (state) => state.routingMark,
          update: (state, value) => state.copyWith(routingMark: value),
        ),
      ),
  ];
}

List<Widget> networkOptionsItems({
  required bool isDesktop,
  required bool isMacOS,
  required bool isCustomInterfaceName,
}) {
  return [
    if (isDesktop) const TUNItem(),
    if (isMacOS) const AutoSetSystemDnsItem(),
    const TunStackItem(),
    // mihomo's DefaultSocketHook ignores interface-name on Android
    // (core/lib.go installHooks, vendored dialer.go), so these rows only
    // apply on desktop.
    if (isDesktop) ...[
      const InterfaceNameModeItem(),
      if (isCustomInterfaceName) const InterfaceNameItem(),
    ],
  ];
}

class VpnSections extends ConsumerWidget {
  const VpnSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final authenticationEnable = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    return Column(
      children: [
        generateSection(
          items: const [VPNItem()],
          footer: appLocalizations.vpnEnableDesc,
        ),
        generateSection(
          title: 'VPN',
          items: const [
            VpnSystemProxyItem(),
            BypassDomainItem(),
            AllowBypassItem(),
            Ipv6Item(),
            DNSHijackingItem(),
          ],
          footer: [
            if (authenticationEnable)
              appLocalizations.authenticationSystemProxyDesc,
            appLocalizations.bypassDomainDesc,
            appLocalizations.ipv6InboundDesc,
          ].join('\n'),
        ),
      ],
    );
  }
}

class SystemProxySection extends ConsumerWidget {
  const SystemProxySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.system,
      items: [
        const SystemProxyItem(),
        const BypassDomainItem(),
        if (system.isWindows) const LoopbackItem(),
      ],
      footer: appLocalizations.bypassDomainDesc,
    );
  }
}

class NetworkOptionsSection extends ConsumerWidget {
  const NetworkOptionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCustomInterfaceName = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.interfaceNameMode == InterfaceNameMode.custom,
      ),
    );
    final appLocalizations = context.appLocalizations;
    final footer = [
      if (system.isDesktop) ...[
        appLocalizations.tunDesc,
        if (isCustomInterfaceName) appLocalizations.interfaceNameDesc,
      ],
    ];
    return generateSection(
      title: appLocalizations.options,
      items: networkOptionsItems(
        isDesktop: system.isDesktop,
        isMacOS: system.isMacOS,
        isCustomInterfaceName: isCustomInterfaceName,
      ),
      footer: footer.isEmpty ? null : footer.join('\n'),
    );
  }
}

class NetworkView extends ConsumerWidget {
  const NetworkView({super.key});

  Future<void> _restoreDefaults(BuildContext context, WidgetRef ref) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      title: l.restoreDefaults,
      message: TextSpan(text: l.networkRestoreDefaultsTip),
      confirmText: l.restore,
    );
    if (confirmed != true || !context.mounted) return;
    final defaults = regionNetworkDefaults(
      ref.read(appSettingProvider).regionCode,
      ref.read(patchClashConfigProvider),
    );
    ref.read(patchClashConfigProvider.notifier).value = defaults.patchConfig;
    ref
        .read(networkSettingProvider.notifier)
        .update((state) => state.copyWith(bypassDomain: defaults.bypassDomain));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final regionCode = ref.watch(
      appSettingProvider.select((state) => state.regionCode),
    );
    final patchConfig = ref.watch(patchClashConfigProvider);
    final bypassDomain = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );
    final defaults = regionNetworkDefaults(regionCode, patchConfig);
    final isDefault =
        defaults.patchConfig == patchConfig &&
        listEquals(defaults.bypassDomain, bypassDomain);
    return CommonScaffold(
      title: l.network,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.reset,
          tooltip: l.restoreDefaults,
          onPressed: isDefault
              ? null
              : () => unawaited(_restoreDefaults(context, ref)),
        ),
      ],
      body: const NetworkListView(),
    );
  }
}

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.sectionsTopPadding,
            bottom: 16 + context.bottomInset,
          ) +
          context.bodyInsets,
      children: [
        if (system.isAndroid) const VpnSections(),
        if (system.isDesktop) const SystemProxySection(),
        const NetworkOptionsSection(),
        TunSection(
          isDesktop: system.isDesktop,
          isLinux: system.isLinux,
          isWindows: system.isWindows,
        ),
        generateSection(
          title: context.appLocalizations.outbound,
          items: outboundItems(
            isDesktop: system.isDesktop,
            isLinux: system.isLinux,
          ),
        ),
      ],
    );
  }
}

final networkToolSettings = <SettingSpec>[
  SettingSpec(
    id: 'network.VPN',
    page: ToolPage.network,
    title: (l) => 'VPN',
    keywords: ['VPN'],
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'network.tun',
    page: ToolPage.network,
    title: (l) => l.tun,
    keywords: ['tun'],
    condition: SettingCondition.desktop,
  ),
  SettingSpec(
    id: 'network.allowBypass',
    page: ToolPage.network,
    title: (l) => l.allowBypass,
    keywords: ['allowBypass'],
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'network.systemProxy',
    page: ToolPage.network,
    title: (l) => l.systemProxy,
    keywords: ['systemProxy'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.IPv6',
    page: ToolPage.network,
    title: (l) => 'IPv6',
    keywords: ['IPv6'],
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'network.autoSetSystemDns',
    page: ToolPage.network,
    title: (l) => l.autoSetSystemDns,
    keywords: ['autoSetSystemDns'],
    condition: SettingCondition.macos,
  ),
  SettingSpec(
    id: 'network.dnsHijacking',
    page: ToolPage.network,
    title: (l) => l.dnsHijacking,
    keywords: ['dnsHijacking'],
    condition: SettingCondition.android,
  ),
  SettingSpec(
    id: 'network.stackMode',
    page: ToolPage.network,
    title: (l) => l.stackMode,
    keywords: ['stackMode'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.interfaceNameMode',
    page: ToolPage.network,
    title: (l) => l.interfaceNameMode,
    keywords: ['interfaceNameMode'],
    condition: SettingCondition.desktop,
  ),
  SettingSpec(
    id: 'network.interfaceName',
    page: ToolPage.network,
    title: (l) => l.interfaceName,
    keywords: ['interfaceName'],
    condition: SettingCondition.customInterface,
  ),
  SettingSpec(
    id: 'network.bypassPrivateRoute',
    page: ToolPage.network,
    title: (l) => l.bypassPrivateRoute,
    keywords: ['bypassPrivateRoute'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.bypassDomain',
    page: ToolPage.network,
    title: (l) => l.bypassDomain,
    keywords: ['bypassDomain'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.routeAddress',
    page: ToolPage.network,
    title: (l) => l.routeAddress,
    keywords: ['routeAddress'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.MTU',
    page: ToolPage.network,
    title: (l) => 'MTU',
    keywords: ['MTU'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.congestionController',
    page: ToolPage.network,
    title: (l) => l.congestionController,
    keywords: ['congestionController'],
    condition: SettingCondition.mipsStack,
  ),
  SettingSpec(
    id: 'network.routeExcludeAddress',
    page: ToolPage.network,
    title: (l) => l.routeExcludeAddress,
    keywords: ['routeExcludeAddress'],
    condition: SettingCondition.always,
  ),
  SettingSpec(
    id: 'network.disableKeepAlive',
    page: ToolPage.network,
    title: (l) => l.disableKeepAlive,
    keywords: ['disableKeepAlive'],
    condition: SettingCondition.desktop,
  ),
  SettingSpec(
    id: 'network.keepAliveIdle',
    page: ToolPage.network,
    title: (l) => l.keepAliveIdle,
    keywords: ['keepAliveIdle'],
    condition: SettingCondition.desktop,
  ),
  SettingSpec(
    id: 'network.keepAliveIntervalDesc',
    page: ToolPage.network,
    title: (l) => l.keepAliveIntervalDesc,
    keywords: ['keepAliveIntervalDesc'],
    condition: SettingCondition.desktop,
  ),
  SettingSpec(
    id: 'network.routingMark',
    page: ToolPage.network,
    title: (l) => l.routingMark,
    keywords: ['routingMark'],
    condition: SettingCondition.linux,
  ),
];
