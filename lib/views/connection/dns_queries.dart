import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
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
  const DnsQueriesView({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<DnsQueriesView> createState() => _DnsQueriesViewState();
}

class _DnsQueriesViewState extends ConsumerState<DnsQueriesView> {
  final _listController = DnsQueryListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        widget.scrollController ??
        ScrollController(initialScrollOffset: double.maxFinite);
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
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final styles = RecordTextStyles.of(context);
    final summary = dnsQuery.error.isNotEmpty
        ? dnsQuery.error
        : dnsQuery.answers.join(', ');
    return RecordListItem(
      isError: dnsQuery.isFailed,
      onTap: () => _openDetail(context),
      header: RecordHeader(
        trailing: Text('${dnsQuery.delay} ms'),
        children: [
          RecordTimestamp(dnsQuery.time.showFull),
          if (dnsQuery.type.isNotEmpty)
            AppTag.compact(
              dnsQuery.type,
              onTap: () => onClickKeyword?.call(dnsQuery.type),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Text(
            dnsQuery.domain,
            style: styles.primary?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (summary.isNotEmpty)
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.secondary?.copyWith(
                color: dnsQuery.isFailed ? colorScheme.error : null,
              ),
            ),
          Wrap(
            spacing: 6,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in dnsQuery.resultTags)
                AppTag.compact(
                  tag,
                  background: dnsQuery.hasFailureRcode && tag == dnsQuery.rcode
                      ? colorScheme.errorContainer
                      : null,
                  foreground: dnsQuery.hasFailureRcode && tag == dnsQuery.rcode
                      ? colorScheme.onErrorContainer
                      : null,
                  onTap: () => onClickKeyword?.call(tag),
                ),
              if (dnsQuery.upstream.isNotEmpty)
                Text(dnsQuery.upstream, style: styles.muted),
            ],
          ),
        ],
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
      ).copyWith(bottom: 20, top: context.appBarInset),
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
