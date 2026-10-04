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
import 'package:reclash/widgets/nav/nav_motion.dart';
import 'package:reclash/widgets/nav/nav_slots.dart';

final _itemShape = AppShape.all(NavRailMetrics.itemCorner);

class AppNavRail extends ConsumerWidget {
  const AppNavRail({
    super.key,
    this.expanded = false,
    this.onToggle,
    this.onToPage,
  });

  @visibleForTesting
  static const Key highlightKey = Key('nav-rail-highlight');

  @visibleForTesting
  static const Key focusRingKey = Key('nav-rail-focus-ring');

  @visibleForTesting
  static const Key toggleKey = Key('nav-rail-toggle');

  final bool expanded;
  final VoidCallback? onToggle;
  final void Function(PageLabel label)? onToPage;

  static int _indexOf(PageLabel label, List<NavigationItem> items) {
    final index = items.indexWhere((item) => item.label == label);
    return index < 0 ? 0 : index;
  }

  void _handleTap(WidgetRef ref, PageLabel label) {
    final callback = onToPage;
    if (callback != null) {
      callback(label);
      return;
    }
    ref.read(currentPageLabelProvider.notifier).toPage(label);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(currentNavigationItemsStateProvider).value;
    final currentLabel = ref.watch(currentPageLabelProvider);
    final selectedIndex = _indexOf(currentLabel, items);
    // Width and slot height animate together; the morph spring overshoots >1
    // and would tear a size, so the fold rides the bounce-free standard easing.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: expanded ? 1.0 : 0.0),
      duration: context.motionDuration(NavRailMetrics.expandDuration),
      curve: Easing.standard,
      builder: (context, progress, _) => SizedBox(
        width: lerpDouble(
          NavRailMetrics.compactWidth,
          NavRailMetrics.expandedWidth,
          progress,
        ),
        child: Column(
          children: [
            Expanded(
              child: _RailBody(
                items: items,
                selectedIndex: selectedIndex,
                onToPage: (label) => _handleTap(ref, label),
                progress: progress,
              ),
            ),
            _RailToggle(progress: progress, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _RailBody extends StatefulWidget {
  const _RailBody({
    required this.items,
    required this.selectedIndex,
    required this.onToPage,
    required this.progress,
  });

  final List<NavigationItem> items;
  final int selectedIndex;
  final void Function(PageLabel label) onToPage;
  final double progress;

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

  @override
  void didUpdateWidget(covariant _RailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cacheItems();
    _slots.sync([for (final item in widget.items) item.label]);
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
    // The slot is a compact square when folded and grows taller to seat a label
    // when open, so the folded icons read smaller than the expanded stack.
    final slotHeight = lerpDouble(
      NavRailMetrics.compactSlotHeight,
      NavRailMetrics.expandedSlotHeight,
      widget.progress,
    )!;
    final selectedLabel = widget.selectedIndex >= 0
        ? items[widget.selectedIndex.clamp(0, items.length - 1)].label
        : null;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
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
                          y += NavRailMetrics.hairline + NavRailMetrics.groupGap;
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

                    if (extent <= constraints.maxHeight) {
                      return body;
                    }
                    // Directional focus traversal reveals the focused slot on its own.
                    return ScrollConfiguration(
                      behavior: const HiddenBarScrollBehavior(),
                      child: SingleChildScrollView(
                        child: SizedBox(height: extent, child: body),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
  });

  final List<_RailRender> renders;
  final double slotHeight;
  final _RailColors colors;
  final void Function(PageLabel label) onToPage;
  final double progress;

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

class _RailSlot extends StatefulWidget {
  const _RailSlot({
    super.key,
    required this.glyph,
    required this.label,
    required this.colors,
    required this.selected,
    required this.progress,
    this.hover = 0,
    this.onToPage,
  });

  final Glyph glyph;
  final String label;
  final _RailColors colors;
  final bool selected;
  final double progress;
  final double hover;
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
    // Folded the label collapses its box entirely so it never pads the square;
    // it grows and fades in under the icon only as the rail opens.
    final labelReveal = ((widget.progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: color,
                    ),
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
    return Semantics(
      selected: widget.selected,
      child: Padding(
        padding: padding,
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
  late int _from = widget.index;

  @override
  void didUpdateWidget(covariant _SelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _from = oldWidget.index;
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

  double _topOf(int index) {
    final clamped = index.clamp(0, widget.centers.length - 1);
    return widget.centers[clamped] - NavRailMetrics.indicatorHeight / 2;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final from = _topOf(_from);
        final to = _topOf(widget.index);
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

/// The collapse/expand control at the foot of the rail. Its glyph morphs with
/// [progress] so the sidebar mark folds open as the rail widens.
class _RailToggle extends StatelessWidget {
  const _RailToggle({required this.progress, this.onToggle});

  final double progress;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = _RailColors(colorScheme);
    final shape = _itemShape;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NavRailMetrics.pillInsetX + 4,
          ),
          child: ColoredBox(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            child: const SizedBox(
              height: NavRailMetrics.hairline,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: NavRailMetrics.groupGap),
        Padding(
          padding: EdgeInsets.only(
            left: NavRailMetrics.pillInsetX,
            right: NavRailMetrics.pillInsetX,
            top: NavRailMetrics.pillInsetY,
            bottom: NavRailMetrics.padding.bottom + NavRailMetrics.pillInsetY,
          ),
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
                height: NavRailMetrics.compactSlotHeight,
                width: double.infinity,
                child: Center(
                  child: GlyphIcon(
                    AppGlyphs.sidebar(progress),
                    size: NavRailMetrics.iconSize,
                    color: colors.foregroundMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
