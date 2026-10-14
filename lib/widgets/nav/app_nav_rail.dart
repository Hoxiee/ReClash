import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/feedback/tooltip.dart';
import 'package:reclash/widgets/nav/nav_motion.dart';
import 'package:reclash/widgets/nav/nav_slots.dart';

final _itemShape = AppShape.all(NavRailMetrics.itemCorner);

class AppNavRail extends ConsumerStatefulWidget {
  const AppNavRail({
    super.key,
    this.expanded = false,
    this.wide = false,
    this.onToggle,
    this.onToPage,
  });

  @visibleForTesting
  static const Key highlightKey = Key('nav-rail-highlight');

  @visibleForTesting
  static const Key focusRingKey = Key('nav-rail-focus-ring');

  @visibleForTesting
  static const Key toggleKey = Key('nav-rail-toggle');

  @visibleForTesting
  static const Key footSeparatorKey = Key('nav-rail-foot-separator');

  final bool expanded;
  final bool wide;
  final VoidCallback? onToggle;
  final void Function(PageLabel label)? onToPage;

  @override
  ConsumerState<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends ConsumerState<AppNavRail>
    with TickerProviderStateMixin {
  late final AnimationController _expand = AnimationController(
    vsync: this,
    duration: NavRailMetrics.expandDuration,
    value: widget.expanded ? 1 : 0,
  );
  late final CurvedAnimation _expandCurved = CurvedAnimation(
    parent: _expand,
    curve: Easing.standardDecelerate,
    reverseCurve: const FlippedCurve(Easing.standardAccelerate),
  );
  // The wide list is a second dimension, not the end of the same fold:
  // flipping `wide` while open used to jump 80<->232 in one frame because
  // the single 0..1 progress was already settled. A dedicated controller
  // keeps that switch animated and leaves the collapsed width untouched.
  late final AnimationController _wide = AnimationController(
    vsync: this,
    duration: NavRailMetrics.expandDuration,
    value: widget.wide ? 1 : 0,
  );
  late final CurvedAnimation _wideCurved = CurvedAnimation(
    parent: _wide,
    curve: Easing.standardDecelerate,
    reverseCurve: const FlippedCurve(Easing.standardAccelerate),
  );
  late final Listenable _motion = Listenable.merge([_expand, _wide]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTargets();
  }

  @override
  void didUpdateWidget(covariant AppNavRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded ||
        widget.wide != oldWidget.wide ||
        context.disableAnimations) {
      _syncTargets();
    }
  }

  void _syncTargets() {
    _drive(_expand, widget.expanded ? 1 : 0);
    _drive(_wide, widget.wide ? 1 : 0);
  }

  void _drive(AnimationController controller, double target) {
    if ((controller.value - target).abs() < 0.001) {
      controller.value = target;
      return;
    }
    if (context.disableAnimations) {
      controller.value = target;
      return;
    }
    // Constant-velocity restarts: a mid-flight reversal only budgets the
    // remaining distance, so rapid toggles reverse smoothly instead of
    // replaying the full duration from a dead stop on every tap.
    final remaining = (controller.value - target).abs().clamp(0.0, 1.0);
    controller.duration = NavRailMetrics.expandDuration * remaining;
    if (target == 1) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    _expandCurved.dispose();
    _expand.dispose();
    _wideCurved.dispose();
    _wide.dispose();
    super.dispose();
  }

  static int _indexOf(PageLabel label, List<NavigationItem> items) {
    final index = items.indexWhere((item) => item.label == label);
    return index < 0 ? 0 : index;
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
    final currentLabel = ref.watch(currentPageLabelProvider);
    final selectedIndex = _indexOf(currentLabel, items);
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, _) {
        final progress = _expandCurved.value;
        final wideProgress = _wideCurved.value;
        final openWidth = lerpDouble(
          NavRailMetrics.expandedWidth,
          NavRailMetrics.wideWidth,
          wideProgress,
        )!;
        final width = lerpDouble(
          NavRailMetrics.compactWidth,
          openWidth,
          progress,
        )!;
        // The narrow column centers its icons, the wide row pins them where
        // the collapsed rail centers them (rail x 12..36), so opening to wide
        // and closing back swap with zero icon travel. Flipping wide while
        // open has no seamless point: switching in shows the row at once
        // (masked by the motion onset), switching out holds the row till the
        // width lands near 80, so icons never fling to the middle of a wide
        // rail — the exact pop this rule replaced.
        final bool wideLayout;
        if (widget.expanded && widget.wide) {
          wideLayout = true;
        } else if (!widget.expanded && widget.wide) {
          wideLayout = progress > 0.001;
        } else if (widget.expanded &&
            wideProgress > 0.001 &&
            width > NavRailMetrics.expandedWidth + 4) {
          wideLayout = true;
        } else {
          wideLayout = false;
        }
        return SizedBox(
          width: width,
          child: _RailBody(
            items: items,
            selectedIndex: selectedIndex,
            onToPage: _handleTap,
            progress: progress,
            wideProgress: wideProgress,
            wide: wideLayout,
            expanded: widget.expanded,
            onToggle: widget.onToggle,
          ),
        );
      },
    );
  }
}

class _RailBody extends StatefulWidget {
  const _RailBody({
    required this.items,
    required this.selectedIndex,
    required this.onToPage,
    required this.progress,
    required this.wideProgress,
    this.wide = false,
    this.expanded = false,
    this.onToggle,
  });

  final List<NavigationItem> items;
  final int selectedIndex;
  final void Function(PageLabel label) onToPage;
  final double progress;
  final double wideProgress;
  final bool wide;
  final bool expanded;
  final VoidCallback? onToggle;

  static int _groupOf(PageLabel label) => switch (label) {
    PageLabel.dashboard => 0,
    PageLabel.proxies || PageLabel.profiles => 1,
    PageLabel.requests ||
    PageLabel.connections ||
    PageLabel.dns ||
    PageLabel.logs ||
    PageLabel.resources => 2,
    PageLabel.tools => 3,
  };

  @override
  State<_RailBody> createState() => _RailBodyState();
}

final _railHoverSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 260),
  bounce: 0.18,
);
final _railFadeSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 200),
);
final _railPressSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 300),
  bounce: 0.24,
);
// A slot's share of the rail's height as it enters or leaves. Bounce-free so
// an overshoot never drives the height below zero.
final _railSlotSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 420),
);

class _RailBodyState extends State<_RailBody> with TickerProviderStateMixin {
  late final NavSpring _hover = NavSpring(
    this,
    widget.selectedIndex
        .clamp(0, math.max(0, widget.items.length - 1))
        .toDouble(),
  );
  late final NavSpring _hoverShow = NavSpring(this, 0);

  late final NavSlots<Object> _slots = NavSlots<Object>(
    vsync: this,
    spring: _railSlotSpring,
  );

  late final ScrollController _scrollController = ScrollController();

  /// The last-seen item for every label, so a leaving slot keeps something to
  /// paint while it collapses after it has left [widget.items].
  final Map<Object, NavigationItem> _itemsByLabel = {};

  bool get _reduceMotion => context.disableAnimations;

  @override
  void initState() {
    super.initState();
    _cacheItems();
    _slots.seed([for (final item in widget.items) item.label]);
  }

  static bool _sameKeys(List<NavigationItem> a, List<NavigationItem> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label) {
        return false;
      }
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant _RailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Progress ticks rebuild this widget every frame of the fold; reconciling
    // the slot membership on each of them re-merges the strip and notifies
    // twice per frame for no change. Only membership or order re-syncs.
    if (!identical(oldWidget.items, widget.items)) {
      _cacheItems();
    }
    if (!_sameKeys(oldWidget.items, widget.items)) {
      _slots.sync([for (final item in widget.items) item.label]);
    }
  }

  void _cacheItems() {
    for (final item in widget.items) {
      _itemsByLabel[item.label] = item;
    }
  }

  void _spring(NavSpring spring, double target, SpringDescription description) {
    if (_reduceMotion) {
      spring.jumpTo(target);
    } else {
      spring.springTo(target, description);
    }
  }

  int _nearestIndex(double y, List<double> centers) {
    var best = 0;
    var bestGap = double.infinity;
    for (var i = 0; i < centers.length; i++) {
      final gap = (centers[i] - y).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = i;
      }
    }
    return best;
  }

  void _onHover(double y, List<double> centers) {
    if (centers.isEmpty) {
      return;
    }
    _spring(_hover, _nearestIndex(y, centers).toDouble(), _railHoverSpring);
    _spring(_hoverShow, 1, _railFadeSpring);
  }

  void _onExit() => _spring(_hoverShow, 0, _railFadeSpring);

  @override
  void dispose() {
    _scrollController.dispose();
    _slots.dispose();
    _hover.dispose();
    _hoverShow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    _slots.reduceMotion = _reduceMotion;
    final colorScheme = context.colorScheme;
    final colors = _RailColors(colorScheme);
    // The open height itself morphs with the wide blend, nested inside the
    // fold: a wide flip while open grows 58->44 per slot instead of jumping.
    final openSlotHeight = lerpDouble(
      NavRailMetrics.expandedSlotHeight,
      NavRailMetrics.wideSlotHeight,
      widget.wideProgress,
    )!;
    final slotHeight = lerpDouble(
      NavRailMetrics.compactSlotHeight,
      openSlotHeight,
      widget.progress,
    )!;
    final selectedLabel = widget.selectedIndex >= 0
        ? items[widget.selectedIndex.clamp(0, items.length - 1)].label
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Slot heights ride the entry/exit springs, so the geometry is
        // recomputed every frame of a membership change.
        return AnimatedBuilder(
          animation: Listenable.merge([_slots, _hover, _hoverShow]),
          builder: (context, _) {
                    final merged = _slots.slots;
                    final tops = <double>[];
                    final heights = <double>[];
                    final dividers = <double>[];
                    final liveCenters = <double>[];
                    final liveIndexByLabel = <Object, int>{};
                    int? prevGroup;
                    var y = NavRailMetrics.padding.top;
                    for (final slot in merged) {
                      final factor = slot.weight.value.clamp(0.0, 1.0);
                      final height = slotHeight * factor;
                      if (!slot.leaving) {
                        final group = _RailBody._groupOf(slot.key as PageLabel);
                        if (prevGroup != null && group != prevGroup) {
                          y += NavRailMetrics.groupGap;
                          dividers.add(y);
                          y +=
                              NavRailMetrics.hairline + NavRailMetrics.groupGap;
                        }
                        prevGroup = group;
                      }
                      tops.add(y);
                      heights.add(height);
                      if (!slot.leaving) {
                        liveIndexByLabel[slot.key] = liveCenters.length;
                        liveCenters.add(y + height / 2);
                      }
                      y += height;
                    }
                    final extent = y + NavRailMetrics.padding.bottom;

                    final show = _hoverShow.value;
                    final hoverAt = _hover.value;
                    final renders = <_RailRender>[
                      for (var i = 0; i < merged.length; i++)
                        if (_itemsByLabel[merged[i].key] != null)
                          _RailRender(
                            label: merged[i].key,
                            item: _itemsByLabel[merged[i].key]!,
                            top: tops[i],
                            height: heights[i],
                            reveal: merged[i].weight.value.clamp(0.0, 1.0),
                            leaving: merged[i].leaving,
                            selected:
                                !merged[i].leaving &&
                                merged[i].key == selectedLabel,
                            hover: merged[i].leaving
                                ? 0.0
                                : show *
                                      math
                                          .max(
                                            0,
                                            1 -
                                                (hoverAt -
                                                        liveIndexByLabel[merged[i]
                                                            .key]!)
                                                    .abs(),
                                          )
                                          .toDouble(),
                          ),
                    ];

                    final body = MouseRegion(
                      onHover: (event) =>
                          _onHover(event.localPosition.dy, liveCenters),
                      onExit: (_) => _onExit(),
                      child: Stack(
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
                          _HoverGhost(
                            centers: liveCenters,
                            position: _hover.value,
                            slotHeight: slotHeight,
                            opacity: _hoverShow.value,
                            color: colors.hoverGhost,
                          ),
                          _SlotLayer(
                            renders: renders,
                            slotHeight: slotHeight,
                            colors: colors,
                            onToPage: widget.onToPage,
                            progress: widget.progress,
                            wideProgress: widget.wideProgress,
                            wide: widget.wide,
                            expanded: widget.expanded,
                          ),
                          if (selectedLabel != null && liveCenters.isNotEmpty)
                            _SelectionIndicator(
                              key: AppNavRail.highlightKey,
                              color: colors.indicator,
                              index: widget.selectedIndex.clamp(
                                0,
                                liveCenters.length - 1,
                              ),
                              centers: liveCenters,
                            ),
                        ],
                      ),
                    );

                    // One stable scrollable whatever the height: swapping the
                    // whole subtree between a bare stack and a scroll view
                    // mid-fold drops the scroll offset, rebuilds every slot
                    // and lets focus fall out of the rail halfway through.
                    // The verdict compares against the scroll viewport, not
                    // the whole body: the foot (~75px) is not scrollable
                    // room, and judging by the full height strands the last
                    // slots under the footer with NeverScrollable physics.
                    // The 9px separator is always budgeted (see below): that
                    // keeps the verdict stable instead of flapping across
                    // the fold that shows or hides it.
                    final pillH = widget.wide
                        ? NavRailMetrics.compactSlotHeight -
                              NavRailMetrics.pillInsetY * 2
                        : slotHeight - NavRailMetrics.pillInsetY * 2;
                    final footH =
                        _FootSeparator.extent +
                        NavRailMetrics.pillInsetY +
                        pillH +
                        NavRailMetrics.padding.bottom +
                        NavRailMetrics.pillInsetY;
                    final scrollable =
                        extent > constraints.maxHeight - footH;
                    if (!scrollable &&
                        _scrollController.hasClients &&
                        _scrollController.offset != 0) {
                      // Growing room (resize, collapse) must carry the view
                      // back: a parked offset under NeverScrollable physics
                      // would pin the list shifted with no way back.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                      });
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: FocusTraversalGroup(
                            policy: OrderedTraversalPolicy(),
                            child: ScrollConfiguration(
                              behavior: const HiddenBarScrollBehavior(),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: scrollable
                                    ? null
                                    : const NeverScrollableScrollPhysics(),
                                child: SizedBox(height: extent, child: body),
                              ),
                            ),
                          ),
                        ),
                        _FootSeparator(visible: scrollable),
                        _RailToggle(
                          progress: widget.progress,
                          wideProgress: widget.wideProgress,
                          wide: widget.wide,
                          expanded: widget.expanded,
                          onToggle: widget.onToggle,
                        ),
                      ],
                    );
                  },
                );
              },
            );
  }
}

/// Sidebar palette: selection reads as a soft [selectedFill] tint plus the
/// primary [indicator]; hover rides the same
/// low-alpha [overlay] and a magnet [hoverGhost] rather than an ink splash.
class _RailColors {
  _RailColors(ColorScheme scheme)
    : selectedFill = scheme.onSurface.withValues(alpha: 0.08),
      foreground = scheme.onSurface,
      foregroundMuted = scheme.onSurfaceVariant,
      indicator = scheme.primary,
      hoverGhost = scheme.onSurface.withValues(alpha: 0.07),
      focusRing = scheme.primary,
      overlay = WidgetStateProperty.fromMap({
        WidgetState.pressed: scheme.onSurface.withValues(alpha: 0.06),
        WidgetState.focused: scheme.onSurface.withValues(alpha: 0.1),
        WidgetState.hovered: scheme.onSurface.withValues(alpha: 0.04),
        WidgetState.any: Colors.transparent,
      });

  final Color selectedFill;
  final Color foreground;
  final Color foregroundMuted;
  final Color indicator;
  final Color hoverGhost;
  final Color focusRing;
  final WidgetStateProperty<Color> overlay;
}

class _HoverGhost extends StatelessWidget {
  const _HoverGhost({
    required this.centers,
    required this.position,
    required this.slotHeight,
    required this.opacity,
    required this.color,
  });

  final List<double> centers;
  final double position;
  final double slotHeight;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.001 || centers.isEmpty) {
      return const SizedBox.shrink();
    }
    final low = position.floor().clamp(0, centers.length - 1);
    final high = position.ceil().clamp(0, centers.length - 1);
    final center = lerpDouble(centers[low], centers[high], position - low)!;
    final height = slotHeight - NavRailMetrics.pillInsetY * 2;
    return Positioned(
      top: center - height / 2,
      left: NavRailMetrics.pillInsetX,
      right: NavRailMetrics.pillInsetX,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color.withValues(alpha: color.a * opacity.clamp(0, 1)),
            shape: _itemShape,
          ),
        ),
      ),
    );
  }
}

/// One slot's resolved placement for a frame: where it sits, how tall it is
/// right now, and how far through its entry/exit it is.
class _RailRender {
  const _RailRender({
    required this.label,
    required this.item,
    required this.top,
    required this.height,
    required this.reveal,
    required this.leaving,
    required this.selected,
    required this.hover,
  });

  final Object label;
  final NavigationItem item;
  final double top;
  final double height;
  final double reveal;
  final bool leaving;
  final bool selected;
  final double hover;
}

class _SlotLayer extends StatelessWidget {
  const _SlotLayer({
    required this.renders,
    required this.slotHeight,
    required this.colors,
    required this.onToPage,
    required this.progress,
    required this.wideProgress,
    required this.wide,
    required this.expanded,
  });

  final List<_RailRender> renders;
  final double slotHeight;
  final _RailColors colors;
  final void Function(PageLabel label) onToPage;
  final double progress;
  final double wideProgress;
  final bool wide;
  final bool expanded;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (var i = 0; i < renders.length; i++)
        Positioned(
          top: renders[i].top,
          left: 0,
          right: 0,
          height: renders[i].height,
          child: FocusTraversalOrder(
            order: NumericFocusOrder(i.toDouble()),
            child: _RailSlotBox(
              reveal: renders[i].reveal,
              maxHeight: slotHeight,
              child: _RailSlot(
                key: ValueKey(renders[i].label),
                glyph: renders[i].item.glyph,
                label: renders[i].item.label.label,
                colors: colors,
                selected: renders[i].selected,
                hover: renders[i].hover,
                progress: progress,
                wide: wide,
                wideProgress: wideProgress,
                expanded: expanded,
                onToPage: renders[i].leaving
                    ? null
                    : () => onToPage(renders[i].item.label),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Holds a slot to its current height while it enters or leaves, dissolving
/// (fade, scale, blur) the icon rather than squashing it.
class _RailSlotBox extends StatelessWidget {
  const _RailSlotBox({
    required this.reveal,
    required this.maxHeight,
    required this.child,
  });

  final double reveal;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reveal >= 0.999) {
      return child;
    }
    final scale = lerpDouble(0.7, 1, reveal)!;
    final blur = 6 * (1 - reveal);
    return ClipRect(
      child: OverflowBox(
        minHeight: 0,
        maxHeight: maxHeight,
        alignment: Alignment.center,
        child: Opacity(
          opacity: reveal.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              enabled: blur > 0.05,
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out at the wide width whatever the rail's current width, so the label
/// is clipped rather than reflowed while the rail widens.
class _WideRow extends StatelessWidget {
  const _WideRow({
    required this.glyph,
    required this.color,
    required this.fill,
    required this.label,
    required this.labelStyle,
    required this.labelOpacity,
  });

  final Glyph glyph;
  final Color color;
  final double fill;
  final String label;
  final TextStyle? labelStyle;
  final double labelOpacity;

  @override
  Widget build(BuildContext context) {
    // One icon axis for every state: the icon sits at rail x 12..36, exactly
    // where the collapsed rail centers it. The row is laid out at the full
    // wide width and curtained by the shrinking edge, so only labels clip.
    const width = NavRailMetrics.wideWidth - NavRailMetrics.pillInsetX * 2;
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        minWidth: width,
        maxWidth: width,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 6,
            end: AppSpacing.sm,
          ),
          child: Row(
            children: [
              GlyphIcon(
                glyph,
                size: NavRailMetrics.iconSize,
                color: color,
                fill: fill,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Opacity(
                  opacity: labelOpacity,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailSlot extends StatefulWidget {
  const _RailSlot({
    super.key,
    required this.glyph,
    required this.label,
    required this.colors,
    required this.selected,
    required this.progress,
    this.hover = 0,
    this.wide = false,
    this.wideProgress = 0,
    this.expanded = false,
    this.onToPage,
  });

  final Glyph glyph;
  final String label;
  final _RailColors colors;
  final bool selected;
  final double progress;
  final double hover;
  final bool wide;
  final double wideProgress;
  final bool expanded;
  final VoidCallback? onToPage;

  @override
  State<_RailSlot> createState() => _RailSlotState();
}

class _RailSlotState extends State<_RailSlot> with TickerProviderStateMixin {
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey);
  late final NavSpring _press = NavSpring(this, 0);
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    FocusHighlightVisibility.visible.addListener(_handleFocusVisibility);
  }

  void _handleFocusVisibility() {
    if (mounted) setState(() {});
  }

  void _setPressed(bool pressed) {
    if (context.disableAnimations) {
      _press.jumpTo(pressed ? 1 : 0);
    } else {
      _press.springTo(pressed ? 1 : 0, _railPressSpring);
    }
  }

  @override
  void dispose() {
    FocusHighlightVisibility.visible.removeListener(_handleFocusVisibility);
    _press.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      final rail = context.findAncestorWidgetOfExactType<AppNavRail>();
      final nodes =
          _focusNode.nearestScope!.traversalDescendants
              .where(
                (node) =>
                    node.context?.findAncestorWidgetOfExactType<AppNavRail>() ==
                    rail,
              )
              .toList()
            ..sort((a, b) => a.rect.top.compareTo(b.rect.top));
      final index = nodes.indexOf(_focusNode);
      final next = index + (key == LogicalKeyboardKey.arrowDown ? 1 : -1);
      if (index >= 0 && next >= 0 && next < nodes.length) {
        FocusTraversalPolicy.defaultTraversalRequestFocusCallback(nodes[next]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowLeft) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final inward = rtl
          ? key == LogicalKeyboardKey.arrowLeft
          : key == LogicalKeyboardKey.arrowRight;
      if (inward) {
        _focusNode.focusInDirection(
          rtl ? TraversalDirection.left : TraversalDirection.right,
        );
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final hover = widget.hover.clamp(0.0, 1.0);
    final color = Color.lerp(
      colors.foregroundMuted,
      colors.foreground,
      widget.selected ? 1.0 : hover,
    )!;
    final fill = widget.selected ? 1.0 : hover * 0.7;
    final foldReveal = ((widget.progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final wideBlend = widget.wideProgress.clamp(0.0, 1.0);
    // Wide row labels live at the very end of the motion. While closing they
    // stay put (the shrinking edge curtains them away) and dissolve only over
    // the last third; while opening they fade in over the last stretch.
    // Fading from the first frame is what used to wipe them on toggle.
    // The stacked label only has room once the slot has grown past the wide
    // height, so it stays back for the wide blend instead of overflowing.
    final double labelReveal;
    if (widget.wide) {
      final staged = widget.expanded
          ? ((widget.progress - 0.55) / 0.45).clamp(0.0, 1.0)
          : (widget.progress / 0.35).clamp(0.0, 1.0);
      labelReveal = staged * wideBlend;
    } else {
      labelReveal = foldReveal * (1 - wideBlend);
    }
    final labelStyle = widget.wide
        ? context.textTheme.bodyMedium?.copyWith(
            fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
          )
        : context.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600,
            color: color,
          );
    final inner = widget.wide
        ? _WideRow(
            glyph: widget.glyph,
            color: color,
            fill: fill,
            label: widget.label,
            labelStyle: labelStyle,
            labelOpacity: labelReveal,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              // Top-anchored: the icon sits at a fixed offset while the label
              // grows downward. Centering vertically here drags every icon up
              // by half the label height mid-fold, so the whole column
              // visibly swims. Horizontally the icon stays centered, exactly
              // as the narrow rail always looked.
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height:
                      (NavRailMetrics.compactSlotHeight -
                          NavRailMetrics.pillInsetY * 2 -
                          NavRailMetrics.iconSize) /
                      2,
                ),
                GlyphIcon(
                  widget.glyph,
                  size: NavRailMetrics.iconSize,
                  color: color,
                  fill: fill,
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: labelReveal,
                    child: Opacity(
                      opacity: labelReveal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
    // Press dips the content without touching its footprint, so the strict
    // per-locale slot bounds stay intact while the tap still feels physical.
    final content = AnimatedBuilder(
      animation: _press,
      builder: (context, child) => Transform.scale(
        scale: lerpDouble(1, 0.94, _press.value.clamp(0.0, 1.0)),
        child: child,
      ),
      child: inner,
    );
    final onToPage = widget.onToPage;
    const padding = EdgeInsets.symmetric(
      horizontal: NavRailMetrics.pillInsetX,
      vertical: NavRailMetrics.pillInsetY,
    );
    if (onToPage == null) {
      return Padding(padding: padding, child: content);
    }
    final shape = _itemShape;
    // Tooltips belong to the folded target state, not to the mid-fold frame:
    // flipping the message at progress 0.5 rebuilds the tooltip entry halfway
    // and can flash it under the cursor while the labels are still moving.
    final tooltip = widget.expanded ? null : widget.label;
    return Semantics(
      selected: widget.selected,
      child: Padding(
        padding: padding,
        child: AppTooltip(
          message: tooltip,
          placement: AppTooltipPlacement.right,
          hoverDelayScale: 2,
          child: Material(
            color: widget.selected ? colors.selectedFill : Colors.transparent,
            shape: shape,
            child: Stack(
              children: [
                // Keyboard and D-pad focus has to read as its own state: the
                // selected fill only ever marks the current page.
                if (_focused &&
                    !widget.selected &&
                    FocusHighlightVisibility.visible.value)
                  Positioned.fill(
                    child: DecoratedBox(
                      key: AppNavRail.focusRingKey,
                      decoration: ShapeDecoration(
                        shape: shape.copyWith(
                          side: BorderSide(color: colors.focusRing, width: 2),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: InkWell(
                    onTap: onToPage,
                    onHighlightChanged: _setPressed,
                    onFocusChange: (value) => setState(() => _focused = value),
                    focusNode: _focusNode,
                    customBorder: shape,
                    mouseCursor: SystemMouseCursors.basic,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: colors.overlay,
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatefulWidget {
  const _SelectionIndicator({
    super.key,
    required this.color,
    required this.index,
    required this.centers,
  });

  final Color color;
  final int index;
  final List<double> centers;

  @override
  State<_SelectionIndicator> createState() => _SelectionIndicatorState();
}

class _SelectionIndicatorState extends State<_SelectionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: NavRailMetrics.indicatorDuration,
    value: 1,
  );
  late double _fromTop = _topOf(widget.index, widget.centers);

  @override
  void didUpdateWidget(covariant _SelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      // Capture the departure in the old geometry: recomputing it from the
      // new (mid-fold) centers teleports the start when a page change lands
      // during the width animation.
      _fromTop = _topOf(oldWidget.index, oldWidget.centers);
      if (context.disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _topOf(int index, List<double> centers) {
    if (centers.isEmpty) {
      return 0;
    }
    final clamped = index.clamp(0, centers.length - 1);
    return centers[clamped] - NavRailMetrics.indicatorHeight / 2;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final from = _fromTop;
        final to = _topOf(widget.index, widget.centers);
        final lead = Curves.easeOutCubic.transform(math.min(1, t / 0.6));
        final trail = Curves.easeInOutCubic.transform(
          math.max(0, (t - 0.35) / 0.65),
        );
        final (top, bottom) = to >= from
            ? (lerpDouble(from, to, trail)!, lerpDouble(from, to, lead)!)
            : (lerpDouble(from, to, lead)!, lerpDouble(from, to, trail)!);
        return PositionedDirectional(
          start: NavRailMetrics.pillInsetX,
          top: top,
          width: NavRailMetrics.indicatorWidth,
          height: bottom - top + NavRailMetrics.indicatorHeight,
          child: child!,
        );
      },
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: widget.color,
            shape: AppShape.full,
          ),
        ),
      ),
    );
  }
}

/// The hairline above the foot toggle. It only earns its keep while the list
/// actually scrolls — above a list that fits it is a stray rule implying
/// content below. Fades and collapses instead of popping when the fold or a
/// resize crosses the scroll threshold mid-flight.
class _FootSeparator extends StatelessWidget {
  const _FootSeparator({required this.visible});

  final bool visible;

  static const double extent =
      NavRailMetrics.groupGap + NavRailMetrics.hairline;

  @override
  Widget build(BuildContext context) {
    final duration = context.resizeDuration(const Duration(milliseconds: 180));
    return AnimatedOpacity(
      key: AppNavRail.footSeparatorKey,
      duration: duration,
      opacity: visible ? 1 : 0,
      // Collapses the 9px block instead of just fading it, so the foot
      // toggle rides up instead of hovering over a dead gap. The clip eats
      // the trailing gap first while the rule lingers (topCenter).
      child: ClipRect(
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          height: visible ? _FootSeparator.extent : 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NavRailMetrics.pillInsetX + 4,
                  ),
                  child: ColoredBox(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.6,
                    ),
                    child: const SizedBox(
                      height: NavRailMetrics.hairline,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: NavRailMetrics.groupGap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The collapse/expand control at the foot of the rail. Its glyph morphs with
/// [progress] so the sidebar mark folds open as the rail widens.
class _RailToggle extends StatelessWidget {
  const _RailToggle({
    required this.progress,
    required this.wideProgress,
    required this.wide,
    required this.expanded,
    this.onToggle,
  });

  final double progress;
  final double wideProgress;
  final bool wide;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = _RailColors(context.colorScheme);
    final shape = _itemShape;
    // Narrow: the toggle is just another slot pill — same animated size, same
    // icon seat (top-center, 6 down, as the slot icons). Wide: it stays the
    // fixed 36x36 square pinned to the icon axis instead of stretching into
    // a full-width bar.
    final openSlotHeight = lerpDouble(
      NavRailMetrics.expandedSlotHeight,
      NavRailMetrics.wideSlotHeight,
      wideProgress,
    )!;
    final slotHeight = lerpDouble(
      NavRailMetrics.compactSlotHeight,
      openSlotHeight,
      progress,
    )!;
    final openWidth = lerpDouble(
      NavRailMetrics.expandedWidth,
      NavRailMetrics.wideWidth,
      wideProgress,
    )!;
    final railWidth = lerpDouble(
      NavRailMetrics.compactWidth,
      openWidth,
      progress,
    )!;
    final pillWidth = wide
        ? NavRailMetrics.compactWidth - NavRailMetrics.pillInsetX * 2
        : railWidth - NavRailMetrics.pillInsetX * 2;
    final pillHeight = wide
        ? NavRailMetrics.compactSlotHeight - NavRailMetrics.pillInsetY * 2
        : slotHeight - NavRailMetrics.pillInsetY * 2;
    final icon = GlyphIcon(
      AppGlyphs.sidebar(progress),
      size: NavRailMetrics.iconSize,
      color: colors.foregroundMuted,
    );
    final l10n = context.appLocalizations;
    // Fixed square, never stretched: it used to ride the full rail width
    // (a 220-wide bar when open) and a full 44-tall slot, reading taller
    // than every slot pill in the folded rail. 36x36 matches the folded
    // pills and stays put on the icon axis in every state.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.only(
          left: NavRailMetrics.pillInsetX,
          right: NavRailMetrics.pillInsetX,
          top: NavRailMetrics.pillInsetY,
          bottom: NavRailMetrics.padding.bottom + NavRailMetrics.pillInsetY,
        ),
        child: AppTooltip(
          message: expanded ? l10n.showLess : l10n.showMore,
          placement: AppTooltipPlacement.right,
          child: Material(
            color: Colors.transparent,
            shape: shape,
            child: InkWell(
              key: AppNavRail.toggleKey,
              onTap: onToggle,
              customBorder: shape,
              mouseCursor: SystemMouseCursors.basic,
              splashFactory: NoSplash.splashFactory,
              overlayColor: colors.overlay,
              child: SizedBox(
                width: pillWidth,
                height: pillHeight,
                // Narrow mirrors the slot pills, but centers the mark: unlike
                // the slots there is no label underneath, so top-pinning
                // would strand it at the pill's roof. Wide pins to the
                // icon axis (rail x 12..36) and never rides to the center.
                child: wide
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 6),
                          child: icon,
                        ),
                      )
                    : Center(child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
