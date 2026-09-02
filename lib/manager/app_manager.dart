import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/permission.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/window_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/animated_visibility.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ref.listenManual(checkIpProvider, (prev, next) {
      if (prev != next && next.isInit && next.needsIpCheck) {
        ref.read(networkDetectionProvider.notifier).startCheck();
      }
    });
    ref.listenManual(currentProfileIdProvider, (prev, next) {
      if (prev == next) return;
      ref
          .read(profilesActionProvider.notifier)
          .applyPanelWidgetsOnProfileSwitch(prev);
    });
    ref.listenManual(configProvider, (prev, next) {
      if (prev != next) {
        ref.read(storeActionProvider.notifier).savePreferencesDebounce();
      }
    });
    ref.listenManual(needUpdateGroupsProvider, (prev, next) {
      if (prev != next) {
        ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
      }
    });
    if (system.isDesktop) {
      void syncPause() {
        final isStart = ref.read(isStartProvider);
        if (!isStart) {
          return;
        }
        debouncer.call(FunctionTag.smartPause, () async {
          final core = ref.read(coreHandlerProvider);
          try {
            if (ref.read(pausedProvider)) {
              await core.pauseTun();
              if (ref.read(vpnSettingProvider).smartPauseCloseConnections) {
                await core.closeConnections();
              }
            } else {
              await core.resumeTun();
            }
          } catch (error) {
            commonPrint.log(
              'Smart pause transition failed: $error',
              logLevel: LogLevel.warning,
            );
          }
          ref.read(checkIpNumProvider.notifier).add();
        });
      }

      // On Android the native module owns the transition; on desktop this is the enforcement.
      ref.listenManual(pausedProvider, (prev, next) {
        if (prev != next) {
          syncPause();
        }
      });
      // A start while already paused never sees a pausedProvider change, so the pause is re-issued.
      ref.listenManual(isStartProvider, (prev, next) {
        if (prev != next && next) {
          syncPause();
        }
      });
    }
    ref.listenManual(networkAnchorProvider, (prev, next) {
      if (!listEquals(prev, next) && next.isNotEmpty) {
        ref.read(manualPauseProvider.notifier).clear();
      }
    });
    ref.listenManual(isStartProvider, (prev, next) {
      if (prev != next && !next) {
        ref.read(manualPauseProvider.notifier).clear();
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

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    if (state == AppLifecycleState.resumed) {
      permissions.check(ref.read);
      render?.resume();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(setupActionProvider.notifier).tryCheckIp();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    ref.read(themeActionProvider.notifier).updateBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (_) {
        render?.resume();
      },
      child: widget.child,
    );
  }
}

class AppEnvManager extends StatelessWidget {
  final Widget child;

  const AppEnvManager({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      if (globalState.isPre) {
        return Banner(
          message: 'DEBUG',
          location: BannerLocation.topEnd,
          child: child,
        );
      }
    }
    if (globalState.isPre) {
      return Banner(
        message: globalState.appEnv.toUpperCase(),
        location: BannerLocation.topEnd,
        child: child,
      );
    }
    return child;
  }
}

class _SidebarRail extends StatelessWidget {
  const _SidebarRail({
    required this.items,
    required this.currentIndex,
    required this.showLabel,
    required this.onSelected,
  });

  final List<NavigationItem> items;
  final int currentIndex;
  final bool showLabel;
  final void Function(int index) onSelected;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.labelLarge!.copyWith(
      color: context.colorScheme.onSurface,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NavigationRail(
            scrollable: true,
            minExtendedWidth: 200,
            backgroundColor: Colors.transparent,
            selectedLabelTextStyle: labelStyle,
            unselectedLabelTextStyle: labelStyle,
            destinations: [
              for (final item in items)
                NavigationRailDestination(
                  icon: item.icon,
                  label: Text(item.label.label),
                ),
            ],
            onDestinationSelected: onSelected,
            extended: false,
            selectedIndex: currentIndex,
            labelType: showLabel
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.none,
          ),
        ),
      ],
    );
  }
}

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  Widget _buildBackground({
    required BuildContext context,
    required Widget child,
  }) {
    return Material(color: context.colorScheme.surfaceContainer, child: child);
  }

  void _updateSideBarWidth(WidgetRef ref, double contentWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideWidthProvider.notifier).value =
          ref.read(viewSizeProvider.select((state) => state.width)) -
          contentWidth;
    });
  }

  void _handleToPage(WidgetRef ref, PageLabel pageLabel) {
    final focusNode = FocusManager.instance.primaryFocus;
    final preserveNavigationFocus =
        focusNode?.context?.findAncestorWidgetOfExactType<NavigationRail>() !=
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
    final isMobileView = navigationState.viewMode == ViewMode.mobile;
    final currentIndex = navigationState.currentIndex;
    final showLabel = ref.watch(appSettingProvider).showLabel;
    return Container(
      color: context.colorScheme.surfaceContainer,
      child: Row(
        children: [
          AnimatedVisibility.sidebar(
            visible: !isMobileView,
            child: _buildBackground(
              context: context,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (system.isMacOS) const SizedBox(height: 22),
                    const SizedBox(height: 10),
                    if (!system.isMacOS) ...[
                      const ClipRect(child: AppIcon()),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: HiddenBarScrollBehavior(),
                        child: _SidebarRail(
                          items: navigationItems,
                          currentIndex: currentIndex,
                          showLabel: showLabel,
                          onSelected: (index) {
                            _handleToPage(ref, navigationItems[index].label);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      tooltip: context.appLocalizations.toggleLabel,
                      onPressed: () {
                        ref
                            .read(appSettingProvider.notifier)
                            .update(
                              (state) =>
                                  state.copyWith(showLabel: !state.showLabel),
                            );
                      },
                      icon: Icon(
                        Icons.menu,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
                  return child;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
