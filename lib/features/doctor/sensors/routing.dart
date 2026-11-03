import 'dart:async';

import 'package:reclash/common/proxy.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../kernel.dart';
import '../snapshot.dart';

/// The override wins the merge, so it is read at once: a remedy that sets it
/// is judged before the config is applied again. Otherwise the profile's own
/// value as last applied.
final effectiveUseSystemHostsProvider = Provider<bool>((ref) {
  final override = ref.watch(
    patchClashConfigProvider.select(
      (config) => config.dnsOverrideKeys.contains(DnsOverrideKey.useSystemHosts)
          ? config.dns.useSystemHosts
          : null,
    ),
  );
  return override ?? ref.watch(appliedUseSystemHostsProvider) ?? true;
});

/// What the app means to route: TUN, its device, the system proxy, whether the
/// Core reads `hosts`, and a system proxy ReClash left applied.
void routingSensor(Ref ref, FactSink sink) {
  ref.listen(
    effectiveUseSystemHostsProvider,
    (_, value) => sink.put(Facts.useSystemHosts, value),
    fireImmediately: true,
  );
  ref.listen(
    patchClashConfigProvider.select((config) => config.tun.enable),
    (_, value) => sink.put(Facts.tunEnabled, value),
    fireImmediately: true,
  );
  ref.listen(
    patchClashConfigProvider.select((config) => config.tun.device),
    (_, value) => sink.put(Facts.tunDevice, value),
    fireImmediately: true,
  );
  ref.listen(
    patchClashConfigProvider.select((config) => config.mixedPort),
    (_, value) => sink.put(Facts.mixedPort, value),
    fireImmediately: true,
  );
  final queue = systemProxyQueue;
  if (queue == null) return;
  ref.listen(
    proxyStateProvider.select((state) => state.isStart && state.systemProxy),
    (_, value) => sink.put(Facts.systemProxyWanted, value),
    fireImmediately: true,
  );
  var changed = false;
  final changes = queue.ownPorts.listen((port) {
    changed = true;
    sink.put(Facts.ownProxyPort, port);
  });
  ref.onDispose(changes.cancel);
  unawaited(
    queue.ownPort().then((port) {
      if (ref.mounted && !changed) sink.put(Facts.ownProxyPort, port);
    }),
  );
}
