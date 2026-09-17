import 'package:defer_pointer/defer_pointer.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widget_registry.dart';
import 'widgets/connection_mode.dart';
import 'widgets/core_status_button.dart';
import 'widgets/dashboard_pager.dart';
import 'widgets/start_button.dart';
import 'widgets/seasonal_overlay.dart';

typedef _IsEditWidgetBuilder = Widget Function(bool isEdit);

const _compactCrossAxisCount = 8;
const _mediumCrossAxisCount = 12;
const _maxCrossAxisCount = 16;
const _mediumGridBreakpoint = 480.0;
const _maxGridBreakpoint = 840.0;
const _maxGridWidth = 280.0 * _maxCrossAxisCount / 4;

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
            icon: const Icon(Icons.add_circle),
          ),
        ),
      FadeRotationScaleBox(
        child: isEdit
            ? IconButton(
                tooltip: context.appLocalizations.save,
                key: const ValueKey(true),
                icon: const Icon(Icons.save, key: ValueKey('save-icon')),
                onPressed: _handleSaveAndExit,
              )
            : IconButton(
                tooltip: context.appLocalizations.edit,
                key: const ValueKey(false),
                icon: const Icon(Icons.edit, key: ValueKey('edit-icon')),
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
                onAdd: (gridItem) {
                  key.currentState?.handleAdd(gridItem);
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
    if (_isEditNotifier.value) {
      return;
    }
    _isEditNotifier.value = true;
  }

  void _handleExitEdit() {
    if (!_isEditNotifier.value) {
      return;
    }
    final dashboardWidgets = _getDashboardWidgets(key.currentState);
    if (dashboardWidgets != null) {
      _saveDashboardWidgets(dashboardWidgets);
    }
    _isEditNotifier.value = false;
  }

  Future<void> _handleSaveAndExit() async {
    if (!_isEditNotifier.value) {
      return;
    }
    await _handleSave();
    if (mounted) {
      _isEditNotifier.value = false;
    }
  }

  Future<void> _handleSave() async {
    final currentState = key.currentState;
    if (currentState == null) {
      return;
    }
    if (!mounted || currentState.snapshotChildren.isEmpty) {
      return;
    }
    final transformCompleted = await currentState.isTransformCompleter;
    if (!transformCompleted ||
        !mounted ||
        !currentState.mounted ||
        !identical(key.currentState, currentState)) {
      return;
    }
    final dashboardWidgets = _getDashboardWidgets(currentState);
    if (dashboardWidgets == null) {
      return;
    }
    _saveDashboardWidgets(dashboardWidgets);
  }

  List<DashboardWidget>? _getDashboardWidgets(SuperGridState? currentState) {
    if (currentState == null) {
      return null;
    }
    final children = currentState.snapshotChildren;
    if (children.isEmpty) {
      return null;
    }
    return children.map(dashboardWidgetOf).toList();
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

  void _saveDashboardWidgets(List<DashboardWidget> dashboardWidgets) {
    final merged = _restoreHidden(dashboardWidgets);
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(dashboardWidgets: merged));
  }

  @override
  Widget build(BuildContext context) {
    final newDashboard = ref.watch(newDashboardEnabledProvider);
    if (newDashboard) {
      return const Scaffold(
        body: SafeArea(child: PanelProfileBackground(child: DashboardPager())),
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
      child: _buildIsEdit(
        (isEdit) => CommonScaffold(
          title: context.appLocalizations.dashboard,
          actions: _buildActions(isEdit),
          floatingActionButton: const StartButton(),
          body: Align(
            alignment: Alignment.topCenter,
            child: Builder(
              builder: (context) => SingleChildScrollView(
                padding: const EdgeInsets.all(
                  16,
                ).copyWith(bottom: 16 + BottomInsetScope.of(context)),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxGridWidth),
                    child: LayoutBuilder(
                      builder: (_, constraints) {
                        final columns = switch (constraints.maxWidth) {
                          < _mediumGridBreakpoint => _compactCrossAxisCount,
                          <= _maxGridBreakpoint => _mediumCrossAxisCount,
                          _ => _maxCrossAxisCount,
                        };
                        return isEdit
                            ? BackLayerScope(
                                onBack: _handleExitEdit,
                                child: SuperGrid(
                                  key: key,
                                  crossAxisCount: columns,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  children: children,
                                  onUpdate: () {
                                    _handleSave();
                                  },
                                ),
                              )
                            : Grid(
                                crossAxisCount: columns,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                children: children,
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddDashboardWidgetModal extends StatelessWidget {
  final List<GridItem> items;
  final Function(GridItem item) onAdd;

  const _AddDashboardWidgetModal({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items
              .map(
                (item) => item.wrap(
                  builder: (child) {
                    return _AddedContainer(
                      onAdd: () {
                        onAdd(item);
                      },
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

class _AddedContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onAdd;

  const _AddedContainer({required this.child, required this.onAdd});

  @override
  State<_AddedContainer> createState() => _AddedContainerState();
}

class _AddedContainerState extends State<_AddedContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_AddedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {}
  }

  Future<void> _handleAdd() async {
    widget.onAdd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ActivateBox(child: widget.child),
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
                padding: const EdgeInsets.all(2),
                onPressed: _handleAdd,
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
