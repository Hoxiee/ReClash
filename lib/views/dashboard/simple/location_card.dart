import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/chains/editor.dart';
import 'package:reclash/views/chains/issues.dart';
import 'package:reclash/views/chains/marks.dart';
import 'package:reclash/views/chains/state.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/views/dashboard/widgets/proxy_groups.dart';
import 'package:reclash/views/proxies/routing_country.dart';

/// Where traffic leaves, with the next best exits one tap away, so changing
/// country never needs the proxies page.
class LocationCard extends ConsumerStatefulWidget {
  const LocationCard({super.key});

  @override
  ConsumerState<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends ConsumerState<LocationCard> {
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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final serverGroup = ref.watch(
      providerHintsProvider.select((hints) => hints?.serverGroup),
    );
    final group = ref.watch(
      visibleGroupsStateProvider.select(
        (state) => pickMainGroup(state.value, serverGroup),
      ),
    );
    final isStart = ref.watch(isStartProvider);
    final live = isStart && !ref.watch(suspendProvider);
    final selected = group == null
        ? null
        : ref.watch(selectedProxyNameProvider(group.name));
    final exit = live
        ? ref.watch(
            outboundIpProbeProvider.select(
              (state) => state.entryOf(routedOutbound).value,
            ),
          )
        : null;
    if (group == null || selected == null || selected.isEmpty) {
      return DashboardCard(
        padding: const EdgeInsets.all(16),
        child: _Headline(
          flag: const ShapeFlag(code: null, size: _flagSize),
          title: appLocalizations.simpleLocationNone,
          subtitle: appLocalizations.simpleLocationNoneHint,
        ),
      );
    }
    if (ref.watch(chainOfGroupProvider(selected)) case final entry?) {
      return _ChainCard(
        entry: entry,
        group: group,
        live: live,
        exit: exit,
        onTap: () => showProxiesSheet(context, groupName: group.name),
      );
    }
    final rcxControl = ref.watch(
      rcxGroupProvider(group.name).select((status) => status?.control),
    );
    final automatic =
        group.type != GroupType.Selector ||
        (rcxControl != null && !rcxControl.isManual && !rcxControl.isPinned);
    final delay = ref.watch(
      delayProvider(proxyName: selected, testUrl: group.testUrl),
    );
    final code = (exit?.countryCode).takeFirstValid([
      countryCodeOfName(selected),
    ]);
    final mode = automatic
        ? appLocalizations.simpleLocationAuto
        : appLocalizations.simpleLocationManual;
    return DashboardCard(
      onTap: () => showProxiesSheet(context, groupName: group.name),
      padding: const EdgeInsets.all(16),
      child: _Headline(
        flag: ShapeFlag(code: code, size: _flagSize, dimmed: !live),
        count: group.all.length - 1,
        title: serverTitle(selected),
        subtitle: exit?.ip ?? '${group.name} · $mode',
        automatic: automatic ? mode : null,
        trailing: _SignalBars(delay: delay, live: live),
      ),
    );
  }
}

const _flagSize = 56.0;

/// The selected chain: where sites see you, or what broke and the fix.
class _ChainCard extends ConsumerWidget {
  const _ChainCard({
    required this.entry,
    required this.group,
    required this.live,
    required this.exit,
    required this.onTap,
  });

  final ChainEntry entry;
  final Group group;
  final bool live;
  final IpInfo? exit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final chain = entry.chain;
    final report = entry.report;
    final measured = exit?.countryCode.toLowerCase() ?? '';
    final exitCode = measured.isNotEmpty
        ? measured
        : hopCountry(ref, chain.exit);
    final mark = RouteMark(
      exit: exitCode,
      entry: hopCountry(ref, chain.entry),
      size: _chainMarkSize,
      dimmed: !live,
      broken: report.isBroken,
    );
    if (!report.isBroken) {
      final delay = ref.watch(
        delayProvider(proxyName: report.group, testUrl: group.testUrl),
      );
      final sites = exitCode == null
          ? null
          : l.chainsSitesSee(
              nameWithoutFlag(rcxCountryName(context, exitCode.toUpperCase())),
            );
      return DashboardCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: _Headline(
          flag: mark,
          title: chainTitle(chain),
          subtitle: [?sites, ?exit?.ip].join(' · '),
          trailing: _SignalBars(delay: delay, live: live),
        ),
      );
    }
    final issue = leadingIssue(report.errors);
    final suggestion = issue?.suggest.firstOrNull;
    final action = ref.read(proxyChainsActionProvider.notifier);
    return DashboardCard(
      onTap: () => showChainEditor(context, chain: chain),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _Headline(
            flag: mark,
            title: chainTitle(chain),
            subtitle: issue == null
                ? l.chainsNotWorking
                : chainShortReason(
                    l,
                    issue,
                    chain.hops,
                    group: report.target ?? '',
                  ),
            subtitleColor: colorScheme.error,
          ),
          Row(
            spacing: 8,
            children: [
              if ((issue, suggestion) case (final issue?, final suggestion?))
                Expanded(
                  flex: 6,
                  child: FilledButton(
                    style: _compactButton,
                    onPressed: () => globalState.safeRun(
                      () => action.replaceHop(
                        chain,
                        issue.hop < 0 ? chain.hops.length - 1 : issue.hop,
                        suggestion,
                      ),
                      silence: false,
                    ),
                    child: Text(
                      l.chainsTakeNamed(serverTitle(suggestion)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Expanded(
                flex: 5,
                child: suggestion == null
                    ? FilledButton(
                        style: _compactButton,
                        onPressed: () => showChainEditor(context, chain: chain),
                        child: Text(l.chainsFix, maxLines: 1),
                      )
                    : FilledButton.tonal(
                        style: _compactButton,
                        onPressed: () => showChainEditor(context, chain: chain),
                        child: Text(l.chainsOtherServer, maxLines: 1),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _chainMarkSize = 52.0;

final _compactButton = FilledButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 12),
);

class _Headline extends StatelessWidget {
  const _Headline({
    required this.flag,
    required this.title,
    required this.subtitle,
    this.count = 0,
    this.automatic,
    this.trailing,
    this.subtitleColor,
  });

  final Widget flag;

  /// The other servers the card opens, worn as a badge on the flag.
  final int count;
  final String title;
  final String subtitle;

  /// The tooltip of the mark that the server is picked automatically.
  final String? automatic;
  final Widget? trailing;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Row(
      spacing: 16,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            flag,
            if (count > 0)
              PositionedDirectional(
                end: -6,
                bottom: -4,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colorScheme.inverseSurface,
                    shape: AppShape.full.copyWith(
                      side: BorderSide(
                        color: DashboardColors.of(context).card,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    child: Text(
                      '+$count',
                      style: AppTextStyle.caption1
                          .of(context, emphasized: true)
                          .toTabular
                          .copyWith(color: colorScheme.onInverseSurface),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 10,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.title3.of(context, emphasized: true),
                    ),
                  ),
                  if (automatic case final automatic?)
                    Tooltip(
                      message: automatic,
                      child: GlyphIcon(
                        AppGlyphs.swap,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DashboardText.label(
                  context,
                  color: subtitleColor,
                ).toTabular,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// The delay as a signal meter, its value in the tooltip.
class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.delay, required this.live});

  final int? delay;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final colors = DashboardColors.of(context);
    final delay = this.delay ?? 0;
    final level = switch (delay) {
      <= 0 => 0,
      < 150 => 4,
      < 300 => 3,
      < 600 => 2,
      _ => 1,
    };
    final ink = !live
        ? context.colorScheme.onSurfaceVariant
        : level >= 3
        ? colors.ok
        : colors.warn;
    final bars = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 3,
      children: [
        for (var i = 0; i < 4; i++)
          DecoratedBox(
            decoration: ShapeDecoration(
              color: i < level ? ink : colors.tone2,
              shape: AppShape.full,
            ),
            child: SizedBox(width: 5, height: 8.0 + i * 4),
          ),
      ],
    );
    if (level == 0) return bars;
    final label = context.appLocalizations.simpleLatency(delay);
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: ExcludeSemantics(child: bars),
      ),
    );
  }
}
