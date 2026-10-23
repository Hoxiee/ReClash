import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'context.dart';
import 'motion.dart';
import 'shape.dart';
import 'surface.dart';
import 'typography.dart';

class NavigationBarEntry {
  const NavigationBarEntry({
    required this.id,
    required this.icon,
    required this.label,
    this.group = 0,
  });

  final Object id;
  final Widget icon;
  final String label;
  final int group;
}

class AnimatedNavigationBar extends StatelessWidget {
  const AnimatedNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.labelBehavior = NavigationDestinationLabelBehavior.alwaysShow,
  });

  final List<NavigationBarEntry> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final NavigationDestinationLabelBehavior labelBehavior;

  @override
  Widget build(BuildContext context) {
    final duration = context.disableAnimations
        ? Duration.zero
        : fadeTabDuration;
    final selected = destinations.isEmpty
        ? 0
        : selectedIndex.clamp(0, destinations.length - 1);
    final Widget bar;
    if (destinations.isEmpty) {
      bar = const SizedBox.shrink();
    } else if (destinations.length == 1) {
      final theme = NavigationBarTheme.of(context);
      final scheme = Theme.of(context).colorScheme;
      final destination = destinations.single;
      bar = Material(
        color: theme.backgroundColor ?? scheme.surfaceContainer,
        child: SafeArea(
          child: SizedBox(
            height: theme.height ?? 80,
            child: Semantics(
              selected: true,
              button: true,
              label:
                  labelBehavior == NavigationDestinationLabelBehavior.alwaysHide
                  ? destination.label
                  : null,
              child: InkWell(
                onTap: () => onSelected(0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color:
                              theme.indicatorColor ??
                              SurfaceLevel.floatingOf(
                                scheme,
                              ).next.colorOf(scheme),
                          shape: theme.indicatorShape ?? AppShape.full,
                        ),
                        child: IconTheme(
                          data:
                              theme.iconTheme?.resolve({
                                WidgetState.selected,
                              }) ??
                              IconThemeData(color: scheme.primary, size: 24),
                          child: destination.icon,
                        ),
                      ),
                      if (labelBehavior !=
                          NavigationDestinationLabelBehavior.alwaysHide) ...[
                        const SizedBox(height: 4),
                        Text(
                          destination.label,
                          style: AppTextStyle.caption1.of(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      bar = Stack(
        children: [
          NavigationBar(
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  key: ValueKey(destination.id),
                  icon: destination.icon,
                  label: destination.label,
                ),
            ],
            selectedIndex: selected,
            onDestinationSelected: onSelected,
            labelBehavior: labelBehavior,
            animationDuration: context.disableAnimations ? Duration.zero : null,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    for (final (index, destination) in destinations.indexed)
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child:
                              index > 0 &&
                                  destination.group !=
                                      destinations[index - 1].group
                              ? SizedBox(
                                  width: 1,
                                  height: 24,
                                  child: ColoredBox(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  ),
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (context.disableAnimations) return bar;
    return AnimatedSize(
      duration: duration,
      alignment: Alignment.bottomCenter,
      curve: fadeTabCurve,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: fadeTabCurve,
        switchOutCurve: fadeTabCurve,
        layoutBuilder: (current, outgoing) => Stack(
          alignment: Alignment.bottomCenter,
          children: [
            for (final child in outgoing)
              IgnorePointer(
                child: ExcludeSemantics(
                  child: ExcludeFocus(
                    child: TickerMode(enabled: false, child: child),
                  ),
                ),
              ),
            ?current,
          ],
        ),
        child: KeyedSubtree(
          key: ValueKey(
            _DestinationSet([for (final item in destinations) item.id]),
          ),
          child: bar,
        ),
      ),
    );
  }
}

class _DestinationSet {
  const _DestinationSet(this.ids);

  final List<Object> ids;

  @override
  bool operator ==(Object other) =>
      other is _DestinationSet && listEquals(ids, other.ids);

  @override
  int get hashCode => Object.hashAll(ids);
}
