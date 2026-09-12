import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavRailLabelMode { none, stacked, extended }

/// Desktop navigation rail. Slots are placed at measured pixel tops rather
/// than at index multiples, because semantic groups insert hairlines and the
/// last group is pinned to the bottom; the travelling pill reads those same
/// tops, so it can never drift from the row it highlights.
class AppNavRail extends ConsumerStatefulWidget {
  const AppNavRail({super.key, this.leading, this.onToPage});

  @visibleForTesting
  static const Key highlightKey = Key('nav-rail-highlight');

  @visibleForTesting
  static const Key focusRingKey = Key('nav-rail-focus-ring');

  final Widget? leading;
  final void Function(PageLabel label)? onToPage;

  @override
  ConsumerState<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends ConsumerState<AppNavRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _from = _to = _indexOf(
      ref.read(currentPageLabelProvider),
      ref.read(currentNavigationItemsStateProvider).value,
    ).toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: NavRailMetrics.motionDuration,
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) {
      _controller.stop();
      _from = _to;
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _indexOf(PageLabel label, List<NavigationItem> items) {
    final index = items.indexWhere((item) => item.label == label);
    return index < 0 ? 0 : index;
  }

  double get _position => lerpDouble(
    _from,
    _to,
    NavRailMetrics.motionCurve.transform(_controller.value),
  )!;

  void _hopTo(int index) {
    if (index.toDouble() == _to) {
      return;
    }
    if (context.disableAnimations) {
      _snapTo(index);
      return;
    }
    _from = _position;
    _to = index.toDouble();
    _controller.forward(from: 0);
  }

  void _snapTo(int index) {
    _from = _to = index.toDouble();
    _controller.value = 1;
  }

  void _handleTap(PageLabel label) {
    final callback = widget.onToPage;
    if (callback != null) {
      callback(label);
      return;
    }
    ref.read(currentPageLabelProvider.notifier).toPage(label);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(currentNavigationItemsStateProvider).value;
    final showLabel = ref.watch(
      appSettingProvider.select((state) => state.showLabel),
    );
    final wide = ref.watch(
      viewWidthProvider.select(
        (width) => width >= NavRailMetrics.extendedMinViewWidth,
      ),
    );
    final mode = switch ((showLabel, wide)) {
      (false, _) => NavRailLabelMode.none,
      (true, false) => NavRailLabelMode.stacked,
      (true, true) => NavRailLabelMode.extended,
    };

    // Listeners, not build: this also covers navigation that did not come
    // from a tap here, and never marks the subtree dirty mid-build.
    ref.listen(currentPageLabelProvider, (_, next) {
      _hopTo(
        _indexOf(next, ref.read(currentNavigationItemsStateProvider).value),
      );
    });
    ref.listen(currentNavigationItemsStateProvider, (_, next) {
      _snapTo(_indexOf(ref.read(currentPageLabelProvider), next.value));
    });

    final leading = widget.leading;
    return AnimatedContainer(
      duration: context.motionDuration(NavRailMetrics.motionDuration),
      curve: NavRailMetrics.motionCurve,
      width: mode == NavRailLabelMode.extended
          ? NavRailMetrics.extendedWidth
          : NavRailMetrics.collapsedWidth,
      child: Column(
        children: [
          if (leading != null) ...[leading, const SizedBox(height: 12)],
          Expanded(
            child: _RailBody(
              items: items,
              mode: mode,
              controller: _controller,
              positionOf: () => _position,
              selectedIndexOf: () => _to.round(),
              onToPage: _handleTap,
            ),
          ),
          _RailChevron(expanded: showLabel),
        ],
      ),
    );
  }
}

class _RailChevron extends ConsumerWidget {
  const _RailChevron({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IconButton(
        onPressed: () => ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(showLabel: !state.showLabel)),
        tooltip: context.appLocalizations.toggleLabel,
        icon: Icon(expanded ? Icons.chevron_left : Icons.chevron_right),
      ),
    );
  }
}

class _RailBody extends StatelessWidget {
  const _RailBody({
    required this.items,
    required this.mode,
    required this.controller,
    required this.positionOf,
    required this.selectedIndexOf,
    required this.onToPage,
  });

  final List<NavigationItem> items;
  final NavRailLabelMode mode;
  final AnimationController controller;
  final double Function() positionOf;
  final int Function() selectedIndexOf;
  final void Function(PageLabel label) onToPage;

  static int _groupOf(PageLabel label) => switch (label) {
    PageLabel.dashboard => 0,
    PageLabel.proxies || PageLabel.profiles => 1,
    PageLabel.requests ||
    PageLabel.connections ||
    PageLabel.logs ||
    PageLabel.resources => 2,
    PageLabel.tools => 3,
  };

  static const int _pinnedGroup = 3;

  double get _slotHeight => switch (mode) {
    NavRailLabelMode.none => NavRailMetrics.iconSlotHeight,
    NavRailLabelMode.stacked => NavRailMetrics.stackedSlotHeight,
    NavRailLabelMode.extended => NavRailMetrics.extendedSlotHeight,
  };

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    final slotHeight = _slotHeight;
    final boundaries = <int>[
      for (var i = 1; i < items.length; i++)
        if (_groupOf(items[i].label) != _groupOf(items[i - 1].label)) i,
    ];
    final fixedExtent =
        NavRailMetrics.padding.vertical +
        items.length * slotHeight +
        boundaries.length * NavRailMetrics.dividerExtent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacer = (constraints.maxHeight - fixedExtent).clamp(
          0.0,
          double.infinity,
        );
        final tops = <double>[];
        final dividers = <double>[];
        var y = NavRailMetrics.padding.top;
        for (var i = 0; i < items.length; i++) {
          if (boundaries.contains(i)) {
            if (_groupOf(items[i].label) == _pinnedGroup) {
              y += spacer;
            }
            y += NavRailMetrics.groupGap;
            dividers.add(y);
            y += NavRailMetrics.hairline + NavRailMetrics.groupGap;
          }
          tops.add(y);
          y += slotHeight;
        }
        final extent = fixedExtent + spacer;

        final body = FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final position = positionOf().clamp(
                0.0,
                (items.length - 1).toDouble(),
              );
              final pillTop = _topAt(position, tops);
              return Stack(
                children: [
                  for (final dividerY in dividers)
                    Positioned(
                      top: dividerY,
                      left: NavRailMetrics.pillInsetX + 4,
                      right: NavRailMetrics.pillInsetX + 4,
                      height: NavRailMetrics.hairline,
                      child: ColoredBox(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  Positioned(
                    top: pillTop + NavRailMetrics.pillInsetY,
                    left: NavRailMetrics.pillInsetX,
                    right: NavRailMetrics.pillInsetX,
                    height: slotHeight - NavRailMetrics.pillInsetY * 2,
                    child: DecoratedBox(
                      key: AppNavRail.highlightKey,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: AppRadius.full,
                      ),
                    ),
                  ),
                  _SlotLayer(
                    items: items,
                    tops: tops,
                    slotHeight: slotHeight,
                    mode: mode,
                    pillTop: pillTop,
                    selectedIndex: selectedIndexOf(),
                    color: colorScheme.onSurfaceVariant,
                    onToPage: onToPage,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: ClipPath(
                          clipper: _HighlightClip(
                            top: pillTop + NavRailMetrics.pillInsetY,
                            height: slotHeight - NavRailMetrics.pillInsetY * 2,
                          ),
                          child: _SlotLayer(
                            items: items,
                            tops: tops,
                            slotHeight: slotHeight,
                            mode: mode,
                            pillTop: pillTop,
                            selectedIndex: selectedIndexOf(),
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        if (spacer > 0) {
          return body;
        }
        // Directional focus traversal reveals the focused slot on its own.
        return SingleChildScrollView(
          child: SizedBox(height: extent, child: body),
        );
      },
    );
  }

  double _topAt(double position, List<double> tops) {
    final low = position.floor().clamp(0, tops.length - 1);
    final high = position.ceil().clamp(0, tops.length - 1);
    return lerpDouble(tops[low], tops[high], position - low)!;
  }
}

class _SlotLayer extends StatelessWidget {
  const _SlotLayer({
    required this.items,
    required this.tops,
    required this.slotHeight,
    required this.mode,
    required this.pillTop,
    required this.selectedIndex,
    required this.color,
    this.onToPage,
  });

  final List<NavigationItem> items;
  final List<double> tops;
  final double slotHeight;
  final NavRailLabelMode mode;
  final double pillTop;
  final int selectedIndex;
  final Color color;
  final void Function(PageLabel label)? onToPage;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (var i = 0; i < items.length; i++)
        Positioned(
          top: tops[i],
          left: 0,
          right: 0,
          height: slotHeight,
          child: _RailSlot(
            item: items[i],
            mode: mode,
            color: color,
            selected: i == selectedIndex,
            covered: (1 - (pillTop - tops[i]).abs() / slotHeight).clamp(
              0.0,
              1.0,
            ),
            onToPage: onToPage == null ? null : () => onToPage!(items[i].label),
          ),
        ),
    ],
  );
}

class _RailSlot extends StatefulWidget {
  const _RailSlot({
    required this.item,
    required this.mode,
    required this.color,
    required this.selected,
    required this.covered,
    this.onToPage,
  });

  final NavigationItem item;
  final NavRailLabelMode mode;
  final Color color;
  final bool selected;
  final double covered;
  final VoidCallback? onToPage;

  @override
  State<_RailSlot> createState() => _RailSlotState();
}

class _RailSlotState extends State<_RailSlot> {
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey);
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final focusedNode = FocusManager.instance.primaryFocus;
    final moved = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => focusedNode?.nextFocus() ?? false,
      LogicalKeyboardKey.arrowUp => focusedNode?.previousFocus() ?? false,
      _ => false,
    };
    return moved ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.item.label.label;
    final icon = Icon(
      widget.item.icon.icon ?? Icons.circle,
      size: 24,
      color: widget.color,
    );
    final content = switch (widget.mode) {
      NavRailLabelMode.none => Center(child: icon),
      NavRailLabelMode.stacked => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ],
      ),
      NavRailLabelMode.extended => Row(
        children: [
          const SizedBox(width: 8),
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    };
    final onToPage = widget.onToPage;
    // Both layers pad identically, or the recoloured copy would sit off the
    // resting one by the pill inset.
    const padding = EdgeInsets.symmetric(
      horizontal: NavRailMetrics.pillInsetX,
      vertical: NavRailMetrics.pillInsetY,
    );
    if (onToPage == null) {
      return Padding(padding: padding, child: content);
    }
    return Semantics(
      selected: widget.selected,
      child: Tooltip(
        message: label,
        child: Padding(
          padding: padding,
          child: Stack(
            children: [
              // Keyboard and D-pad focus has to read as its own state: the
              // pill only ever shows the selected page.
              if (_focused && !widget.selected)
                Positioned.fill(
                  child: DecoratedBox(
                    key: AppNavRail.focusRingKey,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.full,
                      border: Border.all(
                        color: context.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: InkWell(
                  onTap: onToPage,
                  onFocusChange: (value) => setState(() => _focused = value),
                  focusNode: _focusNode,
                  customBorder: AppShape.full,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightClip extends CustomClipper<Path> {
  const _HighlightClip({required this.top, required this.height});

  final double top;
  final double height;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          NavRailMetrics.pillInsetX,
          top,
          size.width - NavRailMetrics.pillInsetX * 2,
          height,
        ),
        const Radius.circular(AppCorner.full),
      ),
    );

  @override
  bool shouldReclip(_HighlightClip oldClipper) =>
      oldClipper.top != top || oldClipper.height != height;
}
