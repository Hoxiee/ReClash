import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/state.dart';
import 'package:riverpod/riverpod.dart'
    show Provider, ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/service_status.g.dart';

typedef ServiceChecker =
    Future<Map<ServiceTarget, ServiceCheck>> Function(
      List<ServiceTarget> targets, {
      CancelToken? cancelToken,
    });

/// Swapped out in tests so the card can build without touching the network.
final serviceCheckerProvider = Provider<ServiceChecker>((ref) {
  return (targets, {cancelToken}) =>
      checkServices(targets, cancelToken: cancelToken);
});

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

@immutable
class ServiceStatusState {
  const ServiceStatusState({
    this.checks = const {},
    this.loading = const {},
  });

  final Map<ServiceTarget, ServiceCheck> checks;
  final Set<ServiceTarget> loading;

  bool isLoading(ServiceTarget target) => loading.contains(target);

  ServiceCheck? checkOf(ServiceTarget target) => checks[target];

  ServiceStatusState copyWith({
    Map<ServiceTarget, ServiceCheck>? checks,
    Set<ServiceTarget>? loading,
  }) {
    return ServiceStatusState(
      checks: checks ?? this.checks,
      loading: loading ?? this.loading,
    );
  }
}

@Riverpod(keepAlive: true)
class ServiceStatus extends _$ServiceStatus with AutoDisposeNotifierMixin {
  CancelToken? _token;

  @override
  ServiceStatusState build() {
    ref.onDispose(() => _token?.cancel());
    return const ServiceStatusState();
  }

  /// Probes [targets] not already in flight; a no-op while the core is stopped,
  /// so nothing leaves the app before there is a proxy to route through.
  Future<void> refresh(List<ServiceTarget> targets) async {
    if (targets.isEmpty || !ref.read(isStartProvider)) {
      return;
    }
    final pending = targets
        .where((target) => !state.loading.contains(target))
        .toList();
    if (pending.isEmpty) {
      return;
    }
    value = state.copyWith(loading: {...state.loading, ...pending});
    final token = CancelToken();
    _token = token;
    try {
      final results = await ref.read(serviceCheckerProvider)(
        pending,
        cancelToken: token,
      );
      if (!ref.mounted) {
        return;
      }
      value = state.copyWith(
        checks: {...state.checks, ...results},
        loading: state.loading.difference(pending.toSet()),
      );
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
      value = state.copyWith(
        loading: state.loading.difference(pending.toSet()),
      );
    }
  }
}
