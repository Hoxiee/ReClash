import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/ip_quality.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/probe_start_hold.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';

/// Enough of the address to recognize it without handing it to a screenshot.
String _maskedIp(String ip) {
  final octets = ip.split('.');
  if (octets.length == 4) return '${octets[0]}.${octets[1]}.•••.${octets[3]}';
  final groups = ip.split(':');
  return groups.length > 2 ? '${groups.first}:${groups[1]}:•••' : ip;
}

/// The IP check put as the question it answers: will sites treat this
/// address as a person or as a VPN.
class SimpleAddressCard extends ConsumerStatefulWidget {
  const SimpleAddressCard({super.key});

  @override
  ConsumerState<SimpleAddressCard> createState() => _SimpleAddressCardState();
}

class _SimpleAddressCardState extends ConsumerState<SimpleAddressCard>
    with ProbeStartHold<SimpleAddressCard> {
  late final OutboundIpProbe _probe;

  @override
  void initState() {
    super.initState();
    _probe = ref.read(outboundIpProbeProvider.notifier)..watch(routedOutbound);
  }

  @override
  void dispose() {
    _probe.unwatch(routedOutbound);
    super.dispose();
  }

  void _refresh(String? ip) {
    _probe.refresh(const [routedOutbound]);
    if (ip != null && ref.read(ipQualityProvider(ip)).hasError) {
      ref.invalidate(ipQualityProvider(ip));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colors = DashboardColors.of(context);
    final live = ref.watch(isStartProvider) && !ref.watch(suspendProvider);
    final hideIp = ref.watch(
      appSettingProvider.select((state) => state.hideIp),
    );
    final entry = ref.watch(
      outboundIpProbeProvider.select((state) => state.entryOf(routedOutbound)),
    );
    final ip = entry.value?.ip;
    final failed = shownPhase(entry) == ProbePhase.failed && ip == null;
    final qualityState = live && ip != null
        ? ref.watch(ipQualityProvider(ip))
        : null;
    final quality = qualityState?.value;
    final (title, description, warn) = !live
        ? (
            appLocalizations.simpleIpReal,
            appLocalizations.simpleIpRealDesc,
            true,
          )
        : quality != null
        ? (
            switch (quality.type) {
              IpType.residential => appLocalizations.simpleIpResidential,
              IpType.mobile => appLocalizations.simpleIpMobile,
              IpType.business => appLocalizations.simpleIpBusiness,
              IpType.hosting => appLocalizations.simpleIpHosting,
            },
            switch (quality.level) {
              IpQualityLevel.good => appLocalizations.simpleIpGoodDesc,
              IpQualityLevel.normal => appLocalizations.simpleIpNormalDesc,
              IpQualityLevel.risky => appLocalizations.simpleIpRiskyDesc,
            },
            false,
          )
        : failed || (qualityState?.hasError ?? false)
        ? (appLocalizations.simpleIpUnknown, null, false)
        : (appLocalizations.loading, null, false);
    return DashboardCard(
      semanticLabel: appLocalizations.simpleIpTitle,
      onTap: live ? () => _refresh(ip) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.eye,
            title: appLocalizations.simpleIpTitle,
            trailing: [
              if (live && ip != null && !hideIp)
                Text(_maskedIp(ip), style: DashboardText.label(context)),
            ],
          ),
          Text(
            title,
            style: AppTextStyle.title3
                .of(context, emphasized: true)
                .copyWith(color: warn ? colors.warn : null),
          ),
          if (description != null)
            Text(
              description,
              style: DashboardText.label(context).copyWith(height: 1.3),
            ),
          if (quality != null) _LevelMeter(level: quality.level),
        ],
      ),
    );
  }
}

class _LevelMeter extends StatelessWidget {
  const _LevelMeter({required this.level});

  final IpQualityLevel level;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final colors = DashboardColors.of(context);
    final steps = [
      (
        IpQualityLevel.risky,
        appLocalizations.simpleIpLevelRisky,
        colorScheme.error,
      ),
      (
        IpQualityLevel.normal,
        appLocalizations.simpleIpLevelNormal,
        colors.warn,
      ),
      (IpQualityLevel.good, appLocalizations.simpleIpLevelClean, colors.ok),
    ];
    final caption = AppTextStyle.caption2.of(context);
    return Row(
      spacing: 4,
      children: [
        for (final (step, label, color) in steps)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: step == level ? color : colors.tone,
                    shape: AppShape.full,
                  ),
                  child: const SizedBox(height: 6, width: double.infinity),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: caption.copyWith(
                    color: step == level
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
