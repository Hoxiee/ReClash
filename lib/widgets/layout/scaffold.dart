import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/base/pop_scope.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';

import '../base/inherited.dart';
import '../feedback/loading.dart';
import '../input/button.dart';
import '../input/chip.dart';
import '../nav/app_nav_bar.dart';
import '../theme/panel_background.dart';
import '../theme/wallpaper.dart';
import 'floating_header.dart';
import 'popup.dart';
import 'sheet.dart';

typedef OnKeywordsUpdateCallback = void Function(List<String> keywords);

typedef AppBarSearchStateBuilder =
    AppBarSearchState? Function(AppBarSearchState? state);

class CommonScaffold extends ConsumerStatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Color? backgroundColor;
  final String? title;
  final Widget? titleWidget;
  final bool isLoading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;
  final bool? isTV;
  final AppBarEditState? editState;
  final AppBarSearchState? searchState;
  final OnKeywordsUpdateCallback? onKeywordsUpdate;
  final bool? resizeToAvoidBottomInset;

  /// When true the body reaches under the floating bar and owns its own
  /// top clearance via `context.appBarInset`; otherwise the scaffold insets
  /// the body so its content rests below the bar.
  final bool floatBody;

  /// A page's chief action: a FAB on its own, riding into the bar where a dock owns the FAB corner.
  final IconButtonData? primaryAction;
  final bool foldPrimaryAction;

  /// Keeps [primaryAction] a standalone button pinned to the leading edge of
  /// the action cluster, exempt from folding and never merged into the group.
  final bool pinPrimaryAction;

  /// Pins [primaryAction] to the trailing edge of the cluster rather than the
  /// leading one; only meaningful together with [pinPrimaryAction].
  final bool pinPrimaryActionTrailing;
  final List<IconButtonData> iconActions;
  final List<CommonPopupMenuItem> menuItems;
  final List<IconButtonData> searchActions;
  final List<IconButtonData> selectionActions;
  final VoidCallback? backAction;

  const CommonScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle,
    this.editState,
    this.isLoading = false,
    this.searchState,
    this.floatingActionButton,
    this.isTV,
    this.onKeywordsUpdate,
    this.resizeToAvoidBottomInset,
    this.floatBody = false,
    this.primaryAction,
    this.foldPrimaryAction = false,
    this.pinPrimaryAction = false,
    this.pinPrimaryActionTrailing = false,
    this.iconActions = const [],
    this.menuItems = const [],
    this.searchActions = const [],
    this.selectionActions = const [],
    this.backAction,
  });

  @override
  ConsumerState<CommonScaffold> createState() => CommonScaffoldState();
}

class CommonScaffoldState extends ConsumerState<CommonScaffold> {
  late final ValueNotifier<AppBarState> _appBarState;
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isFabExtendedNotifier = ValueNotifier(true);
  final ValueNotifier<List<String>> _keywordsNotifier = ValueNotifier([]);
  final _textController = TextEditingController();
  final _searchFocusNode = FocusNode();

  // The pane bar this scaffold last fed and the widget it fed, so a rebuild
  // only republishes when the actions widget actually changes and dispose can
  // tell whether it is still the one on screen.
  ValueNotifier<Widget?>? _relaySink;
  Widget? _relayedActions;

  bool get _isSearch {
    return _appBarState.value.searchState?.query != null;
  }

  bool get _isEdit {
    final editState = _appBarState.value.editState;
    if (editState == null) {
      return false;
    }
    return editState.editCount > 0;
  }

  bool get _hasActions {
    return _appBarState.value.searchState != null ||
        widget.primaryAction != null ||
        widget.iconActions.isNotEmpty ||
        widget.menuItems.isNotEmpty ||
        widget.selectionActions.isNotEmpty ||
        widget.actions?.isNotEmpty == true;
  }

  @override
  void initState() {
    super.initState();
    _appBarState = ValueNotifier(
      AppBarState(editState: widget.editState, searchState: widget.searchState),
    );
    _loadingNotifier.value = widget.isLoading;
  }

  Future<void> _updateSearchState(AppBarSearchStateBuilder builder) async {
    _appBarState.value = _appBarState.value.copyWith(
      searchState: builder(_appBarState.value.searchState),
    );
  }

  void handleToSearch() {
    _updateSearchState((state) => state?.copyWith(query: ''));
  }

  Widget _buildSearchingAppBarTheme(Widget child) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: colorScheme.surface,
          iconTheme: theme.primaryIconTheme.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          titleTextStyle: theme.textTheme.titleLarge,
          toolbarTextStyle: theme.textTheme.bodyMedium,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: InputBorder.none,
        ),
      ),
      child: child,
    );
  }

  @override
  void didUpdateWidget(CommonScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editState != widget.editState) {
      _appBarState.value = _appBarState.value.copyWith(
        editState: widget.editState,
      );
    }
    if (oldWidget.searchState != widget.searchState) {
      // A view republishes its search state (e.g. flipping useRegex) with a
      // fresh onRegexChange closure and a null query, so carry the live query
      // forward or the open search would collapse on every such rebuild.
      final query = _appBarState.value.searchState?.query;
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState?.copyWith(query: query),
      );
    }
    if (oldWidget.isLoading != widget.isLoading) {
      _loadingNotifier.value = widget.isLoading;
    }
  }

  void _handleClearInput() {
    _textController.text = '';
    if (_appBarState.value.searchState != null) {
      _appBarState.value.searchState!.onSearch('');
    }
  }

  void _handleClear() {
    if (_textController.text.isNotEmpty) {
      _handleClearInput();
      return;
    }
    _popAppBarLayer();
  }

  void handleExitSearching() {
    if (!_isSearch) {
      return;
    }
    _handleClearInput();
    _updateSearchState((state) => state?.copyWith(query: null));
  }

  void _handleExitAppBarLayer() {
    handleExitSearching();
    if (_isEdit) {
      _appBarState.value.editState?.onExit();
    }
  }

  void _popAppBarLayer() {
    if (!_isEdit && !_isSearch) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Stop feeding a shared pane bar that outlives this scaffold, or it would
    // keep painting a disposed tool's actions.
    final relaySink = _relaySink;
    if (relaySink != null && relaySink.value == _relayedActions) {
      relaySink.value = null;
    }
    _appBarState.dispose();
    _textController.dispose();
    _searchFocusNode.dispose();
    _isFabExtendedNotifier.dispose();
    _loadingNotifier.dispose();
    _keywordsNotifier.dispose();
    super.dispose();
  }

  void addKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)..add(keyword);
    _keywordsNotifier.value = keywords;
  }

  void _deleteKeyword(String keyword) {
    final isContains = _keywordsNotifier.value.contains(keyword);
    if (!isContains) return;
    final keywords = List<String>.from(_keywordsNotifier.value)
      ..remove(keyword);
    _keywordsNotifier.value = keywords;
  }

  Widget _buildSheetPopButton(
    VoidCallback? backAction, {
    required bool useCloseIcon,
  }) {
    final appLocalizations = context.appLocalizations;
    return AppBarActionButton(
      data: useCloseIcon
          ? IconButtonData(
              glyph: AppGlyphs.close,
              onPressed: context.safeNestedPop,
              tooltip: appLocalizations.close,
            )
          : IconButtonData(
              glyph: AppGlyphs.backFor(Theme.of(context).platform),
              onPressed: backAction ?? () => Navigator.of(context).pop(),
              tooltip: appLocalizations.back,
            ),
    );
  }

  Widget? _buildLeading(VoidCallback? backAction, {required _SheetPop? pop}) {
    final button = _buildLeadingButton(backAction, pop: pop);
    return button == null ? null : Center(child: ElasticPress(child: button));
  }

  Widget? _buildLeadingButton(
    VoidCallback? backAction, {
    required _SheetPop? pop,
  }) {
    if (_isEdit) {
      return IconButton(
        tooltip: context.appLocalizations.close,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.close),
      ).withAppTooltip();
    }
    if (_isSearch) {
      return IconButton(
        tooltip: context.appLocalizations.back,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.arrowBack),
      ).withAppTooltip();
    }
    if (pop != null) {
      return pop.asSuffix
          ? null
          : _buildSheetPopButton(backAction, useCloseIcon: pop.useCloseIcon);
    }
    return backAction != null
        ? BackButton(
            onPressed: () {
              if (!mounted) {
                return;
              }
              backAction();
            },
          ).withAppTooltip(context.appLocalizations.back)
        : _autoLeadingButton();
  }

  /// Built by hand, not by `automaticallyImplyLeading`, so it can ride inside
  /// [ElasticPress].
  Widget? _autoLeadingButton() {
    final route = ModalRoute.of(context);
    if (route?.impliesAppBarDismissal != true) {
      return null;
    }
    return route is PageRoute && route.fullscreenDialog
        ? (const CloseButton()).withAppTooltip(context.appLocalizations.close)
        : (const BackButton()).withAppTooltip(context.appLocalizations.back);
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    if (_isSearch) {
      return _buildSearchField(startState);
    }
    if (_isEdit) {
      return Text(
        context.appLocalizations.selectedCountTitle(
          '${_appBarState.value.editState?.editCount ?? 0}',
        ),
      );
    }
    return widget.titleWidget ?? Text(widget.title!);
  }

  /// The searching title: a filled pill that reveals out of the search button,
  /// its regex toggle moved into the action group beside the close button.
  Widget _buildSearchField(AppBarSearchState? startState) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return _SearchFieldReveal(
      color: colorScheme.surfaceContainerHigh,
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          GlyphIcon(
            AppGlyphs.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _textController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              inputFormatters: TextInputLimits.limit(TextInputLimits.search),
              style: context.textTheme.bodyLarge,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (value) {
                if (startState != null) {
                  startState.onSearch(value);
                }
              },
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: appLocalizations.search,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    IconButtonData? primaryAction,
    List<Widget> legacyActions,
    _SheetForm form,
    VoidCallback? backAction,
    AppBarSearchState? searchState,
  ) {
    final appLocalizations = context.appLocalizations;
    if (_isSearch) {
      return _buildSearchActions(searchState);
    }
    final pop = form.pop;
    final hasSearchButton = searchState != null && searchState.autoAddSearch;
    final lead = hasSearchButton
        ? IconButtonData(
            glyph: AppGlyphs.search,
            tooltip: appLocalizations.search,
            onPressed: handleToSearch,
          )
        : null;
    final pinPrimary = widget.pinPrimaryAction && primaryAction != null;
    final pinPrimaryTrailing = pinPrimary && widget.pinPrimaryActionTrailing;
    final pinPrimaryLeading = pinPrimary && !widget.pinPrimaryActionTrailing;
    final selection = widget.selectionActions;
    final selectionCount = selection.isEmpty ? 0 : 1;
    final fold = _foldBarActions(
      hasLead: lead != null,
      primary: pinPrimary ? null : primaryAction,
      foldPrimary: widget.foldPrimaryAction,
      icons: widget.iconActions,
      widgetCount: legacyActions.length + selectionCount,
      menuItems: widget.menuItems,
    );
    final shown = [?lead, ...fold.shown];
    final grouped = shown.length > 1 ? shown.take(_maxGroupedActions) : null;
    final searchWithOverflow =
        grouped == null &&
        lead != null &&
        fold.shown.isEmpty &&
        fold.overflow.isNotEmpty;
    // A lone action reads as a bare icon beside the overflow dots; fold the two
    // into one capsule so the bar matches the grouped multi-action clusters.
    final actionWithOverflow =
        grouped == null &&
        !searchWithOverflow &&
        shown.isNotEmpty &&
        fold.overflow.isNotEmpty;
    final popAsSuffix = !_isEdit && pop?.asSuffix == true;
    return genActions([
      if (pinPrimaryLeading)
        ElasticPress(
          enabled: !primaryAction.isLoading,
          child: AppBarActionButton(data: primaryAction),
        ),
      if (grouped != null)
        TonalButtonGroup(
          children: [
            for (final data in grouped) AppBarActionButton(data: data),
          ],
        ),
      if (searchWithOverflow)
        TonalButtonGroup(
          children: [
            AppBarActionButton(data: lead),
            _OverflowMenuButton(items: fold.overflow),
          ],
        ),
      if (actionWithOverflow)
        TonalButtonGroup(
          children: [
            for (final data in shown) AppBarActionButton(data: data),
            _OverflowMenuButton(items: fold.overflow),
          ],
        ),
      for (final data in shown.skip(
        grouped?.length ??
            (searchWithOverflow
                ? 1
                : actionWithOverflow
                ? shown.length
                : 0),
      ))
        ElasticPress(
          enabled: !data.isLoading,
          child: AppBarActionButton(data: data),
        ),
      if (selection.isNotEmpty)
        TonalButtonGroup(
          children: [
            for (final data in selection) AppBarActionButton(data: data),
          ],
        ),
      if (pinPrimaryTrailing)
        ElasticPress(
          enabled: !primaryAction.isLoading,
          child: AppBarActionButton(data: primaryAction),
        ),
      for (final action in legacyActions) ElasticPress(child: action),
      if (fold.overflow.isNotEmpty &&
          !searchWithOverflow &&
          !actionWithOverflow)
        ElasticPress(child: _OverflowMenuButton(items: fold.overflow)),
      if (popAsSuffix)
        ElasticPress(
          child: _buildSheetPopButton(
            backAction,
            useCloseIcon: pop!.useCloseIcon,
          ),
        ),
    ], edge: AppBarActionEdge.container);
  }

  /// The searching action cluster: the regex toggle folds into one pill with
  /// the close button, so the extra controls read as a single grouped capsule.
  List<Widget> _buildSearchActions(AppBarSearchState? searchState) {
    final appLocalizations = context.appLocalizations;
    final onRegexChange = searchState?.onRegexChange;
    final close = IconButtonData(
      glyph: AppGlyphs.close,
      tooltip: appLocalizations.clearSearch,
      onPressed: _handleClear,
    );
    return genActions([
      if (onRegexChange != null)
        TonalButtonGroup(
          children: [
            _RegexToggleButton(
              active: searchState!.useRegex,
              onChanged: (value) => onRegexChange(value),
            ),
            AppBarActionButton(data: close),
          ],
        )
      else
        ElasticPress(child: AppBarActionButton(data: close)),
      for (final data in widget.searchActions)
        ElasticPress(child: AppBarActionButton(data: data)),
    ], edge: AppBarActionEdge.container);
  }

  Widget _buildAppBarWrap(Widget child) {
    final appBar = TonalButtonTheme(
      child: _isSearch ? _buildSearchingAppBarTheme(child) : child,
    );
    if (_isEdit || _isSearch) {
      return BackLayerScope(onBack: _handleExitAppBarLayer, child: appBar);
    }
    return appBar;
  }

  Widget _buildFloatingHeader(Widget appBar) {
    final top = MediaQuery.paddingOf(context).top;
    return FloatingHeader(
      backgroundColor: widget.backgroundColor ?? context.colorScheme.surface,
      fadeStart: top / (top + pageToolbarHeight),
      overhang: _headerOverhang,
      child: appBar,
    );
  }

  PreferredSizeWidget _buildAppBar(
    VoidCallback? backAction,
    _SheetForm form, {
    required IconButtonData? primaryAction,
  }) {
    final isBottomSheet = form.isBottomSheet;
    return PreferredSize(
      preferredSize: Size.fromHeight(
        isBottomSheet ? sheetToolbarHeight : pageToolbarHeight,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          widget.appBar ??
              ValueListenableBuilder<AppBarState>(
                valueListenable: _appBarState,
                builder: (_, state, _) {
                  final appBar = _buildAppBarWrap(
                    AppBar(
                      clipBehavior: Clip.none,
                      animateColor: true,
                      toolbarHeight: isBottomSheet
                          ? sheetToolbarHeight
                          : pageToolbarHeight,
                      automaticallyImplyLeading: false,
                      leadingWidth: appBarLeadingWidth(
                        _isCompactBar(context, context.isMobileView),
                      ),
                      // Float over the body, opaque only while searching; a
                      // sheet's own scrim carries the tint, so stay clear.
                      forceMaterialTransparency: isBottomSheet || !_isSearch,
                      centerTitle:
                          !_isSearch && (widget.centerTitle ?? isBottomSheet),
                      titleTextStyle: isBottomSheet
                          ? context.textTheme.titleLarge?.adjustSize(-4)
                          : null,
                      leading: _buildLeading(backAction, pop: form.pop),
                      title: _buildTitle(state.searchState),
                      actions: _buildActions(
                        primaryAction,
                        state.actions.isNotEmpty
                            ? state.actions
                            : widget.actions ?? const [],
                        form,
                        backAction,
                        state.searchState,
                      ),
                    ),
                  );
                  return isBottomSheet ? appBar : _buildFloatingHeader(appBar);
                },
              ),
          ValueListenableBuilder(
            valueListenable: _loadingNotifier,
            builder: (_, value, _) {
              return value == true
                  ? const LinearProgressIndicator()
                  : Container();
            },
          ),
        ],
      ),
    );
  }

  /// A chrome-suppressed pane keeps no app bar of its own, so its actions are
  /// built here and handed to the shared bar. The result stays reactive to
  /// edit/search/loading through the same [_appBarState] the real bar reads.
  Widget _relayActions(
    _SheetForm form,
    VoidCallback? backAction,
    IconButtonData? primaryAction,
  ) {
    return ValueListenableBuilder<AppBarState>(
      valueListenable: _appBarState,
      builder: (_, state, _) {
        final actions = _buildActions(
          primaryAction,
          state.actions.isNotEmpty ? state.actions : widget.actions ?? const [],
          form,
          backAction,
          state.searchState,
        );
        if (actions.isEmpty) {
          return const SizedBox.shrink();
        }
        return TonalButtonTheme(
          child: Row(mainAxisSize: MainAxisSize.min, children: actions),
        );
      },
    );
  }

  void _publishRelayActions(Widget actions, ValueNotifier<Widget?> sink) {
    _relaySink = sink;
    _relayedActions = actions;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _relayedActions == actions) {
        sink.value = actions;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.appBar != null || widget.title != null || widget.titleWidget != null,
    );
    final backActionProvider = CommonScaffoldBackActionProvider.of(context);
    final backAction = widget.backAction ?? backActionProvider?.backAction;
    final form = _SheetForm.of(context, hasActions: _hasActions);
    final isBottomSheet = form.isBottomSheet;
    final isTV = widget.isTV ?? system.isTV;
    final bottomInset = BottomInsetScope.of(context);
    final primaryAction = widget.primaryAction;
    final actionInBar = isBottomSheet || (!isTV && DockedPageScope.of(context));
    final fabSlot = actionInBar
        ? null
        : widget.floatingActionButton ??
              (primaryAction == null
                  ? null
                  : _PrimaryActionFab(data: primaryAction));
    final hasFab = !isTV && fabSlot != null;
    final appBar = _buildAppBar(
      backAction,
      form,
      primaryAction: actionInBar ? primaryAction : null,
    );
    final fabChild = ValueListenableBuilder<bool>(
      valueListenable: _isFabExtendedNotifier,
      builder: (_, isExtended, child) {
        return CommonScaffoldFabExtendedProvider(
          isExtended: isExtended,
          child: child!,
        );
      },
      child: fabSlot,
    );
    final fab = hasFab
        ? bottomInset > 0
              ? Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: fabChild,
                )
              : fabChild
        : null;
    if (isBottomSheet) {
      return _buildBottomSheet(
        backAction: backAction,
        appBar: appBar,
        hasFab: hasFab,
        bottomInset: bottomInset,
        fab: fab,
        form: form,
      );
    }
    // Inside a list-detail pane that already draws its own heading, drop the
    // app bar and top inset so the tool body sits flush under the shared bar.
    if (ToolsPaneChrome.suppressOf(context)) {
      final sink = ToolsPaneChrome.actionsSinkOf(context);
      if (sink != null) {
        _publishRelayActions(
          _relayActions(form, backAction, actionInBar ? primaryAction : null),
          sink,
        );
      }
      final chromelessBody = MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FloatingBarScope(
          inset: 0,
          child: DockedPageScope(
            docked: false,
            child: hasFab
                ? BottomInsetScope(
                    inset:
                        bottomInset +
                        BottomInsetScope.floatingActionButtonInset,
                    child: widget.body,
                  )
                : widget.body,
          ),
        ),
      );
      // Stay transparent: the outer shell already paints the wallpaper, so a
      // second one here would seam against it at the pane divider.
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: chromelessBody,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        floatingActionButton: fab,
      );
    }
    final barFloats = widget.appBar == null;
    final appBarInset = MediaQuery.paddingOf(context).top + pageToolbarHeight;
    final scrollsUnder = barFloats && widget.floatBody;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTV && fabSlot != null)
          Padding(
            padding: AppInsets.lg,
            child: CommonScaffoldFabExtendedProvider(
              isExtended: true,
              child: fabSlot,
            ),
          ),
        ValueListenableBuilder(
          valueListenable: _keywordsNotifier,
          builder: (_, keywords, _) {
            if (widget.onKeywordsUpdate != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onKeywordsUpdate!(keywords);
              });
            }
            if (keywords.isEmpty) {
              return const SizedBox();
            }
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: scrollsUnder ? appBarInset + 16 : 16,
                bottom: 16,
              ),
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  for (final keyword in keywords)
                    CommonChip(
                      label: keyword,
                      onDeleted: () {
                        _deleteKeyword(keyword);
                      },
                    ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: scrollsUnder
              ? ValueListenableBuilder<List<String>>(
                  valueListenable: _keywordsNotifier,
                  builder: (context, keywords, child) {
                    if (keywords.isEmpty) {
                      return child!;
                    }
                    return MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: FloatingBarScope(inset: 0, child: child!),
                    );
                  },
                  child: widget.body,
                )
              : widget.body,
        ),
      ],
    );
    final body = SafeArea(
      top: !barFloats,
      // A side sheet floats as a card offset from the trailing edge; its
      // leading edge sits deep in the screen, far from any left display
      // cutout, so honoring that cutout here only doubles the left padding.
      left: !form.isSideSheet,
      child: FloatingBarScope(
        inset: appBarInset,
        child: barFloats && !widget.floatBody
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Padding(
                  padding: EdgeInsets.only(top: appBarInset),
                  child: content,
                ),
              )
            : content,
      ),
    );
    final foreground = NotificationListener<UserScrollNotification>(
      child: DockedPageScope(
        docked: false,
        child: hasFab
            ? BottomInsetScope(
                inset: bottomInset + BottomInsetScope.floatingActionButtonInset,
                child: body,
              )
            : body,
      ),
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse) {
          _isFabExtendedNotifier.value = false;
        } else if (notification.direction == ScrollDirection.forward) {
          _isFabExtendedNotifier.value = true;
        }
        return true;
      },
    );
    return AppWallpaper(
      builder: (context, active) => Scaffold(
        appBar: appBar,
        extendBodyBehindAppBar: barFloats,
        body: PanelProfileBackground(enabled: !active, child: foreground),
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        backgroundColor: active || form.isSideSheet
            ? Colors.transparent
            : widget.backgroundColor,
        floatingActionButton: fab,
      ),
    );
  }

  /// Renders the modal bottom-sheet form: the toolbar folds into a floating,
  /// fading header over the body, matching every other sheet. A snap sheet
  /// (one that brings a [SheetOverhangScope]) fills its detent and clips its
  /// own corners; any other sheet hugs its content and clips here.
  Widget _buildBottomSheet({
    required VoidCallback? backAction,
    required PreferredSizeWidget appBar,
    required bool hasFab,
    required double bottomInset,
    required Widget? fab,
    required _SheetForm form,
  }) {
    final hugsContent = SheetOverhangScope.of(context) == null;
    const overlap = sheetAppBarHeight;
    final sheetContent = ValueListenableBuilder(
      valueListenable: _keywordsNotifier,
      builder: (context, keywords, _) {
        if (widget.onKeywordsUpdate != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onKeywordsUpdate!(keywords);
          });
        }
        final Widget clearBody = keywords.isNotEmpty
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: FloatingBarScope(inset: 0, child: widget.body),
              )
            : widget.floatBody
            ? widget.body
            : MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: overlap),
                  child: widget.body,
                ),
              );
        return FloatingBarScope(
          inset: overlap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hugsContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (keywords.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, overlap, 16, 16),
                  child: Wrap(
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      for (final keyword in keywords)
                        CommonChip(
                          label: keyword,
                          onDeleted: () {
                            _deleteKeyword(keyword);
                          },
                        ),
                    ],
                  ),
                ),
              Flexible(
                fit: hugsContent ? FlexFit.loose : FlexFit.tight,
                child: clearBody,
              ),
            ],
          ),
        );
      },
    );
    final insetContent = sheetContent;
    final foreground = NotificationListener<UserScrollNotification>(
      child: DockedPageScope(
        docked: false,
        child: hasFab
            ? BottomInsetScope(
                inset: bottomInset + BottomInsetScope.floatingActionButtonInset,
                child: insetContent,
              )
            : insetContent,
      ),
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse) {
          _isFabExtendedNotifier.value = false;
        } else if (notification.direction == ScrollDirection.forward) {
          _isFabExtendedNotifier.value = true;
        }
        return true;
      },
    );
    final sheetBody = FloatingHeaderBody(
      backgroundColor:
          widget.backgroundColor ?? context.colorScheme.surfaceContainerLow,
      // The floating scrim is an IgnorePointer, so blank spots on the toolbar
      // fall through to the scrollable and only the buttons caught the modal's
      // drag-to-dismiss. An opaque catcher shadows the body across the whole
      // strip, letting the framework drag win uncontested from anywhere on top.
      header: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: SheetToolBar(appBar: appBar),
      ),
      body: foreground,
    );
    final sheetFab = fab == null ? null : SheetOverhangLift(child: fab);
    if (!hugsContent) {
      return Scaffold(
        body: sheetBody,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        backgroundColor: widget.backgroundColor,
        floatingActionButton: sheetFab,
      );
    }
    return ClipRSuperellipse(
      borderRadius: AppRadius.top(AppCorner.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: sheetBody),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }
}

const double _headerOverhang = 16;

class AppBarClearance extends StatelessWidget {
  const AppBarClearance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.appBarInset),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: FloatingBarScope(inset: 0, child: child),
      ),
    );
  }
}

List<Widget> genActions(
  List<Widget> actions, {
  double? space,
  AppBarActionEdge? edge,
}) {
  return <Widget>[
    ...actions.separated(SizedBox(width: space ?? edge?.gap ?? 4)),
    edge == null ? const SizedBox(width: AppSpacing.sm) : _ActionEdgeGap(edge),
  ];
}

class BaseScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: body,
      title: title,
      actions: actions,
      floatBody: true,
    );
  }
}

/// Whether a scaffold's page rides above a dock that owns the FAB corner, so
/// its [CommonScaffold.primaryAction] belongs in the bar rather than as a FAB.
/// Set by the home shell for mobile top-level pages; reset to false so a
/// nested route gets a FAB again.
class DockedPageScope extends InheritedWidget {
  const DockedPageScope({
    super.key,
    required this.docked,
    required super.child,
  });

  final bool docked;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DockedPageScope>()?.docked ??
      false;

  @override
  bool updateShouldNotify(DockedPageScope oldWidget) =>
      docked != oldWidget.docked;
}

class _PrimaryActionFab extends StatelessWidget {
  const _PrimaryActionFab({required this.data});

  static const _duration = Duration(milliseconds: 400);

  final IconButtonData data;

  @override
  Widget build(BuildContext context) {
    final isLoading = data.isLoading;
    return IgnorePointer(
      ignoring: isLoading,
      child: AnimatedScale(
        scale: isLoading ? 0 : 1,
        duration: context.motionDuration(_duration),
        curve: AppSpringCurves.morph,
        child: AnimatedOpacity(
          opacity: isLoading ? 0 : 1,
          duration: context.motionDuration(_duration),
          child: CommonFloatingActionButton(
            onPressed: data.onPressed,
            icon: GlyphIcon(data.glyph, fill: 1),
            label: data.tooltip ?? '',
          ),
        ),
      ),
    );
  }
}

const _maxBarButtons = 3;
const _maxGroupedActions = 2;

({List<IconButtonData> shown, List<CommonPopupMenuItem> overflow})
_foldBarActions({
  required bool hasLead,
  IconButtonData? primary,
  bool foldPrimary = false,
  List<IconButtonData> icons = const [],
  int widgetCount = 0,
  List<CommonPopupMenuItem> menuItems = const [],
}) {
  final foldable = [?primary, ...icons];
  final fixed = (hasLead ? 1 : 0) + widgetCount;
  if (fixed + foldable.length + (menuItems.isEmpty ? 0 : 1) <= _maxBarButtons) {
    return (shown: foldable, overflow: menuItems);
  }
  final slots = _maxBarButtons - 1 - fixed;
  final kept = (foldPrimary ? [...icons, ?primary] : foldable)
      .take(slots < 0 ? 0 : slots)
      .toList();
  bool isKept(IconButtonData data) => kept.any((it) => identical(it, data));
  return (
    shown: [
      for (final data in foldable)
        if (isKept(data)) data,
    ],
    overflow: [
      for (final data in foldable)
        if (!isKept(data))
          CommonPopupMenuItem(
            glyph: data.glyph,
            label: data.tooltip ?? '',
            onPressed: data.isLoading ? null : data.onPressed,
          ),
      ...menuItems,
    ],
  );
}

class _OverflowMenuButton extends StatelessWidget {
  const _OverflowMenuButton({required this.items});

  final List<CommonPopupMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return CommonPopupBox(
      targetBuilder: (open) => IconButton(
        tooltip: context.appLocalizations.more,
        onPressed: () => open(offset: Offset(0, context.isMobileView ? 0 : 20)),
        icon: const GlyphIcon(AppGlyphs.more),
      ).withAppTooltip(),
      popupBuilder: (_) => CommonPopupMenu(items: items),
    );
  }
}

/// An app bar action from [IconButtonData], standing in a spinner while it runs.
class AppBarActionButton extends StatelessWidget {
  const AppBarActionButton({super.key, required this.data});

  final IconButtonData data;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: data.tooltip,
      onPressed: data.isLoading ? null : data.onPressed,
      icon: data.isLoading
          ? SizedBox.square(
              dimension: TonalButtonSize.bar.icon,
              child: const Padding(
                padding: AppInsets.xxs,
                child: CommonCircleLoading(),
              ),
            )
          : GlyphIcon(data.glyph),
    ).withAppTooltip();
  }
}

const double appBarActionSpace = 4;

const double _barButtonGap = 8;
const double _iconButtonTapPadding = 4;

/// Where a filled button sits from the app bar edge: the layout margin iOS
/// gives a compact and a regular width.
double appBarActionInset(bool compact) => compact ? 16 : 20;

double appBarLeadingWidth(bool compact) =>
    TonalButtonSize.bar.button + appBarActionInset(compact) * 2;

/// A compact bar packs its edge closer: mobile widths, and any sheet toolbar
/// that is not a full page.
bool _isCompactBar(BuildContext context, bool isMobileView) {
  final sheet = SheetProvider.of(context)?.type;
  return isMobileView || (sheet != null && sheet != SheetType.page);
}

double _iconActionInset(bool isMobileView) => isMobileView ? 4 : 8;

enum AppBarActionEdge {
  icon,
  container;

  double spaceOf(BuildContext context, bool isMobileView) => switch (this) {
    icon => _iconActionInset(isMobileView) - _tapPaddingOf(context),
    container => appBarActionInset(_isCompactBar(context, isMobileView)),
  };

  double get gap => switch (this) {
    icon => appBarActionSpace,
    container => _barButtonGap,
  };
}

double _tapPaddingOf(BuildContext context) =>
    Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
    ? _iconButtonTapPadding
    : 0;

class _ActionEdgeGap extends StatelessWidget {
  const _ActionEdgeGap(this.edge);

  final AppBarActionEdge edge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: edge.spaceOf(context, context.isMobileView));
  }
}

/// Which sheet form (if any) this scaffold is rendering inside. A page carries
/// no [SheetProvider]; a modal (bottom or side) does. Only a modal supplies a
/// [_SheetPop], since only a modal draws its own pop control.
class _SheetForm {
  const _SheetForm({
    required this.isSheet,
    required this.isBottomSheet,
    required this.isSideSheet,
    required this.pop,
  });

  factory _SheetForm.of(BuildContext context, {required bool hasActions}) {
    final provider = SheetProvider.of(context);
    final isModal = provider != null && provider.type != SheetType.page;
    final isBottomSheet = provider?.type == SheetType.bottomSheet;
    return _SheetForm(
      isSheet: provider != null,
      isBottomSheet: isBottomSheet,
      isSideSheet: provider?.type == SheetType.sideSheet,
      pop: isModal
          ? _SheetPop.of(context, provider, hasActions: hasActions)
          : null,
    );
  }

  final bool isSheet;
  final bool isBottomSheet;
  final bool isSideSheet;
  final _SheetPop? pop;
}

/// The pop control a modal sheet draws for itself: a close glyph when the sheet
/// is at its root, a back glyph once a nested route has pushed over it. It
/// tucks in as a trailing suffix only when the toolbar has nothing else.
class _SheetPop {
  const _SheetPop({required this.useCloseIcon, required this.asSuffix});

  factory _SheetPop.of(
    BuildContext context,
    SheetProvider provider, {
    required bool hasActions,
  }) {
    final useCloseIcon =
        provider.nestedNavigatorPop == null ||
        ModalRoute.of(context)?.impliesAppBarDismissal == false;
    return _SheetPop(
      useCloseIcon: useCloseIcon,
      asSuffix: useCloseIcon && !hasActions,
    );
  }

  final bool useCloseIcon;
  final bool asSuffix;
}

/// The regex toggle that sits inside the searching action pill: a selectable
/// icon button that tints its glyph to [primary] while active.
class _RegexToggleButton extends StatelessWidget {
  const _RegexToggleButton({required this.active, required this.onChanged});

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return IconButton(
      isSelected: active,
      tooltip: context.appLocalizations.regexSearch,
      onPressed: () => onChanged(!active),
      icon: GlyphIcon(
        AppGlyphs.code,
        color: active ? colorScheme.primary : null,
      ),
    ).withAppTooltip();
  }
}

/// Grows the search pill leftward out of the search button on first build, so
/// the capsule reads as sliding out from under the action that opened it. The
/// shell snaps in first, then its contents fade up once there is room, so the
/// text never smears across the fast opening sweep.
class _SearchFieldReveal extends StatefulWidget {
  const _SearchFieldReveal({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  State<_SearchFieldReveal> createState() => _SearchFieldRevealState();
}

class _SearchFieldRevealState extends State<_SearchFieldReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 420);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  // The width rides the app's monotone sheet spring (never overshoots 1, so it
  // is safe to drive a widthFactor); the shell and content fade on plain M3
  // easing, staggered so the pill materialises before its contents.
  late final Animation<double> _expand = CurvedAnimation(
    parent: _controller,
    curve: AppSpringCurves.sheet,
  );
  late final Animation<double> _shell = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.3, curve: Easing.standardDecelerate),
  );
  late final Animation<double> _content = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.3, 1, curve: Easing.standard),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      if (context.disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: _expand.value.clamp(0.0, 1.0),
            child: SizedBox(
              height: TonalButtonSize.bar.button,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: widget.color.withValues(
                    alpha: _shell.value.clamp(0.0, 1.0),
                  ),
                  shape: AppShape.full,
                ),
                child: Opacity(
                  opacity: _content.value.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
