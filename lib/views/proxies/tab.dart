import 'dart:async';
import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/chains/band.dart';
import 'package:reclash/views/chains/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';
import 'group_tabs.dart';

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final Map<String, ScrollController> _scrollControllers = {};
  int _columns = 1;
  double _width = 0;

  @override
  void initState() {
    super.initState();
    ref.listenManual(proxiesTabControllerStateProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (!stringListEquality.equals(prev?.groupNames, next.groupNames)) {
        final groupNames = next.groupNames;
        final currentGroupName = next.currentGroupName;
        final index = groupNames.indexWhere((item) => item == currentGroupName);
        _updateTabController(groupNames.length, index);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _destroyTabController();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ScrollController _scrollControllerOf(String groupName) {
    return _scrollControllers.putIfAbsent(
      groupName,
      () => sheetScrollController(context),
    );
  }

  // The page of a dropped group still holds its controller until this frame
  // unmounts it.
  void _pruneScrollControllers(List<Group> groups) {
    final names = {for (final group in groups) group.name};
    final dropped = [
      for (final entry in _scrollControllers.entries)
        if (!names.contains(entry.key)) entry,
    ];
    for (final entry in dropped) {
      _scrollControllers.remove(entry.key);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => entry.value.dispose(),
      );
    }
  }

  void scrollToGroupSelected() {
    final group = currentGroup;
    final controller = _scrollControllers[group?.name];
    if (group == null || controller == null) {
      return;
    }
    final cardType = ref.read(proxiesTabStateProvider).proxyCardType;
    final rowOffset = _bandedRowOffset(
      group,
      ref.read(selectedProxyNameProvider(group.name)),
      getRowExtent(cardType),
    );
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(controller, rowOffset);
  }

  /// Mirrors [ProxyGroupView]: the hint card, then each band under its label.
  double? _bandedRowOffset(Group group, String? selected, double rowExtent) {
    final bands = splitProxyBands(
      group.all,
      chains: ref.read(chainGeneratedNamesProvider).groups,
      favorites: ref.read(favoriteSetProvider),
    );
    final labelled = proxyBandsLabelled(bands);
    var offset = ref.read(chainHintGroupProvider) == group.name
        ? chainHintExtent(context, _width)
        : 0.0;
    for (final (band: _, :proxies) in bands) {
      if (labelled) offset += proxyBandLabelExtent;
      final row = selectedRowOffset(
        proxies: proxies,
        selectedProxyName: selected,
        columns: _columns,
        rowExtent: rowExtent,
      );
      if (row != null) return offset + row;
      offset += (proxies.length / _columns).ceil() * rowExtent;
    }
    return null;
  }

  Future<void> delayTestCurrentGroup() async {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    await ref
        .read(proxiesActionProvider.notifier)
        .delayTestPageGroup(group.name);
  }

  Group? get currentGroup {
    return _getGroup(_tabController?.index);
  }

  Group? _getGroup(int? index) {
    final groups = ref.read(proxiesTabStateProvider).groups;
    if (index == null || index < 0 || index >= groups.length) {
      return null;
    }
    return groups[index];
  }

  void _tabControllerListener([int? index]) {
    final group = _getGroup(index ?? _tabController?.index);
    if (group == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(proxiesActionProvider.notifier)
          .updateCurrentGroupName(group.name);
    });
  }

  void _destroyTabController() {
    _tabController?.removeListener(_tabControllerListener);
    _tabController?.dispose();
    _tabController = null;
  }

  // An empty group list keeps the previous controller: the outgoing tab bar
  // still drives it while the empty state animates in.
  void _updateTabController(int length, int index) {
    if (length == 0) {
      return;
    }
    _destroyTabController();
    final realIndex = index == -1 ? 0 : index;
    final controller = TabController(
      length: length,
      initialIndex: realIndex,
      vsync: this,
    );
    _tabController = controller;
    _tabControllerListener(realIndex);
    controller.addListener(_tabControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    ref.watch(themeSettingProvider.select((state) => state.textScale));
    final groups = ref.watch(
      proxiesTabStateProvider.select((state) => state.groups),
    );
    final cardType = ref.watch(
      proxiesTabStateProvider.select((state) => state.proxyCardType),
    );
    final proxiesLayout = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.layout),
    );
    final isSearching = ref.watch(
      queryProvider(
        QueryTag.proxies,
      ).select((query) => SearchQuery(query).isNotEmpty),
    );
    _pruneScrollControllers(groups);
    final controller = _tabController;
    return NullStatusSwitcher(
      isEmpty: groups.isEmpty || controller == null,
      isSearching: isSearching,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.proxies,
        label: appLocalizations.nullTip(appLocalizations.proxies),
      ),
      child: controller == null
          ? const SizedBox.shrink()
          : AppBarClearance(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.contentTopPadding - context.appBarInset,
                      bottom: 16,
                    ),
                    child: GroupTabs(controller: controller, groups: groups),
                  ),
                  Expanded(
                    child: WidthBuilder(
                      builder: (_, width) {
                        final columns = getProxiesColumns(
                          max(width - 32, 0),
                          proxiesLayout,
                        );
                        _columns = columns;
                        _width = max(width - 32, 0);
                        return TabBarView(
                          controller: controller,
                          children: [
                            for (final group in groups)
                              ProxyGroupView(
                                key: ValueKey(group.name),
                                controller: _scrollControllerOf(group.name),
                                group: group,
                                columns: columns,
                                cardType: cardType,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProxyGroupView extends ConsumerWidget {
  final Group group;
  final ScrollController controller;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.controller,
    required this.columns,
    required this.cardType,
  });

  PageStorageKey _getPageStorageKey(WidgetRef ref) {
    final profile = ref.read(currentProfileProvider);
    final key =
        '${profile?.id}_${ScrollPositionCacheKey.proxiesTabList.name}_${group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chains = ref.watch(
      chainGeneratedNamesProvider.select((names) => names.groups),
    );
    final bands = splitProxyBands(
      group.all,
      chains: chains,
      favorites: ref.watch(favoriteSetProvider),
    );
    final labelled = proxyBandsLabelled(bands);
    final showHint = ref.watch(chainHintGroupProvider) == group.name;
    final delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: proxyGridSpacing,
      crossAxisSpacing: 8,
      mainAxisExtent: getItemHeight(cardType),
    );
    SliverGrid grid(List<Proxy> proxies) => SliverGrid(
      gridDelegate: delegate,
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          final proxy = proxies[index];
          return chains.contains(proxy.name)
              ? ChainTile(
                  groupName: group.name,
                  groupType: group.type,
                  testUrl: group.testUrl,
                  proxy: proxy,
                  type: cardType,
                )
              : ProxyCard(
                  testUrl: group.testUrl,
                  groupType: group.type,
                  type: cardType,
                  proxy: proxy,
                  groupName: group.name,
                );
        },
        childCount: proxies.length,
        addAutomaticKeepAlives: false,
      ),
    );
    return CommonScrollBar(
      controller: controller,
      thumbVisibility: true,
      child: CustomScrollView(
        key: _getPageStorageKey(ref),
        controller: controller,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16 + context.bottomInset,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                if (showHint) const SliverToBoxAdapter(child: ChainHintCard()),
                for (final (index, (:band, :proxies)) in bands.indexed) ...[
                  if (labelled)
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : proxyGridSpacing,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: ProxyBandLabel(
                          band: band,
                          proxies: proxies,
                          testUrl: group.testUrl,
                        ),
                      ),
                    ),
                  grid(proxies),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
