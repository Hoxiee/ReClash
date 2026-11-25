import 'dart:async';
import 'dart:math';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/features/proxy_chains/proxy_chains.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/chains/band.dart';
import 'package:reclash/views/chains/marks.dart';
import 'package:reclash/views/chains/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';
import 'common.dart';
import 'routing.dart';
import 'routing_strategy.dart';

const _headerInset = 10.0;
const _headerButtonInset = 4.0;
const _groupInset = 16.0;
const _liftDistance = 16.0;
const _groupMinWidth = 360.0;
const _groupMaxColumns = 3;
const _lastRowGrowth = _headerInset - proxyGridSpacing;

class ProxiesListView extends ConsumerStatefulWidget {
  const ProxiesListView({super.key});

  @override
  ConsumerState<ProxiesListView> createState() => _ProxiesListViewState();
}

class _ProxiesListViewState extends ConsumerState<ProxiesListView> {
  late final ScrollController _controller;
  int _columns = 1;
  int _groupColumns = 1;
  double _gap = 0;
  Set<String> _chains = const {};
  Set<String> _favorites = const {};
  String? _hintGroup;
  double _hintExtent = 0;

  _GroupLayout _layoutOf(Group group, double rowExtent) => _GroupLayout.of(
    group,
    columns: _columns,
    rowExtent: rowExtent,
    chains: _chains,
    favorites: _favorites,
    hintExtent: group.name == _hintGroup ? _hintExtent : null,
  );

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String groupName) {
    _autoScrollToGroup(groupName);
    final tempUnfoldSet = Set<String>.from(ref.read(unfoldSetProvider));
    if (!tempUnfoldSet.remove(groupName)) {
      tempUnfoldSet.add(groupName);
    }
    ref
        .read(proxiesActionProvider.notifier)
        .updateCurrentUnfoldSet(tempUnfoldSet);
  }

  GroupOffsets _getGroupOffsets() {
    final state = ref.read(proxiesListStateProvider);
    final offsets = <double>[];
    final rowExtent = getRowExtent(state.proxyCardType);
    final columnOffsets = List.filled(_groupColumns, 0.0);
    for (final (index, group) in state.groups.indexed) {
      final column = index % _groupColumns;
      offsets.add(columnOffsets[column]);
      columnOffsets[column] += listHeaderHeight + _gap;
      if (state.currentUnfoldSet.contains(group.name)) {
        columnOffsets[column] += _layoutOf(group, rowExtent).extent;
      }
    }
    return GroupOffsets(state.groups, offsets);
  }

  double _getGroupOffset(String groupName) {
    if (!_controller.hasClients || _controller.position.maxScrollExtent == 0) {
      return 0;
    }
    return _getGroupOffsets().offsetOf(groupName);
  }

  void _scrollToMakeVisibleWithPadding({
    required double containerHeight,
    required double pixels,
    required double start,
    required double end,
    double padding = 24,
  }) {
    final visibleStart = pixels;
    final visibleEnd = pixels + containerHeight;

    final isElementVisible = start >= visibleStart && end <= visibleEnd;
    if (isElementVisible) {
      return;
    }

    double targetScrollOffset;

    if (end <= visibleStart) {
      targetScrollOffset = start;
    } else if (start >= visibleEnd) {
      targetScrollOffset = end - containerHeight + padding;
    } else {
      final visibleTopPart = end - visibleStart;
      final visibleBottomPart = visibleEnd - start;
      if (visibleTopPart.abs() >= visibleBottomPart.abs()) {
        targetScrollOffset = end - containerHeight + padding;
      } else {
        targetScrollOffset = start;
      }
    }

    targetScrollOffset = targetScrollOffset.clamp(
      _controller.position.minScrollExtent,
      _controller.position.maxScrollExtent,
    );

    _controller.jumpTo(targetScrollOffset);
  }

  void _autoScrollToGroup(String groupName) {
    final pixels = _controller.position.pixels;
    final offset = _getGroupOffset(groupName);
    _scrollToMakeVisibleWithPadding(
      containerHeight: max(
        _controller.position.viewportDimension - context.contentTopPadding,
        0,
      ),
      pixels: pixels,
      start: offset,
      end: offset + listHeaderHeight,
    );
  }

  void _scrollToGroupSelected(String groupName) {
    final cardType = ref.read(proxiesListStateProvider).proxyCardType;
    final group = ref.read(proxiesListStateProvider).groups.getGroup(groupName);
    if (group == null) {
      return;
    }
    final selected = ref.read(selectedProxyNameProvider(groupName));
    final rowOffset = selected == null
        ? null
        : _layoutOf(group, getRowExtent(cardType)).offsetOf(selected);
    if (rowOffset == null) {
      return;
    }
    animateScrollTo(_controller, _getGroupOffset(groupName) + rowOffset);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return Consumer(
      builder: (_, ref, _) {
        final groups = ref.watch(
          proxiesListStateProvider.select((state) => state.groups),
        );
        final cardType = ref.watch(
          proxiesListStateProvider.select((state) => state.proxyCardType),
        );
        ref.watch(themeSettingProvider.select((state) => state.textScale));
        final chains = ref.watch(
          chainGeneratedNamesProvider.select((names) => names.groups),
        );
        final favorites = ref.watch(favoriteSetProvider);
        final hintGroup = ref.watch(chainHintGroupProvider);
        final viewMode = ref.watch(viewModeProvider);
        final proxiesLayout = ref.watch(
          proxiesStyleSettingProvider.select((state) => state.layout),
        );
        final isSearching = ref.watch(
          queryProvider(
            QueryTag.proxies,
          ).select((query) => SearchQuery(query).isNotEmpty),
        );
        return NullStatusSwitcher(
          isEmpty: groups.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            illustration: NullStatusIllustration.proxies,
            label: appLocalizations.nullTip(appLocalizations.proxies),
          ),
          child: WidthBuilder(
            builder: (_, maxWidth) {
              final gap = cardSpacingOf(context, viewMode);
              final width = max(maxWidth - _groupInset * 2, 0.0);
              final groupColumns = viewMode == ViewMode.mobile
                  ? 1
                  : ((width + gap) / (_groupMinWidth + gap)).floor().clamp(
                      1,
                      _groupMaxColumns,
                    );
              final groupWidth =
                  (width - gap * (groupColumns - 1)) / groupColumns;
              final columns = getProxiesColumns(
                max(groupWidth - _headerInset * 2, 0),
                proxiesLayout,
              );
              _columns = columns;
              _groupColumns = groupColumns;
              _gap = gap;
              _chains = chains;
              _favorites = favorites;
              _hintGroup = hintGroup;
              _hintExtent = hintGroup == null
                  ? 0
                  : chainHintExtent(
                      context,
                      max(groupWidth - _headerInset * 2, 0),
                    );
              Widget buildGroup(Group group) => _GroupSliver(
                key: _GroupSliverKey(group.name),
                group: group,
                columns: columns,
                cardType: cardType,
                gap: gap,
                chains: chains,
                favorites: favorites,
                hintExtent: group.name == hintGroup ? _hintExtent : null,
                onChange: _handleChange,
                onScrollToSelected: _scrollToGroupSelected,
              );
              return CommonScrollBar(
                controller: _controller,
                thumbVisibility: true,
                child: CustomScrollView(
                  key: proxiesListStoreKey,
                  controller: _controller,
                  slivers: [
                    PinnedHeaderSliver(
                      child: SizedBox(height: context.contentTopPadding),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _groupInset,
                      ),
                      sliver: groupColumns == 1
                          ? SliverMainAxisGroup(
                              slivers: groups.map(buildGroup).toList(),
                            )
                          : SliverCrossAxisGroup(
                              slivers: [
                                for (
                                  var column = 0;
                                  column < groupColumns;
                                  column++
                                ) ...[
                                  if (column > 0)
                                    SliverConstrainedCrossAxis(
                                      maxExtent: gap,
                                      sliver: const SliverToBoxAdapter(),
                                    ),
                                  SliverCrossAxisExpanded(
                                    flex: 1,
                                    sliver: SliverMainAxisGroup(
                                      slivers: [
                                        for (
                                          var index = column;
                                          index < groups.length;
                                          index += groupColumns
                                        )
                                          buildGroup(groups[index]),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 16 + context.bottomInset),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

sealed class _BandRow {
  const _BandRow();
}

final class _HintRow extends _BandRow {
  const _HintRow();
}

final class _LabelRow extends _BandRow {
  const _LabelRow(this.band, this.proxies);

  final ProxyBand band;
  final List<Proxy> proxies;
}

final class _CardsRow extends _BandRow {
  const _CardsRow(this.proxies);

  final List<Proxy> proxies;
}

/// A group's rows with their extents: favorites, then chains, on their own
/// rows above the servers, and the first-contact card above them all.
class _GroupLayout {
  _GroupLayout._(this.rows, this.extents, {required this.uniform});

  factory _GroupLayout.of(
    Group group, {
    required int columns,
    required double rowExtent,
    required Set<String> chains,
    required Set<String> favorites,
    double? hintExtent,
  }) {
    final bands = splitProxyBands(
      group.all,
      chains: chains,
      favorites: favorites,
    );
    final labelled = proxyBandsLabelled(bands);
    final rows = <_BandRow>[];
    final extents = <double>[];
    void add(_BandRow row, double extent) {
      rows.add(row);
      extents.add(extent);
    }

    if (hintExtent != null) add(const _HintRow(), hintExtent);
    for (final (:band, :proxies) in bands) {
      if (labelled) add(_LabelRow(band, proxies), proxyBandLabelExtent);
      for (final chunk in proxies.chunks(columns)) {
        add(_CardsRow(chunk), rowExtent);
      }
    }
    return _GroupLayout._(
      rows,
      extents,
      uniform: hintExtent == null && !labelled,
    );
  }

  final List<_BandRow> rows;
  final List<double> extents;
  final bool uniform;

  double get extent => extents.isEmpty ? 0 : extents.sum + _lastRowGrowth;

  double? offsetOf(String proxyName) {
    var offset = 0.0;
    for (final (index, row) in rows.indexed) {
      if (row is _CardsRow &&
          row.proxies.any((proxy) => proxy.name == proxyName)) {
        return offset;
      }
      offset += extents[index];
    }
    return null;
  }
}

class _GroupSliverKey extends ValueKey<String> {
  const _GroupSliverKey(super.value);
}

/// Watches only its own group's fold state, so folding one group leaves the
/// cards of every other group untouched, and keeps its rows sliver while the
/// inputs that shape it are equal.
class _GroupSliver extends ConsumerStatefulWidget {
  const _GroupSliver({
    super.key,
    required this.group,
    required this.columns,
    required this.cardType,
    required this.gap,
    required this.chains,
    required this.favorites,
    required this.hintExtent,
    required this.onChange,
    required this.onScrollToSelected,
  });

  final Group group;
  final int columns;
  final ProxyCardType cardType;
  final double gap;
  final Set<String> chains;
  final Set<String> favorites;
  final double? hintExtent;
  final void Function(String groupName) onChange;
  final void Function(String groupName) onScrollToSelected;

  @override
  ConsumerState<_GroupSliver> createState() => _GroupSliverState();
}

class _GroupSliverState extends ConsumerState<_GroupSliver>
    with SingleTickerProviderStateMixin {
  Widget? _rows;
  double _rowExtent = 0;
  late final _controller = AnimationController(
    vsync: this,
    value: ref.read(unfoldSetProvider).contains(widget.group.name) ? 1 : 0,
  );
  late final _unfold = UnfoldEntryTransition.curveOf(_controller);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((_) => setState(() {}));
    ref.listenManual(
      unfoldSetProvider.select((state) => state.contains(widget.group.name)),
      (_, isExpand) => _handleUnfold(isExpand),
    );
  }

  @override
  void dispose() {
    _unfold.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleUnfold(bool isExpand) {
    _controller.duration = context.motionDuration(
      UnfoldEntryTransition.duration,
    );
    isExpand ? _controller.forward() : _controller.reverse();
  }

  @override
  void didUpdateWidget(_GroupSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.group != oldWidget.group ||
        widget.columns != oldWidget.columns ||
        widget.cardType != oldWidget.cardType ||
        !setEquals(widget.chains, oldWidget.chains) ||
        !setEquals(widget.favorites, oldWidget.favorites) ||
        widget.hintExtent != oldWidget.hintExtent) {
      _rows = null;
    }
  }

  _GroupLayout _layoutOf(double rowExtent) => _GroupLayout.of(
    widget.group,
    columns: widget.columns,
    rowExtent: rowExtent,
    chains: widget.chains,
    favorites: widget.favorites,
    hintExtent: widget.hintExtent,
  );

  Widget _buildBandRow(BuildContext context, _BandRow row) => switch (row) {
    _HintRow() => const Padding(
      padding: EdgeInsets.symmetric(horizontal: _headerInset),
      child: ChainHintCard(),
    ),
    _LabelRow(:final band, :final proxies) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: _headerInset),
      child: ProxyBandLabel(
        band: band,
        proxies: proxies,
        testUrl: widget.group.testUrl,
      ),
    ),
    _CardsRow(:final proxies) => _buildRow(context, proxies),
  };

  Widget _buildRow(BuildContext context, List<Proxy> proxies) {
    final group = widget.group;
    final cardType = widget.cardType;
    final groupName = group.name;
    final children = proxies
        .map<Widget>(
          (proxy) => Flexible(
            child: SizedBox(
              height: getItemHeight(cardType),
              child: widget.chains.contains(proxy.name)
                  ? ChainTile(
                      key: ValueKey('$groupName.${proxy.name}'),
                      groupName: groupName,
                      groupType: group.type,
                      testUrl: group.testUrl,
                      proxy: proxy,
                      type: cardType,
                    )
                  : ProxyCard(
                      testUrl: group.testUrl,
                      type: cardType,
                      groupType: group.type,
                      key: ValueKey('$groupName.${proxy.name}'),
                      proxy: proxy,
                      groupName: groupName,
                    ),
            ),
          ),
        )
        .fill(widget.columns, filler: (_) => const Flexible(child: SizedBox()))
        .separated(const SizedBox(width: 8));
    return SurfaceScope(
      level: context.raisedSurfaceLevel,
      child: Padding(
        padding: const EdgeInsets.only(
          left: _headerInset,
          right: _headerInset,
          bottom: proxyGridSpacing,
        ),
        child: Row(children: children.toList()),
      ),
    );
  }

  Widget _buildRows(double extent) {
    final layout = _layoutOf(extent);
    final rows = layout.rows;
    final delegate = SliverChildBuilderDelegate(
      (context, index) => _buildBandRow(context, rows[index]),
      childCount: rows.length,
      addAutomaticKeepAlives: false,
    );
    if (layout.uniform) {
      return SliverFixedExtentList(itemExtent: extent, delegate: delegate);
    }
    final extents = layout.extents;
    return SliverVariedExtentList(
      itemExtentBuilder: (index, _) =>
          index < extents.length ? extents[index] : null,
      delegate: delegate,
    );
  }

  Widget _buildUnfoldingRows(double extent, ShapeDecoration decoration) {
    final layout = _layoutOf(extent);
    final rows = layout.rows;
    final visible = min(
      rows.length.toDouble(),
      MediaQuery.sizeOf(context).height / extent,
    );
    final count = min(rows.length, visible.floor() + 1);
    return DecoratedBox(
      decoration: decoration,
      child: SizeTransition(
        sizeFactor: _unfold,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            for (var index = 0; index < count; index++)
              UnfoldEntryTransition(
                animation: _unfold,
                index: index,
                visibleCount: visible,
                child: SizedBox(
                  height: layout.extents[index],
                  child: _buildBandRow(context, rows[index]),
                ),
              ),
            if (count == rows.length) const SizedBox(height: _lastRowGrowth),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupName = widget.group.name;
    final isExpand = ref.watch(
      unfoldSetProvider.select((state) => state.contains(groupName)),
    );
    final unfolded = _controller.isCompleted;
    Widget? rows;
    if (!_controller.isDismissed && widget.group.all.isNotEmpty) {
      final extent = getRowExtent(widget.cardType);
      final decoration = ShapeDecoration(
        color: context.raisedSurfaceLevel.colorOf(context.colorScheme),
        shape: AppShape.vertical(
          top: AppCorner.none,
          bottom: AppCorner.xl.ap(context),
        ),
      );
      if (!unfolded) {
        _rows = null;
        rows = SliverToBoxAdapter(
          child: _buildUnfoldingRows(extent, decoration),
        );
      } else {
        if (_rows == null || _rowExtent != extent) {
          _rows = _buildRows(extent);
          _rowExtent = extent;
        }
        rows = DecoratedSliver(
          decoration: decoration,
          sliver: SliverMainAxisGroup(
            slivers: [
              _rows!,
              const SliverToBoxAdapter(child: SizedBox(height: _lastRowGrowth)),
            ],
          ),
        );
      }
    } else {
      _rows = null;
    }
    final backing = context.raisedSurfaceLevel.colorOf(context.colorScheme);
    Widget buildHeader({double floating = 0, double lift = 0}) => SizedBox(
      height: listHeaderHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (rows != null)
            Positioned(
              top: listHeaderHeight / 2,
              left: 0,
              right: 0,
              bottom: -1,
              child: ColoredBox(color: backing),
            ),
          ListHeader(
            enterAnimated: false,
            floating: floating,
            lift: lift,
            onScrollToSelected: widget.onScrollToSelected,
            key: ValueKey(groupName),
            isExpand: isExpand,
            unfolded: unfolded,
            group: widget.group,
            onChange: widget.onChange,
          ),
        ],
      ),
    );
    return SliverPadding(
      padding: EdgeInsets.only(bottom: widget.gap),
      sliver: SliverMainAxisGroup(
        slivers: [
          _buildPinnedHeader(isExpand, buildHeader),
          if (rows != null) _GroupRowsClip(sliver: rows),
        ],
      ),
    );
  }

  /// Rounds the header and lifts it as its own rows scroll under it, and lets
  /// the shadow go before the end of the group pushes it out. The backdrop
  /// behind its upper half hides the rows that went under it, which would
  /// otherwise show around its top corners and above it. Every header is laid
  /// out on every pass, so one beyond the cache area builds nothing.
  Widget _buildPinnedHeader(
    bool isExpand,
    Widget Function({double floating, double lift}) buildHeader,
  ) {
    final rowsExtent = isExpand ? _layoutOf(_rowExtent).extent : 0.0;
    final groupExtent =
        listHeaderHeight +
        (_controller.isDismissed
            ? 0.0
            : _layoutOf(getRowExtent(widget.cardType)).extent);
    (double, double, double)? headerState;
    Widget? header;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final beyondCache =
            constraints.remainingCacheExtent <= 0 ||
            constraints.scrollOffset + constraints.cacheOrigin >= groupExtent;
        final under = isExpand
            ? constraints.scrollOffset + constraints.overlap
            : 0.0;
        final state = beyondCache
            ? null
            : (
                (under / _liftDistance).clamp(0.0, 1.0),
                (min(under, rowsExtent - under) / _liftDistance).clamp(
                  0.0,
                  1.0,
                ),
                isExpand ? constraints.overlap : 0.0,
              );
        if (header != null && state == headerState) {
          return header!;
        }
        headerState = state;
        if (state == null) {
          return header = PinnedHeaderSliver(
            child: SizedBox(height: listHeaderHeight),
          );
        }
        final (floating, lift, cover) = state;
        return header = PinnedHeaderSliver(
          child: RepaintBoundary(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -cover,
                  left: 0,
                  right: 0,
                  height: cover + listHeaderHeight / 2,
                  child: const PageBackdrop(),
                ),
                buildHeader(floating: floating, lift: lift),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupRowsClip extends SingleChildRenderObjectWidget {
  const _GroupRowsClip({required Widget sliver}) : super(child: sliver);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGroupRowsClip();
}

class _RenderGroupRowsClip extends RenderProxySliver {
  Rect get _paintClip {
    final extent = geometry!.paintExtent;
    return Rect.fromLTRB(
      0,
      constraints.overlap.clamp(0.0, extent),
      constraints.crossAxisExtent,
      extent,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    layer = context.pushClipRect(
      needsCompositing,
      offset,
      _paintClip,
      super.paint,
      oldLayer: layer as ClipRectLayer?,
    );
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) =>
      mainAxisPosition >= constraints.overlap &&
      super.hitTestChildren(
        result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );

  @override
  Rect describeApproximatePaintClip(RenderObject child) => _paintClip;
}

class ListHeader extends ConsumerWidget {
  final Group group;

  final Function(String groupName) onChange;
  final Function(String groupName) onScrollToSelected;
  final bool isExpand;

  /// Whether the rows have settled under the header, squaring its bottom.
  final bool unfolded;

  final bool enterAnimated;

  /// How far the group's own rows have scrolled under the pinned header, as a
  /// fraction of the distance that rounds its bottom corners.
  final double floating;

  /// The shadow that lifts the header off the rows under it.
  final double lift;

  const ListHeader({
    super.key,
    this.enterAnimated = true,
    this.floating = 0,
    this.lift = 0,
    required this.group,
    required this.onChange,
    required this.onScrollToSelected,
    required this.isExpand,
    required this.unfolded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupName = group.name;
    final isDelayTesting = ref.watch(
      delayTestingGroupsProvider.select((state) => state.contains(groupName)),
    );
    final (scripted, profile) = ref.watch(
      rcxGroupProvider(groupName).select(
        (state) => switch (state) {
          null => (false, null),
          final group => (true, group.control.isManual ? null : group.profile),
        },
      ),
    );
    final behaviour = watchGroupBehaviour(ref, group);
    final showRouting = behaviour || scripted;
    final colorScheme = context.colorScheme;
    final level = floating > 0
        ? SurfaceLevel.floatingOf(colorScheme)
        : context.raisedSurfaceLevel;
    final radius = AppCorner.xl.ap(context);
    final card = CommonCard(
      enterActionsOnRight: true,
      enterAnimated: enterAnimated,
      key: key,
      shape: AppShape.vertical(
        top: radius - _headerButtonInset,
        bottom: unfolded
            ? max(radius * floating - _headerButtonInset, 0)
            : radius - _headerButtonInset,
      ),
      child: Padding(
        padding: const EdgeInsets.all(_headerInset - _headerButtonInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  _GroupIcon(src: group.icon, name: groupName),
                  Flexible(child: _GroupSummary(groupName: groupName)),
                ],
              ),
            ),
            _GroupActions(
              isExpand: isExpand,
              routingTooltip: behaviour
                  ? context.appLocalizations.rcxBehaviour
                  : null,
              isDelayTesting: isDelayTesting,
              groupType: profile == null
                  ? group.type.name
                  : rcxProfileTitle(context, ref, profile),
              onRouting: showRouting
                  ? () => unawaited(
                      behaviour
                          ? showGroupBehaviour(context, groupName)
                          : showRoutingSheet(context, groupName),
                    )
                  : null,
              onScrollToSelected: () {
                onScrollToSelected(groupName);
              },
              onDelayTest: () {
                ref
                    .read(proxiesActionProvider.notifier)
                    .delayTestPageGroup(groupName);
              },
              onToggle: () {
                onChange(groupName);
              },
            ),
          ],
        ),
      ),
      onPressed: () {
        onChange(groupName);
      },
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: level.colorOf(colorScheme),
        shape: AppShape.vertical(
          top: radius,
          bottom: unfolded ? radius * floating : radius,
        ),
        shadows: lift == 0 ? null : _floatingShadows(colorScheme, lift),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_headerButtonInset),
        child: SurfaceScope(
          // CommonCard fills one level above its scope.
          level: SurfaceLevel.values[level.index - 1],
          child: card,
        ),
      ),
    );
  }
}

List<BoxShadow> _floatingShadows(ColorScheme colorScheme, double lift) {
  final strength = colorScheme.brightness == Brightness.dark ? 3.0 : 1.0;
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.08 * strength * lift),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.04 * strength * lift),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];
}

class _GroupIcon extends ConsumerWidget {
  const _GroupIcon({required this.src, required this.name});

  final String src;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconStyle = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconStyle),
    );
    return switch (iconStyle) {
      ProxiesIconStyle.filled => LayoutBuilder(
        builder: (_, constraints) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                padding: EdgeInsets.all(6.ap(context)),
                decoration: ShapeDecoration(
                  color: context.raisedSurfaceLevel.colorOf(
                    context.colorScheme,
                  ),
                  shape: AppShape.all(AppCorner.xl.ap(context) - _headerInset),
                ),
                clipBehavior: Clip.antiAlias,
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: constraints.maxHeight - 12.ap(context),
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  child: CommonTargetIcon(
                    src: src,
                    fallback: GroupMonogram(name),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ProxiesIconStyle.plain => Container(
        margin: const EdgeInsets.only(left: 2, right: 10),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return IconTheme.merge(
              data: IconThemeData(
                size: constraints.maxHeight,
                color: context.colorScheme.primary,
              ),
              child: CommonTargetIcon(src: src, fallback: GroupMonogram(name)),
            );
          },
        ),
      ),
      // Lines the title up with the proxy card names below, which sit at the
      // row inset plus the card padding.
      ProxiesIconStyle.hidden => const SizedBox(width: 4),
    };
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmojiText(
          groupName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.callout.of(context, emphasized: true),
        ),
        const SizedBox(height: 2),
        Flexible(flex: 1, child: _SelectedProxyName(groupName: groupName)),
      ],
    );
  }
}

class _SelectedProxyName extends ConsumerWidget {
  const _SelectedProxyName({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyName = ref
        .watch(selectedProxyNameProvider(groupName))
        .takeFirstValid([]);
    if (proxyName.isEmpty) {
      return const SizedBox.shrink();
    }
    final chain = ref.watch(
      chainOfGroupProvider(proxyName).select((entry) => entry?.chain),
    );
    final title = chain == null ? proxyName : chainTitle(chain);
    final control = ref.watch(
      rcxGroupProvider(groupName).select((state) => state?.control),
    );
    final l = context.appLocalizations;
    final mode = switch (control) {
      null => null,
      RcxControl(isManual: true) => null,
      RcxControl(isPinned: true) => l.rcxPinnedLabel,
      _ => l.rcxModeAuto,
    };
    return EmojiText(
      mode == null ? title : '$mode · $title',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.caption1.of(context, emphasized: true).toLight,
    );
  }
}

class _GroupActions extends StatelessWidget {
  const _GroupActions({
    required this.isExpand,
    required this.isDelayTesting,
    required this.groupType,
    required this.onScrollToSelected,
    required this.onDelayTest,
    required this.onToggle,
    this.onRouting,
    this.routingTooltip,
  });

  final bool isExpand;
  final bool isDelayTesting;
  final String groupType;
  final VoidCallback onScrollToSelected;
  final VoidCallback onDelayTest;
  final VoidCallback onToggle;
  final VoidCallback? onRouting;
  final String? routingTooltip;

  @override
  Widget build(BuildContext context) {
    return TonalButtonTheme(
      size: TonalButtonSize.compact,
      child: Row(
        children: [
          if (isExpand)
            TonalButtonGroup(
              size: TonalButtonSize.compact,
              children: [
                IconButton(
                  tooltip: context.appLocalizations.scrollToSelected,
                  onPressed: onScrollToSelected,
                  iconSize: 19,
                  icon: const GlyphIcon(AppGlyphs.locate),
                ),
                IconButton(
                  tooltip: context.appLocalizations.delayTest,
                  onPressed: isDelayTesting ? null : onDelayTest,
                  icon: isDelayTesting
                      ? CommonCircleLoading(size: TonalButtonSize.compact.icon)
                      : const GlyphIcon(AppGlyphs.bolt),
                ),
                if (onRouting != null)
                  IconButton(
                    tooltip:
                        routingTooltip ?? context.appLocalizations.rcxTitle,
                    onPressed: onRouting,
                    icon: const GlyphIcon(AppGlyphs.shuffle),
                  ),
              ],
            )
          else
            Text(
              groupType,
              style: AppTextStyle.caption1
                  .of(context, emphasized: true)
                  .toLight,
            ),
          const SizedBox(width: 6),
          ElasticPress(
            child: IconButton(
              tooltip: isExpand
                  ? context.appLocalizations.showLess
                  : context.appLocalizations.showMore,
              onPressed: onToggle,
              icon: CommonExpandIcon(expand: isExpand),
            ),
          ),
        ],
      ),
    );
  }
}
