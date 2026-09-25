import 'dart:async';
import 'package:reclash/icons/icons.dart';

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
        icon: const GlyphIcon(AppGlyphs.save),
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
      title: appLocalizations.logs,
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
                  onResumeToEnd: () {
                    _listController.resumeAutoScrollToEnd(
                      ref.read(logsProvider).list,
                    );
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
                      top: context.appBarInset,
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

  CommonPopupMenuItem _optionItem(
    Enum value,
    bool selected,
    VoidCallback onPressed,
  ) {
    return CommonPopupMenuItem(
      glyph: selected ? AppGlyphs.check : AppGlyphs.checkboxBlank,
      label: value.name.toUpperCase(),
      onPressed: onPressed,
    );
  }

  List<CommonPopupMenuItem> _buildItems(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.code,
        label: appLocalizations.source,
        subItems: [
          for (final source in LogSource.values)
            _optionItem(
              source,
              logsState.sources.contains(source),
              () => onToggleSource(source),
            ),
        ],
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.flag,
        label: appLocalizations.level,
        subItems: [
          for (final level in LogLevel.values)
            if (level != LogLevel.silent)
              _optionItem(
                level,
                logsState.levels.contains(level),
                () => onToggleLevel(level),
              ),
        ],
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.filter,
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
        const icon = GlyphIcon(AppGlyphs.filter);
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

  (String date, String time) _splitDateTime() {
    final parts = log.dateTime.split(' ');
    if (parts.length >= 2) {
      return (parts.first, parts.sublist(1).join(' '));
    }
    return ('', log.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final level = log.logLevel;
    final accent = level.accentColor(context);
    final emphasized = level == LogLevel.error || level == LogLevel.warning;
    final (date, time) = _splitDateTime();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized ? accent.opacity3 : null,
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 10, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppTag(
                  level.name,
                  uppercase: true,
                  foreground: level.onBadgeColor(context),
                  background: level.badgeColor(context),
                  letterSpacing: 0.4,
                  onTap: () => onClick?.call(level.name),
                ),
                AppTag(
                  log.source.name,
                  uppercase: true,
                  letterSpacing: 0.4,
                  side: BorderSide(color: context.colorScheme.outlineVariant),
                ),
                const Spacer(),
                _TimeLabel(date: date, time: time),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SelectableText(
              log.payload,
              style: context.textTheme.bodyMedium
                  ?.copyWith(
                    color: level == LogLevel.silent
                        ? colorScheme.outline
                        : colorScheme.onSurface,
                    height: 1.35,
                  )
                  .toJetBrainsMono,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String date;
  final String time;

  const _TimeLabel({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant)
              .toJetBrainsMono,
        ),
        if (date.isNotEmpty)
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall
                ?.copyWith(color: colorScheme.outline)
                .toJetBrainsMono,
          ),
      ],
    );
  }
}
