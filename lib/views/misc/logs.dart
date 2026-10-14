import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
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

class _LogsViewState extends ConsumerState<LogsView>
    with RouteMotionHoldMixin<LogsView> {
  final _listController = LogListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(
      context,
      initialScrollOffset: double.maxFinite,
    );
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
    ];
  }

  List<IconButtonData> _buildIconActions() {
    return [
      IconButtonData(
        glyph: AppGlyphs.export,
        tooltip: context.appLocalizations.exportLogs,
        onPressed: _handleExport,
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
      updateWhenRouteSettled(
        () => _listController.setLogs(ref.read(logsProvider).list),
      );
    }, duration: renderThrottleDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      actions: _buildActions(),
      iconActions: _buildIconActions(),
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
            isSearching: state.isSearching,
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
                    extentEstimation: zeroDividerExtentEstimation,
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
              ).withAppTooltip()
            : IconButton(
                tooltip: tooltip,
                onPressed: () => open(),
                icon: icon,
              ).withAppTooltip();
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
    final tone = switch (log.logLevel) {
      LogLevel.warning => RecordTone.warning,
      LogLevel.error => RecordTone.error,
      LogLevel.info => RecordTone.neutral,
      LogLevel.debug || LogLevel.silent => RecordTone.muted,
    };
    final payload = LogPayload.parse(log.payload);
    return RecordListItem(
      tone: tone,
      onTap: () {},
      header: RecordHeader(
        children: [
          RecordTimestamp(log.dateTime),
          RecordLabel(
            label: log.logLevel.name,
            tone: tone,
            onPressed: () => onClick?.call(log.logLevel.name),
          ),
          RecordLabel(label: log.source.name, tone: RecordTone.muted),
        ],
      ),
      body: _LogBody(payload: payload, errorColor: tone.accentColor(context)),
    );
  }
}

class _LogBody extends StatelessWidget {
  final LogPayload payload;
  final Color? errorColor;

  const _LogBody({required this.payload, this.errorColor});

  String get _sourceText => [
    payload.tag,
    if (payload.route case final route?) ...[route.source, route.sourceDetail],
  ].where((text) => text.isNotEmpty).join('  ·  ');

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final route = payload.route;
    if (route == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(payload.message, style: styles.primary),
          if (payload.tag.isNotEmpty) Text(payload.tag, style: styles.muted),
        ],
      );
    }
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: route.destination,
            style: styles.primary?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (route.error.isNotEmpty)
            TextSpan(
              text: '\n${route.error}',
              style: styles.secondary?.copyWith(color: errorColor),
            ),
          const TextSpan(text: '\n'),
          if (route.rule.isNotEmpty) ...[
            TextSpan(text: route.rule, style: styles.secondary),
            TextSpan(text: ' → ', style: styles.muted?.toJetBrainsMono),
          ],
          TextSpan(
            text: route.proxy,
            style: styles.secondary?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: '\n$_sourceText', style: styles.muted),
        ],
      ),
    );
  }
}
