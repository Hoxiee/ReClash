import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/common/permission.dart';
import 'package:reclash/common/system_dns.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/animated_visibility.dart';
import 'package:reclash/widgets/app_nav_rail.dart';
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
  Future<void> _uiActiveOperation = Future.value();
  bool? _pendingUiActive;
  bool? _sentUiActive;
  var _uiActiveConnectionRevision = 0;
  int? _sentUiActiveRevision;

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
      if (next == CoreStatus.connected) {
        _requestUiActiveSync(force: true);
        unawaited(
          doctor.refresh().catchError((Object error) {
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    commonPrint.log('$state');
    _requestUiActiveSync();
    if (state == AppLifecycleState.resumed) {
      permissions.check(ref.read);
      render?.resume();
      ref.read(themeActionProvider.notifier).updateBrightness();
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

class AppSidebarContainer extends ConsumerWidget {
  final Widget child;

  const AppSidebarContainer({super.key, required this.child});

  Widget _buildBackground({
    required BuildContext context,
    required Widget child,
  }) {
    return Material(
      color: context.colorScheme.surfaceContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: child,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobileView = ref.watch(isMobileViewProvider);
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
                  children: [
                    if (system.isMacOS) const SizedBox(height: 22),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const HiddenBarScrollBehavior(),
                        child: AppNavRail(
                          leading: navigationPort?.buildStatusMark(),
                          onToPage: (label) => _handleToPage(ref, label),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: ClipRect(child: child)),
        ],
      ),
    );
  }
}
