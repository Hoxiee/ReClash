import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/dns.dart';
import 'package:reclash/views/config/network.dart';
import 'package:reclash/views/dashboard/widget_metrics.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _QuickSwitchCard extends StatelessWidget {
  const _QuickSwitchCard({
    required this.label,
    required this.glyph,
    required this.items,
    required this.selector,
    required this.onChanged,
  });

  final String label;
  final Glyph glyph;
  final List<Widget> items;
  final ProviderListenable<bool> selector;
  final void Function(WidgetRef ref, bool value) onChanged;

  static const _switchHeight = kMinInteractiveDimension - 8;

  @override
  Widget build(BuildContext context) {
    final inset = DashboardWidgetMetrics.insetOf(context);
    final lineHeight =
        globalState.measure.bodyMediumHeight *
            DashboardWidgetMetrics.textScaleOf(context) +
        2;
    final overhang = max(0.0, (_switchHeight - lineHeight) / 2);
    return SizedBox(
      height: DashboardWidgetMetrics.heightOf(context, 1),
      child: CommonCard(
        radius: DashboardWidgetMetrics.radiusOf(context),
        infoPadding: DashboardWidgetMetrics.paddingOf(
          context,
        ).copyWith(bottom: 0),
        onPressed: () {
          showSheet(
            context: context,
            builder: (_) {
              return AdaptiveSheetScaffold(
                body: generateListView(generateSection(items: items)),
                title: label,
              );
            },
          );
        },
        info: Info(label: label, glyph: glyph),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            inset,
            0,
            inset,
            DashboardWidgetMetrics.verticalInsetOf(context) - overhang,
          ),
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            maxHeight: double.infinity,
            child: Consumer(
              builder: (_, ref, _) {
                final value = ref.watch(selector);
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TooltipText(
                        text: Text(
                          value
                              ? context.appLocalizations.enabled
                              : context.appLocalizations.disabled,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.adjustSize(-2).toLight,
                        ),
                      ),
                    ),
                    Switch(
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: value,
                      onChanged: (value) => onChanged(ref, value),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TUNButton extends StatelessWidget {
  const TUNButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.tun,
      glyph: AppGlyphs.chart,
      items: [
        if (system.isDesktop) const TUNItem(),
        if (system.isMacOS) const AutoSetSystemDnsItem(),
        const TunStackItem(),
      ],
      selector: patchClashConfigProvider.select((state) => state.tun.enable),
      onChanged: (ref, value) {
        ref.read(systemActionProvider.notifier).setTunEnabled(value);
      },
    );
  }
}

class SystemProxyButton extends StatelessWidget {
  const SystemProxyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.systemProxy,
      glyph: AppGlyphs.shuffle,
      items: const [SystemProxyItem(), BypassDomainItem()],
      selector: networkSettingProvider.select((state) => state.systemProxy),
      onChanged: (ref, value) {
        ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: value));
      },
    );
  }
}

class VpnButton extends StatelessWidget {
  const VpnButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: 'VPN',
      glyph: AppGlyphs.chart,
      items: const [VPNItem(), VpnSystemProxyItem(), TunStackItem()],
      selector: vpnSettingProvider.select((state) => state.enable),
      onChanged: (ref, value) {
        ref
            .read(vpnSettingProvider.notifier)
            .update((state) => state.copyWith(enable: value));
      },
    );
  }
}

class OverrideDnsButton extends StatelessWidget {
  const OverrideDnsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return _QuickSwitchCard(
      label: context.appLocalizations.overrideDns,
      glyph: AppGlyphs.dns,
      items: dnsItems,
      selector: overrideDnsProvider,
      onChanged: (ref, value) {
        ref.read(overrideDnsProvider.notifier).value = value;
      },
    );
  }
}
