import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/l10n.dart';
import 'package:reclash/ui/scroll_behavior.dart';
import 'package:reclash/ui/shape.dart';
import 'package:reclash/ui/spring.dart';
import 'package:reclash/ui/surface.dart';
import 'package:reclash/ui/tooltip.dart';
import 'package:reclash/ui/typography.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const _compactWidth = 48.0;
const _expandedWidth = 220.0;
const _itemSize = 36.0;
const _pillWidth = 36.0;
const _pillInsetY = 4.0;
const _toggleGap = 8.0;
const _verticalInset = 4.0;
const _maxSideInset = 12.0;
const _iconSize = 24.0;
const _labelGap = 12.0;
const _indicatorWidth = 3.0;
const _indicatorHeight = 16.0;
const _expandDuration = Duration(milliseconds: 250);
const _indicatorDuration = Duration(milliseconds: 320);
const _groupGap = 8.0;
const _hairline = 1.0;
const _dividerExtent = _groupGap * 2 + _hairline;
// The hover ghost chases the cursor with a spring, like a magnet snapping to
// the nearest slot, and dissolves when the cursor leaves. The ticker survives
// retargets, so a moving cursor steers one flight instead of restarting it.
final _hoverSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 260),
  bounce: 0.18,
);
final _hoverFadeSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 200),
);
// Press dips the content without touching its footprint, so strict slot
// bounds stay intact while the tap still feels physical.
final _pressSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 300),
  bounce: 0.24,
);
final _itemShape = AppShape.all(10);

class SidebarDestination {
  const SidebarDestination({
    required this.glyph,
    required this.label,
    this.group = 0,
  });

  final Glyph glyph;
  final String label;

  /// Group separators draw between different groups, never inside one.
  final int group;
}

/// Where the sidebar cannot widen in place, [onToggle] is null and the toggle
/// opens the expanded pane over the content instead.
///
/// [windowControls] is the area native window buttons cover at the top start
/// corner; the pane keeps it clear and never gets narrower than it.
class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.expanded,
    required this.onSelected,
    this.onToggle,
    this.windowControls = Size.zero,
  });

  @visibleForTesting
  static const Key hoverGhostKey = Key('sidebar-hover-ghost');

  @visibleForTesting
  static bool isGroupDivider(Widget widget) => widget is _GroupDivider;

  @visibleForTesting
  static const Key footSeparatorKey = Key('sidebar-foot-separator');

  final List<SidebarDestination> destinations;
  final int selectedIndex;
  final bool expanded;
  final ValueChanged<int> onSelected;
  final VoidCallback? onToggle;
  final Size windowControls;

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  late final AnimationController _overlayExpansion = AnimationController(
    vsync: this,
    duration: _expandDuration,
  );
  late final CurvedAnimation _overlayProgress = CurvedAnimation(
    parent: _overlayExpansion,
    curve: Easing.standard,
  );

  @override
  void didUpdateWidget(covariant NavigationSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onToggle != null && _overlayController.isShowing) {
      _overlayExpansion.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _hideIfDismissed());
    }
  }

  void _handleToggle() {
    final onToggle = widget.onToggle;
    if (onToggle != null) {
      onToggle();
    } else if (_overlayExpansion.isForwardOrCompleted) {
      _closeOverlay();
    } else {
      _overlayController.show();
      _overlayExpansion.forward();
    }
  }

  void _closeOverlay() {
    _overlayExpansion.reverse().whenCompleteOrCancel(_hideIfDismissed);
  }

  void _hideIfDismissed() {
    if (mounted && _overlayExpansion.isDismissed) {
      _overlayController.hide();
    }
  }

  @override
  void dispose() {
    _overlayProgress.dispose();
    _overlayExpansion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, info) {
        return _SidebarOverlay(
          anchor: MatrixUtils.transformRect(
            info.childPaintTransform,
            Offset.zero & info.childSize,
          ),
          overlayWidth: info.overlaySize.width,
          progress: _overlayProgress,
          onDismiss: _closeOverlay,
          builder: (progress) => Padding(
            padding: safePadding,
            child: _SidebarPane(
              progress: progress,
              windowControls: widget.windowControls,
              expanded: true,
              destinations: widget.destinations,
              selectedIndex: widget.selectedIndex,
              onSelected: (index) {
                widget.onSelected(index);
                _closeOverlay();
              },
              onToggle: _closeOverlay,
            ),
          ),
        );
      },
      child: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: widget.expanded ? 1.0 : 0.0),
          duration: _expandDuration,
          curve: Easing.standard,
          builder: (context, progress, _) => _SidebarPane(
            progress: progress,
            windowControls: widget.windowControls,
            expanded: widget.expanded,
            destinations: widget.destinations,
            selectedIndex: widget.selectedIndex,
            onSelected: widget.onSelected,
            onToggle: _handleToggle,
          ),
        ),
      ),
    );
  }
}

class _SidebarOverlay extends StatelessWidget {
  const _SidebarOverlay({
    required this.anchor,
    required this.overlayWidth,
    required this.progress,
    required this.onDismiss,
    required this.builder,
  });

  final Rect anchor;
  final double overlayWidth;
  final Animation<double> progress;
  final VoidCallback onDismiss;
  final Widget Function(double progress) builder;

  @override
  Widget build(BuildContext context) {
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final colorScheme = context.colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: isLtr ? anchor.left : null,
          right: isLtr ? null : overlayWidth - anchor.right,
          top: anchor.top,
          height: anchor.height,
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
            },
            child: Actions(
              actions: {
                DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (_) {
                    onDismiss();
                    return null;
                  },
                ),
              },
              child: FocusScope(
                autofocus: true,
                child: Material(
                  color: colorScheme.chromeSurface,
                  shape: BorderDirectional(
                    end: Divider.createBorderSide(context),
                  ),
                  elevation: 8,
                  shadowColor: colorScheme.shadow,
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (_, _) => builder(progress.value),
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

class _SidebarColors {
  _SidebarColors(ColorScheme scheme)
    : selectedFill = scheme.onSurface.withValues(alpha: 0.08),
      label = scheme.onSurface,
      icon = scheme.onSurfaceVariant,
      indicator = scheme.primary,
      hoverGhost = scheme.onSurface.withValues(alpha: 0.07),
      overlay = WidgetStateProperty.fromMap({
        WidgetState.pressed: scheme.onSurface.withValues(alpha: 0.06),
        WidgetState.focused: scheme.onSurface.withValues(alpha: 0.1),
        WidgetState.hovered: scheme.onSurface.withValues(alpha: 0.04),
        WidgetState.any: Colors.transparent,
      });

  final Color selectedFill;
  final Color label;
  final Color icon;
  final Color indicator;
  final Color hoverGhost;
  final WidgetStateProperty<Color> overlay;
}

class _SidebarPane extends StatefulWidget {
  const _SidebarPane({
    required this.progress,
    required this.windowControls,
    required this.expanded,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.onToggle,
  });

  final double progress;
  final Size windowControls;
  final bool expanded;
  final List<SidebarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onToggle;

  @override
  State<_SidebarPane> createState() => _SidebarPaneState();
}

class _SidebarPaneState extends State<_SidebarPane>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final NavSpring _hover = NavSpring(
    this,
    widget.selectedIndex
        .clamp(0, math.max(0, widget.destinations.length - 1))
        .toDouble(),
  );
  late final NavSpring _hoverShow = NavSpring(this, 0);

  @override
  void dispose() {
    _scrollController.dispose();
    _hover.dispose();
    _hoverShow.dispose();
    super.dispose();
  }

  bool get _reduceMotion => context.disableAnimations;

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
    _spring(_hover, _nearestIndex(y, centers).toDouble(), _hoverSpring);
    _spring(_hoverShow, 1, _hoverFadeSpring);
  }

  void _onExit() => _spring(_hoverShow, 0, _hoverFadeSpring);

  @override
  Widget build(BuildContext context) {
    final colors = _SidebarColors(context.colorScheme);
    final fontSize = AppTextStyle.subheadline.size;
    final labelOpacity = ((widget.progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final compactWidth = math.max(_compactWidth, widget.windowControls.width);
    final sideInset = math.min(_maxSideInset, (compactWidth - _pillWidth) / 2);
    final itemWidth = compactWidth - sideInset * 2;
    final iconInset = (itemWidth - _iconSize) / 2;
    final itemHeight =
        _itemSize + MediaQuery.textScalerOf(context).scale(fontSize) - fontSize;
    final rowWidth = _expandedWidth - sideInset * 2;
    final labelStyle = AppTextStyle.subheadline.of(context);
    final labelWidth = rowWidth - iconInset - _iconSize - _labelGap * 2;
    String? rowTooltip(String label) =>
        widget.expanded &&
            widget.progress == 1 &&
            _fitsOneLine(context, label, labelStyle, labelWidth)
        ? null
        : label;
    final stride = itemHeight + _pillInsetY * 2;
    final centers = <double>[];
    var y = 0.0;
    int? prevGroup;
    for (var i = 0; i < widget.destinations.length; i++) {
      final group = widget.destinations[i].group;
      if (i > 0 && group != prevGroup) {
        y += _dividerExtent;
      }
      prevGroup = group;
      centers.add(y + stride / 2);
      y += stride;
    }
    final extent = y;
    return SizedBox(
      width: lerpDouble(compactWidth, _expandedWidth, widget.progress),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: widget.windowControls.height + _verticalInset),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // The foot stays clear of the toggle: only a list that
                // actually scrolls earns the hairline above it.
                final scrollable = extent > constraints.maxHeight;
                return Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const HiddenBarScrollBehavior(),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: MouseRegion(
                            onHover: (event) =>
                                _onHover(event.localPosition.dy, centers),
                            onExit: (_) => _onExit(),
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_hover, _hoverShow]),
                              builder: (context, _) {
                                final show = _hoverShow.value;
                                final hoverAt = _hover.value;
                                double hoverOf(int index) =>
                                    show *
                                    math
                                        .max(0, 1 - (hoverAt - index).abs())
                                        .toDouble();
                                return Stack(
                                  children: [
                                    _HoverGhost(
                                      key: NavigationSidebar.hoverGhostKey,
                                      centers: centers,
                                      position: hoverAt,
                                      pillHeight: itemHeight,
                                      opacity: show,
                                      sideInset: sideInset,
                                      color: colors.hoverGhost,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (
                                          var index = 0;
                                          index < widget.destinations.length;
                                          index++
                                        ) ...[
                                          if (index > 0 &&
                                              widget
                                                      .destinations[index]
                                                      .group !=
                                                  widget
                                                      .destinations[index - 1]
                                                      .group)
                                            _GroupDivider(
                                              margin: sideInset + 4,
                                            ),
                                          Builder(
                                            builder: (context) {
                                              final selected =
                                                  index == widget.selectedIndex;
                                              final hover = hoverOf(index);
                                              final color = Color.lerp(
                                                colors.icon,
                                                colors.label,
                                                selected ? 1.0 : hover,
                                              )!;
                                              return _SidebarButton(
                                                key: ValueKey(
                                                  widget
                                                      .destinations[index]
                                                      .label,
                                                ),
                                                colors: colors,
                                                height: itemHeight,
                                                sideInset: sideInset,
                                                selected: selected,
                                                tooltip: rowTooltip(
                                                  widget
                                                      .destinations[index]
                                                      .label,
                                                ),
                                                hoverDelayScale: 2,
                                                onTap: () =>
                                                    widget.onSelected(index),
                                                child: _DestinationRow(
                                                  destination: widget
                                                      .destinations[index],
                                                  color: color,
                                                  fill: selected
                                                      ? 1.0
                                                      : hover * 0.7,
                                                  width: rowWidth,
                                                  iconInset: iconInset,
                                                  style: labelStyle,
                                                  labelOpacity: labelOpacity,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (widget.selectedIndex <
                                        widget.destinations.length)
                                      _SelectionIndicator(
                                        color: colors.indicator,
                                        index: widget.selectedIndex,
                                        centers: centers,
                                        start: sideInset,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    _FootSeparator(
                      key: NavigationSidebar.footSeparatorKey,
                      visible: scrollable,
                      sideInset: sideInset,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _SidebarButton(
                        colors: colors,
                        height: itemHeight,
                        sideInset: sideInset,
                        tooltip: widget.expanded
                            ? UiLocalizations.of(context).showLess
                            : UiLocalizations.of(context).showMore,
                        onTap: widget.onToggle,
                        child: SizedBox(
                          width: itemWidth,
                          child: Center(
                            child: GlyphIcon(
                              AppGlyphs.sidebar(widget.progress),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: _verticalInset + _toggleGap),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Hairline between destination groups. The foot reuses it, shown only while
/// the list scrolls; it collapses instead of popping when the verdict flips.
class _GroupDivider extends StatelessWidget {
  const _GroupDivider({required this.margin});

  final double margin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: _groupGap),
        Container(
          height: _hairline,
          margin: EdgeInsets.symmetric(horizontal: margin),
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        const SizedBox(height: _groupGap),
      ],
    );
  }
}

/// The hairline above the foot toggle. It only earns its keep while the list
/// actually scrolls — above a list that fits it is a stray rule implying
/// content below. Fades and collapses instead of popping when the verdict
/// flips; a SizeTransition (not an animated height) so mid-flight frames
/// never squeeze a taller child into a shorter box.
class _FootSeparator extends StatefulWidget {
  const _FootSeparator({
    super.key,
    required this.visible,
    required this.sideInset,
  });

  final bool visible;
  final double sideInset;

  @override
  State<_FootSeparator> createState() => _FootSeparatorState();
}

class _FootSeparatorState extends State<_FootSeparator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: widget.visible ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant _FootSeparator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (context.disableAnimations) {
      _controller.value = widget.visible ? 1 : 0;
    } else if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SizeTransition(
        sizeFactor: _controller.drive(CurveTween(curve: Curves.easeOutCubic)),
        axis: Axis.vertical,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: _hairline,
              margin: EdgeInsets.symmetric(horizontal: widget.sideInset),
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: _groupGap),
          ],
        ),
      ),
    );
  }
}

/// The magnet: a soft pill that springs to the slot nearest the cursor and
/// dissolves when the cursor leaves. The position rides a fractional slot
/// index, so the pill glides through group gaps instead of jumping them.
/// Purely a hover affordance, it never intercepts taps.
class _HoverGhost extends StatelessWidget {
  const _HoverGhost({
    super.key,
    required this.centers,
    required this.position,
    required this.pillHeight,
    required this.opacity,
    required this.sideInset,
    required this.color,
  });

  final List<double> centers;
  final double position;
  final double pillHeight;
  final double opacity;
  final double sideInset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.001 || centers.isEmpty) {
      return const SizedBox.shrink();
    }
    final low = position.floor().clamp(0, centers.length - 1);
    final high = position.ceil().clamp(0, centers.length - 1);
    final center = lerpDouble(centers[low], centers[high], position - low)!;
    return Positioned(
      top: center - pillHeight / 2,
      left: sideInset,
      right: sideInset,
      height: pillHeight,
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

class _SidebarButton extends StatefulWidget {
  const _SidebarButton({
    super.key,
    required this.colors,
    required this.height,
    required this.sideInset,
    required this.tooltip,
    required this.onTap,
    required this.child,
    this.selected,
    this.hoverDelayScale = 1,
  });

  final _SidebarColors colors;
  final double height;
  final double sideInset;
  final bool? selected;
  final String? tooltip;
  final double hoverDelayScale;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton>
    with SingleTickerProviderStateMixin {
  late final NavSpring _press = NavSpring(this, 0);

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (context.disableAnimations) {
      _press.jumpTo(pressed ? 1 : 0);
    } else {
      _press.springTo(pressed ? 1 : 0, _pressSpring);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.sideInset,
        vertical: _pillInsetY,
      ),
      child: Semantics(
        container: true,
        button: true,
        selected: widget.selected,
        child: FocusRing(
          shape: _itemShape,
          child: Material(
            color: widget.selected == true
                ? widget.colors.selectedFill
                : Colors.transparent,
            shape: _itemShape,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: _setPressed,
              customBorder: _itemShape,
              mouseCursor: SystemMouseCursors.basic,
              splashFactory: NoSplash.splashFactory,
              overlayColor: widget.colors.overlay,
              child: AppTooltip(
                message: widget.tooltip,
                placement: AppTooltipPlacement.right,
                hoverDelayScale: widget.hoverDelayScale,
                child: AnimatedBuilder(
                  animation: _press,
                  builder: (context, child) => Transform.scale(
                    scale: lerpDouble(1, 0.94, _press.value.clamp(0.0, 1.0))!,
                    child: child,
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(
                      size: _iconSize,
                      color: widget.colors.icon,
                    ),
                    child: SizedBox(height: widget.height, child: widget.child),
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

bool _fitsOneLine(
  BuildContext context,
  String text,
  TextStyle? style,
  double width,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  )..layout(maxWidth: width);
  final fits = !painter.didExceedMaxLines;
  painter.dispose();
  return fits;
}

/// The row lays out at the expanded width whatever the pane's current width,
/// so the label is clipped rather than reflowed while the pane animates.
class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.destination,
    required this.color,
    required this.fill,
    required this.width,
    required this.iconInset,
    required this.style,
    required this.labelOpacity,
  });

  final SidebarDestination destination;
  final Color color;
  final double fill;
  final double width;
  final double iconInset;
  final TextStyle? style;
  final double labelOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        alignment: AlignmentDirectional.centerStart,
        minWidth: width,
        maxWidth: width,
        child: Row(
          children: [
            SizedBox(width: iconInset),
            GlyphIcon(
              destination.glyph,
              size: _iconSize,
              color: color,
              fill: fill,
            ),
            const SizedBox(width: _labelGap),
            Expanded(
              child: Opacity(
                opacity: labelOpacity,
                alwaysIncludeSemantics: true,
                child: Text(
                  destination.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: style?.copyWith(color: color),
                ),
              ),
            ),
            const SizedBox(width: _labelGap),
          ],
        ),
      ),
    );
  }
}

/// The indicator moves by stretching toward the new row before its trailing
/// edge catches up, rather than sliding at a fixed size. Slot centers come
/// from the pane, since group dividers break a uniform stride.
class _SelectionIndicator extends StatefulWidget {
  const _SelectionIndicator({
    required this.color,
    required this.index,
    required this.centers,
    required this.start,
  });

  final Color color;
  final int index;
  final List<double> centers;
  final double start;

  @override
  State<_SelectionIndicator> createState() => _SelectionIndicatorState();
}

class _SelectionIndicatorState extends State<_SelectionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _indicatorDuration,
    value: 1,
  );
  late double _from = _topOf(widget.index, widget.centers);

  @override
  void didUpdateWidget(covariant _SelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      // Capture the departure in the old geometry: recomputing it from the
      // new centers teleports the start when a page change lands mid-layout.
      _from = _topOf(oldWidget.index, oldWidget.centers);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _topOf(int index, List<double> centers) {
    if (centers.isEmpty) {
      return 0;
    }
    final clamped = index.clamp(0, centers.length - 1);
    return centers[clamped] - _indicatorHeight / 2;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final from = _from;
        final to = _topOf(widget.index, widget.centers);
        final lead = Curves.easeOutCubic.transform(math.min(1, t / 0.6));
        final trail = Curves.easeInOutCubic.transform(
          math.max(0, (t - 0.35) / 0.65),
        );
        final (top, bottom) = to >= from
            ? (lerpDouble(from, to, trail)!, lerpDouble(from, to, lead)!)
            : (lerpDouble(from, to, lead)!, lerpDouble(from, to, trail)!);
        return PositionedDirectional(
          start: widget.start,
          top: top,
          width: _indicatorWidth,
          height: bottom - top + _indicatorHeight,
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
