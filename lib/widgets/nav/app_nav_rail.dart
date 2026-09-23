import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNavRail extends ConsumerStatefulWidget {
  const AppNavRail({super.key, this.leading, this.onToPage, this.onAbout});

  @visibleForTesting
  static const Key highlightKey = Key('nav-rail-highlight');

  @visibleForTesting
  static const Key focusRingKey = Key('nav-rail-focus-ring');

  final Widget? leading;
  final void Function(PageLabel label)? onToPage;
  final VoidCallback? onAbout;

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
    return SizedBox(
      width: NavRailMetrics.width,
      child: Column(
        children: [
          if (leading != null) ...[leading, const SizedBox(height: 12)],
          Expanded(
            child: _RailBody(
              items: items,
              controller: _controller,
              positionOf: () => _position,
              selectedIndexOf: () => _to.round(),
              onToPage: _handleTap,
              onAbout: widget.onAbout,
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
    required this.controller,
    required this.positionOf,
    required this.selectedIndexOf,
    required this.onToPage,
    this.onAbout,
  });

  final List<NavigationItem> items;
  final AnimationController controller;
  final double Function() positionOf;
  final int Function() selectedIndexOf;
  final void Function(PageLabel label) onToPage;
  final VoidCallback? onAbout;

  static int _groupOf(PageLabel label) => switch (label) {
    PageLabel.dashboard => 0,
    PageLabel.proxies || PageLabel.profiles => 1,
    PageLabel.requests ||
    PageLabel.connections ||
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

                final body = AnimatedBuilder(
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
                            decoration: ShapeDecoration(
                              color: colorScheme.primary,
                              shape: AppShape.md,
                            ),
                          ),
                        ),
                        _SlotLayer(
                          items: items,
                          tops: tops,
                          slotHeight: slotHeight,
                          selectedIndex: selectedIndexOf(),
                          color: colorScheme.onSurfaceVariant,
                          onToPage: onToPage,
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: ClipPath(
                                clipper: _HighlightClip(
                                  shape: AppShape.md,
                                  top: pillTop + NavRailMetrics.pillInsetY,
                                  height:
                                      slotHeight -
                                      NavRailMetrics.pillInsetY * 2,
                                ),
                                child: _SlotLayer(
                                  items: items,
                                  tops: tops,
                                  slotHeight: slotHeight,
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
                  icon: Icons.info_outline,
                  label: context.appLocalizations.about,
                  color: colorScheme.onSurfaceVariant,
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
    required this.selectedIndex,
    required this.color,
    this.onToPage,
  });

  final List<NavigationItem> items;
  final List<double> tops;
  final double slotHeight;
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
          child: FocusTraversalOrder(
            order: NumericFocusOrder(i.toDouble()),
            child: _RailSlot(
              icon: items[i].icon.icon ?? Icons.circle,
              label: items[i].label.label,
              color: color,
              selected: i == selectedIndex,
              onToPage: onToPage == null
                  ? null
                  : () => onToPage!(items[i].label),
            ),
          ),
        ),
    ],
  );
}

class _RailSlot extends StatefulWidget {
  const _RailSlot({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    this.onToPage,
  });

  final IconData icon;
  final String label;
  final Color color;
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
    final label = widget.label;
    final icon = Icon(widget.icon, size: 24, color: widget.color);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
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
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            // Keyboard and D-pad focus has to read as its own state: the
            // pill only ever shows the selected page.
            if (_focused &&
                !widget.selected &&
                FocusHighlightVisibility.visible.value)
              Positioned.fill(
                child: DecoratedBox(
                  key: AppNavRail.focusRingKey,
                  decoration: ShapeDecoration(
                    shape: AppShape.md.copyWith(
                      side: BorderSide(
                        color: context.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: InkWell(
                onTap: onToPage,
                onFocusChange: (value) => setState(() => _focused = value),
                focusNode: _focusNode,
                customBorder: AppShape.md,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightClip extends CustomClipper<Path> {
  const _HighlightClip({
    required this.shape,
    required this.top,
    required this.height,
  });

  final ShapeBorder shape;
  final double top;
  final double height;

  @override
  Path getClip(Size size) => shape.getOuterPath(
    Rect.fromLTWH(
      NavRailMetrics.pillInsetX,
      top,
      size.width - NavRailMetrics.pillInsetX * 2,
      height,
    ),
  );

  @override
  bool shouldReclip(_HighlightClip oldClipper) =>
      oldClipper.shape != shape ||
      oldClipper.top != top ||
      oldClipper.height != height;
}
