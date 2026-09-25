import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DnsQueryListController extends ValueNotifier<DnsQueriesState> {
  DnsQueryListController() : super(const DnsQueriesState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void setUseRegex(bool useRegex) {
    value = value.copyWith(useRegex: useRegex);
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setDnsQueries(List<DnsQuery> dnsQueries) {
    if (identical(dnsQueries, value.dnsQueries)) {
      return;
    }
    value = value.copyWith(
      dnsQueries: value.autoScrollToEnd
          ? dnsQueries
          : retainTrimmedHead(
              value.dnsQueries,
              dnsQueries,
              pausedMaxDnsQueriesLength,
            ),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<DnsQuery> dnsQueries) {
    value = value.copyWith(autoScrollToEnd: true, dnsQueries: dnsQueries);
  }
}

class DnsQueriesView extends ConsumerStatefulWidget {
  const DnsQueriesView({super.key});

  @override
  ConsumerState<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends ConsumerState<DnsQueriesView> {
  final _listController = DnsQueryListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setDnsQueries(ref.read(dnsQueriesProvider).list);
    ref.listenManual(dnsQueriesProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      _updateThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateThrottler() {
    throttler.call(FunctionTag.dnsQueries, () {
      if (!mounted) {
        return;
      }
      _listController.setDnsQueries(ref.read(dnsQueriesProvider).list);
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      floatBody: true,
      title: appLocalizations.dnsQueries,
      searchState: AppBarSearchState(
        onSearch: _listController.search,
        onRegexChange: (value) {
          _listController.setUseRegex(value);
          setState(() {});
        },
        useRegex: _listController.value.useRegex,
      ),
      onKeywordsUpdate: _listController.updateKeywords,
      body: ValueListenableBuilder<DnsQueriesState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final dnsQueries = state.list;
          return NullStatusSwitcher(
            isEmpty: dnsQueries.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.dnsQueries),
              illustration: NullStatusIllustration.dns,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (dnsQueries.length - 1)).round();
                  return dnsQueries[index].time.showFull;
                },
                child: ScrollToEndBox(
                  controller: _scrollController,
                  dataSource: dnsQueries,
                  enable: state.autoScrollToEnd,
                  onCancelToEnd: () {
                    _listController.setAutoScrollToEnd(false);
                  },
                  onResumeToEnd: () {
                    _listController.resumeAutoScrollToEnd(
                      ref.read(dnsQueriesProvider).list,
                    );
                  },
                  child: DnsQueryList(
                    reverse: true,
                    shrinkWrap: true,
                    physics: const NextClampingScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: context.appBarInset,
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    dnsQueries: dnsQueries,
                    detailTitle: appLocalizations.details(
                      appLocalizations.dnsQueries,
                    ),
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

class DnsQueryList extends StatelessWidget {
  final List<DnsQuery> dnsQueries;
  final String detailTitle;
  final ScrollController? controller;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const DnsQueryList({
    super.key,
    required this.dnsQueries,
    required this.detailTitle,
    this.controller,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SuperListView.separated(
      reverse: reverse,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      padding: padding,
      itemCount: dnsQueries.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (_, index) {
        final dnsQuery = dnsQueries[index];
        return DnsQueryItem(
          dnsQuery: dnsQuery,
          detailTitle: detailTitle,
          onClickKeyword: (value) {
            context.commonScaffoldState?.addKeyword(value);
          },
        );
      },
    );
  }
}

enum _DnsStatus { resolved, cached, failed }

class _DnsStyle {
  final Color background;
  final Color foreground;
  final Glyph icon;

  const _DnsStyle(this.background, this.foreground, this.icon);
}

_DnsStatus _statusOf(DnsQuery dnsQuery) {
  if (dnsQuery.isFailed) {
    return _DnsStatus.failed;
  }
  if (dnsQuery.cached) {
    return _DnsStatus.cached;
  }
  return _DnsStatus.resolved;
}

_DnsStyle _dnsStyle(BuildContext context, _DnsStatus status) {
  final colorScheme = context.colorScheme;
  return switch (status) {
    _DnsStatus.resolved => _DnsStyle(
      colorScheme.primaryContainer,
      colorScheme.onPrimaryContainer,
      AppGlyphs.dns,
    ),
    _DnsStatus.cached => _DnsStyle(
      colorScheme.tertiaryContainer,
      colorScheme.onTertiaryContainer,
      AppGlyphs.bolt,
    ),
    _DnsStatus.failed => _DnsStyle(
      colorScheme.errorContainer,
      colorScheme.onErrorContainer,
      AppGlyphs.error,
    ),
  };
}

class DnsQueryItem extends StatelessWidget {
  final DnsQuery dnsQuery;
  final String detailTitle;
  final Function(String)? onClickKeyword;

  const DnsQueryItem({
    super.key,
    required this.dnsQuery,
    required this.detailTitle,
    this.onClickKeyword,
  });

  void _openDetail(BuildContext context) {
    showExtend(
      context,
      builder: (_) {
        return AdaptiveSheetScaffold(
          sheetTransparentToolBar: true,
          body: DnsQueryDetailView(dnsQuery: dnsQuery),
          title: detailTitle,
        );
      },
    );
  }

  String get _summary {
    if (dnsQuery.error.isNotEmpty) {
      return dnsQuery.error;
    }
    if (dnsQuery.answers.isNotEmpty) {
      return dnsQuery.answers.join(', ');
    }
    return dnsQuery.rcode.isEmpty ? '' : dnsQuery.rcode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final style = _dnsStyle(context, _statusOf(dnsQuery));
    final summary = _summary;
    final initiator = dnsQuery.initiator;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 14,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: style.background,
                  shape: AppShape.md,
                ),
                child: GlyphIcon(style.icon, size: 22, color: style.foreground),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      dnsQuery.domain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (dnsQuery.type.isNotEmpty)
                          CommonChip(
                            label: dnsQuery.type,
                            onPressed: () =>
                                onClickKeyword?.call(dnsQuery.type),
                          ),
                        if (initiator != null) MetaChip(label: initiator.label),
                        if (dnsQuery.cached)
                          MetaChip(label: appLocalizations.cache),
                        if (dnsQuery.hasFailureRcode)
                          _ToneTag(
                            label: dnsQuery.rcode,
                            background: colorScheme.errorContainer,
                            foreground: colorScheme.onErrorContainer,
                          ),
                      ],
                    ),
                    if (summary.isNotEmpty)
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: dnsQuery.isFailed
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    dnsQuery.time.getLastUpdateTimeDesc(context),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  if (dnsQuery.delay > 0)
                    Text(
                      '${dnsQuery.delay} ms',
                      style: context.textTheme.labelSmall?.toJetBrainsMono
                          .copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToneTag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _ToneTag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: background, shape: AppShape.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class DnsQueryDetailView extends StatelessWidget {
  final DnsQuery dnsQuery;

  const DnsQueryDetailView({super.key, required this.dnsQuery});

  List<Widget> _buildRows(List<(String, String)> entries) {
    return [
      for (final (title, value) in entries)
        if (value.isNotEmpty) DetailRow.text(title: title, value: value),
    ];
  }

  Widget _buildAnswers(BuildContext context) {
    return DecorationListItem(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Text(context.appLocalizations.answers),
          Flexible(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                for (final answer in dnsQuery.answers) MetaChip(label: answer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final initiator = dnsQuery.initiator;
    final delay = dnsQuery.delay > 0 ? '${dnsQuery.delay} ms' : '';
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ).copyWith(bottom: 20, top: context.sheetTopPadding),
      children: [
        generateSectionV3(
          title: appLocalizations.basicInfo,
          items: _buildRows([
            (appLocalizations.domain, dnsQuery.domain),
            (appLocalizations.recordType, dnsQuery.type),
            (appLocalizations.initiator, initiator?.label ?? ''),
            (appLocalizations.upstream, dnsQuery.upstream),
            (appLocalizations.responseCode, dnsQuery.rcode),
            (appLocalizations.error, dnsQuery.error),
            (appLocalizations.delay, delay),
            (appLocalizations.time, dnsQuery.time.showFull),
          ]),
        ),
        if (dnsQuery.answers.isNotEmpty)
          generateSectionV3(
            title: appLocalizations.answers,
            items: [_buildAnswers(context)],
          ),
      ],
    );
  }
}
