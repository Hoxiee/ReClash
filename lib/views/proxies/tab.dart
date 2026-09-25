import 'dart:async';
import 'package:reclash/icons/icons.dart';
import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';

typedef ProxyGroupViewKeyMap =
    Map<String, GlobalObjectKey<_ProxyGroupViewState>>;

const _scrollDuration = Duration(milliseconds: 300);
const _testDuration = Duration(milliseconds: 400);

class ProxiesTabView extends ConsumerStatefulWidget {
  const ProxiesTabView({super.key});

  static Map<String, PageStorageKey> pageListStoreMap = {};

  @override
  ConsumerState<ProxiesTabView> createState() => ProxiesTabViewState();
}

class ProxiesTabViewState extends ConsumerState<ProxiesTabView>
    with TickerProviderStateMixin {
  static const _emptyHold = Duration(milliseconds: 600);

  TabController? _tabController;
  final _hasMoreButtonNotifier = ValueNotifier<bool>(false);
  ProxyGroupViewKeyMap _keyMap = {};

  // Held groups keep the live TabController's length matched to the tabs when a reload blinks the list empty.
  List<Group> _heldGroups = const [];
  Timer? _emptyTimer;

  List<Group> _displayGroups(List<Group> live) {
    if (live.isNotEmpty) {
      _emptyTimer?.cancel();
      _emptyTimer = null;
      _heldGroups = live;
      return live;
    }
    if (_heldGroups.isNotEmpty && _tabController != null) {
      _emptyTimer ??= Timer(_emptyHold, () {
        _emptyTimer = null;
        if (mounted) setState(() => _heldGroups = const []);
      });
      return _heldGroups;
    }
    return const [];
  }

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
    _emptyTimer?.cancel();
    _destroyTabController();
    _hasMoreButtonNotifier.dispose();
    super.dispose();
  }

  void scrollToGroupSelected() {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    _keyMap[group.name]?.currentState?.scrollToSelected();
  }

  Future<void> delayTestCurrentGroup() async {
    final group = currentGroup;
    if (group == null) {
      return;
    }
    await ref
        .read(proxiesActionProvider.notifier)
        .delayTest(group.all, group.testUrl);
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

  Widget _buildMoreButton() {
    return Consumer(
      builder: (_, ref, _) {
        final isMobileView = ref.watch(isMobileViewProvider);
        return IconButton(
          tooltip: context.appLocalizations.more,
          onPressed: _showMoreMenu,
          icon: isMobileView
              ? const GlyphIcon(AppGlyphs.chevronDown)
              : const GlyphIcon(AppGlyphs.chevronForward),
        );
      },
    );
  }

  void _showMoreMenu() {
    showSheet(
      context: context,
      props: const SheetProps(isScrollControlled: false),
      builder: (_) {
        return AdaptiveSheetScaffold(
          body: SingleChildScrollView(
            padding: AppInsets.lg,
            child: Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(proxiesTabControllerStateProvider);
                final groupNames = state.groupNames;
                final currentGroupName = state.currentGroupName;
                return SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final groupName in groupNames)
                        SettingInfoCard(
                          Info(label: groupName),
                          onPressed: () {
                            final index = groupNames.indexWhere(
                              (item) => item == groupName,
                            );
                            if (index == -1) return;
                            _tabController?.animateTo(
                              index,
                              duration: context.motionDuration(
                                NavBarMetrics.motionDuration,
                              ),
                            );
                            ref
                                .read(proxiesActionProvider.notifier)
                                .updateCurrentGroupName(groupName);
                            Navigator.of(context).pop();
                          },
                          isSelected: groupName == currentGroupName,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          title: context.appLocalizations.proxyGroup,
        );
      },
    );
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
    final state = ref.watch(proxiesTabStateProvider.select((state) => state));
    final proxiesLayout = ref.watch(
      effectiveProxiesStyleProvider.select((state) => state.layout),
    );
    final groups = _displayGroups(state.groups);
    _keyMap = {};
    return NullStatusSwitcher(
      isEmpty: groups.isEmpty || _tabController == null,
      nullStatus: NullStatus(
        illustration: NullStatusIllustration.proxies,
        label: appLocalizations.nullTip(appLocalizations.proxies),
      ),
      child: _tvTraversalBoundary(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.appBarInset),
            NotificationListener<ScrollMetricsNotification>(
              onNotification: (scrollNotification) {
                _hasMoreButtonNotifier.value =
                    scrollNotification.metrics.maxScrollExtent > 0;
                return false;
              },
              child: ValueListenableBuilder(
                valueListenable: _hasMoreButtonNotifier,
                builder: (_, value, child) {
                  return Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      TabBar(
                        controller: _tabController,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16 + (value ? 16 : 0),
                        ),
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          for (final group in groups)
                            Tab(
                              child: Builder(
                                builder: (context) {
                                  return EmojiText(
                                    groupDisplayName(group.name),
                                    style: DefaultTextStyle.of(context).style,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      if (value) Positioned(right: 0, child: child!),
                    ],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.colorScheme.surface.opacity10,
                        context.colorScheme.surface,
                      ],
                      stops: const [0.0, 0.1],
                    ),
                  ),
                  child: _buildMoreButton(),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final columns = getProxiesColumns(
                    max(constraints.maxWidth - 32, 0),
                    proxiesLayout,
                  );
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      for (final group in groups)
                        ProxyGroupView(
                          key: _keyMap.updateCacheValue(
                            group.name,
                            () => GlobalObjectKey<_ProxyGroupViewState>(
                              group.name,
                            ),
                          ),
                          group: group,
                          columns: columns,
                          cardType: state.proxyCardType,
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

Widget _tvTraversalBoundary(Widget child) {
  return system.isTV ? FocusTraversalGroup(child: child) : child;
}

class ProxyGroupView extends ConsumerStatefulWidget {
  final Group group;
  final int columns;
  final ProxyCardType cardType;

  const ProxyGroupView({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
  });

  @override
  ConsumerState<ProxyGroupView> createState() => _ProxyGroupViewState();
}

class _ProxyGroupViewState extends ConsumerState<ProxyGroupView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  PageStorageKey _getPageStorageKey() {
    final profile = ref.read(currentProfileProvider);
    final key =
        '${profile?.id}_${ScrollPositionCacheKey.proxiesTabList.name}_${widget.group.name}';
    return ProxiesTabView.pageListStoreMap.updateCacheValue(
      key,
      () => PageStorageKey(key),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void scrollToSelected() {
    if (_controller.position.maxScrollExtent == 0) {
      return;
    }
    final offset = min(
      16 +
          getScrollToSelectedOffset(
            ref: ref,
            groupName: widget.group.name,
            proxies: widget.group.all,
            columns: widget.columns,
          ),
      _controller.position.maxScrollExtent,
    );
    if (context.disableAnimations) {
      _controller.jumpTo(offset);
      return;
    }
    _controller.animateTo(
      offset,
      duration: _scrollDuration,
      curve: Easing.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final proxies = group.all;
    return CommonScrollBar(
      controller: _controller,
      child: GridView.builder(
        key: _getPageStorageKey(),
        controller: _controller,
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 16 + BottomInsetScope.of(context),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: getItemHeight(widget.cardType),
        ),
        itemCount: proxies.length,
        itemBuilder: (_, index) {
          final proxy = proxies[index];
          return ProxyCard(
            testUrl: group.testUrl,
            groupType: group.type,
            type: widget.cardType,
            proxy: proxy,
            groupName: group.name,
          );
        },
      ),
    );
  }
}

class DelayTestButton extends StatefulWidget {
  final Future Function() onClick;

  const DelayTestButton({super.key, required this.onClick});

  @override
  State<DelayTestButton> createState() => _DelayTestButtonState();
}

class _DelayTestButtonState extends State<DelayTestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _running = false;

  Future<void> _healthcheck() async {
    if (_running) {
      return;
    }
    _running = true;
    unawaited(_controller.forward());
    try {
      await widget.onClick();
    } catch (e, s) {
      commonPrint.log('healthcheck ===> $e, $s', logLevel: LogLevel.warning);
    } finally {
      _running = false;
      if (mounted) {
        unawaited(_controller.reverse());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _testDuration);
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Easing.standard));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final duration = context.motionDuration(_testDuration);
    if (_controller.duration == duration) {
      return;
    }
    _controller.duration = duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, child) {
        return FadeTransition(
          opacity: _animation,
          child: ScaleTransition(scale: _animation, child: child),
        );
      },
      child: CommonFloatingActionButton(
        onPressed: _healthcheck,
        label: appLocalizations.delayTest,
        icon: const GlyphIcon(AppGlyphs.networkCheck),
      ),
    );
  }
}
