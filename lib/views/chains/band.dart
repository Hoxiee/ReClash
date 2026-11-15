import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/proxies/card.dart';
import 'package:reclash/views/proxies/common.dart';
import 'package:reclash/widgets/widgets.dart';

import 'editor.dart';
import 'issues.dart';
import 'marks.dart';
import 'page.dart';
import 'state.dart';

const chainBandLabelExtent = 32.0;

/// [all] split into the chain band, in [chains], and the servers under it.
({List<Proxy> chains, List<Proxy> servers}) splitChainBand(
  List<Proxy> all,
  Set<String> chains,
) {
  if (chains.isEmpty) return (chains: const [], servers: all);
  final band = all.where((proxy) => chains.contains(proxy.name)).toList();
  if (band.isEmpty) return (chains: const [], servers: all);
  return (
    chains: band,
    servers: all.where((proxy) => !chains.contains(proxy.name)).toList(),
  );
}

/// A label over the chains or the servers of a group, with the way to every
/// chain beside the first.
class ChainBandLabel extends StatelessWidget {
  const ChainBandLabel({super.key, required this.chains});

  final bool chains;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: chainBandLabelExtent - 4,
        child: Row(
          children: [
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                chains ? l.chainsTitle : l.chainsServers,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.footnote
                    .of(context, emphasized: true)
                    .copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (chains)
              TextButton(
                onPressed: () => openChainsPage(context),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(l.chainsAll),
                    const GlyphIcon(AppGlyphs.chevronForward, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A chain among the servers: its name is its route, the flags say it twice.
class ChainTile extends ConsumerWidget {
  const ChainTile({
    super.key,
    required this.groupName,
    required this.groupType,
    required this.testUrl,
    required this.proxy,
    required this.type,
  });

  final String groupName;
  final GroupType groupType;
  final String? testUrl;
  final Proxy proxy;
  final ProxyCardType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final entry = ref.watch(chainOfGroupProvider(proxy.name));
    final card = ProxyCard(
      groupName: groupName,
      testUrl: testUrl,
      proxy: proxy,
      groupType: groupType,
      type: type,
      title: entry == null ? null : chainTitle(entry.chain),
      detail: entry == null ? null : _ChainDetail(entry: entry),
      failure: entry?.report.isBroken == true ? l.chainsNotWorking : null,
      extraMenuItems: [
        if (entry != null) ...[
          CommonPopupMenuItem(
            glyph: AppGlyphs.link,
            label: l.chainsOpen,
            onPressed: () => showChainEditor(context, chain: entry.chain),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.speed,
            label: l.chainsTest,
            onPressed: () => ref
                .read(proxyChainsActionProvider.notifier)
                .testDelay(entry.chain),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.eyeOff,
            label: l.chainsHide,
            onPressed: () => globalState.safeRun(
              () => ref
                  .read(proxyChainsActionProvider.notifier)
                  .setOffered(entry.chain, false),
              silence: false,
            ),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.toggle,
            label: l.chainsDisable,
            onPressed: () => disableChain(context, ref, entry.chain),
          ),
        ],
      ],
    );
    return card;
  }
}

/// Turns [chain] off; when it was the selected server, says which server the
/// group fell back to. The tile is gone by then, so the fallback is read
/// through the scope's container.
Future<void> disableChain(
  BuildContext context,
  WidgetRef ref,
  ProxyChain chain,
) async {
  final l = context.appLocalizations;
  final container = ProviderScope.containerOf(context, listen: false);
  final report = ref.read(chainReportProvider(chain.id));
  final target = report?.target;
  final selected =
      target != null &&
      ref.read(selectedProxyNameProvider(target)) == report?.group;
  await globalState.safeRun(
    () => ref.read(proxyChainsActionProvider.notifier).setEnabled(chain, false),
    silence: false,
  );
  if (!selected) return;
  final server = container.read(selectedProxyNameProvider(target));
  if (server == null || server.isEmpty) return;
  dialogs.showNotifier(l.chainsDisabledNotice(serverTitle(server)));
}

class _ChainDetail extends ConsumerWidget {
  const _ChainDetail({required this.entry});

  final ChainEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = entry.chain;
    final report = entry.report;
    final warning = report.status == ChainStatus.degraded
        ? leadingIssue(report.warnings)
        : null;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        RouteFlags(
          codes: [hopCountry(ref, chain.entry), hopCountry(ref, chain.exit)],
        ),
        if (warning != null)
          Tooltip(
            message: chainShortReason(
              context.appLocalizations,
              warning,
              chain.hops,
              group: report.target ?? '',
            ),
            child: GlyphIcon(
              AppGlyphs.warning,
              size: 14,
              color: DashboardColors.of(context).warn,
            ),
          ),
      ],
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: row,
    );
  }
}

const _hintPadding = EdgeInsetsDirectional.fromSTEB(14, 14, 4, 14);
const _hintMark = 44.0;
const _hintGap = 14.0;
const _hintButton = 40.0;
const _hintClose = 40.0;

/// The first-contact card's height at [width], with the gap under it, so the
/// group's rows keep a fixed extent.
double chainHintExtent(BuildContext context, double width) {
  final textWidth = math.max(
    width -
        _hintPadding.horizontal -
        RouteMark.extentOf(_hintMark) -
        _hintClose -
        _hintGap * 2,
    1.0,
  );
  final painter = TextPainter(
    text: TextSpan(
      text: context.appLocalizations.chainsHint,
      style: AppTextStyle.subheadline.of(context, emphasized: true),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: textWidth);
  final text = painter.height;
  painter.dispose();
  return _hintPadding.vertical +
      math.max(text + 10 + _hintButton, _hintClose) +
      proxyGridSpacing;
}

/// First contact: one sentence and one action, at the top of the main group,
/// shown only when the profile has servers at home and abroad.
class ChainHintCard extends ConsumerWidget {
  const ChainHintCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final group = ref.watch(chainMainGroupProvider);
    final abroad = group?.all
        .map((proxy) => countryOfHopName(proxy.name))
        .firstWhere((code) => code != null && code != 'ru', orElse: () => null);
    return Padding(
      padding: const EdgeInsets.only(bottom: proxyGridSpacing),
      child: CommonCard(
        radius: AppCorner.lg,
        onPressed: () => showChainEditor(context),
        child: Padding(
          padding: _hintPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: _hintGap,
            children: [
              RouteMark(exit: abroad, entry: 'ru', size: _hintMark),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      l.chainsHint,
                      style: AppTextStyle.subheadline.of(
                        context,
                        emphasized: true,
                      ),
                    ),
                    SizedBox(
                      height: _hintButton,
                      child: FilledButton(
                        onPressed: () => showChainEditor(context),
                        child: Text(l.chainsBuild),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: _hintClose,
                child: IconButton(
                  tooltip: l.chainsHintDismiss,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    final profileId = ref.read(currentProfileIdProvider);
                    if (profileId == null) return;
                    ref
                        .read(chainsHintDismissedProvider.notifier)
                        .dismiss(profileId);
                  },
                  icon: GlyphIcon(
                    AppGlyphs.close,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
