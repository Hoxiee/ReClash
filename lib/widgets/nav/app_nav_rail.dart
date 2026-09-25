import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _itemShape = AppShape.all(NavRailMetrics.itemCorner);

class AppNavRail extends ConsumerWidget {
  const AppNavRail({super.key, this.leading, this.onToPage, this.onAbout});

  @visibleForTesting
  static const Key highlightKey = Key('nav-rail-highlight');

  @visibleForTesting
  static const Key focusRingKey = Key('nav-rail-focus-ring');

  final Widget? leading;
  final void Function(PageLabel label)? onToPage;
  final VoidCallback? onAbout;

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
    final selectedIndex = _indexOf(ref.watch(currentPageLabelProvider), items);
    final leading = this.leading;
    return SizedBox(
      width: NavRailMetrics.width,
      child: Column(
        children: [
          if (leading != null) ...[leading, const SizedBox(height: 12)],
          Expanded(
            child: _RailBody(
              items: items,
              selectedIndex: selectedIndex,
              onToPage: (label) => _handleTap(ref, label),
              onAbout: onAbout,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailBody extends StatelessWidget {
  const _RailBody({
    required this.items,
    required this.selectedIndex,
    required this.onToPage,
    this.onAbout,
  });

  final List<NavigationItem> items;
  final int selectedIndex;
  final void Function(PageLabel label) onToPage;
  final VoidCallback? onAbout;

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

  static double _extentOf(int count, int boundaries, double slotHeight) =>
      NavRailMetrics.padding.vertical +
      count * slotHeight +
      boundaries * NavRailMetrics.dividerExtent;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;
    final colors = _RailColors(colorScheme);
    const slotHeight = NavRailMetrics.stackedSlotHeight;
    final boundaries = <int>[
      for (var i = 1; i < items.length; i++)
        if (_groupOf(items[i].label) != _groupOf(items[i - 1].label)) i,
    ];

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final extent = _extentOf(
                  items.length,
                  boundaries.length,
                  slotHeight,
                );
                final tops = <double>[];
                final dividers = <double>[];
                var y = NavRailMetrics.padding.top;
                for (var i = 0; i < items.length; i++) {
                  if (boundaries.contains(i)) {
                    y += NavRailMetrics.groupGap;
                    dividers.add(y);
                    y += NavRailMetrics.hairline + NavRailMetrics.groupGap;
                  }
                  tops.add(y);
                  y += slotHeight;
                }
                final centers = [for (final top in tops) top + slotHeight / 2];

                final body = Stack(
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
                    _SlotLayer(
                      items: items,
                      tops: tops,
                      slotHeight: slotHeight,
                      selectedIndex: selectedIndex,
                      colors: colors,
                      onToPage: onToPage,
                    ),
                    _SelectionIndicator(
                      key: AppNavRail.highlightKey,
                      color: colors.indicator,
                      index: selectedIndex,
                      centers: centers,
                    ),
                  ],
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
            ),
          ),
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
            padding: EdgeInsets.only(bottom: NavRailMetrics.padding.bottom),
            child: SizedBox(
              height: slotHeight,
              width: double.infinity,
              child: FocusTraversalOrder(
                order: NumericFocusOrder(items.length.toDouble()),
                child: _RailSlot(
                  glyph: AppGlyphs.info,
                  label: context.appLocalizations.about,
                  colors: colors,
                  selected: false,
                  onToPage: onAbout,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FlClash's sidebar palette: selection reads as a soft [selectedFill] tint
/// plus the primary edge [indicator], and hover/press/focus ride the same
/// low-alpha [overlay] rather than an ink splash.
class _RailColors {
  _RailColors(ColorScheme scheme)
    : selectedFill = scheme.onSurface.withValues(alpha: 0.08),
      foreground = scheme.onSurface,
      foregroundMuted = scheme.onSurfaceVariant,
      indicator = scheme.primary,
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
  final Color focusRing;
  final WidgetStateProperty<Color> overlay;
}

class _SlotLayer extends StatelessWidget {
  const _SlotLayer({
    required this.items,
    required this.tops,
    required this.slotHeight,
    required this.selectedIndex,
    required this.colors,
    required this.onToPage,
  });

  final List<NavigationItem> items;
  final List<double> tops;
  final double slotHeight;
  final int selectedIndex;
  final _RailColors colors;
  final void Function(PageLabel label) onToPage;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (var i = 0; i < items.length; i++)
        Positioned(
          top: tops[i],
          left: 0,
          right: 0,
          height: slotHeight,
          child: FocusTraversalOrder(
            order: NumericFocusOrder(i.toDouble()),
            child: _RailSlot(
              glyph: items[i].glyph,
              label: items[i].label.label,
              colors: colors,
              selected: i == selectedIndex,
              onToPage: () => onToPage(items[i].label),
            ),
          ),
        ),
    ],
  );
}

class _RailSlot extends StatefulWidget {
  const _RailSlot({
    required this.glyph,
    required this.label,
    required this.colors,
    required this.selected,
    this.onToPage,
  });

  final Glyph glyph;
  final String label;
  final _RailColors colors;
  final bool selected;
  final VoidCallback? onToPage;

  @override
  State<_RailSlot> createState() => _RailSlotState();
}

class _RailSlotState extends State<_RailSlot> {
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey);
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    FocusHighlightVisibility.visible.addListener(_handleFocusVisibility);
  }

  void _handleFocusVisibility() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FocusHighlightVisibility.visible.removeListener(_handleFocusVisibility);
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
    final color = widget.selected ? colors.foreground : colors.foregroundMuted;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlyphIcon(widget.glyph, size: NavRailMetrics.iconSize, color: color, fill: widget.selected ? 1 : 0),
          const SizedBox(height: 2),
          Text(
            widget.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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

/// FlClash's selection bar: it moves by stretching toward the new slot before
/// its trailing edge catches up, rather than sliding at a fixed height.
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
