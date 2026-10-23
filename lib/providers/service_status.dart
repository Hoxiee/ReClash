import 'dart:async';

import 'package:reclash/common/mixin.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';
import 'core.dart';
import 'route_state.dart';
import 'routed_probe.dart';

part 'generated/service_status.g.dart';

@Riverpod(keepAlive: true)
class ServiceStatus extends _$ServiceStatus
    with RoutedProbe<ServiceTarget, ServiceCheck> {
  Timer? _automaticTimer;

  @override
  bool get automaticChecks => false;

  @override
  RoutedProbeState<ServiceTarget, ServiceCheck> build() {
    final initial = buildProbe();
    ref.listen(routeTrackerProvider, (previous, next) {
      if (previous?.coreEpoch != next.coreEpoch ||
          previous?.hostEpoch != next.hostEpoch ||
          previous?.routeVersion != next.routeVersion ||
          previous?.proxied != next.proxied ||
          previous?.live != next.live ||
          previous?.synced != next.synced) {
        _scheduleAutomatic();
      }
    });
    ref.listen(appVisibleProvider, (_, _) => _scheduleAutomatic());
    ref.listen(
      appSettingProvider.select(
        (settings) => (
          settings.autoCheckActiveServices,
          settings.autoCheckAllServices,
          settings.serviceCheckOnlyWhenConnected,
        ),
      ),
      (_, _) => _scheduleAutomatic(),
    );
    ref.listen(enabledServiceTargetsProvider, (_, _) => _scheduleAutomatic());
    final tracker = ref.read(routeTrackerProvider.notifier);
    var attached = false;
    scheduleMicrotask(() {
      if (!ref.mounted) return;
      attached = true;
      tracker.attach();
      _scheduleAutomatic();
    });
    ref.onDispose(() {
      _automaticTimer?.cancel();
      if (attached) scheduleMicrotask(tracker.detach);
    });
    return initial;
  }

  void _scheduleAutomatic() {
    _automaticTimer?.cancel();
    final settings = ref.read(appSettingProvider);
    final route = ref.read(routeTrackerProvider);
    if ((!settings.autoCheckActiveServices && !settings.autoCheckAllServices) ||
        !route.live ||
        !route.synced ||
        !ref.read(appVisibleProvider) ||
        (settings.serviceCheckOnlyWhenConnected && !route.proxied)) {
      return;
    }
    _automaticTimer = Timer(const Duration(seconds: 3), () {
      if (!ref.mounted) return;
      refresh(
        settings.autoCheckAllServices
            ? ref.read(serviceTargetsProvider)
            : ref.read(enabledServiceTargetsProvider),
      );
    });
  }

  @override
  bool isFailure(ServiceCheck value) =>
      value.status == ServiceProbeStatus.timeout ||
      value.status == ServiceProbeStatus.failed;

  @override
  Future<Map<ServiceTarget, ProbeAnswer<ServiceCheck>>> probe(
    ServiceTarget target,
    RouteState route,
  ) async {
    final checks = await checkServices(
      ref.read(coreHandlerProvider),
      proxyName: route.proxied ? '' : directOutbound,
      targets: [target],
    );
    final check = checks[target];
    return {
      if (check != null)
        target: ProbeAnswer(
          value: check,
          coreEpoch: check.coreEpoch,
          routeVersion: check.routeVersion,
          hits: check.hits,
        ),
    };
  }
}

/// How many of [enabledServiceTargets] the dashboard card has room for, which
/// its sheet marks as shown there.
@Riverpod(keepAlive: true)
class ShownServiceCount extends _$ShownServiceCount
    with AutoDisposeNotifierMixin {
  @override
  int build() => 2;
}

@riverpod
List<ServiceTarget> serviceTargets(Ref ref) {
  final order = ref.watch(
    appSettingProvider.select((state) => SelectValue(state.serviceOrder)),
  );
  return orderServiceTargets(order.value);
}

@riverpod
List<ServiceTarget> enabledServiceTargets(Ref ref) {
  final settings = ref.watch(
    appSettingProvider.select(
      (state) => (
        regionCode: state.regionCode,
        serviceOrder: state.serviceOrder,
        enabledServices: state.enabledServices,
        disabledServices: state.disabledServices,
      ),
    ),
  );
  return enabledServiceTargetsForRegion(
    regionCode: settings.regionCode,
    order: settings.serviceOrder,
    enabled: settings.enabledServices.toSet(),
    disabled: settings.disabledServices.toSet(),
  );
}
