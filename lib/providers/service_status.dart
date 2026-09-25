import 'package:reclash/common/common.dart';
import 'package:reclash/providers/config.dart';
import 'package:riverpod/riverpod.dart'
    show Provider, ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core.dart';
import 'route_state.dart';
import 'routed_probe.dart';

part 'generated/service_status.g.dart';

/// The region's full catalog, before the user's order/disable choices.
final serviceTargetsProvider = Provider<List<ServiceTarget>>((ref) {
  return serviceTargetsForRegion(ref.watch(appRegionProvider));
});

/// The region catalog reordered by the user and pruned of disabled services.
final enabledServiceTargetsProvider = Provider<List<ServiceTarget>>((ref) {
  final allowed = ref.watch(serviceTargetsProvider);
  final order = ref.watch(
    appSettingProvider.select((state) => state.serviceOrder),
  );
  final disabled = ref
      .watch(appSettingProvider.select((state) => state.disabledServices))
      .toSet();
  return [
    for (final target in orderServiceTargets(order, allowed))
      if (!disabled.contains(target.id)) target,
  ];
});

@Riverpod(keepAlive: true)
class ServiceStatus extends _$ServiceStatus
    with RoutedProbe<ServiceTarget, ServiceCheck> {
  @override
  RoutedProbeState<ServiceTarget, ServiceCheck> build() => buildProbe();

  @override
  bool get batched => true;

  @override
  bool isFailure(ServiceCheck value) =>
      value.status == ServiceProbeStatus.timeout ||
      value.status == ServiceProbeStatus.failed;

  @override
  Future<Map<ServiceTarget, ProbeAnswer<ServiceCheck>>> probe(
    List<ServiceTarget> targets,
    RouteState route,
  ) async {
    final checks = await checkServices(
      ref.read(coreHandlerProvider),
      proxyName: route.proxied ? routedOutbound : directOutbound,
      targets: targets,
    );
    return {
      for (final MapEntry(key: target, value: check) in checks.entries)
        target: ProbeAnswer(
          value: check,
          coreEpoch: check.coreEpoch == 0 ? null : check.coreEpoch,
          picksVersion: check.picksVersion == 0 ? null : check.picksVersion,
          chains: check.chains,
        ),
    };
  }
}
