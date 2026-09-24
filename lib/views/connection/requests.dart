import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/views/views.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView> {
  final _listController = TrackerInfoListController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setTrackerInfos(ref.read(requestsProvider).list);
    ref.listenManual(requestsProvider.select((state) => state.revision), (
      _,
      _,
    ) {
      updateRequestsThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void updateRequestsThrottler() {
    throttler.call(FunctionTag.requests, () {
      if (!mounted) {
        return;
      }
      _listController.setTrackerInfos(ref.read(requestsProvider).list);
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.requests,
      floatBody: true,
      searchState: AppBarSearchState(
        onSearch: _listController.search,
        onRegexChange: (value) {
          _listController.setUseRegex(value);
          setState(() {});
        },
        useRegex: _listController.value.useRegex,
      ),
      onKeywordsUpdate: _listController.updateKeywords,
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
                  ref.read(requestsProvider).list,
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
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final requests = state.list;
          return NullStatusSwitcher(
            isEmpty: requests.isEmpty,
            nullStatus: NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
              illustration: NullStatusIllustration.requests,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: FloatingScrollbar(
                controller: _scrollController,
                hintBuilder: (fraction) {
                  final index = (fraction * (requests.length - 1)).round();
                  return requests[index].start.showFull;
                },
                child: ScrollToEndBox(
                  controller: _scrollController,
                  dataSource: requests,
                  enable: state.autoScrollToEnd,
                  onCancelToEnd: () {
                    _listController.setAutoScrollToEnd(false);
                  },
                  child: TrackerInfoList(
                    reverse: true,
                    shrinkWrap: true,
                    physics: const NextClampingScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: context.appBarInset,
                      bottom: 16 + BottomInsetScope.of(context),
                    ),
                    trackerInfos: requests,
                    detailTitle: appLocalizations.details(
                      appLocalizations.request,
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
