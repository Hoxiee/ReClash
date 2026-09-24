import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/views/views.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const ConnectionsView({super.key, @visibleForTesting this.connectionsReader});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsView> {
  CoreController get _core => ref.read(coreHandlerProvider);

  final _listController = TrackerInfoListController();
  final ScrollController _scrollController = ScrollController();
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

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: context.appLocalizations.closeConnections,
        onPressed: () async {
          unawaited(_core.closeConnections());
          await _refreshConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
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
    // sort by total traffic to keep the list stable between refreshes.
    final sorted = _withSpeeds(trackerInfos)
      ..sort((a, b) {
        final traffic = (b.upload + b.download).compareTo(
          a.upload + a.download,
        );
        if (traffic != 0) {
          return traffic;
        }
        final start = b.start.compareTo(a.start);
        return start != 0 ? start : a.id.compareTo(b.id);
      });
    _listController.setTrackerInfos(sorted);
  }

  Future<void> _handleBlockConnection(String id) async {
    await _core.closeConnection(id);
    await _refreshConnections();
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
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
      actions: _buildActions(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final connections = state.list;
          return NullStatusSwitcher(
            isEmpty: connections.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
              illustration: NullStatusIllustration.connections,
            ),
            child: TrackerInfoAnimatedList(
              controller: _scrollController,
              padding: EdgeInsets.only(top: context.appBarInset),
              trackerInfos: connections,
              detailTitle: appLocalizations.details(
                appLocalizations.connection,
              ),
              trailingBuilder: (trackerInfo) => IconButton(
                tooltip: appLocalizations.blockConnection,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.block, size: 20),
                onPressed: () {
                  _handleBlockConnection(trackerInfo.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
