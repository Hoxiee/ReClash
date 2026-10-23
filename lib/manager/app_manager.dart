import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:reclash/common/common.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/icon.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _sidebarWallpaperOpacity = 0.5;
const _sidebarWallpaperBlur = 18.0;

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // A desktop build started to the tray mounts while hidden, and a paused
    // render never runs a post-frame callback.
    scheduleMicrotask(() {
      if (mounted) {
        _updateVisible(WidgetsBinding.instance.lifecycleState);
      }
    });
    ref.listenManual(providerSettingsSyncProvider, (_, _) {});
    ref.listenManual(configProvider, (prev, next) {
      if (prev != next) {
        ref.read(storeActionProvider.notifier).savePreferencesDebounce();
      }
    });
    ref.listenManual(groupsProvider, (prev, next) {
      if (prev != next) {
        unawaited(precacheTargetIcons(next.map((group) => group.icon)));
      }
    }, fireImmediately: true);
    ref.listenManual(iconSetsProvider, (_, next) {
      if (next.value case final iconSets?) {
        unawaited(
          precacheTargetIcons(iconSets.map((iconSet) => iconSet.cover)),
        );
      }
    }, fireImmediately: true);
    ref.listenManual(needUpdateGroupsProvider, (prev, next) {
      if (prev != next) {
        ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
      }
    });
    ref.listenManual(suspendProvider, (prev, next) {
      if (prev != next) {
        ref.read(setupActionProvider.notifier).syncSuspend();
      }
    });
    ref.listenManual(vpnSettingProvider, (prev, next) {
      if (prev?.onDemandFullStop != next.onDemandFullStop) {
        ref.read(setupActionProvider.notifier).syncSuspend();
      }
    });
    ref.listenManual(onDemandNetworkAnchorProvider, (prev, next) {
      final override = ref.read(onDemandOverrideProvider);
      if (next.isNotEmpty &&
          override.paused != null &&
          !listEquals(next, override.anchor)) {
        ref.read(onDemandOverrideProvider.notifier).clear();
      }
    });
    final systemDns = systemDnsCoordinator;
    if (systemDns != null) {
      ref.listenManual(shouldPatchSystemDnsProvider, (prev, next) {
        unawaited(systemDns.sync(next));
      }, fireImmediately: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateVisible(AppLifecycleState? state) {
    ref.read(appVisibleProvider.notifier).value = switch (state) {
      null || AppLifecycleState.resumed || AppLifecycleState.inactive => true,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => false,
    };
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    _updateVisible(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(locationPermissionsProvider.notifier).refresh());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(routeTrackerProvider.notifier).markResumed();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(themeActionProvider.notifier).updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppEnvManager extends ConsumerWidget {
  final Widget child;

  const AppEnvManager({super.key, required this.child});

  String? _bannerMessage({required bool safeMode}) {
    if (safeMode) {
      return 'SAFE MODE';
    }
    if (!globalState.isPre) {
      return null;
    }
    return kDebugMode ? 'DEBUG' : globalState.appEnv.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = _bannerMessage(safeMode: ref.watch(safeModeProvider));
    if (message == null) {
      return child;
    }
    return Banner(
      message: message,
      location: BannerLocation.topEnd,
      child: child,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.viewMode,
    required this.onSelected,
  });

  final List<NavigationItem> items;
  final int currentIndex;
  final ViewMode viewMode;
  final void Function(int index) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canExpand = canExpandSidebar(viewMode);
    final sidebarExpanded = ref.watch(
      appSettingProvider.select((state) => state.sidebarExpanded),
    );
    final version = ref.watch(versionProvider);
    return NavigationSidebar(
      destinations: [
        for (final item in items)
          SidebarDestination(
            id: item.label,
            glyph: item.glyph,
            label: item.label.label,
            group: navigationGroupOf(item.label),
          ),
      ],
      selectedIndex: currentIndex,
      expanded: canExpand && sidebarExpanded,
      onSelected: onSelected,
      onToggle: canExpand
          ? () {
              ref
                  .read(appSettingProvider.notifier)
                  .update(
                    (state) =>
                        state.copyWith(sidebarExpanded: !state.sidebarExpanded),
                  );
            }
          : null,
      windowControls: windowControlsOverSidebar(
        isMacOS: system.isMacOS,
        version: version,
      ),
    );
  }
}

class _SidebarBackground extends StatefulWidget {
  const _SidebarBackground({
    required this.wallpaperActive,
    required this.windowBlur,
    required this.child,
  });

  final bool wallpaperActive;
  final bool windowBlur;
  final Widget child;

  @override
  State<_SidebarBackground> createState() => _SidebarBackgroundState();
}

class _SidebarBackgroundState extends State<_SidebarBackground> {
  final GlobalKey _panelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = widget.wallpaperActive
        ? colorScheme.chromeSurface.withValues(alpha: _sidebarWallpaperOpacity)
        : widget.windowBlur
        ? colorScheme.chromeSurface.withValues(alpha: kSidebarBlurOpacity)
        : colorScheme.chromeSurface;
    final panel = Material(
      key: _panelKey,
      color: color,
      shape: BorderDirectional(end: Divider.createBorderSide(context)),
      child: widget.child,
    );
    if (!widget.wallpaperActive) return panel;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _sidebarWallpaperBlur,
          sigmaY: _sidebarWallpaperBlur,
        ),
        child: panel,
      ),
    );
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  void _updateSideBarWidth(WidgetRef ref, double contentWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value =
          ref.read(viewSizeProvider.select((state) => state.width)) -
          contentWidth;
    });
  }

  void _handleToPage(WidgetRef ref, PageLabel pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final focusContext = focusNode?.context;
    final preserveNavigationFocus =
        focusContext?.findAncestorWidgetOfExactType<NavigationSidebar>() !=
        null;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationStateProvider);
    final navigationItems = navigationState.navigationItems;
    final viewMode = navigationState.viewMode;
    final currentIndex = navigationState.currentIndex;
    final blur = ref.watch(windowBlurProvider);
    final wallpaperActive = ref.watch(effectiveWallpaperImageProvider) != null;
    final page = SurfaceLevel.page.colorOf(context.colorScheme);
    void onSelected(int index) {
      _handleToPage(ref, navigationItems[index].label);
    }

    final hasSidebar = viewMode != ViewMode.mobile;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    return PageBackground(
      baseColor: blur && !wallpaperActive ? Colors.transparent : page,
      child: Container(
        color: blur || wallpaperActive ? Colors.transparent : page,
        child: Row(
          children: [
            AnimatedVisibility.sidebar(
              visible: hasSidebar,
              child: _SidebarBackground(
                wallpaperActive: wallpaperActive,
                windowBlur: blur,
                child: MediaQuery.removePadding(
                  context: context,
                  removeLeft: !isLtr,
                  removeRight: isLtr,
                  child: _Sidebar(
                    items: navigationItems,
                    currentIndex: currentIndex,
                    viewMode: viewMode,
                    onSelected: onSelected,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    _updateSideBarWidth(ref, constraints.maxWidth);
                    return ColoredBox(
                      color: wallpaperActive ? Colors.transparent : page,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeLeft: hasSidebar && isLtr,
                        removeRight: hasSidebar && !isLtr,
                        child: child,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
