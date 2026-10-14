import 'dart:ui' show ImageFilter;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/effect/animated_visibility.dart';
import 'package:reclash/widgets/layout/popup.dart';
import 'package:reclash/widgets/nav/app_nav_rail.dart';
import 'package:reclash/widgets/theme/wallpaper.dart';

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  void _handleToPage(WidgetRef ref, PageLabel pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final preserveNavigationFocus =
        focusNode?.context?.findAncestorWidgetOfExactType<AppNavRail>() != null;
    ref.read(currentPageLabelProvider.notifier).toPage(pageLabel);
    if (!preserveNavigationFocus || focusNode == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.context != null && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  KeyEventResult _handleContentKey(WidgetRef ref, FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(node.context!) == TextDirection.rtl;
    final toRail =
        e.logicalKey ==
        (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft);
    if (!toRail) {
      return KeyEventResult.ignored;
    }
    final focus = FocusManager.instance.primaryFocus;
    final focusRect = focus?.rect;
    if (focus == null ||
        focusRect == null ||
        focus.context?.findAncestorWidgetOfExactType<AppNavRail>() != null) {
      return KeyEventResult.ignored;
    }
    // Directional traversal inside the page runs first; only the page's own
    // left edge falls through to here, where it should land on the rail.
    final hasInnerTarget = focus.nearestScope!.traversalDescendants.any((n) {
      if (n == focus || n.rect.overlaps(focusRect)) {
        return false;
      }
      final beyond = rtl
          ? n.rect.left > focusRect.left
          : n.rect.right < focusRect.right;
      final overlapsRow =
          n.rect.top < focusRect.bottom && n.rect.bottom > focusRect.top;
      return beyond && overlapsRow;
    });
    if (hasInnerTarget) {
      return KeyEventResult.ignored;
    }
    final railNodes =
        FocusManager.instance.rootScope.traversalDescendants
            .where(
              (n) =>
                  n.context?.findAncestorWidgetOfExactType<AppNavRail>() !=
                  null,
            )
            .toList()
          ..sort((a, b) => a.rect.top.compareTo(b.rect.top));
    if (railNodes.isEmpty) {
      return KeyEventResult.ignored;
    }
    final items = ref.read(currentNavigationItemsStateProvider).value;
    final selected = items.indexWhere(
      (item) => item.label == ref.read(currentPageLabelProvider),
    );
    final target = (selected >= 0 && selected < railNodes.length)
        ? railNodes[selected]
        : railNodes.first;
    FocusTraversalPolicy.defaultTraversalRequestFocusCallback(target);
    return KeyEventResult.handled;
  }

  void _showRailMenu(BuildContext context, WidgetRef ref, Offset globalPoint) {
    final appLocalizations = context.appLocalizations;
    final navigator = Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject();
    if (navigatorBox is! RenderBox) {
      return;
    }
    final point = navigatorBox.globalToLocal(globalPoint);
    final wide = ref.read(appSettingProvider).railWide;
    void choose({required bool value}) => ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(railWide: value));
    final route = CommonPopupRoute<void>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      placement: PopupPlacement.belowPoint,
      modal: false,
      anchorOf: () => point & Size.zero,
      builder: (_) => CommonPopupMenu(
        items: [
          CommonPopupMenuItem(
            label: appLocalizations.sidebarOpenNarrow,
            checked: !wide,
            onPressed: () => choose(value: false),
          ),
          CommonPopupMenuItem(
            label: appLocalizations.sidebarOpenWide,
            checked: wide,
            onPressed: () => choose(value: true),
          ),
        ],
      ),
    );
    navigator.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showRail = ref.watch(navSurfaceProvider) == NavSurface.rail;
    final sidebarExpanded = ref.watch(
      appSettingProvider.select((state) => state.sidebarExpanded),
    );
    final railWide = ref.watch(
      appSettingProvider.select((state) => state.railWide),
    );
    // One wallpaper spans the whole shell so the rail shares the content's
    // continuous backdrop instead of standing as an opaque cut-out beside it.
    return AppWallpaper(
      // The base matches the inactive shell fill so a wallpaper crossfade never
      // flashes through to a bare surface.
      baseColor: context.colorScheme.surfaceContainer,
      // The painted wallpaper sits behind this builder, so a solid fill here
      // would hide it; tint only when there is no wallpaper to show through.
      builder: (context, active) => Container(
        color: active ? null : context.colorScheme.surfaceContainer,
        child: Row(
          children: [
            AnimatedVisibility.sidebar(
              visible: showRail,
              child: _RailBackground(
                active: active,
                child: SafeArea(
                  child: Column(
                    children: [
                      if (system.isMacOS) const SizedBox(height: 22),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const HiddenBarScrollBehavior(),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onSecondaryTapUp: (details) => _showRailMenu(
                              context,
                              ref,
                              details.globalPosition,
                            ),
                            child: AppNavRail(
                              expanded: sidebarExpanded,
                              wide: railWide,
                              onToggle: () => ref
                                  .read(appSettingProvider.notifier)
                                  .update(
                                    (state) => state.copyWith(
                                      sidebarExpanded: !state.sidebarExpanded,
                                    ),
                                  ),
                              onToPage: (label) => _handleToPage(ref, label),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Focus(
                canRequestFocus: false,
                onKeyEvent: (node, event) =>
                    _handleContentKey(ref, node, event),
                // One backdrop for the whole content region: pages, per-page
                // navigators and side sheets share it, so nested scaffolds no
                // longer each paint a mis-aligned crop.
                child: ClipRect(
                  child: AppWallpaper(builder: (context, _) => child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The frosted glass only exists while a wallpaper shows through, so toggling
/// it used to reparent the whole rail between a bare panel and one wrapped in a
/// backdrop blur, rebuilding every rail item. A stable [GlobalKey] on the panel
/// moves that subtree across the two layouts instead of recreating it.
class _RailBackground extends StatefulWidget {
  const _RailBackground({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_RailBackground> createState() => _RailBackgroundState();
}

class _RailBackgroundState extends State<_RailBackground> {
  final GlobalKey _panelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final panel = Material(
      key: _panelKey,
      // Card opacity keeps the rail near-solid; a wallpaper wants it frosted, so
      // drop to a glass alpha and let the backdrop blur carry the image through.
      color: widget.active
          ? colorScheme.surfaceContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: widget.child,
      ),
    );
    if (!widget.active) {
      return panel;
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: panel,
      ),
    );
  }
}
