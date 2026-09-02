import 'dart:ui' show lerpDouble;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mobile floating bottom navigation. A single controller drives a fractional
/// segment index; the highlight's position, the segment lift and the label
/// colours all read that one number, so they cannot disagree. The row is
/// painted twice — resting colours, and on-primary colours clipped to the
/// highlight — so a label recolours exactly as the highlight sweeps it.
class AppNavBar extends ConsumerStatefulWidget {
  const AppNavBar({super.key, this.onToPage});

  @visibleForTesting
  static const Key highlightKey = Key('nav-bar-highlight');

  final void Function(PageLabel label)? onToPage;

  @override
  ConsumerState<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends ConsumerState<AppNavBar>
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
      duration: NavBarMetrics.motionDuration,
      value: 1,
    );
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
        NavBarMetrics.motionCurve.transform(_controller.value),
      )!;

  void _hopTo(int index) {
    if (index.toDouble() == _to) {
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(currentNavigationItemsStateProvider).value;
    if (items.length < 2) {
      return const SizedBox.shrink();
    }
    final colorScheme = context.colorScheme;

    // Listeners, not build: this also covers navigation that did not come
    // from a tap here, and never marks the subtree dirty mid-build.
    ref.listen(currentPageLabelProvider, (_, next) {
      _hopTo(
        _indexOf(next, ref.read(currentNavigationItemsStateProvider).value),
      );
    });
    ref.listen(currentNavigationItemsStateProvider, (previous, next) {
      if (previous?.value.length == next.value.length) {
        return;
      }
      _snapTo(_indexOf(ref.read(currentPageLabelProvider), next.value));
    });

    return SafeArea(
      top: false,
      child: Padding(
        padding: NavBarMetrics.padding,
        child: Material(
          color: colorScheme.surfaceContainerHighest,
          surfaceTintColor: Colors.transparent,
          elevation: 6,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
          shape: AppShape.full,
          child: Container(
            height: NavBarMetrics.pillHeight,
            padding: const EdgeInsets.all(NavBarMetrics.highlightInset),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final segmentWidth = constraints.maxWidth / items.length;
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final position = _position.clamp(
                      0.0,
                      (items.length - 1).toDouble(),
                    );
                    final highlightLeft = segmentWidth * position;
                    return Stack(
                      children: [
                        Positioned(
                          left: highlightLeft,
                          top: 0,
                          bottom: 0,
                          width: segmentWidth,
                          child: DecoratedBox(
                            key: AppNavBar.highlightKey,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: AppRadius.full,
                            ),
                          ),
                        ),
                        _SegmentRow(
                          items: items,
                          position: position,
                          color: colorScheme.onSurfaceVariant,
                          onToPage: (label) {
                            final callback = widget.onToPage;
                            if (callback != null) {
                              callback(label);
                            } else {
                              ref
                                  .read(currentPageLabelProvider.notifier)
                                  .toPage(label);
                            }
                          },
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: ClipPath(
                                clipper: _HighlightClip(
                                  left: highlightLeft,
                                  width: segmentWidth,
                                ),
                                child: _SegmentRow(
                                  items: items,
                                  position: position,
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
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.items,
    required this.position,
    required this.color,
    this.onToPage,
  });

  final List<NavigationItem> items;
  final double position;
  final Color color;
  final void Function(PageLabel label)? onToPage;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _Segment(
                item: items[i],
                color: color,
                covered: (1 - (position - i).abs()).clamp(0.0, 1.0),
                onToPage: onToPage == null
                    ? null
                    : () => onToPage!(items[i].label),
              ),
            ),
        ],
      );
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.item,
    required this.color,
    required this.covered,
    this.onToPage,
  });

  final NavigationItem item;
  final Color color;
  final double covered;
  final VoidCallback? onToPage;

  @override
  Widget build(BuildContext context) {
    final label = item.label.label;
    final content = Transform.scale(
      scale: lerpDouble(0.92, 1, covered)!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon.icon ?? Icons.circle, size: 24, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
    if (onToPage == null) {
      return Center(child: content);
    }
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onToPage,
        customBorder: AppShape.full,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(child: content),
      ),
    );
  }
}

class _HighlightClip extends CustomClipper<Path> {
  const _HighlightClip({required this.left, required this.width});

  final double left;
  final double width;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, width, size.height),
        const Radius.circular(AppCorner.full),
      ),
    );

  @override
  bool shouldReclip(_HighlightClip oldClipper) =>
      oldClipper.left != left || oldClipper.width != width;
}
