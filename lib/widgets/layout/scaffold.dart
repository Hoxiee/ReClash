import 'package:reclash/common/common.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/widgets/base/pop_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/loading.dart';
import '../input/button.dart';
import '../input/chip.dart';
import '../nav/app_nav_bar.dart';
import '../base/inherited.dart';
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
      _appBarState.value = _appBarState.value.copyWith(
        searchState: widget.searchState,
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
    _appBarState.dispose();
    _textController.dispose();
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
      );
    }
    if (_isSearch) {
      return IconButton(
        tooltip: context.appLocalizations.back,
        onPressed: _popAppBarLayer,
        icon: const GlyphIcon(AppGlyphs.arrowBack),
      );
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
          )
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
        ? const CloseButton()
        : const BackButton();
  }

  Widget _buildTitle(AppBarSearchState? startState) {
    final appLocalizations = context.appLocalizations;
    return _isSearch
        ? TextField(
            autofocus: true,
            controller: _textController,
            inputFormatters: TextInputLimits.limit(TextInputLimits.search),
            style: context.textTheme.titleLarge,
            onChanged: (value) {
              if (startState != null) {
                startState.onSearch(value);
              }
            },
            decoration: InputDecoration(
              hintText: appLocalizations.search,
              suffixIcon: startState?.onRegexChange != null
                  ? IconButton(
                      tooltip: appLocalizations.regexSearch,
                      isSelected: startState!.useRegex,
                      color: startState.useRegex
                          ? context.colorScheme.primary
                          : null,
                      onPressed: () =>
                          startState.onRegexChange!(!startState.useRegex),
                      icon: const GlyphIcon(AppGlyphs.code),
                    )
                  : null,
            ),
          )
        : Text(
            !_isEdit
                ? widget.title!
                : appLocalizations.selectedCountTitle(
                    '${_appBarState.value.editState?.editCount ?? 0}',
                  ),
          );
  }

  List<Widget> _buildActions(
    bool hasSearch,
    IconButtonData? primaryAction,
    List<Widget> legacyActions,
    _SheetForm form,
    VoidCallback? backAction,
  ) {
    final appLocalizations = context.appLocalizations;
    final pop = form.pop;
    final hasSearchButton =
        hasSearch && widget.searchState?.autoAddSearch == true;
    final lead = _isSearch
        ? IconButtonData(
            glyph: AppGlyphs.close,
            tooltip: appLocalizations.clearSearch,
            onPressed: _handleClear,
          )
        : hasSearchButton
        ? IconButtonData(
            glyph: AppGlyphs.search,
            tooltip: appLocalizations.search,
            onPressed: handleToSearch,
          )
        : null;
    final widgets = _isSearch ? const <Widget>[] : legacyActions;
    final selection = widget.selectionActions;
    final selectionCount = selection.isEmpty ? 0 : 1;
    final fold = _isSearch
        ? _foldBarActions(
            hasLead: true,
            icons: widget.searchActions,
            widgetCount: selectionCount,
          )
        : _foldBarActions(
            hasLead: lead != null,
            primary: primaryAction,
            foldPrimary: widget.foldPrimaryAction,
            icons: widget.iconActions,
            widgetCount: widgets.length + selectionCount,
            menuItems: widget.menuItems,
          );
    final shown = [?lead, ...fold.shown];
    final grouped = shown.length > 1 ? shown.take(_maxGroupedActions) : null;
    final popAsSuffix = !_isSearch && !_isEdit && pop?.asSuffix == true;
    return genActions([
      if (grouped != null)
        TonalButtonGroup(
          children: [
            for (final data in grouped) AppBarActionButton(data: data),
          ],
        ),
      for (final data in shown.skip(grouped?.length ?? 0))
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
      for (final action in widgets) ElasticPress(child: action),
      if (fold.overflow.isNotEmpty)
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
                      centerTitle: widget.centerTitle ?? isBottomSheet,
                      titleTextStyle: isBottomSheet
                          ? context.textTheme.titleLarge?.adjustSize(-4)
                          : null,
                      leading: _buildLeading(backAction, pop: form.pop),
                      title: _buildTitle(state.searchState),
                      actions: _buildActions(
                        state.searchState != null,
                        primaryAction,
                        state.actions.isNotEmpty
                            ? state.actions
                            : widget.actions ?? const [],
                        form,
                        backAction,
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

  @override
  Widget build(BuildContext context) {
    assert(widget.appBar != null || widget.title != null);
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
        backgroundColor: active ? Colors.transparent : widget.backgroundColor,
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
    final foreground = NotificationListener<UserScrollNotification>(
      child: DockedPageScope(
        docked: false,
        child: hasFab
            ? BottomInsetScope(
                inset: bottomInset + BottomInsetScope.floatingActionButtonInset,
                child: sheetContent,
              )
            : sheetContent,
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
        duration: _duration,
        curve: Curves.easeInOutBack,
        child: AnimatedOpacity(
          opacity: isLoading ? 0 : 1,
          duration: _duration,
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
      ),
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
    );
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
    required this.pop,
  });

  factory _SheetForm.of(BuildContext context, {required bool hasActions}) {
    final provider = SheetProvider.of(context);
    final isModal = provider != null && provider.type != SheetType.page;
    return _SheetForm(
      isSheet: provider != null,
      isBottomSheet: provider?.type == SheetType.bottomSheet,
      pop: isModal
          ? _SheetPop.of(context, provider, hasActions: hasActions)
          : null,
    );
  }

  final bool isSheet;
  final bool isBottomSheet;
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
