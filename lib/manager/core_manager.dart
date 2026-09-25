import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/connection_doctor.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/route_state.dart';
import 'package:reclash/providers/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreManager extends ConsumerStatefulWidget {
  final Widget child;

  const CoreManager({super.key, required this.child});

  @override
  ConsumerState<CoreManager> createState() => _CoreContainerState();
}

class _CoreContainerState extends ConsumerState<CoreManager>
    with CoreEventListener {
  CoreController get _core => ref.read(coreHandlerProvider);
  int? _profileSetupId;

  void _scheduleFullSetup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(setupActionProvider.notifier).fullSetup());
    });
  }

  void _scheduleProfileSetup(int? profileId) {
    _profileSetupId = profileId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_profileSetupId == profileId) {
        _profileSetupId = null;
      }
      unawaited(ref.read(setupActionProvider.notifier).fullSetup());
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    coreEventManager.addListener(this);
    ref.read(updatingActionProvider.notifier);
    // A rejected profile stays selected on purpose: silently reverting to
    // the previous one hides the error and looks like the switch was lost.
    ref.listenManual(currentProfileIdProvider, (prev, next) {
      if (prev == next) return;
      _scheduleProfileSetup(next);
    });
    ref.listenManual(updateParamsProvider, (prev, next) {
      if (prev != next) {
        ref.read(setupActionProvider.notifier).updateConfigDebounce();
      }
    });
    ref.listenManual(smartRoutingSettingProvider, (prev, next) {
      if (prev == next) {
        return;
      }
      if (ref.read(coreStatusProvider) == CoreStatus.connected) {
        unawaited(
          _core
              .configureSmartRouting(
                next.rcxParamsFor(ref.read(currentProfileProvider)),
              )
              .then(
                (_) {},
                // An older core without the rcx methods keeps tunneling; the
                // next start re-syncs the engine when a matching core returns.
                onError: (Object error) => commonPrint.log(
                  'smart routing sync skipped: $error',
                  logLevel: LogLevel.warning,
                ),
              ),
        );
      }
      // The RCX groups only exist in profiles built while enabled, so the
      // flip has to rebuild the whole profile, not just the engine config.
      if (prev?.enabled != next.enabled) {
        _scheduleFullSetup();
      }
    });
    ref.listenManual(
      currentProfileProvider.select(
        (profile) => (
          policies: profile?.serviceRoutePolicies,
          manifest: profile?.capabilityManifest,
          manual: profile?.manualCapabilitySelectors,
        ),
      ),
      (prev, next) {
        if (prev == next) return;
        if (ref.read(coreStatusProvider) == CoreStatus.connected) {
          final params = ref
              .read(smartRoutingSettingProvider)
              .rcxParamsFor(ref.read(currentProfileProvider));
          unawaited(
            _core.configureSmartRouting(params).catchError((Object error) {
              commonPrint.log(
                'smart routing lane sync skipped: $error',
                logLevel: LogLevel.warning,
              );
              return false;
            }),
          );
        }
        final profileId = ref.read(currentProfileIdProvider);
        if (_profileSetupId != profileId) {
          _scheduleFullSetup();
        }
      },
    );
    // Rules and the outbound only exist in profiles built while it was on, so the
    // flip has to rebuild the config, not just push options to the service.
    // Strategy and cache keys are engine-only: they reach the listener through
    // VpnOptions, and the strategy tester flips them dozens of times a run.
    ref.listenManual(
      effectiveDesyncSettingProvider.select(
        (state) => (
          enabled: state.enabled,
          onlyDpi: state.onlyDpi,
          port: state.port,
          // A new List with the same categories is not a new selection.
          categories: state.categories.map((e) => e.name).join(','),
          forceTcp: state.forceTcp,
        ),
      ),
      (prev, next) {
        if (prev == next) return;
        _scheduleFullSetup();
      },
    );
    ref.listenManual(
      appSettingProvider.select((state) => state.smartRoutingDiagnostics),
      (prev, next) {
        if (prev == next) return;
        if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
        unawaited(
          _core.setSmartRoutingDiagnostics(next).then(
            (_) {},
            onError: (Object error) => commonPrint.log(
              'smart routing diagnostics sync skipped: $error',
              logLevel: LogLevel.warning,
            ),
          ),
        );
      },
    );
    ref.listenManual(appSettingProvider.select((state) => state.openLogs), (
      prev,
      next,
    ) {
      if (next) {
        _core.startLog();
      } else {
        _core.stopLog();
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    coreEventManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onDelay(Delay delay) async {
    super.onDelay(delay);
    final proxiesAction = ref.read(proxiesActionProvider.notifier);
    proxiesAction.setDelay(delay);
    debouncer.call(FunctionTag.updateDelay, () async {
      proxiesAction.updateGroupsDebounce();
    }, duration: const Duration(milliseconds: 5000));
  }

  @override
  void onLog(Log log) {
    fileLogger.log('[CORE ${log.logLevel.name.toUpperCase()}] ${log.payload}');
    ref.read(logsProvider.notifier).add(log);
    if (log.logLevel == LogLevel.error) {
      throttler.call(
        FunctionTag.coreErrorNotifier,
        () => dialogs.showNotifier(log.payload, level: MessageLevel.error),
        duration: const Duration(seconds: 3),
        fire: true,
      );
    }
    super.onLog(log);
  }

  @override
  void onRequest(TrackerInfo trackerInfo) async {
    ref.read(requestsProvider.notifier).addRequest(trackerInfo);
    super.onRequest(trackerInfo);
  }

  @override
  void onDnsQuery(DnsQuery dnsQuery) {
    ref.read(dnsQueriesProvider.notifier).addDnsQuery(dnsQuery);
    super.onDnsQuery(dnsQuery);
  }

  @override
  Future<void> onLoaded(String providerName) async {
    final provider = await _core.getExternalProvider(providerName);
    if (!mounted) {
      return;
    }
    ref.read(providersProvider.notifier).setProvider(provider);
    debouncer.call(FunctionTag.loadedProvider, () async {
      if (!mounted) {
        return;
      }
      ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
    }, duration: const Duration(milliseconds: 5000));
    super.onLoaded(providerName);
  }

  @override
  Future<void> onCrash(String message) async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) {
      return;
    }
    ref.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      context.showNotifier(message, level: MessageLevel.error);
    }
    super.onCrash(message);
  }

  @override
  void onRcxStatus(RcxStatus status) {
    ref.read(smartRoutingStatusProvider.notifier).value = status;
    ref.read(smartRoutingTrailProvider.notifier).update((trail) {
      return status.enabled ? rcxTrailWith(trail, status.node) : const [];
    });
    super.onRcxStatus(status);
  }

  @override
  void onDoctorStatus(DoctorStatus status) {
    final snapshot = ref.read(connectionDoctorProvider);
    if (status.revision > snapshot.revision) {
      unawaited(
        ref
            .read(connectionDoctorProvider.notifier)
            .refreshFromStatus(minimumRevision: status.revision)
            .catchError((Object error) {
              commonPrint.log(
                'Connection doctor refresh failed: $error',
                logLevel: coreFailureLogLevel(error),
              );
              return snapshot;
            }),
      );
    }
    super.onDoctorStatus(status);
  }

  @override
  void onGeoUpdate(String geoType, bool updating, bool skipped, String? error) {
    ref
        .read(geoResourceActionProvider.notifier)
        .handleCoreUpdate(geoType, updating, skipped, error);
    super.onGeoUpdate(geoType, updating, skipped, error);
  }

  @override
  void onRouteChanged(RouteSnapshot snapshot) {
    ref.read(routeTrackerProvider.notifier).applySnapshot(snapshot);
    super.onRouteChanged(snapshot);
  }
}
