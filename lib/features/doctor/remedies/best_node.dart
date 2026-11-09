import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import '../probes/verify.dart';

const _builtinTypes = {
  'direct',
  'reject',
  'rejectdrop',
  'pass',
  'compatible',
  'dns',
};

/// The candidate that answered fastest; built-in outbounds never count, or a
/// dead plan would "heal" onto DIRECT.
String? fastestNode(List<Proxy> candidates, int? Function(Proxy) delayOf) {
  String? best;
  var bestDelay = 0;
  for (final proxy in candidates) {
    if (_builtinTypes.contains(proxy.type.toLowerCase())) continue;
    final delay = delayOf(proxy);
    if (delay == null || delay <= 0) continue;
    if (best == null || delay < bestDelay) {
      best = proxy.name;
      bestDelay = delay;
    }
  }
  return best;
}

/// Re-tests the main group's nodes. A Selector moves to the fastest live
/// one; URLTest and Fallback pick from the fresh delays themselves.
Future<void> selectBestNode(Ref ref) async {
  final name = mainGroup(ref);
  final group = name == null ? null : ref.read(groupsProvider).getGroup(name);
  if (group == null) throw StateError('no proxy group to test');
  await ref.read(proxiesActionProvider.notifier).delayTestGroups([group]);
  final best = fastestNode(
    group.all,
    (proxy) =>
        ref.read(delayProvider(proxyName: proxy.name, testUrl: group.testUrl)),
  );
  if (best == null) throw StateError('no live node in ${group.name}');
  if (group.type != GroupType.Selector || best == group.now) return;
  await ref
      .read(proxiesActionProvider.notifier)
      .changeProxy(groupName: group.name, proxyName: best, silence: true);
}
