const providerChainLimit = 16;
const minProviderChainHops = 2;
const maxProviderChainHops = 3;
const _nameLimit = 64;
const _chainKeys = {'name', 'hops', 'target-group', 'offered', 'fingerprints'};
const _fingerprintKeys = {'type', 'server', 'port'};

class ProviderHopFingerprint {
  const ProviderHopFingerprint({
    required this.type,
    required this.server,
    required this.port,
  });

  final String type;
  final String server;
  final int port;
}

/// A route the provider offers, over nodes and groups of its own subscription.
class ProviderChain {
  const ProviderChain({
    required this.name,
    required this.hops,
    this.offered = true,
    this.targetGroup,
    this.fingerprints = const [],
  });

  final String name;
  final List<String> hops;
  final bool offered;
  final String? targetGroup;

  /// Per hop, null where the provider names none; empty without any.
  final List<ProviderHopFingerprint?> fingerprints;
}

/// Provider chains take negative ids, which no stored chain has.
int providerChainId(int index) => -(index + 1);

/// What the preferences hold for a chain the user turned off.
String providerChainKey(int profileId, String name) => '$profileId:$name';

bool isProviderChainId(int id) => id < 0;

/// Null when the section is not a list; a chain that is invalid is skipped
/// with a warning, so one mistake does not withdraw the others.
List<ProviderChain>? parseProviderChains(Object? value, List<String> warnings) {
  if (value is! List) return null;
  final chains = <ProviderChain>[];
  final names = <String>{};
  for (final (index, item) in value.indexed) {
    if (chains.length == providerChainLimit) {
      warnings.add('Only $providerChainLimit chains are used');
      break;
    }
    final chain = _chain(item);
    if (chain == null) {
      warnings.add('Invalid chain ${index + 1}');
    } else if (!names.add(chain.name)) {
      warnings.add('Duplicate chain ${chain.name}');
    } else {
      chains.add(chain);
    }
  }
  return List.unmodifiable(chains);
}

ProviderChain? _chain(Object? item) {
  if (item is! Map<String, Object?> ||
      item.keys.any((key) => !_chainKeys.contains(key))) {
    return null;
  }
  final name = item['name'];
  final hops = item['hops'];
  if (name is! String ||
      name.trim().isEmpty ||
      name.length > _nameLimit ||
      hops is! List ||
      hops.length < minProviderChainHops ||
      hops.length > maxProviderChainHops ||
      hops.any((hop) => hop is! String || hop.isEmpty)) {
    return null;
  }
  final offered = item['offered'];
  final target = item['target-group'];
  if (offered != null && offered is! bool ||
      target != null && (target is! String || target.isEmpty)) {
    return null;
  }
  final fingerprints = _fingerprints(item['fingerprints'], hops.length);
  if (fingerprints == null) return null;
  return ProviderChain(
    name: name.trim(),
    hops: List.unmodifiable(hops.cast<String>()),
    offered: offered as bool? ?? true,
    targetGroup: target as String?,
    fingerprints: fingerprints,
  );
}

/// One entry per hop, null for a hop without a fingerprint.
List<ProviderHopFingerprint?>? _fingerprints(Object? value, int hops) {
  if (value == null) return const [];
  if (value is! List || value.length != hops) return null;
  final result = <ProviderHopFingerprint?>[];
  for (final item in value) {
    if (item == null) {
      result.add(null);
      continue;
    }
    if (item is! Map<String, Object?> ||
        item.keys.any((key) => !_fingerprintKeys.contains(key))) {
      return null;
    }
    final type = item['type'];
    final server = item['server'];
    final port = item['port'];
    if (type is! String ||
        type.isEmpty ||
        server is! String ||
        server.isEmpty ||
        port is! int ||
        port < 1 ||
        port > 65535) {
      return null;
    }
    result.add(ProviderHopFingerprint(type: type, server: server, port: port));
  }
  return List.unmodifiable(result);
}
