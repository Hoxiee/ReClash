import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class LogListController extends ValueNotifier<LogsState> {
  LogListController() : super(const LogsState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setUseRegex(bool useRegex) {
    value = value.copyWith(useRegex: useRegex);
  }

  void toggleSource(LogSource source) {
    value = value.toggleSource(source);
  }

  void toggleLevel(LogLevel level) {
    value = value.toggleLevel(level);
  }

  void clearFilters() {
    value = value.clearFilters();
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setLogs(List<Log> logs) {
    if (identical(logs, value.logs)) {
      return;
    }
    value = value.copyWith(
      logs: value.autoScrollToEnd
          ? logs
          : retainTrimmedHead(value.logs, logs, pausedMaxLogsLength),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<Log> logs) {
    value = value.copyWith(autoScrollToEnd: true, logs: logs);
  }
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  final _listController = LogListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setLogs(ref.read(logsProvider).list);
    ref.listenManual(logsProvider.select((state) => state.revision), (_, _) {
      updateLogsThrottler();
    });
  }

  List<Widget> _buildActions() {
    return [
      ValueListenableBuilder<LogsState>(
        valueListenable: _listController,
        builder: (_, state, _) => _LogFilterButton(
          logsState: state,
          onToggleSource: _listController.toggleSource,
          onToggleLevel: _listController.toggleLevel,
          onClear: _listController.clearFilters,
        ),
      ),
      IconButton(
        tooltip: context.appLocalizations.exportLogs,
        onPressed: () {
          _handleExport();
        },
        icon: const Icon(Icons.save_as_outlined),
      ),
    ];
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      return ref.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    unawaited(
      dialogs.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.exportSuccess),
      ),
    );
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      _listController.setLogs(ref.read(logsProvider).list);
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      actions: _buildActions(),
      onKeywordsUpdate: _listController.updateKeywords,
      searchState: AppBarSearchState(
        onSearch: _listController.search,
        onRegexChange: (value) {
          _listController.setUseRegex(value);
          setState(() {});
        },
        useRegex: _listController.value.useRegex,
      ),
      title: appLocalizations.logs,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _listController,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FloatingActionButton(
            tooltip: autoScrollToEnd
                ? appLocalizations.pause
                : appLocalizations.resume,
            onPressed: () {
              if (autoScrollToEnd) {
                _listController.setAutoScrollToEnd(false);
              } else {
                _listController.resumeAutoScrollToEnd(
                  ref.read(logsProvider).list,
                );
              }
            },
            child: FadeRotationScaleBox(
              child: autoScrollToEnd
                  ? const Icon(Icons.block, key: ValueKey('pause'))
                  : const Icon(
                      Icons.vertical_align_top,
                      key: ValueKey('resume'),
                    ),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<LogsState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final logs = state.list;
          return NullStatusSwitcher(
            isEmpty: logs.isEmpty,
            nullStatus: NullStatus(
              illustration: NullStatusIllustration.logs,
              label: appLocalizations.nullTip(appLocalizations.logs),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (logs.length - 1)).round();
                  return logs[index].dateTime;
                },
                child: ScrollToEndBox(
                  onCancelToEnd: () {
                    _listController.setAutoScrollToEnd(false);
                  },
                  controller: _scrollController,
                  enable: state.autoScrollToEnd,
                  dataSource: logs,
                  child: SuperListView.separated(
                    physics: const NextClampingScrollPhysics(),
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 0),
                    itemBuilder: (_, index) {
                      final log = logs[index];
                      return LogItem(
                        log: log,
                        onClick: (value) {
                          context.commonScaffoldState?.addKeyword(value);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogFilterButton extends StatelessWidget {
  final LogsState logsState;
  final ValueChanged<LogSource> onToggleSource;
  final ValueChanged<LogLevel> onToggleLevel;
  final VoidCallback onClear;

  const _LogFilterButton({
    required this.logsState,
    required this.onToggleSource,
    required this.onToggleLevel,
    required this.onClear,
  });

  String _label(Enum value, bool selected) {
    return '${selected ? '✓ ' : ''}${value.name.toUpperCase()}';
  }

  List<CommonPopupMenuItem> _buildItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        icon: Icons.source_outlined,
        label: appLocalizations.source,
        subItems: [
          for (final source in LogSource.values)
            CommonPopupMenuItem(
              label: _label(source, logsState.sources.contains(source)),
              onPressed: () => onToggleSource(source),
            ),
        ],
      ),
      CommonPopupMenuItem(
        icon: Icons.flag_outlined,
        label: appLocalizations.level,
        subItems: [
          for (final level in LogLevel.values)
            if (level != LogLevel.silent)
              CommonPopupMenuItem(
                label: _label(level, logsState.levels.contains(level)),
                onPressed: () => onToggleLevel(level),
              ),
        ],
      ),
      CommonPopupMenuItem(
        icon: Icons.filter_alt_off_outlined,
        label: appLocalizations.reset,
        onPressed: onClear,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = context.appLocalizations.filter;
    return CommonPopupBox(
      popupBuilder: (_) => CommonPopupMenu(items: _buildItems(context)),
      targetBuilder: (open) {
        const icon = Icon(Icons.filter_alt_outlined);
        return logsState.hasFilters
            ? IconButton.filledTonal(
                tooltip: tooltip,
                onPressed: () => open(),
                icon: icon,
              )
            : IconButton(tooltip: tooltip, onPressed: () => open(), icon: icon);
      },
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;

  const LogItem({super.key, required this.log, this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ).copyWith(bottom: 12),
      onTap: () {},
      minVerticalPadding: 0,
      title: SelectableText(
        log.payload,
        style: context.textTheme.bodyLarge?.copyWith(
          color: log.logLevel.color(context),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonChip(
              label: log.logLevel.name,
              onPressed: () => onClick?.call(log.logLevel.name),
            ),
            Flexible(
              child: Text(
                log.dateTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
