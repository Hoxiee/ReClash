import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/views.dart';
import 'package:reclash/widgets/widgets.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;
  final ScrollController? scrollController;

  const ConnectionsView({
    super.key,
    this.scrollController,
    @visibleForTesting this.connectionsReader,
  });

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsView> {
  CoreController get _core => ref.read(coreHandlerProvider);

  final _listController = TrackerInfoListController();
  late final ScrollController _scrollController;
  final Map<String, ({int up, int down, DateTime at})> _samples = {};

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  List<TrackerInfo> _withSpeeds(List<TrackerInfo> trackerInfos) {
    final now = DateTime.now();
    final withSpeeds = [
      for (final info in trackerInfos)
        () {
          final prev = _samples[info.id];
          if (prev == null) {
            return info;
          }
          final seconds = now.difference(prev.at).inMilliseconds / 1000;
          if (seconds <= 0) {
            return info;
          }
          return info.copyWith(
            downloadSpeed: ((info.download - prev.down) / seconds)
                .round()
                .clamp(0, 1 << 62),
            uploadSpeed: ((info.upload - prev.up) / seconds).round().clamp(
              0,
              1 << 62,
            ),
          );
        }(),
    ];
    _samples
      ..clear()
      ..addEntries(
        trackerInfos.map(
          (info) => MapEntry(info.id, (
            up: info.upload,
            down: info.download,
            at: now,
          )),
        ),
      );
    return withSpeeds;
  }

  String _sortLabel(ConnectionSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      ConnectionSortType.traffic => appLocalizations.traffic,
      ConnectionSortType.time => appLocalizations.time,
      ConnectionSortType.upload => appLocalizations.upload,
      ConnectionSortType.download => appLocalizations.download,
      ConnectionSortType.host => appLocalizations.host,
    };
  }

  void _handleSort(ConnectionSortType type) {
    _listController.setSortType(type);
    setState(() {});
  }

  List<CommonPopupMenuItem> _buildMenuItems() {
    final current = _listController.value.sortType;
    return [
      CommonPopupMenuItem(
        label: context.appLocalizations.closeConnections,
        glyph: AppGlyphs.clearAll,
        onPressed: () async {
          unawaited(_core.closeConnections());
          await _refreshConnections();
        },
      ),
      CommonPopupMenuItem(
        label: context.appLocalizations.sort,
        glyph: AppGlyphs.sort,
        subItems: [
          for (final type in ConnectionSortType.values)
            CommonPopupMenuItem(
              label: _sortLabel(type),
              glyph: current == type ? AppGlyphs.check : null,
              onPressed: () => _handleSort(type),
            ),
        ],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !isCurrent()) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<void> _refreshConnections() async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !mounted) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      return connectionsReader != null
          ? await connectionsReader()
          : await _core.getConnections();
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _applyConnections(List<TrackerInfo> trackerInfos) {
    // The core snapshot iterates a Go map, so its order is random per poll;
    // the controller's list getter sorts by the chosen key for a stable order.
    _listController.setTrackerInfos(_withSpeeds(trackerInfos));
  }

  Future<void> _handleBlockConnection(String id) async {
    await _core.closeConnection(id);
    await _refreshConnections();
  }

  @override
  void dispose() {
    _listController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.connections,
      floatBody: true,
      onKeywordsUpdate: _listController.updateKeywords,
      searchState: AppBarSearchState(
        onSearch: _listController.search,
        onRegexChange: (value) {
          _listController.setUseRegex(value);
          setState(() {});
        },
        useRegex: _listController.value.useRegex,
      ),
      menuItems: _buildMenuItems(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final connections = state.list;
          final topInset = context.appBarInset;
          // In a sheet the connection list is a focused drill-in, so the
          // running totals belong to the full tab, not the overlay.
          final showSummary = !context.isInSheet && connections.isNotEmpty;
          return Column(
            children: [
              if (showSummary)
                _SummaryBar(totals: state.totals, topInset: topInset),
              Expanded(
                child: NullStatusSwitcher(
                  isEmpty: connections.isEmpty,
                  nullStatus: NullStatus(
                    label: appLocalizations.nullTip(
                      appLocalizations.connections,
                    ),
                    illustration: NullStatusIllustration.connections,
                  ),
                  child: TrackerInfoAnimatedList(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: showSummary ? 8 : topInset,
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    trackerInfos: connections,
                    detailTitle: appLocalizations.details(
                      appLocalizations.connection,
                    ),
                    trailingBuilder: (trackerInfo) => _BlockConnectionButton(
                      onPressed: () {
                        _handleBlockConnection(trackerInfo.id);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.totals, required this.topInset});

  final ({
    int connections,
    int upload,
    int download,
    int uploadSpeed,
    int downloadSpeed,
  })
  totals;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 4, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerLow,
          shape: AppShape.lg,
        ),
        child: Row(
          children: [
            _SummaryCell(
              glyph: AppGlyphs.connections,
              label: appLocalizations.connections,
              value: '${totals.connections}',
            ),
            _SummaryCell(
              glyph: AppGlyphs.trendDown,
              label: '${totals.downloadSpeed.traffic.show}/s',
              value: totals.download.traffic.show,
            ),
            _SummaryCell(
              glyph: AppGlyphs.trendUp,
              label: '${totals.uploadSpeed.traffic.show}/s',
              value: totals.upload.traffic.show,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.glyph,
    required this.label,
    required this.value,
  });

  final Glyph glyph;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlyphIcon(glyph, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// One per live row: an IconButton would add a theme animation to each.
class _BlockConnectionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BlockConnectionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppTooltip(
      message: context.appLocalizations.blockConnection,
      child: Semantics(
        button: true,
        child: InkResponse(
          onTap: onPressed,
          radius: 14,
          child: SizedBox.square(
            dimension: 28,
            child: Center(
              child: GlyphIcon(
                AppGlyphs.block,
                size: 16,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
