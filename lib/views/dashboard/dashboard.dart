import 'package:defer_pointer/defer_pointer.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:reclash/widgets/theme/wallpaper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widget_metrics.dart';
import 'widget_registry.dart';
import 'widgets/connection_mode.dart';
import 'widgets/dashboard_pager.dart';
import 'widgets/seasonal_overlay.dart';
import 'widgets/provider_effect_overlay.dart';
import 'widgets/core_status_button.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final key = GlobalKey<SuperGridState>();
  final _isEditNotifier = ValueNotifier<bool>(false);
  final _addedWidgetsNotifier = ValueNotifier<List<GridItem>>([]);

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      dashboardStateProvider.select((state) => state.dashboardWidgets),
      (_, _) => _syncAddedWidgets(),
      fireImmediately: true,
    );
    ref.listenManual(dashboardModeProvider, (_, _) => _syncAddedWidgets());
  }

  void _syncAddedWidgets() {
    final mode = ref.read(dashboardModeProvider);
    final shown = ref
        .read(dashboardStateProvider)
        .dashboardWidgets
        .where((item) => item.visibleIn(mode))
        .map((item) => item.widget)
        .toSet();
    _addedWidgetsNotifier.value = DashboardWidget.values
        .where((item) => item.visibleIn(mode) && !shown.contains(item.widget))
        .map((item) => item.widget)
        .toList();
  }

  @override
  void dispose() {
    _isEditNotifier.dispose();
    _addedWidgetsNotifier.dispose();
    super.dispose();
  }

  Widget _buildIsEdit(_IsEditWidgetBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _isEditNotifier,
      builder: (_, isEdit, _) {
        return builder(isEdit);
      },
    );
  }

  List<Widget> _buildActions(bool isEdit) {
    return [
      if (!isEdit && coreLib == null) const CoreStatusButton(),
      if (isEdit)
        ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, addedChildren, child) {
            if (addedChildren.isEmpty) {
              return Container();
            }
            return child!;
          },
          child: IconButton(
            tooltip: context.appLocalizations.addWidget,
            onPressed: () {
              _showAddWidgetsModal();
            },
            icon: const GlyphIcon(AppGlyphs.addCircle),
          ),
        ),
      FadeRotationScaleBox(
        child: isEdit
            ? IconButton(
                tooltip: context.appLocalizations.save,
                key: const ValueKey(true),
                icon: const GlyphIcon(
                  AppGlyphs.save,
                  key: ValueKey('save-icon'),
                ),
                onPressed: _handleExitEdit,
              )
            : IconButton(
                tooltip: context.appLocalizations.edit,
                key: const ValueKey(false),
                icon: const GlyphIcon(
                  AppGlyphs.edit,
                  key: ValueKey('edit-icon'),
                ),
                onPressed: _handleEnterEdit,
              ),
      ),
    ];
  }

  void _showAddWidgetsModal() {
    showSheet(
      builder: (_) {
        return ValueListenableBuilder(
          valueListenable: _addedWidgetsNotifier,
          builder: (_, value, _) {
            return AdaptiveSheetScaffold(
              body: _AddDashboardWidgetModal(
                items: value,
                onAdd: (gridItem, from) {
                  key.currentState?.addItem(gridItem, from: from);
                },
              ),
              title: context.appLocalizations.add,
            );
          },
        );
      },
      context: context,
    );
  }

  void _handleEnterEdit() {
    _isEditNotifier.value = true;
  }

  void _handleExitEdit() {
    _isEditNotifier.value = false;
  }

  /// The grid only ever holds the tiles this mode and platform can show, so a
  /// save has to put the rest back where the user left them.
  List<DashboardWidget> _restoreHidden(List<DashboardWidget> visible) {
    final mode = ref.read(dashboardModeProvider);
    final hiddenAt = <int, List<DashboardWidget>>{};
    var seen = 0;
    for (final item in ref.read(dashboardStateProvider).dashboardWidgets) {
      if (item.visibleIn(mode)) {
        seen++;
      } else {
        final anchor = seen.clamp(0, visible.length);
        (hiddenAt[anchor] ??= []).add(item);
      }
    }
    if (hiddenAt.isEmpty) {
      return visible;
    }
    final merged = <DashboardWidget>[];
    for (var index = 0; index <= visible.length; index++) {
      merged.addAll(hiddenAt[index] ?? const []);
      if (index < visible.length) {
        merged.add(visible[index]);
      }
    }
    return merged;
  }

  void _saveDashboardWidgets(List<GridItem> items) {
    if (items.isEmpty) {
      return;
    }
    final merged = _restoreHidden(items.map(dashboardWidgetOf).toList());
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(dashboardWidgets: merged));
  }

  @override
  Widget build(BuildContext context) {
    final newDashboard = ref.watch(newDashboardEnabledProvider);
    if (newDashboard) {
      return AppWallpaper(
        builder: (context, active) => Scaffold(
          backgroundColor: active ? Colors.transparent : null,
          body: SafeArea(
            child: PanelProfileBackground(
              enabled: !active,
              child: const DashboardPager(),
            ),
          ),
        ),
      );
    }
    final dashboardState = ref.watch(dashboardStateProvider);
    final mode = ref.watch(dashboardModeProvider);
    final spacing = 14.mAp;
    final children = [
      ...dashboardState.dashboardWidgets
          .where((item) => item.visibleIn(mode))
          .map((item) => item.widget),
    ];
    return SeasonalDashboardOverlay(
      child: ProviderEffectOverlay(
        child: _buildIsEdit(
          (isEdit) => CommonScaffold(
            title: context.appLocalizations.dashboard,
            actions: _buildActions(isEdit),
            floatBody: true,
            // SingleChildScrollView snaps a bounce back to its edge whenever a
            // card's refresh relays it out; a sliver viewport keeps the
            // overscroll.
            body: Align(
              alignment: Alignment.topCenter,
              child: Builder(
                builder: (context) {
                  final padding = EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: context.appBarInset,
                    bottom: 16 + BottomInsetScope.of(context),
                  );
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: padding,
                        sliver: SliverToBoxAdapter(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: dashboardMaxGridWidth,
                              ),
                              child: LayoutBuilder(
                                builder: (_, constraints) {
                                  final columns = DashboardGridBand.of(
                                    constraints.maxWidth,
                                  ).columns;
                                  final grid = SuperGrid(
                                    key: key,
                                    editing: isEdit,
                                    crossAxisCount: columns,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    onChanged: _saveDashboardWidgets,
                                    revealPadding: padding.copyWith(
                                      left: 0,
                                      right: 0,
                                    ),
                                    children: children,
                                  );
                                  return DashboardWidgetMetrics(
                                    unitHeight: dashboardUnitHeight(
                                      constraints.maxWidth,
                                    ),
                                    child: isEdit
                                        ? BackLayerScope(
                                            onBack: _handleExitEdit,
                                            child: grid,
                                          )
                                        : grid,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef _AddCallback = void Function(GridItem item, Rect from);

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final _AddCallback onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: AppInsets.lg,
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: (from) => onAdd(item, from),
                      child: child,
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _AddedContainer extends StatelessWidget {
  final Widget child;
  final ValueChanged<Rect> onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  void _handleAdd(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    onAdd(box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: child),
        Positioned(
          top: -8,
          right: -8,
          child: DeferPointer(
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton.filled(
                tooltip: context.appLocalizations.add,
                iconSize: 20,
                padding: AppInsets.xxs,
                onPressed: () => _handleAdd(context),
                icon: const GlyphIcon(AppGlyphs.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
