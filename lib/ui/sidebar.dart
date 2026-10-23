import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:reclash/ui/context.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/inherited.dart';
import 'package:reclash/ui/l10n.dart';
import 'package:reclash/ui/nav_slots.dart';
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
final _slotSpring = SpringDescription.withDurationAndBounce(
  duration: const Duration(milliseconds: 420),
);

class _DestinationKey {
  const _DestinationKey(this.identity, this.occurrence);

  final Object identity;
  final int occurrence;

  @override
  bool operator ==(Object other) =>
      other is _DestinationKey &&
      other.identity == identity &&
      other.occurrence == occurrence;

  @override
  int get hashCode => Object.hash(identity, occurrence);
}

class SidebarDestination {
  const SidebarDestination({
    required this.glyph,
    required this.label,
    this.group = 0,
    this.id,
  });

  final Glyph glyph;
  final String label;

  /// Group separators draw between different groups, never inside one.
  final int group;
  final Object? id;

  Object get identity => id ?? glyph;
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
  late final ScrollController _scrollController;

  late final NavSpring _hover = NavSpring(this, 0);
  late final NavSpring _hoverShow = NavSpring(this, 0);
  late final NavSlots<_DestinationKey> _slots = NavSlots<_DestinationKey>(
    vsync: this,
    spring: _slotSpring,
  );
  final Map<_DestinationKey, SidebarDestination> _destinationsById = {};
  final Map<_DestinationKey, NavSpring> _groupSprings = {};
  final Map<_DestinationKey, bool> _groupTargets = {};
  _DestinationKey? _hoveredIdentity;

  @override
  void initState() {
    super.initState();
    _scrollController = sheetScrollController(context);
    _slots.seed(_destinationKeys(widget.destinations));
    _cacheDestinations();
    _syncGroupSprings(seed: true);
    _slots.addListener(_handleSlotsChanged);
  }

  @override
  void didUpdateWidget(covariant _SidebarPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    _slots.sync(_destinationKeys(widget.destinations));
    _cacheDestinations();
    _syncGroupSprings();
    final hoveredIdentity = _hoveredIdentity;
    if (hoveredIdentity != null) {
      final liveKeys = _slots.slots
          .where((slot) => !slot.leaving)
          .map((slot) => slot.key)
          .toList();
      final index = liveKeys.indexOf(hoveredIdentity);
      if (index < 0) {
        _hoveredIdentity = null;
      } else {
        _spring(_hover, index.toDouble(), _hoverSpring);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slots.reduceMotion = _reduceMotion;
    if (_reduceMotion) {
      final liveKeys = _slots.slots
          .where((slot) => !slot.leaving)
          .map((slot) => slot.key)
          .toList();
      final hoveredIdentity = _hoveredIdentity;
      final hoverIndex = hoveredIdentity == null
          ? -1
          : liveKeys.indexOf(hoveredIdentity);
      _hover.jumpTo(hoverIndex < 0 ? 0 : hoverIndex.toDouble());
      _hoverShow.jumpTo(hoverIndex < 0 ? 0 : 1);
      for (final entry in _groupSprings.entries) {
        entry.value.jumpTo(_groupTargets[entry.key] == true ? 1 : 0);
      }
    }
  }

  List<_DestinationKey> _destinationKeys(
    List<SidebarDestination> destinations,
  ) {
    final occurrences = <Object, int>{};
    return [
      for (final destination in destinations)
        _DestinationKey(
          destination.identity,
          occurrences.update(
            destination.identity,
            (count) => count + 1,
            ifAbsent: () => 0,
          ),
        ),
    ];
  }

  void _cacheDestinations() {
    final keys = _destinationKeys(widget.destinations);
    for (var i = 0; i < keys.length; i++) {
      _destinationsById[keys[i]] = widget.destinations[i];
    }
    final retained = _slots.slots.map((slot) => slot.key).toSet();
    _destinationsById.removeWhere((key, _) => !retained.contains(key));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _slots.removeListener(_handleSlotsChanged);
    _slots.dispose();
    for (final spring in _groupSprings.values) {
      spring.dispose();
    }
    _groupSprings.clear();
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

  void _onHover(
    double y,
    List<double> centers,
    List<_DestinationKey> identities,
  ) {
    if (centers.isEmpty) return;
    final index = _nearestIndex(y, centers);
    _hoveredIdentity = identities[index];
    _spring(_hover, index.toDouble(), _hoverSpring);
    _spring(_hoverShow, 1, _hoverFadeSpring);
  }

  void _onExit() {
    _hoveredIdentity = null;
    _spring(_hoverShow, 0, _hoverFadeSpring);
  }

  void _selectIdentity(_DestinationKey key) {
    final index = _destinationKeys(widget.destinations).indexOf(key);
    if (index >= 0) widget.onSelected(index);
  }

  void _handleSlotsChanged() => _syncGroupSprings();

  void _syncGroupSprings({bool seed = false}) {
    final retained = <Object>{};
    int? previousGroup;
    for (final slot in _slots.slots) {
      final destination = _destinationsById[slot.key];
      if (destination == null) continue;
      retained.add(slot.key);
      final separates =
          previousGroup != null && destination.group != previousGroup;
      final spring = _groupSprings.putIfAbsent(
        slot.key,
        () => NavSpring(this, seed && separates ? 1 : 0),
      );
      final oldTarget = _groupTargets[slot.key];
      _groupTargets[slot.key] = separates;
      if (!seed && oldTarget != separates) {
        _spring(spring, separates ? 1 : 0, _slotSpring);
      }
      previousGroup = destination.group;
    }
    for (final key in _groupSprings.keys.toList()) {
      if (retained.contains(key)) continue;
      _groupSprings.remove(key)!.dispose();
      _groupTargets.remove(key);
    }
  }

  double _slotExtent(double stride) {
    var extent = 0.0;
    var previousReveal = 0.0;
    var hasPrevious = false;
    for (final slot in _slots.slots) {
      final destination = _destinationsById[slot.key];
      if (destination == null) continue;
      final reveal = slot.weight.value.clamp(0.0, 1.0);
      final divider = _groupSprings[slot.key]?.value.clamp(0.0, 1.0) ?? 0.0;
      if (hasPrevious) {
        extent += _dividerExtent * divider * math.min(previousReveal, reveal);
      }
      extent += stride * reveal;
      previousReveal = reveal;
      hasPrevious = true;
    }
    return extent;
  }

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

    return SizedBox(
      width: lerpDouble(compactWidth, _expandedWidth, widget.progress),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: widget.windowControls.height + _verticalInset + stride / 2,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => AnimatedBuilder(
                animation: Listenable.merge([_slots, ..._groupSprings.values]),
                builder: (context, _) => Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const HiddenBarScrollBehavior(),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _slots,
                              ..._groupSprings.values,
                              _hover,
                              _hoverShow,
                            ]),
                            builder: (context, _) {
                              final slots = _slots.slots;
                              final layouts = <_SidebarSlotLayout>[];
                              final centers = <double>[];
                              final liveIdentities = <_DestinationKey>[];
                              final liveIndex = <_DestinationKey, int>{};
                              var y = 0.0;
                              var previousReveal = 0.0;
                              var hasPrevious = false;
                              for (final slot in slots) {
                                final destination = _destinationsById[slot.key];
                                if (destination == null) continue;
                                final reveal = slot.weight.value.clamp(
                                  0.0,
                                  1.0,
                                );
                                final divider =
                                    _groupSprings[slot.key]?.value.clamp(
                                      0.0,
                                      1.0,
                                    ) ??
                                    0.0;
                                final gap = hasPrevious
                                    ? _dividerExtent *
                                          divider *
                                          math.min(previousReveal, reveal)
                                    : 0.0;
                                y += gap;
                                final top = y;
                                final height = stride * reveal;
                                final live = !slot.leaving && reveal > 0.001;
                                final index = live ? centers.length : -1;
                                if (live) {
                                  liveIndex[slot.key] = index;
                                  liveIdentities.add(slot.key);
                                  centers.add(top + height / 2);
                                }
                                layouts.add(
                                  _SidebarSlotLayout(
                                    slot: slot,
                                    destination: destination,
                                    reveal: reveal,
                                    dividerBefore: gap,
                                    liveIndex: index,
                                  ),
                                );
                                y += height;
                                previousReveal = reveal;
                                hasPrevious = true;
                              }
                              final extent = y;
                              final selectedKey =
                                  widget.selectedIndex >= 0 &&
                                      widget.selectedIndex <
                                          widget.destinations.length
                                  ? _destinationKeys(
                                      widget.destinations,
                                    )[widget.selectedIndex]
                                  : null;
                              final selectedLayoutIndex = selectedKey == null
                                  ? -1
                                  : liveIndex[selectedKey] ?? -1;
                              final show = _hoverShow.value;
                              final hoverAt = _hover.value;
                              double hoverOf(_SidebarSlotLayout layout) {
                                if (layout.liveIndex < 0) return 0;
                                return show *
                                    math.max(
                                      0,
                                      1 - (hoverAt - layout.liveIndex).abs(),
                                    );
                              }

                              return MouseRegion(
                                onHover: (event) => _onHover(
                                  event.localPosition.dy,
                                  centers,
                                  liveIdentities,
                                ),
                                onExit: (_) => _onExit(),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (final layout in layouts) ...[
                                          if (layout.dividerBefore > 0)
                                            _AnimatedGroupDivider(
                                              extent: layout.dividerBefore,
                                              margin: sideInset + 4,
                                            ),
                                          _SidebarSlot(
                                            key: ValueKey(layout.slot.key),
                                            layout: layout,
                                            colors: colors,
                                            itemHeight: itemHeight,
                                            stride: stride,
                                            sideInset: sideInset,
                                            tooltip: rowTooltip(
                                              layout.destination.label,
                                            ),
                                            selected:
                                                layout.slot.key ==
                                                    selectedKey &&
                                                !layout.slot.leaving,
                                            color: Color.lerp(
                                              colors.icon,
                                              colors.label,
                                              layout.slot.key == selectedKey
                                                  ? 1.0
                                                  : hoverOf(layout),
                                            )!,
                                            fill: layout.slot.key == selectedKey
                                                ? 1.0
                                                : hoverOf(layout) * 0.7,
                                            rowWidth: rowWidth,
                                            iconInset: iconInset,
                                            style: labelStyle,
                                            labelOpacity: labelOpacity,
                                            onTap: () => _selectIdentity(
                                              layout.slot.key,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    _HoverGhost(
                                      key: NavigationSidebar.hoverGhostKey,
                                      centers: centers,
                                      position: hoverAt,
                                      pillHeight: itemHeight,
                                      opacity: show,
                                      sideInset: sideInset,
                                      color: colors.hoverGhost,
                                    ),
                                    if (selectedLayoutIndex >= 0)
                                      _SelectionIndicator(
                                        color: colors.indicator,
                                        index: selectedLayoutIndex,
                                        centers: centers,
                                        start: sideInset,
                                      ),
                                    SizedBox(height: extent),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    _FootSeparator(
                      key: NavigationSidebar.footSeparatorKey,
                      visible: _slotExtent(stride) > constraints.maxHeight,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSlotLayout {
  const _SidebarSlotLayout({
    required this.slot,
    required this.destination,
    required this.reveal,
    required this.dividerBefore,
    required this.liveIndex,
  });

  final NavSlot<_DestinationKey> slot;
  final SidebarDestination destination;
  final double reveal;
  final double dividerBefore;
  final int liveIndex;
}

class _AnimatedGroupDivider extends StatelessWidget {
  const _AnimatedGroupDivider({required this.extent, required this.margin});

  final double extent;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final reveal = (extent / _dividerExtent).clamp(0.0, 1.0);
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: reveal,
        child: Opacity(
          opacity: reveal,
          child: _GroupDivider(margin: margin),
        ),
      ),
    );
  }
}

class _SidebarSlot extends StatelessWidget {
  const _SidebarSlot({
    super.key,
    required this.layout,
    required this.colors,
    required this.itemHeight,
    required this.stride,
    required this.sideInset,
    required this.tooltip,
    required this.selected,
    required this.color,
    required this.fill,
    required this.rowWidth,
    required this.iconInset,
    required this.style,
    required this.labelOpacity,
    required this.onTap,
  });

  final _SidebarSlotLayout layout;
  final _SidebarColors colors;
  final double itemHeight;
  final double stride;
  final double sideInset;
  final String? tooltip;
  final bool selected;
  final Color color;
  final double fill;
  final double rowWidth;
  final double iconInset;
  final TextStyle? style;
  final double labelOpacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reveal = layout.reveal;
    final leaving = layout.slot.leaving;
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: reveal,
        child: Opacity(
          opacity: reveal,
          child: IgnorePointer(
            ignoring: leaving,
            child: ExcludeSemantics(
              excluding: leaving,
              child: SizedBox(
                height: stride,
                child: _SidebarButton(
                  colors: colors,
                  height: itemHeight,
                  sideInset: sideInset,
                  selected: selected,
                  tooltip: tooltip,
                  hoverDelayScale: 2,
                  onTap: onTap,
                  child: _DestinationRow(
                    destination: layout.destination,
                    color: color,
                    fill: fill,
                    width: rowWidth,
                    iconInset: iconInset,
                    style: style,
                    labelOpacity: labelOpacity,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) _controller.value = widget.visible ? 1 : 0;
  }

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
      _from = _topOf(oldWidget.index, oldWidget.centers);
      if (context.disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.disableAnimations) _controller.value = 1;
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
