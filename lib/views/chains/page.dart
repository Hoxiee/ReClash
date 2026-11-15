import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/flag.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/proxies/routing_country.dart';
import 'package:reclash/widgets/widgets.dart';

import 'band.dart';
import 'editor.dart';
import 'issues.dart';
import 'marks.dart';

Future<void> openChainsPage(BuildContext context) =>
    BaseNavigator.push<void>(context, const ChainsView());

/// Every chain of the profile, its state in one line.
class ChainsView extends ConsumerStatefulWidget {
  const ChainsView({super.key});

  @override
  ConsumerState<ChainsView> createState() => _ChainsViewState();
}

class _ChainsViewState extends ConsumerState<ChainsView> {
  final Map<int, ChainDelay> _delays = {};
  List<ProxyChain>? _order;
  bool _tested = false;

  Future<void> _testAll(List<ProxyChain> chains) async {
    final action = ref.read(proxyChainsActionProvider.notifier);
    await Future.wait([
      for (final chain in chains)
        if (chain.enabled)
          action.testDelay(chain).then((delays) {
            if (mounted) setState(() => _delays[chain.id] = delays);
          }),
    ]);
  }

  Future<void> _test(ProxyChain chain) async {
    final delays = await ref
        .read(proxyChainsActionProvider.notifier)
        .testDelay(chain);
    if (mounted) setState(() => _delays[chain.id] = delays);
  }

  Future<void> _setEnabled(ProxyChain chain, bool enabled) async {
    if (!enabled) return disableChain(context, ref, chain);
    await globalState.safeRun(
      () =>
          ref.read(proxyChainsActionProvider.notifier).setEnabled(chain, true),
      silence: false,
    );
  }

  Future<void> _duplicate(ProxyChain chain) => globalState.safeRun(
    () => ref
        .read(proxyChainsActionProvider.notifier)
        .create(
          profileId: chain.profileId,
          hops: chain.hops,
          enabled: false,
          offered: chain.offered,
          targetGroup: chain.targetGroup,
        ),
    silence: false,
  );

  Future<void> _delete(ProxyChain chain) async {
    final l = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(text: l.chainsDeleteConfirm(chainTitle(chain))),
      destructive: true,
      confirmText: l.delete,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(proxyChainsActionProvider.notifier).delete(chain);
  }

  void _reorder(List<ProxyChain> chains, int oldIndex, int newIndex) {
    final next = chains.copyAndReorder(oldIndex, newIndex);
    setState(() => _order = next);
    unawaited(
      ref.read(proxyChainsActionProvider.notifier).reorder(
        next.first.profileId,
        [for (final c in next) c.id],
      ),
    );
  }

  List<CommonPopupMenuItem> _menuOf(ProxyChain chain) {
    final l = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.edit,
        label: l.edit,
        onPressed: () => showChainEditor(context, chain: chain),
      ),
      if (chain.enabled)
        CommonPopupMenuItem(
          glyph: AppGlyphs.speed,
          label: l.chainsTest,
          onPressed: () => _test(chain),
        ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.copy,
        label: l.chainsDuplicate,
        onPressed: () => _duplicate(chain),
      ),
      CommonPopupMenuItem(
        danger: true,
        glyph: AppGlyphs.delete,
        label: l.delete,
        onPressed: () => _delete(chain),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final loaded = ref.watch(currentProfileChainsProvider).value;
    final group = ref.watch(chainMainGroupProvider)?.name ?? '';
    final profile = ref.watch(
      currentProfileProvider.select((profile) => profile?.realLabel),
    );
    if (loaded != null && !_tested) {
      _tested = true;
      unawaited(_testAll(loaded));
    }
    final ordered = _order;
    final chains =
        ordered != null &&
            loaded != null &&
            ordered.length == loaded.length &&
            ordered.every((chain) => loaded.any((c) => c.id == chain.id))
        ? [
            for (final chain in ordered)
              loaded.firstWhere((c) => c.id == chain.id),
          ]
        : loaded ?? const <ProxyChain>[];
    final insets =
        const EdgeInsets.all(16).copyWith(
          top: context.contentTopPadding,
          bottom: 16 + context.bottomInset,
        ) +
        context.bodyInsets;
    Widget row(int index) {
      final chain = chains[index];
      return ReorderableDelayedDragStartListener(
        key: ValueKey(chain.id),
        index: index,
        child: ContextMenuRegion(
          menuItems: _menuOf(chain),
          child: ItemPositionProvider(
            position: ItemPosition.get(index, chains.length),
            child: ChainRow(
              chain: chain,
              delays: _delays[chain.id],
              onToggle: (value) => _setEnabled(chain, value),
            ),
          ),
        ),
      );
    }

    return CommonScaffold(
      title: l.chainsTitle,
      iconActions: [
        if (chains.isNotEmpty)
          IconButtonData(
            glyph: AppGlyphs.add,
            tooltip: l.chainsNew,
            onPressed: () => showChainEditor(context),
          ),
      ],
      body: loaded == null
          ? const SizedBox.shrink()
          : chains.isEmpty
          ? Padding(
              padding: insets + const EdgeInsets.symmetric(horizontal: 16),
              child: const ChainsEmpty(),
            )
          : RefreshIndicator(
              onRefresh: () => _testAll(chains),
              child: ReorderableListView.builder(
                padding: insets,
                buildDefaultDragHandles: false,
                header: profile == null
                    ? null
                    : ListHeader(title: l.chainsProfileSection(profile)),
                footer: group.isEmpty
                    ? null
                    : ListFooter(text: l.chainsPageFooter(group)),
                itemCount: chains.length,
                itemBuilder: (_, index) => row(index),
                proxyDecorator: (_, index, animation) =>
                    commonProxyDecorator(row(index), index, animation),
                onReorderItem: (oldIndex, newIndex) =>
                    _reorder(chains, oldIndex, newIndex),
              ),
            ),
    );
  }
}

/// What a chain is, drawn before there is one, and the way to make it.
class ChainsEmpty extends ConsumerWidget {
  const ChainsEmpty({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final region = ref
        .watch(appSettingProvider.select((setting) => setting.regionCode))
        ?.toLowerCase();
    final home = region ?? 'ru';
    final abroad = home == 'nl' ? 'de' : 'nl';
    String country(String code) =>
        nameWithoutFlag(rcxCountryName(context, code.toUpperCase()));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: RouteStrip(
              nodes: [
                youNode(context),
                StripNode(
                  code: home,
                  label: country(home),
                  caption: l.chainsRoleEntry,
                ),
                StripNode(
                  code: abroad,
                  label: country(abroad),
                  caption: l.chainsRoleExit,
                ),
                StripNode(
                  label: l.chainsSites,
                  caption: '',
                  glyph: AppGlyphs.proxies,
                ),
              ],
              segments: const [ChainSeg.ok, ChainSeg.ok, ChainSeg.ok],
            ),
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              l.chainsEmpty,
              textAlign: TextAlign.center,
              style: AppTextStyle.body.of(context),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => showChainEditor(context),
            child: Text(l.chainsBuild),
          ),
        ],
      ),
    );
  }
}

class ChainRow extends ConsumerWidget {
  const ChainRow({
    super.key,
    required this.chain,
    required this.delays,
    required this.onToggle,
  });

  final ProxyChain chain;
  final ChainDelay? delays;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final report = ref.watch(chainReportProvider(chain.id));
    final target = report?.target;
    final selected =
        target != null &&
        ref.watch(selectedProxyNameProvider(target)) == report?.group;
    final group = target ?? '';
    final (String status, Color? tone) = switch (report) {
      _ when !chain.enabled => (l.chainsRowOff, null),
      final report? when report.isBroken => (
        l.chainsRowBroken(switch (leadingIssue(report.errors)) {
          final issue? => chainShortReason(l, issue, chain.hops, group: group),
          null => l.chainsIssueUnknownTitle,
        }),
        colorScheme.error,
      ),
      final report? when report.status == ChainStatus.degraded => (
        switch (leadingIssue(report.warnings)) {
          final issue? => chainShortReason(l, issue, chain.hops, group: group),
          null => '',
        },
        DashboardColors.of(context).warn,
      ),
      _ => (
        [
          if (selected) l.chainsRowSelected,
          if (!chain.offered) l.chainsRowRulesOnly,
          _delayLine(l, delays),
        ].join(' · '),
        null,
      ),
    };
    return DecorationListItem(
      onPressed: () => showChainEditor(context, chain: chain),
      leading: RouteMark(
        exit: hopCountry(ref, chain.exit),
        entry: hopCountry(ref, chain.entry),
        size: 40,
        dimmed: !chain.enabled,
        broken: chain.enabled && report?.isBroken == true,
      ),
      title: EmojiText(
        chainTitle(chain),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: chain.enabled
            ? null
            : TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      subtitle: status.isEmpty
          ? null
          : Text(
              status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tone == null ? null : TextStyle(color: tone),
            ),
      trailing: CommonSwitch(value: chain.enabled, onChanged: onToggle),
    );
  }
}

String _delayLine(AppLocalizations l, ChainDelay? delays) {
  final entry = delays?.entry;
  final path = delays?.chain;
  if (entry == null || path == null) return l.chainsRowDelays('—', '—');
  if (entry <= 0 || path <= 0) return l.chainsNoResponse;
  return l.chainsRowDelays(chainLatency(l, entry), chainLatency(l, path));
}
