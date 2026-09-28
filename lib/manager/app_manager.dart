import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/app/permission.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/net/system_dns.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/effect/animated_visibility.dart';
import 'package:reclash/widgets/nav/app_nav_rail.dart';
import 'package:reclash/widgets/theme/wallpaper.dart';

class AppStateManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  ConsumerState<AppStateManager> createState() => _AppStateManagerState();
}

class _AppStateManagerState extends ConsumerState<AppStateManager>
    with WidgetsBindingObserver {
  Timer? _milestoneTimer;
  Future<void> _uiActiveOperation = Future.value();
  bool? _pendingUiActive;
  bool? _sentUiActive;
  var _uiActiveConnectionRevision = 0;
  int? _sentUiActiveRevision;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncRuntimeActivity(WidgetsBinding.instance.lifecycleState);
    _startMilestoneTimer();
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
    ref.listenManual(pausedProvider, (prev, next) {
      if (prev == next || !ref.read(isStartProvider)) {
        return;
      }
      final vpn = ref.read(vpnSettingProvider);
      final rule = smartPauseMatchedRules(
        vpn.smartPauseNetworks,
        ssid: ref.read(currentSSIDProvider),
        ipv4s: ref.read(currentIPv4sProvider),
        ipv6s: ref.read(currentIPv6sProvider),
        strict: vpn.smartPauseStrict,
      ).firstOrNull;
      ref
          .read(smartPauseLastEventProvider.notifier)
          .record(paused: next, rule: rule ?? '');
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
    // The screen-off signal arrives out of band from lifecycle changes, so a
    // re-sync folds it into the Android runtime gates when it flips.
    ref.listenManual(screenOffProvider, (prev, next) {
      if (prev != next) {
        _syncRuntimeActivity(WidgetsBinding.instance.lifecycleState);
      }
    });
    ref.listenManual(isStartProvider, (prev, next) {
      if (prev != next && !next) {
        ref.read(manualPauseProvider.notifier).clear();
        ref.read(smartRoutingStatusProvider.notifier).value = null;
      }
    });
    ref.listenManual(coreStatusProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      final doctor = ref.read(connectionDoctorProvider.notifier);
      if (prev != null) {
        doctor.resetForCoreConnection();
      }
      if (next == CoreStatus.disconnected && prev != null) {
        ref.read(milestonesProvider.notifier).coreDisconnected();
      }
      if (next == CoreStatus.connected) {
        _requestUiActiveSync(force: true);
        unawaited(
          ref.read(milestonesProvider.notifier).refresh().catchError((
            Object error,
          ) {
            commonPrint.log(
              'Milestone refresh failed: $error',
              logLevel: coreFailureLogLevel(error),
            );
          }),
        );
        unawaited(
          doctor.refreshFromStatus().catchError((Object error) {
            commonPrint.log(
              'Connection doctor reconnect refresh failed: $error',
              logLevel: coreFailureLogLevel(error),
            );
            return ref.read(connectionDoctorProvider);
          }),
        );
      }
    }, fireImmediately: true);
    final systemDns = systemDnsCoordinator;
    if (systemDns != null) {
      ref.listenManual(shouldPatchSystemDnsProvider, (prev, next) {
        unawaited(systemDns.sync(next));
      }, fireImmediately: true);
    }
  }

  void _syncRuntimeActivity(AppLifecycleState? state) {
    final screenOff = ref.read(screenOffProvider);
    unawaited(
      ref
          .read(connectionDoctorProvider.notifier)
          .updateActivity(
            lifecycleState: state,
            isAndroid: system.isAndroid,
            screenOff: screenOff,
          )
          .catchError((Object error) {
            commonPrint.log(
              'Connection doctor resume refresh failed: $error',
              logLevel: coreFailureLogLevel(error),
            );
            return unsupportedDoctorSnapshot;
          }),
    );
    ref
        .read(setupActionProvider.notifier)
        .updateRuntimeActivity(
          lifecycleState: state,
          isAndroid: system.isAndroid,
          screenOff: screenOff,
        );
    ref
        .read(routeTrackerProvider.notifier)
        .updateActivity(
          lifecycleState: state,
          isAndroid: system.isAndroid,
          screenOff: screenOff,
        );
  }

  void _requestUiActiveSync({bool force = false}) {
    final active =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (!force && _pendingUiActive == active) {
      return;
    }
    _pendingUiActive = active;
    if (force) {
      _uiActiveConnectionRevision++;
      _sentUiActive = null;
      _sentUiActiveRevision = null;
    }
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    final connectionRevision = _uiActiveConnectionRevision;
    _uiActiveOperation = _uiActiveOperation.then((_) async {
      final pending = _pendingUiActive;
      if (pending == null ||
          (_sentUiActive == pending &&
              _sentUiActiveRevision == connectionRevision)) {
        return;
      }
      try {
        if (await ref.read(coreHandlerProvider).setUiActive(pending)) {
          if (connectionRevision == _uiActiveConnectionRevision) {
            _sentUiActive = pending;
            _sentUiActiveRevision = connectionRevision;
          }
        }
      } catch (error) {
        commonPrint.log(
          'UI activity sync failed: $error',
          logLevel: coreFailureLogLevel(error),
        );
      }
    });
  }

  void _startMilestoneTimer() {
    _milestoneTimer ??= Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshMilestones();
    });
  }

  void _stopMilestoneTimer() {
    _milestoneTimer?.cancel();
    _milestoneTimer = null;
  }

  void _refreshMilestones() {
    if (!mounted ||
        ref.read(coreStatusProvider) != CoreStatus.connected ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.hidden) {
      return;
    }
    unawaited(
      ref.read(milestonesProvider.notifier).refresh().catchError((
        Object error,
      ) {
        commonPrint.log(
          'Milestone refresh failed: $error',
          logLevel: coreFailureLogLevel(error),
        );
      }),
    );
  }

  @override
  void dispose() {
    _milestoneTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    _syncRuntimeActivity(state);
    _requestUiActiveSync();
    if (state == AppLifecycleState.resumed) {
      _startMilestoneTimer();
      _refreshMilestones();
      permissions.check(ref.read);
      render?.resume();
      ref.read(themeActionProvider.notifier).updateBrightness();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(routeTrackerProvider.notifier).markResumed();
        ref.read(setupActionProvider.notifier).tryCheckIp();
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _stopMilestoneTimer();
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

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  Widget _buildBackground({
    required BuildContext context,
    required bool active,
    required Widget child,
  }) {
    final colorScheme = context.colorScheme;
    final panel = Material(
      // Card opacity keeps the rail near-solid; a wallpaper wants it frosted, so
      // drop to a glass alpha and let the backdrop blur carry the image through.
      color: active
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
        child: child,
      ),
    );
    if (!active) {
      return panel;
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: panel,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobileView = ref.watch(isMobileViewProvider);
    final sidebarExpanded = ref.watch(
      appSettingProvider.select((state) => state.sidebarExpanded),
    );
    // One wallpaper spans the whole shell so the rail shares the content's
    // continuous backdrop instead of standing as an opaque cut-out beside it.
    return AppWallpaper(
      // The painted wallpaper sits behind this builder, so a solid fill here
      // would hide it; tint only when there is no wallpaper to show through.
      builder: (context, active) => Container(
        color: active ? null : context.colorScheme.surfaceContainer,
        child: Row(
          children: [
            AnimatedVisibility.sidebar(
              visible: !isMobileView,
              child: _buildBackground(
                context: context,
                active: active,
                child: SafeArea(
                  child: Column(
                    children: [
                      if (system.isMacOS) const SizedBox(height: 22),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const HiddenBarScrollBehavior(),
                          child: AppNavRail(
                            expanded: sidebarExpanded,
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
