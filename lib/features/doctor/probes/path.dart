import 'dart:async';

import 'package:reclash/common/network_cost.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/doctor.dart';
import 'package:reclash/providers/outbound_ip.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/routed_probe.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;
import 'package:riverpod/riverpod.dart';

import '../cause.dart';
import '../kernel.dart';
import '../path.dart';
import '../rules/device.dart';
import '../rules/profile.dart';
import '../snapshot.dart';
import 'clock.dart';
import 'scheduler.dart';

enum PathTarget { reach, internet }

const _probeTimeout = Duration(seconds: 8);
const _answerTimeout = Duration(seconds: 20);
const _routedTtl = Duration(minutes: 2);

/// The node reach and the `generate_204` behind the server, dns and internet
/// steps, asked only when a path runs.
final pathRouteProbeProvider =
    NotifierProvider<PathRouteProbe, RoutedProbeState<PathTarget, Object>>(
      PathRouteProbe.new,
    );

class PathRouteProbe extends Notifier<RoutedProbeState<PathTarget, Object>>
    with RoutedProbe<PathTarget, Object> {
  @override
  RoutedProbeState<PathTarget, Object> build() => buildProbe();

  @override
  bool get automaticChecks => false;

  @override
  bool isFailure(Object value) => switch (value) {
    ReachResult(:final cause) => cause != null,
    ProbeResult(:final error, :final statusCode) =>
      error != null || statusCode < 200 || statusCode >= 400,
    _ => false,
  };

  @override
  Future<Map<PathTarget, ProbeAnswer<Object>>> probe(
    PathTarget target,
    RouteState route,
  ) async {
    final core = ref.read(coreHandlerProvider);
    final url = ref.read(patchClashConfigProvider).testUrl;
    final timeout = _probeTimeout.inMilliseconds;
    final answer = switch (target) {
      PathTarget.reach => switch (await core.reach(
        ReachParams(url: url, timeout: timeout),
      )) {
        final result? => ProbeAnswer<Object>(
          value: result,
          coreEpoch: result.coreEpoch,
          routeVersion: result.routeVersion,
          hits: result.hits,
        ),
        null => const ProbeAnswer<Object>(),
      },
      PathTarget.internet => switch (await core.probe(
        ProbeParams(url: url, timeout: timeout),
      )) {
        final result? => ProbeAnswer<Object>(
          value: result,
          coreEpoch: result.coreEpoch,
          routeVersion: result.routeVersion,
          hits: result.hits,
        ),
        null => const ProbeAnswer<Object>(),
      },
    };
    return {target: answer};
  }
}

/// The route counters a routed answer is valid for.
Object pathIntent(Ref ref) {
  final route = ref.read(routeTrackerProvider);
  return (
    route.coreEpoch,
    route.routeVersion,
    route.hostEpoch,
    route.proxied,
    ref.read(patchClashConfigProvider).testUrl,
  );
}

/// Asks [target] of a routed probe and waits for its answer; null when it
/// cannot be asked now or does not describe the route in force any more.
Future<V?> _askRouted<K, V>(
  Ref ref,
  RoutedProbe<K, V> probe,
  ProviderListenable<ProbeEntry<V>> entry,
  K target,
  ProbeToken token,
) async {
  if (!ref.read(appVisibleProvider)) return null;
  final answer = Completer<ProbeEntry<V>>();
  var launched = false;
  final subscription = ref.listen(entry, (_, next) {
    launched |= next.isLoading;
    if (launched && !next.isLoading && !answer.isCompleted) {
      answer.complete(next);
    }
  }, fireImmediately: true);
  probe
    ..watch(target)
    ..refresh([target]);
  try {
    final result = await Future.any<ProbeEntry<V>?>([
      answer.future,
      token.whenCancelled.then((_) => throw ProbeCancelled('$target')),
    ]).timeout(_answerTimeout, onTimeout: () => null);
    final stamp = result?.stamp;
    if (result == null ||
        stamp == null ||
        !ref.read(routeTrackerProvider).isFresh(stamp)) {
      return null;
    }
    return result.value;
  } finally {
    subscription.close();
    probe.unwatch(target);
  }
}

Future<ReachResult?> _reach(Ref ref, DiagnosticKernel kernel) {
  return kernel.probe(
    ProbeRequest<ReachResult>(
      key: 'path.reach',
      cost: CheckCost.network,
      ttl: _routedTtl,
      intent: pathIntent(ref),
      run: (token) async {
        final probe = ref.read(pathRouteProbeProvider.notifier);
        final value = await _askRouted(
          ref,
          probe,
          pathRouteProbeProvider.select(
            (state) => state.entryOf(PathTarget.reach),
          ),
          PathTarget.reach,
          token,
        );
        if (value is! ReachResult) {
          throw const ProbeFailure(FailureCause.unknown);
        }
        return value;
      },
    ),
  );
}

FailureCause _causeOf(String? wire) =>
    FailureCause.fromWire(wire) ?? FailureCause.unknown;

bool _connected(Ref ref) =>
    ref.read(coreStatusProvider) == CoreStatus.connected &&
    ref.read(isStartProvider) &&
    !ref.read(suspendProvider);

T? _device<T extends Object>(DiagnosticKernel kernel, FactKey<T> key) =>
    kernel.snapshot.at(DateTime.now()).valueOf(key);

String _signed(Duration skew) =>
    '${skew.isNegative ? '−' : '+'}${skew.inSeconds.abs()} s';

/// The checks behind each step, read when the step starts so the intent is
/// the route in force at that moment.
PathCheck? pathCheck(Ref ref, DiagnosticKernel kernel, PathStep step) {
  final intent = pathIntent(ref);
  return switch (step) {
    PathStep.network => PathCheck(
      cost: CheckCost.local,
      run: (_) async {
        final network = await createNetworkCostMonitor().read();
        if (network.cost == NetworkCost.offline) {
          return const StepCheck.fail(FailureCause.noNetwork);
        }
        return _device(kernel, Facts.captivePortal) == true
            ? const StepCheck.fail(FailureCause.captivePortal)
            : const StepCheck.pass();
      },
    ),
    PathStep.clock => PathCheck(
      cost: CheckCost.local,
      intent: intent,
      ttl: clockSkewTtl,
      run: (_) async {
        if (!_connected(ref)) return const StepCheck.unknown();
        try {
          final skew = await kernel.probe(
            clockSkewProbe(
              ref.read(coreHandlerProvider).clockSkew,
              url: ref.read(patchClashConfigProvider).testUrl,
            ),
          );
          return skew.abs() >= clockSkewCritical
              ? StepCheck.fail(FailureCause.clockSkew, detail: _signed(skew))
              : StepCheck.pass(detail: _signed(skew));
        } on ProbeFailure {
          return const StepCheck.unknown();
        }
      },
    ),
    PathStep.core => PathCheck(
      cost: CheckCost.local,
      run: (_) async => ref.read(coreStatusProvider) == CoreStatus.connected
          ? const StepCheck.pass()
          : const StepCheck.fail(FailureCause.coreDown),
    ),
    PathStep.profile => PathCheck(
      cost: CheckCost.local,
      run: (_) async {
        final profile = ref.read(currentProfileProvider);
        if (profile == null) {
          return const StepCheck.fail(FailureCause.profileInvalid);
        }
        final finding = subscriptionRule(kernel.snapshot.at(DateTime.now()));
        return finding?.cause != null
            ? StepCheck.fail(finding!.cause, detail: profile.realLabel)
            : StepCheck.pass(detail: profile.realLabel);
      },
    ),
    PathStep.tunnel => PathCheck(
      cost: CheckCost.local,
      run: (_) async {
        if (_connected(ref)) return const StepCheck.pass();
        if (_device(kernel, Facts.vpnPermission) == VpnPermission.revoked) {
          return const StepCheck.fail(FailureCause.tunnelDenied);
        }
        return _device(kernel, Facts.otherVpn) == true
            ? const StepCheck.fail(FailureCause.tunnelTaken)
            : const StepCheck.fail(null);
      },
    ),
    PathStep.dns => PathCheck(
      cost: CheckCost.local,
      intent: intent,
      ttl: _routedTtl,
      run: (_) async {
        final reach = await _reach(ref, kernel);
        if (reach == null) return const StepCheck.unknown();
        if (reach.stage == 'dns') {
          return StepCheck.fail(FailureCause.dnsFailed, detail: reach.message);
        }
        return _device(kernel, Facts.privateDns) == PrivateDnsMode.strict
            ? StepCheck.pass(
                detail:
                    'Private DNS · ${_device(kernel, Facts.privateDnsHost)}',
              )
            : const StepCheck.pass();
      },
    ),
    PathStep.server => PathCheck(
      cost: CheckCost.local,
      intent: intent,
      ttl: _routedTtl,
      run: (_) async {
        final reach = await _reach(ref, kernel);
        if (reach == null) return const StepCheck.unknown();
        if (reach.direct) return const StepCheck.unknown(detail: 'DIRECT');
        return reach.cause != null
            ? StepCheck.fail(_causeOf(reach.cause), detail: reach.proxy)
            : StepCheck.pass(detail: reach.proxy);
      },
    ),
    PathStep.internet => PathCheck(
      cost: CheckCost.network,
      intent: intent,
      ttl: _routedTtl,
      run: (token) async {
        final value = await _askRouted(
          ref,
          ref.read(pathRouteProbeProvider.notifier),
          pathRouteProbeProvider.select(
            (state) => state.entryOf(PathTarget.internet),
          ),
          PathTarget.internet,
          token,
        );
        if (value is! ProbeResult) return const StepCheck.unknown();
        if (value.error != null) {
          return StepCheck.fail(_causeOf(value.cause), detail: value.message);
        }
        if (value.statusCode < 200 || value.statusCode >= 400) {
          return StepCheck.fail(
            FailureCause.noUpstream,
            detail: 'HTTP ${value.statusCode}',
          );
        }
        final ip = await _askRouted(
          ref,
          ref.read(outboundIpProbeProvider.notifier),
          outboundIpProbeProvider.select(
            (state) => state.entryOf(routedOutbound),
          ),
          routedOutbound,
          token,
        );
        return StepCheck.pass(
          detail: ip == null ? null : '${ip.ip} · ${ip.countryCode}',
        );
      },
    ),
    PathStep.services => _servicesCheck(ref, intent),
  };
}

const _blockingServiceStatuses = {
  ServiceProbeStatus.unavailable,
  ServiceProbeStatus.restricted,
  ServiceProbeStatus.disallowedIsp,
  ServiceProbeStatus.blocked,
  ServiceProbeStatus.unsupportedRegion,
};

PathCheck? _servicesCheck(Ref ref, Object intent) {
  final targets = ref.read(enabledServiceTargetsProvider);
  if (targets.isEmpty) return null;
  return PathCheck(
    cost: CheckCost.network,
    intent: (intent, targets),
    ttl: _routedTtl,
    run: (token) async {
      final probe = ref.read(serviceStatusProvider.notifier);
      final checks = await Future.wait([
        for (final target in targets)
          _askRouted(
            ref,
            probe,
            serviceStatusProvider.select((state) => state.entryOf(target)),
            target,
            token,
          ),
      ]);
      final blocked = [
        for (final (index, check) in checks.indexed)
          if (check != null && _blockingServiceStatuses.contains(check.status))
            targets[index].label,
      ];
      if (blocked.isNotEmpty) {
        return StepCheck.fail(
          FailureCause.serviceBlocked,
          detail: blocked.join(', '),
        );
      }
      return checks.any((check) => check == null)
          ? const StepCheck.unknown()
          : const StepCheck.pass();
    },
  );
}
